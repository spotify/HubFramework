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

    NSMutableIndexSet *reloads = [NSMutableIndexSet indexSet];

    // Finding the longest common subsequence
    NSMutableIndexSet *commonIndexSet = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0, j = 0 ; i < fromViewModelCount && j < toViewModelCount; ) {
        if ([firstIdentifiers[i] isEqualToString:secondIdentifiers[j]]) {
            if (![fromViewModel.bodyComponentModels[i] isEqual:toViewModel.bodyComponentModels[j]]) {
                [reloads addIndex:i];
            }

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
            i++;
            j++;
        } else {
            [insertions addIndex:j];
            j++;
        }
    }

    return [[HUBViewModelDiff alloc] initWithInserts:[insertions copy]
                                             deletes:[deletions copy]
                                             reloads:[reloads copy]];
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
