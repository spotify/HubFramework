#import "HUBViewModelDiff.h"
#import "HUBComponentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelDiff ()

@property (nonatomic, strong) NSIndexSet *insertedIndices;
@property (nonatomic, strong) NSIndexSet *deletedIndices;
@property (nonatomic, strong) NSIndexSet *reloadedIndices;

@end

@implementation HUBViewModelDiff

+ (NSArray<NSString *> *)componentIdentifiersFromViewModel:(id<HUBViewModel>)viewModel
{
    NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:viewModel.bodyComponentModels.count];
    for (id<HUBComponentModel> model in viewModel.bodyComponentModels) {
        [identifiers addObject:model.identifier];
    }
    return identifiers;
}

+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel
{
    NSArray<NSString *> *firstIdentifiers = [self componentIdentifiersFromViewModel:fromViewModel];
    NSArray<NSString *> *secondIdentifiers = [self componentIdentifiersFromViewModel:toViewModel];

    // Longest Common Subsequence
    // https://www.ics.uci.edu/~eppstein/161/960229.html
    
    const NSUInteger fromViewModelCount = firstIdentifiers.count;
    const NSUInteger toViewModelCount = secondIdentifiers.count;
    const NSUInteger matrixHeight = toViewModelCount + 1;

    // The matrix containing all the subproblem results
    NSUInteger *subsequenceMatrix = calloc((fromViewModelCount + 1) * (toViewModelCount + 1), sizeof(NSUInteger));
    if (subsequenceMatrix == NULL) {
        return nil;
    }

    // Populating the subsequence matrix
    for (NSUInteger i = fromViewModelCount; i < NSUIntegerMax; i--) {
        for (NSUInteger j = toViewModelCount; j < NSUIntegerMax; j--) {
            if (i == fromViewModelCount || j == toViewModelCount) {
                subsequenceMatrix[matrixHeight * i + j] = 0;
            } else if ([firstIdentifiers[i] isEqualToString:secondIdentifiers[j]]) {
                subsequenceMatrix[matrixHeight * i + j] = 1 + subsequenceMatrix[matrixHeight * (i + 1) + (j + 1)];
            } else {
                subsequenceMatrix[matrixHeight * i + j] = MAX(subsequenceMatrix[matrixHeight * (i + 1) + j], subsequenceMatrix[matrixHeight * i + (j + 1)]);
            }
        }
    }

    // Finding the longest common subsequence
    NSMutableIndexSet *commonIndexSet = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0, j = 0 ; i < fromViewModelCount && j < toViewModelCount; ) {
        if ([firstIdentifiers[i] isEqualToString:secondIdentifiers[j]]) {
            [commonIndexSet addIndex:i];
            i++;
            j++;
        } else if (subsequenceMatrix[matrixHeight * (i + 1) + j] >= subsequenceMatrix[matrixHeight * i + (j + 1)]) {
            i++;
        } else {
            j++;
        }
    }
    
    free(subsequenceMatrix);
    
    NSMutableIndexSet *insertions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *deletions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *reloads = [NSMutableIndexSet indexSet];

    // Comparing the first model indices to the common indices to find deletions
    for (NSUInteger i = 0; i < fromViewModelCount; i++) {
        if (![commonIndexSet containsIndex:i]) {
            [deletions addIndex:i];
        }
    }

    NSArray<id<HUBComponentModel>> *commonObjects = [fromViewModel.bodyComponentModels objectsAtIndexes:commonIndexSet];

    /* Comparing second model indices to find reloads (if identifiers match but deep comparison fails) or
       insertions (if identifiers differ). */
    for (NSUInteger i = 0, j = 0; i < commonObjects.count || j < toViewModelCount; ) {
        if (i < commonObjects.count && j < toViewModelCount &&
            [commonObjects[i].identifier isEqualToString:secondIdentifiers[j]]) {
            if (![commonObjects[i] isEqual:toViewModel.bodyComponentModels[j]]) {
                [reloads addIndex:j];
            }
            i++;
            j++;
        } else {
            [insertions addIndex:j];
            j++;
        }
    }

    HUBViewModelDiff *diff = [HUBViewModelDiff new];

    diff.insertedIndices = [insertions copy];
    diff.deletedIndices = [deletions copy];
    diff.reloadedIndices = [reloads copy];

    return diff;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\t{\n\
        deletions: %@\n\
        insertions: %@\n\
        reloads: %@\n\
    \t}", self.deletedIndices, self.insertedIndices, self.reloadedIndices];
}

@end

NS_ASSUME_NONNULL_END
