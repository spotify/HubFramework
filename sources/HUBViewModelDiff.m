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
#import "HUBIdentifier.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static inline NSArray<NSIndexPath *> *HUBIndexSetToIndexPathArray(NSIndexSet *indexSet) {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:indexSet.count];

    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:(NSInteger)idx inSection:0]];
    }];

    return [indexPaths copy];
}

@interface  HUBViewModelDiff ()

@property (nonatomic, assign) BOOL headerComponentIdentifierHasChanged;

@end

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

+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel
                        algorithm:(HUBDiffAlgorithm)algorithm
{
    NSParameterAssert(algorithm);
    HUBViewModelDiff *diff =  algorithm(fromViewModel, toViewModel);
    [diff calculateHeaderChangesFromViewModel:fromViewModel toViewModel:toViewModel];
    return diff;
}

+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel
{
    return [self diffFromViewModel:fromViewModel toViewModel:toViewModel algorithm:HUBDiffMyersAlgorithm];
}

- (BOOL)hasChanges
{
    return self.insertedBodyComponentIndexPaths.count > 0
        || self.deletedBodyComponentIndexPaths.count > 0
        || self.reloadedBodyComponentIndexPaths.count > 0
        || self.headerComponentIdentifierHasChanged;
}

- (void)calculateHeaderChangesFromViewModel:(id<HUBViewModel>)fromViewModel toViewModel:(id<HUBViewModel>)toViewModel
{
    id<HUBComponentModel> fromHeaderModel = fromViewModel.headerComponentModel;
    id<HUBComponentModel> toHeaderModel = toViewModel.headerComponentModel;

    if (!fromHeaderModel && !toHeaderModel) {
        return;
    }

    if (![fromHeaderModel isEqual:toHeaderModel]) {
        self.headerComponentIdentifierHasChanged = YES;
    }
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\t{\n\
        deletions: %@\n\
        insertions: %@\n\
        reloads: %@\n\
        header: %d\n\
    \t}", self.deletedBodyComponentIndexPaths, self.insertedBodyComponentIndexPaths, self.reloadedBodyComponentIndexPaths, self.headerComponentIdentifierHasChanged];
}

@end

#pragma mark - Longest common subsequence

static NSArray<NSString *> *HUBDiffComponentIdentifiersFromViewModel(id<HUBViewModel> viewModel) {
    NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:viewModel.bodyComponentModels.count];
    for (id<HUBComponentModel> model in viewModel.bodyComponentModels) {
        [identifiers addObject:model.identifier];
    }
    return identifiers;
}

