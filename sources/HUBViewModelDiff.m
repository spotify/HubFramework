/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */


#import "HUBViewModelDiff.h"
#import "HUBComponentModel.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static inline NSArray<NSIndexPath *> *HUBIndexSetToIndexPathArray(NSIndexSet *indexSet) {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:indexSet.count];

    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:(NSInteger)idx inSection:0]];
    }];

    return [indexPaths copy];
}

@implementation HUBViewModelDiff

- (instancetype)initWithInserts:(NSIndexSet *)inserts
                        deletes:(NSIndexSet *)deletes
                        reloads:(NSIndexSet *)reloads
{
    self = [super init];
    if (self) {
        _insertedBodyComponentIndexPaths = HUBIndexSetToIndexPathArray(inserts);
        _deletedBodyComponentIndexPaths = HUBIndexSetToIndexPathArray(deletes);
        _reloadedBodyComponentIndexPaths = HUBIndexSetToIndexPathArray(reloads);
    }
    return self;
}

+ (NSMutableArray<NSString *> *)componentIdentifiersFromViewModel:(id<HUBViewModel>)viewModel
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
    return [self diffUsingHashTableAlgorithmFromViewModel:fromViewModel toViewModel:toViewModel];
}

+ (instancetype)diffUsingStandardAlgorithmFromViewModel:(id<HUBViewModel>)fromViewModel
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

    return [[HUBViewModelDiff alloc] initWithInserts:insertions
                                             deletes:deletions
                                             reloads:reloads];
}

+ (instancetype)emptyDiff
{
    return [[HUBViewModelDiff alloc] initWithInserts:[NSIndexSet indexSet]
                                             deletes:[NSIndexSet indexSet]
                                             reloads:[NSIndexSet indexSet]];
}

typedef NSDictionary<NSString *, id<HUBComponentModel>> HUBViewModelComponentMap;

+ (HUBViewModelComponentMap *)createComponentMapWithViewModel:(id<HUBViewModel>)viewModel
{
    NSMutableDictionary * const dictionary = [NSMutableDictionary dictionaryWithCapacity:viewModel.bodyComponentModels.count];
    [viewModel.bodyComponentModels enumerateObjectsUsingBlock:^(id<HUBComponentModel>  component, NSUInteger idx, BOOL *stop) {
        dictionary[component.identifier] = component;
    }];

    return [dictionary copy];
}

+ (instancetype)diffUsingHashTableAlgorithmFromViewModel:(id<HUBViewModel>)fromViewModel
                                             toViewModel:(id<HUBViewModel>)toViewModel
{
    HUBViewModelComponentMap * const fromComponentsMap = [self createComponentMapWithViewModel:fromViewModel];
    HUBViewModelComponentMap * const toComponentsMap = [self createComponentMapWithViewModel:toViewModel];

    NSMutableIndexSet *insertions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *deletions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *reloads = [NSMutableIndexSet indexSet];

//    [fromComponentsMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<HUBComponentModel> component, BOOL *stop) {
//        id<HUBComponentModel> matchingComponent = toComponentsMap[key];
//        if (matchingComponent == nil || matchingComponent.index != component.index) {
//            [deletions addIndex:component.index];
//        } else if (![component isEqual:matchingComponent]) {
//            [reloads addIndex:matchingComponent.index];
//        }
//    }];
//
//    [toComponentsMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<HUBComponentModel> component, BOOL *stop) {
//        id<HUBComponentModel> matchingComponent = fromComponentsMap[key];
//        if (matchingComponent != nil) {
//            NSUInteger oldComponentIndex = component.index;
//            NSUInteger deletionsBeforeIndex = [deletions indexesPassingTest:^BOOL(NSUInteger index, BOOL *stahp) {
//                BOOL lessThan = index < oldComponentIndex;
//                if (!lessThan) {
//                    *stahp = YES;
//                }
//                return lessThan;
//            }].count;
//
//            if (oldComponentIndex - deletionsBeforeIndex != component.index) {
//                [insertions addIndex:component.index];
//            }
//        } else {
//            [insertions addIndex:component.index];
//        }
//    }];

    NSMutableOrderedSet<NSString *> *commonIdentifiers = [NSMutableOrderedSet orderedSet];

    for (id<HUBComponentModel> component in fromViewModel.bodyComponentModels) {
        id<HUBComponentModel> matching = toComponentsMap[component.identifier];
        if (matching == nil) {
            [deletions addIndex:component.index];
        } else {
            [commonIdentifiers addObject:component.identifier];
        }
    }
    
    for (id<HUBComponentModel> component in toViewModel.bodyComponentModels) {
        id<HUBComponentModel> matching = fromComponentsMap[component.identifier];
        if (matching == nil) {
            [insertions addIndex:component.index];
        } else {
            [commonIdentifiers addObject:component.identifier];
        }
    }

    NSMutableArray<NSIndexPath *> *moves = [NSMutableArray arrayWithCapacity:commonIdentifiers.count];
    for (NSString *identifier in commonIdentifiers) {
        id<HUBComponentModel> matchingFrom = fromComponentsMap[identifier];
        id<HUBComponentModel> matchingTo = toComponentsMap[identifier];

        NSUInteger insertionsBefore = [insertions indexesPassingTest:^BOOL(NSUInteger index, BOOL *stop) {
            BOOL isLess = index < matchingTo.index;
            if (isLess) {
                *stop = YES;
            }
            return isLess;
        }].count;
        
        NSUInteger deletionsBefore = [deletions indexesPassingTest:^BOOL(NSUInteger index, BOOL *stop) {
            BOOL isLess = index < matchingFrom.index;
            if (isLess) {
                *stop = YES;
            }
            return isLess;
        }].count;

        if (matchingFrom.index - deletionsBefore + insertionsBefore == matchingTo.index) {
            if (![matchingFrom isEqual:matchingTo]) {
                [reloads addIndex:matchingTo.index];
            }
        } else {
            NSUInteger changePath[2] = {matchingFrom.index, matchingTo.index};
            [moves addObject:[NSIndexPath indexPathWithIndexes:changePath length:2]];
        }
    }

    return [[HUBViewModelDiff alloc] initWithInserts:insertions
                                             deletes:deletions
                                             reloads:reloads];
}

