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

+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel
                        algorithm:(HUBDiffAlgorithm)algorithm
{
    NSParameterAssert(algorithm);
    return algorithm(fromViewModel, toViewModel);
}

+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel
{
    return [self diffFromViewModel:fromViewModel toViewModel:toViewModel algorithm:HUBDiffMyersAlgorithm];
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

typedef struct {
    NSInteger x;
    NSInteger y;
} HUBDiffPoint;

static inline HUBDiffPoint HUBDiffPointMake(NSInteger x, NSInteger y) {
    return (HUBDiffPoint){ .x = x, .y = y};
}

typedef struct {
    NSInteger changes;
    NSInteger diagonal;
    NSInteger previousX;
    NSInteger nextX;
} HUBDiffTraceStep;

static inline HUBDiffTraceStep HUBDiffTraceStepMake(NSInteger changes, NSInteger diagonal, NSInteger previousX, NSInteger nextX) {
    return (HUBDiffTraceStep){ .changes = changes, .diagonal = diagonal, .previousX = previousX, .nextX = nextX };
}

typedef NS_ENUM(NSUInteger, HUBDiffTraceType) {
    HUBDiffTraceTypeInsert,
    HUBDiffTraceTypeDelete,
    HUBDiffTraceTypeMatchPoint
};

@interface HUBDiffTrace : NSObject

@property (nonatomic, assign, readonly) HUBDiffPoint from;
@property (nonatomic, assign, readonly) HUBDiffPoint to;
@property (nonatomic, assign, readonly) NSInteger changes;

@property (nonatomic, assign, readonly) HUBDiffTraceType type;

@end

@implementation HUBDiffTrace

+ (instancetype)nextTraceFromStep:(HUBDiffTraceStep)step
{
    HUBDiffTraceType type;
    if (step.diagonal == -(step.changes)) {
        type = HUBDiffTraceTypeInsert;
    } else if (step.diagonal != step.changes) {
        if (step.previousX < step.nextX) {
            type = HUBDiffTraceTypeInsert;
        } else {
            type = HUBDiffTraceTypeDelete;
        }
    } else {
        type = HUBDiffTraceTypeDelete;
    }
    
    if (type == HUBDiffTraceTypeInsert) {
        NSInteger x = step.nextX;
        
        return [[self alloc] initWithFromPoint:HUBDiffPointMake(x, x - step.diagonal - 1) toPoint:HUBDiffPointMake(x, x - step.diagonal) changes:step.changes];
    } else {
        NSInteger x = step.previousX + 1;

        return [[self alloc] initWithFromPoint:HUBDiffPointMake(x - 1, x - step.diagonal) toPoint:HUBDiffPointMake(x, x - step.diagonal) changes:step.changes];
    }
}

- (instancetype)initWithFromPoint:(HUBDiffPoint)fromPoint toPoint:(HUBDiffPoint)toPoint changes:(NSInteger)changes
{
    self = [super init];
    if (self) {
        _from = fromPoint;
        _to = toPoint;
        _changes = changes;
    }
    return self;
}

- (HUBDiffTraceType)type
{
    if (self.from.x + 1 == self.to.x && self.from.y + 1 == self.to.y) {
        return HUBDiffTraceTypeMatchPoint;
    } else if (self.from.y < self.to.y) {
        return HUBDiffTraceTypeInsert;
    } else {
        return HUBDiffTraceTypeDelete;
    }
}

@end

static NSArray<HUBDiffTrace *> *HUBDiffInsertionTracesFromViewModel(id<HUBViewModel> viewModel) {
    NSInteger toCount = (NSInteger)viewModel.bodyComponentModels.count;
    NSMutableArray<HUBDiffTrace *> *traces = [NSMutableArray arrayWithCapacity:(NSUInteger)toCount];

    for (NSInteger i = 0; i < toCount; i++) {
        HUBDiffTrace *trace = [[HUBDiffTrace alloc] initWithFromPoint:HUBDiffPointMake(0, i) toPoint:HUBDiffPointMake(0, i + 1) changes:0];
        [traces addObject:trace];
    }
    
    return traces;
}

static NSArray<HUBDiffTrace *> *HUBDiffDeletionTracesFromViewModel(id<HUBViewModel> viewModel) {
    NSInteger fromCount = (NSInteger)viewModel.bodyComponentModels.count;
    NSMutableArray<HUBDiffTrace *> *traces = [NSMutableArray arrayWithCapacity:(NSUInteger)fromCount];

    for (NSInteger i = 0; i < fromCount; i++) {
        HUBDiffTrace *trace = [[HUBDiffTrace alloc] initWithFromPoint:HUBDiffPointMake(i, 0) toPoint:HUBDiffPointMake(i + 1, 0) changes:0];
        [traces addObject:trace];
    }
    
    return traces;
}

static NSArray<HUBDiffTrace *> *HUBDiffMyersTracesBetweenViewModels(id<HUBViewModel> fromViewModel, id<HUBViewModel> toViewModel) {
    NSInteger fromCount = (NSInteger)fromViewModel.bodyComponentModels.count;
    NSInteger toCount = (NSInteger)toViewModel.bodyComponentModels.count;
    NSInteger max = fromCount + toCount;

    NSMutableArray *traces = [NSMutableArray arrayWithCapacity:(NSUInteger)max];

    NSUInteger endpointCount = 2 * (NSUInteger)max + 1;
    NSInteger *endpoints = malloc(sizeof(NSInteger) * endpointCount);
    for (NSUInteger i = 0; i < endpointCount; i++) {
        endpoints[i] = -1;
    }
    endpoints[max + 1] = 0;

    for (NSInteger changes = 0; changes <= max; changes++) {
        for (NSInteger diagonal = -changes; diagonal <= changes; diagonal += 2) {
            NSInteger index = diagonal + max;

            HUBDiffTraceStep step = HUBDiffTraceStepMake(changes, diagonal, endpoints[index - 1], endpoints[index + 1]);
            HUBDiffTrace *trace = [HUBDiffTrace nextTraceFromStep:step];

            if (trace.to.x <= fromCount && trace.to.y <= toCount) {
                [traces addObject:trace];

                NSInteger x = trace.to.x;
                NSInteger y = trace.to.y;
                
                while (x >= 0 && y >= 0 && x < fromCount && y < toCount) {
                    id<HUBComponentModel> target = toViewModel.bodyComponentModels[(NSUInteger)y];
                    id<HUBComponentModel> base = fromViewModel.bodyComponentModels[(NSUInteger)x];

                    if ([base.identifier isEqual:target.identifier]) {
                        x += 1;
                        y += 1;

                        HUBDiffTrace *nextTrace = [[HUBDiffTrace alloc] initWithFromPoint:HUBDiffPointMake(x - 1, y - 1) toPoint:HUBDiffPointMake(x, y) changes:changes];
                        
                        [traces addObject:nextTrace];
                    } else {
                        break;
                    }
                }

                // Only the x-point needs to be stored since y = x - k
                endpoints[index] = x;

                if (x >= fromCount && y >= toCount) {
                    free(endpoints);
                    return traces;
                }
            }
        }
    }

    free(endpoints);
    return @[];
}

static NSArray<HUBDiffTrace *> *HUBDiffTracesBetweenViewModels(id<HUBViewModel> fromViewModel, id<HUBViewModel> toViewModel) {
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

static NSArray<HUBDiffTrace *> *HUBDiffFindPathFromTraces(NSArray<HUBDiffTrace *> *traces) {
    if (traces.count == 0) {
        return traces;
    }

    NSMutableArray<HUBDiffTrace *> *pathTraces = [NSMutableArray array];

    HUBDiffTrace *lastTrace = traces.lastObject;
    [pathTraces addObject:lastTrace];

    if (lastTrace.from.x != 0 || lastTrace.from.y != 0) {
        for (HUBDiffTrace *trace in traces.reverseObjectEnumerator) {
            if (trace.to.x == lastTrace.from.x && trace.to.y == lastTrace.from.y) {
                [pathTraces insertObject:trace atIndex:0];
                lastTrace = trace;

                if (trace.from.x == 0 && trace.from.y == 0) {
                    break;
                }
            }
        }
    }

    return pathTraces;
}

HUBViewModelDiff *HUBDiffMyersAlgorithm(id<HUBViewModel> fromViewModel, id<HUBViewModel> toViewModel) {
    NSArray<HUBDiffTrace *> *traces = HUBDiffTracesBetweenViewModels(fromViewModel, toViewModel);
    NSArray<HUBDiffTrace *> *path = HUBDiffFindPathFromTraces(traces);

    NSMutableIndexSet *insertions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *deletions = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *reloads = [NSMutableIndexSet indexSet];
    for (HUBDiffTrace *trace in path) {
        HUBDiffTraceType type = trace.type;
        if (type == HUBDiffTraceTypeInsert) {
            [insertions addIndex:(NSUInteger)trace.from.y];
        } else if (type == HUBDiffTraceTypeDelete) {
            [deletions addIndex:(NSUInteger)trace.from.x];
        } else {
            id<HUBComponentModel> base = fromViewModel.bodyComponentModels[(NSUInteger)trace.from.x];
            id<HUBComponentModel> target = toViewModel.bodyComponentModels[(NSUInteger)trace.from.y];
            if (![target isEqual:base]) {
                [reloads addIndex:(NSUInteger)trace.from.x];
            }
        }
    }

    return [[HUBViewModelDiff alloc] initWithInserts:insertions deletes:deletions reloads:reloads];
}

NS_ASSUME_NONNULL_END
