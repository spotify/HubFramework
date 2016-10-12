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

#import <stack>
#import <unordered_map>
#import <vector>

#import "HUBViewModelDiff.h"
#import "HUBComponentModel.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

using namespace std;

@implementation HUBViewModelDiff

- (instancetype)initWithInserts:(NSArray<NSIndexPath *> *)inserts
                        deletes:(NSArray<NSIndexPath *> *)deletes
                        reloads:(NSArray<NSIndexPath *> *)reloads
                        moves:(NSArray<HUBMoveIndexPath *> *)moves
{
    self = [super init];
    if (self) {
        _insertedBodyComponentIndexPaths = inserts;
        _deletedBodyComponentIndexPaths = deletes;
        _reloadedBodyComponentIndexPaths = reloads;
        _movedBodyComponentIndexPaths = moves;
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

/// Used to track data stats while diffing.
struct HUBEntry {
    /// Flag marking if the data has been updated between arrays by checking the isEqual: method
    BOOL updated = NO;
    /// The number of times the data occurs in the old array
    NSUInteger oldCounter = 0;
    /// The number of times the data occurs in the new array
    NSUInteger newCounter = 0;
    /// The indexes of the data in the old array
    stack<NSUInteger> oldIndexes;
};

/// Track both the entry and algorithm index. Default the index to NSNotFound
struct HUBRecord {
    HUBEntry * _Nullable entry;
    mutable NSUInteger index;

    HUBRecord() {
        entry = NULL;
        index = NSNotFound;
    }
};

struct HUBEqualID {
    bool operator()(const id a, const id b) const {
        return (a == b) || [a isEqual: b];
    }
};

struct HUBHashID {
    size_t operator()(const id o) const {
        return static_cast<size_t>([o hash]);
    }
};

/*
 * Algorithm shamelessly pullled from IGListKit – massive props to these guys:
 * https://github.com/Instagram/IGListKit
 */
+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel
{
    NSArray<id<HUBComponentModel>> *newModels = toViewModel.bodyComponentModels;
    NSArray<id<HUBComponentModel>> *oldModels = fromViewModel.bodyComponentModels;

    const NSUInteger newCount = toViewModel.bodyComponentModels.count;
    const NSUInteger oldCount = fromViewModel.bodyComponentModels.count;

    // symbol table uses the old/new array diffIdentifier as the key and HUBEntry as the value
    // using id<NSObject> as the key provided by https://lists.gnu.org/archive/html/discuss-gnustep/2011-07/msg00019.html
    unordered_map<id<NSObject>, HUBEntry, HUBHashID, HUBEqualID> table;

    // pass 1
    // create an entry for every item in the new array
    // increment its new count for each occurence
    vector<HUBRecord> newResultsArray(newCount);
    for (NSUInteger i = 0; i < newCount; i++) {
        id<NSObject> key = [newModels[i] identifier];
        HUBEntry &entry = table[key];
        entry.newCounter++;

        // add NSNotFound for each occurence of the item in the new array
        entry.oldIndexes.push(NSNotFound);

        // note: the entry is just a pointer to the entry which is stack-allocated in the table
        newResultsArray[i].entry = &entry;
    }

    // pass 2
    // update or create an entry for every item in the old array
    // increment its old count for each occurence
    // record the original index of the item in the old array
    // MUST be done in descending order to respect the oldIndexes stack construction
    vector<HUBRecord> oldResultsArray(oldCount);
    for (NSUInteger i = oldCount - 1; i <= NSNotFound; i--) {
        id<NSObject> key = [oldModels[i] identifier];
        HUBEntry &entry = table[key];
        entry.oldCounter++;

        // push the original indices where the item occured onto the index stack
        entry.oldIndexes.push(i);

        // note: the entry is just a pointer to the entry which is stack-allocated in the table
        oldResultsArray[i].entry = &entry;
    }

    // pass 3
    // handle data that occurs in both arrays
    for (NSUInteger i = 0; i < newCount; i++) {
        HUBEntry *entry = newResultsArray[i].entry;

        // grab and pop the top original index. if the item was inserted this will be NSNotFound
        NSCAssert(!entry->oldIndexes.empty(), @"Old indexes is empty while iterating new item %zi. Should have NSNotFound", i);
        const NSUInteger originalIndex = entry->oldIndexes.top();
        entry->oldIndexes.pop();

        if (originalIndex < oldCount) {
            const id<HUBComponentModel> n = newModels[i];
            const id<HUBComponentModel> o = oldModels[originalIndex];
            // use -[HUBDiffable isEqual:] between both version of data to see if anything has changed
            // skip the equality check if both indexes point to the same object
            if (n != o && ![n isEqual:o]) {
                entry->updated = YES;
            }
        }

        if (originalIndex != NSNotFound
            && entry->newCounter > 0
            && entry->oldCounter > 0) {
            // if an item occurs in the new and old array, it is unique
            // assign the index of new and old records to the opposite index (reverse lookup)
            newResultsArray[i].index = originalIndex;
            oldResultsArray[originalIndex].index = i;
        }
    }

    // storage for final NSIndexPaths or indexes
    NSMutableArray<NSIndexPath *> * const mInserts = [NSMutableArray<NSIndexPath *> array];
    NSMutableArray<NSIndexPath *> * const mUpdates = [NSMutableArray<NSIndexPath *> array];
    NSMutableArray<NSIndexPath *> * const mDeletes = [NSMutableArray<NSIndexPath *> array];
    NSMutableArray<HUBMoveIndexPath *> * const mMoves = [NSMutableArray<HUBMoveIndexPath *> array];

    // populate a container based on whether we want NSIndexPaths or indexes
    // section into INDEX SET
    // item, section into ARRAY
    // HUBMoveIndex or HUBMoveIndexPath into ARRAY
    void (^addIndexToCollection)(id, NSInteger, id) = ^(id collection, NSInteger index, id obj) {
        if (obj) {
            [collection addObject:obj];
        } else {
            NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
            [collection addObject:path];
        }
    };

    NSMapTable * const oldMap = [NSMapTable strongToStrongObjectsMapTable];
    NSMapTable * const newMap = [NSMapTable strongToStrongObjectsMapTable];
    void (^addIndexToMap)(NSInteger, NSArray *, NSMapTable *) = ^(NSInteger index, NSArray<id<HUBViewModel>> *array, NSMapTable *map) {
        NSIndexPath * const value = [NSIndexPath indexPathForItem:index inSection:0];
        id<NSObject> key = [array[static_cast<NSUInteger>(index)] identifier];
        [map setObject:value forKey:key];
    };

    // track offsets from deleted items to calculate where items have moved
    vector<NSInteger> deleteOffsets(oldCount), insertOffsets(newCount);
    NSInteger runningOffset = 0;

    // iterate old array records checking for deletes
    // incremement offset for each delete
    for (NSUInteger i = 0; i < oldCount; i++) {
        deleteOffsets[i] = runningOffset;
        const HUBRecord record = oldResultsArray[i];
        // if the record index in the new array doesn't exist, its a delete
        if (record.index == NSNotFound) {
            addIndexToCollection(mDeletes, static_cast<NSInteger>(i), nil);
            runningOffset++;
        }

        addIndexToMap(static_cast<NSInteger>(i), oldModels, oldMap);
    }

    // reset and track offsets from inserted items to calculate where items have moved
    runningOffset = 0;

    for (NSUInteger ui = 0; ui < newCount; ui++) {
        NSInteger i = static_cast<NSInteger>(ui);
        insertOffsets[ui] = runningOffset;
        const HUBRecord record = newResultsArray[ui];
        const NSInteger oldIndex = static_cast<NSInteger>(record.index);
        // add to inserts if the opposing index is NSNotFound
        if (record.index == NSNotFound) {
            addIndexToCollection(mInserts, static_cast<NSInteger>(i), nil);
            runningOffset++;
        } else {
            // note that an entry can be updated /and/ moved
            if (record.entry->updated) {
                addIndexToCollection(mUpdates, static_cast<NSInteger>(oldIndex), nil);
            }

            // calculate the offset and determine if there was a move
            // if the indexes match, ignore the index
            const NSInteger insertOffset = insertOffsets[ui];
            const NSInteger deleteOffset = deleteOffsets[static_cast<NSUInteger>(oldIndex)];
            if ((oldIndex - deleteOffset + insertOffset) != i) {
                NSIndexPath * const from = [NSIndexPath indexPathForItem:oldIndex inSection:0];
                NSIndexPath * const to = [NSIndexPath indexPathForItem:i inSection:0];
                HUBMoveIndexPath * const move = [[HUBMoveIndexPath alloc] initWithFrom:from to:to];
                addIndexToCollection(mMoves, NSNotFound, move);
            }
        }

        addIndexToMap(i, newModels, newMap);
    }

    NSCAssert((oldCount + [mInserts count] - [mDeletes count]) == newCount,
              @"Sanity check failed applying %zi inserts and %zi deletes to old count %zi equaling new count %zi",
              oldCount, [mInserts count], [mDeletes count], newCount);

    return [[HUBViewModelDiff alloc] initWithInserts:mInserts
                                             deletes:mDeletes
                                             reloads:mUpdates
                                               moves:mMoves];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\t{\n\
        deletions: %@\n\
        insertions: %@\n\
        reloads: %@\n\
        moves: %@\n\
    \t}",
            self.deletedBodyComponentIndexPaths,
            self.insertedBodyComponentIndexPaths,
            self.reloadedBodyComponentIndexPaths,
            self.movedBodyComponentIndexPaths];
}

@end

NS_ASSUME_NONNULL_END