//+ (instancetype)diffUsingHirschbergsAlgorithmFromViewModel:(id<HUBViewModel>)fromViewModel
//                                               toViewModel:(id<HUBViewModel>)toViewModel
//                                                firstRange:(NSRange)firstRange
//                                               secondRange:(NSRange)secondRange
//{
//    NSUInteger i, j, max, arrmax, arr2max, up, down;
//    NSArray<id<HUBComponentModel>> *fromModels = fromViewModel.bodyComponentModels;
//    NSArray<id<HUBComponentModel>> *toModels = toViewModel.bodyComponentModels;
//
//    if (firstRange.length == 1 || secondRange.length == 0) {
//        if (secondRange.length == 0) {
//            return [self emptyDiff];
//        }
//
//        for (j = 1; j <= firstRange.length; j++) {
//            id<HUBComponentModel> firstModel = fromModels[1];
//            id<HUBComponentModel> secondModel = toModels[j];
//
//            if ([firstModel.identifier isEqualToString:secondModel.identifier]) {
//                if ([firstModel isEqual:secondModel]) {
//                    return [[HUBViewModelDiff alloc] initWithInserts:[NSIndexSet indexSet]
//                                                             deletes:[NSIndexSet indexSet]
//                                                             reloads:[NSIndexSet indexSetWithIndex:0]];
//                } else {
//                    return [self emptyDiff];
//                }
//            }
//        }
//    }
//
//
//    
//
//    return nil;
//}

+ (NSUInteger)commonPrefixLengthFromIdentifiers:(NSArray<NSString *> *)fromIdentifiers
                                  toIdentifiers:(NSArray<NSString *> *)toIdentifiers
{
    NSUInteger n = MIN(fromIdentifiers.count, toIdentifiers.count);
    for (NSUInteger i = 0; i < n; i++) {
        if (![fromIdentifiers[i] isEqual:toIdentifiers[i]]) {
            return i;
        }
    }

    return n;
}

+ (NSUInteger)commonSuffixLengthFromIdentifiers:(NSArray<NSString *> *)fromIdentifiers
                                  toIdentifiers:(NSArray<NSString *> *)toIdentifiers
{                                              
    NSUInteger fromCount = fromIdentifiers.count;
    NSUInteger toCount = toIdentifiers.count;
    NSUInteger n = MIN(fromCount, toCount);
    for (NSUInteger i = 1; i <= n; i++) {
        if (![fromIdentifiers[i] isEqual:toIdentifiers[i]]) {
            return i - 1;
        }
    }

    return n;
}

+ (NSIndexSet *)reloadedIndicesFromComponents:(NSArray<id<HUBComponentModel>> *)fromComponents
                                 toComponents:(NSArray<id<HUBComponentModel>> *)toComponents
                                 commonIndices:(NSIndexSet *)commonIndices
{
    NSMutableIndexSet *reloads = [NSMutableIndexSet indexSet];
    [commonIndices enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        if (![fromComponents[index] isEqual:toComponents[index]]) {
            [reloads addIndex:index];
        }
    }];

    return reloads;
}

+ (instancetype)diffUsingMyersAlgorithmFromViewModel:(id<HUBViewModel>)fromViewModel
                                         toViewModel:(id<HUBViewModel>)toViewModel
{
    // Optimizations for empty sets
    if (fromViewModel.bodyComponentModels.count == 0 && toViewModel.bodyComponentModels.count == 0) {
        return [self emptyDiff];
    } else if (fromViewModel.bodyComponentModels.count == 0) {
        NSIndexSet *inserts = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, toViewModel.bodyComponentModels.count)];
        return [[HUBViewModelDiff alloc] initWithInserts:inserts
                                                 deletes:[NSIndexSet indexSet]
                                                 reloads:[NSIndexSet indexSet]];
    } else if (toViewModel.bodyComponentModels.count == 0) {
        NSIndexSet *deletions = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, fromViewModel.bodyComponentModels.count)];
        return [[HUBViewModelDiff alloc] initWithInserts:[NSIndexSet indexSet]
                                                 deletes:deletions
                                                 reloads:[NSIndexSet indexSet]];
    }

    NSArray<NSString *> *firstIdentifiers = [self componentIdentifiersFromViewModel:fromViewModel];
    NSArray<NSString *> *secondIdentifiers = [self componentIdentifiersFromViewModel:toViewModel];


    // Optimization for identical sets
    if ([[firstIdentifiers componentsJoinedByString:@""] isEqual:[secondIdentifiers componentsJoinedByString:@""]]) {
        NSIndexSet *reloads = [self reloadedIndicesFromComponents:fromViewModel.bodyComponentModels
                                                     toComponents:toViewModel.bodyComponentModels
                                                    commonIndices:]
        return [self emptyDiff];
    }


}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\t{\n\
        deletions: %@\n\
        insertions: %@\n\
        reloads: %@\n\
    \t}", self.deletedBodyComponentIndexPaths, self.insertedBodyComponentIndexPaths, self.reloadedBodyComponentIndexPaths];
}

@end

NS_ASSUME_NONNULL_END