HUBViewModelDiff *HUBDiffLCSAlgorithm(id<HUBViewModel> fromViewModel, id<HUBViewModel> toViewModel) {
    NSArray<NSString *> *firstIdentifiers = HUBDiffComponentIdentifiersFromViewModel(fromViewModel);
    NSArray<NSString *> *secondIdentifiers = HUBDiffComponentIdentifiersFromViewModel(toViewModel);

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

#pragma mark - Myers algorithm

/**
 * A point representing movement within the acyclic edit graph, with x being the position in the sequence being,
 * transitioned from and y the position in the sequence transitioned to.
 */ 
typedef struct {
    NSInteger x;
    NSInteger y;
} HUBDiffPoint;

static inline HUBDiffPoint HUBDiffPointMake(NSInteger x, NSInteger y) {
    return (HUBDiffPoint){ .x = x, .y = y };
}

typedef NS_ENUM(NSUInteger, HUBDiffStepType) {
    HUBDiffStepTypeInsert,
    HUBDiffStepTypeDelete,
    HUBDiffStepTypeMatchPoint
};

static inline HUBDiffStepType HUBDiffStepTypeInfer(NSInteger k, NSInteger d, NSInteger previousX, NSInteger nextX) {
    // k = -d and k = +d are edge cases which can only be reached through vertical and horizontal movement, respectively
    if (k == -d) {
        return HUBDiffStepTypeInsert;
    } else if (k == d) {
        return HUBDiffStepTypeDelete;
    } else {
        // If the next x is greater than the previous, it is a horizontal movement and thus an insertion.
        if (previousX < nextX) {
            return HUBDiffStepTypeInsert;
        } else {
            return HUBDiffStepTypeDelete;
        }
    }
}

@interface HUBDiffStep : NSObject

@property (nonatomic, assign, readonly) HUBDiffPoint from;
@property (nonatomic, assign, readonly) HUBDiffPoint to;
@property (nonatomic, assign, readonly) HUBDiffStepType type;

@end

@implementation HUBDiffStep

- (instancetype)initWithFromPoint:(HUBDiffPoint)fromPoint toPoint:(HUBDiffPoint)toPoint
{
    self = [super init];
    if (self) {
        _from = fromPoint;
        _to = toPoint;
    }
    return self;
}

- (HUBDiffStepType)type
{
    // Diagonal movement, the two elements match.
    if (self.from.x + 1 == self.to.x && self.from.y + 1 == self.to.y) {
        return HUBDiffStepTypeMatchPoint;
    // Vertical movement, insertion
    } else if (self.from.y < self.to.y) {
        return HUBDiffStepTypeInsert;
    // Horizontal movement, insertion
    } else {
        return HUBDiffStepTypeDelete;
    }
}

@end

// Optimization – when going from an empty sequence, everything is an insertion.
static NSArray<HUBDiffStep *> *HUBDiffInsertionTracesFromViewModel(id<HUBViewModel> viewModel) {
    NSInteger toCount = (NSInteger)viewModel.bodyComponentModels.count;
    NSMutableArray<HUBDiffStep *> *traces = [NSMutableArray arrayWithCapacity:(NSUInteger)toCount];

    for (NSInteger i = 0; i < toCount; i++) {
        HUBDiffStep *trace = [[HUBDiffStep alloc] initWithFromPoint:HUBDiffPointMake(0, i) toPoint:HUBDiffPointMake(0, i + 1)];
        [traces addObject:trace];
    }

    return traces;
}

// Optimization – when going to an empty sequence, everything is a deletion.
static NSArray<HUBDiffStep *> *HUBDiffDeletionTracesFromViewModel(id<HUBViewModel> viewModel) {
    NSInteger fromCount = (NSInteger)viewModel.bodyComponentModels.count;
    NSMutableArray<HUBDiffStep *> *traces = [NSMutableArray arrayWithCapacity:(NSUInteger)fromCount];

    for (NSInteger i = 0; i < fromCount; i++) {
        HUBDiffStep *trace = [[HUBDiffStep alloc] initWithFromPoint:HUBDiffPointMake(i, 0) toPoint:HUBDiffPointMake(i + 1, 0)];
        [traces addObject:trace];
    }
    
    return traces;
}

// Calculating the different paths between the two sequences.
static NSArray<HUBDiffStep *> *HUBDiffMyersTracesBetweenViewModels(id<HUBViewModel> fromViewModel, id<HUBViewModel> toViewModel) {
    NSInteger fromCount = (NSInteger)fromViewModel.bodyComponentModels.count;
    NSInteger toCount = (NSInteger)toViewModel.bodyComponentModels.count;
    NSInteger max = fromCount + toCount;

    /**
     * The algorithm can be visualized with an acyclic graph where the elements of the first sequence are
     * along the x-axis and the second sequence along the y-axis. The goal is to find the shortest path
     * from the top left (x0, y0) to the bottom right (xn, ym). A horizontal movement (x+1) represents
     * a deletion from the first sequence, and a vertical movement (y+1) represents an insertion from the
     * second sequence. A diagonal movement  (x+1, y+1) represents a match between the two sequences.
     */
    NSMutableArray *steps = [NSMutableArray arrayWithCapacity:(NSUInteger)max];

    NSUInteger endpointCount = 2 * (NSUInteger)max + 1;
    NSInteger *endpoints = malloc(sizeof(NSInteger) * endpointCount);
    for (NSUInteger i = 0; i < endpointCount; i++) {
        endpoints[i] = -1;
    }
    endpoints[max + 1] = 0;

    /**
     * d represents the number of non-diagonal steps taken. The algorithm is iterative and explores every
     * path one step at a time (with the exception of diagonal steps).
     */
    for (NSInteger d = 0; d <= max; d++) {
        /**
         * k represents the diagonal movement within the graph, with a "k-line" being a diagonal line through the graph
         * defined by the equation y = x - k. k can be bounded between [-d...d] since certain k-lines can only be
         * reached with a certain number of edits. E.g. the line k = -2 starts at (x0, y2), meaning it must be 
         * preceded by two vertical movements.
         */
        for (NSInteger k = -d; k <= d; k += 2) {
            /**
             * The goal here is to find the furthest reaching path for the given k-line. To get to this k-line from an
             * earlier step, we must move from the adjacent k-lines (either k - 1 or k + 1). These points are retrieved
             * from earlier iterations in the endpoints array.
             */
            NSInteger index = k + max;

            NSInteger previousX = endpoints[index - 1];
            NSInteger nextX = endpoints[index + 1];
            HUBDiffStepType type = HUBDiffStepTypeInfer(k, d, previousX, nextX);

            // Once the type of edit is determined, the next step can be taken.
            HUBDiffStep *step = nil;
            if (type == HUBDiffStepTypeInsert) {
                NSInteger x = nextX;
                step = [[HUBDiffStep alloc] initWithFromPoint:HUBDiffPointMake(x, x - k - 1) toPoint:HUBDiffPointMake(x, x - k)];
            } else {
                NSInteger x = previousX + 1;
                step = [[HUBDiffStep alloc] initWithFromPoint:HUBDiffPointMake(x - 1, x - k) toPoint:HUBDiffPointMake(x, x - k)];
            }
            
            /// Here the goal is to follow the diagonal line with additional steps to find the longest common sequence
            if (step.to.x <= fromCount && step.to.y <= toCount) {
                [steps addObject:step];

                NSInteger x = step.to.x;
                NSInteger y = step.to.y;
                
                while (x >= 0 && y >= 0 && x < fromCount && y < toCount) {
                    id<HUBComponentModel> target = toViewModel.bodyComponentModels[(NSUInteger)y];
                    id<HUBComponentModel> base = fromViewModel.bodyComponentModels[(NSUInteger)x];

                    /**
                     * Only the element's identity is compared here, as equality is checked later in order to determine
                     * the location of updates.
                     */ 
                    if ([base.identifier isEqual:target.identifier]) {
                        // A match is found and another step can be taken diagonally.
                        x += 1;
                        y += 1;

                        HUBDiffStep *nextStep = [[HUBDiffStep alloc] initWithFromPoint:HUBDiffPointMake(x - 1, y - 1) toPoint:HUBDiffPointMake(x, y)];
                        
                        [steps addObject:nextStep];
                    } else {
                        break;
                    }
                }

                // Only the x-point needs to be stored since y can be inferred with y = x - k
                endpoints[index] = x;

                // The end of the graph has been reached, and a solution has been found.
                if (x >= fromCount && y >= toCount) {
                    free(endpoints);
                    return steps;
                }
            }
        }
    }

    // Unless there is an early return, no solution was found. This should never happen.
    free(endpoints);
    return @[];
}

/**
 * Filtering out any steps not part of the solution path (or "snake").
 */
static NSArray<HUBDiffStep *> *HUBDiffFindPathFromSteps(NSArray<HUBDiffStep *> *steps) {
    if (steps.count == 0) {
        return steps;
    }

    NSMutableArray<HUBDiffStep *> *pathSteps = [NSMutableArray array];

    HUBDiffStep *lastStep = steps.lastObject;
    [pathSteps addObject:lastStep];

    // Starting with the last step (being the last step of the solution) and tracing the path backwards.
    if (lastStep.from.x != 0 || lastStep.from.y != 0) {
        for (HUBDiffStep *step in steps.reverseObjectEnumerator) {
            if (step.to.x == lastStep.from.x && step.to.y == lastStep.from.y) {
                [pathSteps insertObject:step atIndex:0];
                lastStep = step;

                if (step.from.x == 0 && step.from.y == 0) {
                    break;
                }
            }
        }
    }

    return pathSteps;
}

static NSArray<HUBDiffStep *> *HUBDiffStepsBetweenViewModels(id<HUBViewModel> fromViewModel, id<HUBViewModel> toViewModel) {
    if (fromViewModel.bodyComponentModels.count == 0 && toViewModel.bodyComponentModels.count == 0) {
        return @[];
    } else if (fromViewModel.bodyComponentModels.count == 0) {
        return HUBDiffInsertionTracesFromViewModel(toViewModel);
    } else if (toViewModel.bodyComponentModels.count == 0) {
        return HUBDiffDeletionTracesFromViewModel(fromViewModel);
    } else {
        return HUBDiffMyersTracesBetweenViewModels(fromViewModel, toViewModel);
    }
}

HUBViewModelDiff *HUBDiffMyersAlgorithm(id<HUBViewModel> fromViewModel, id<HUBViewModel> toViewModel) {
    NSArray<HUBDiffStep *> *steps = HUBDiffStepsBetweenViewModels(fromViewModel, toViewModel);
    NSArray<HUBDiffStep *> *path = HUBDiffFindPathFromSteps(steps);

    NSMutableIndexSet *insertions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *deletions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *reloads = [NSMutableIndexSet indexSet];

    // Converting the edit path to insert|delete|reload indexes
    for (HUBDiffStep *step in path) {
        HUBDiffStepType type = step.type;
        if (type == HUBDiffStepTypeInsert) {
            [insertions addIndex:(NSUInteger)step.from.y];
        } else if (type == HUBDiffStepTypeDelete) {
            [deletions addIndex:(NSUInteger)step.from.x];
        } else if (type == HUBDiffStepTypeMatchPoint) {
            // Here we perform the deep equality check to determine if the element has actually changed.
            id<HUBComponentModel> base = fromViewModel.bodyComponentModels[(NSUInteger)step.from.x];
            id<HUBComponentModel> target = toViewModel.bodyComponentModels[(NSUInteger)step.from.y];
            if (![target isEqual:base]) {
                [reloads addIndex:(NSUInteger)step.from.x];
            }
        }
    }

    return [[HUBViewModelDiff alloc] initWithInserts:insertions deletes:deletions reloads:reloads];
}

NS_ASSUME_NONNULL_END
