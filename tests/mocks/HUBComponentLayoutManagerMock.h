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

#import "HUBComponentLayoutManager.h"

/// Mocked component layout manager, for use in tests only
@interface HUBComponentLayoutManagerMock : NSObject <HUBComponentLayoutManager>

/// Map of content edge margins to use (for all edges) for a set of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSSet<HUBComponentLayoutTrait> *, NSNumber *> *contentEdgeMarginsForLayoutTraits;

/// Map of header margins to use for a set of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSSet<HUBComponentLayoutTrait> *, NSNumber *> *headerMarginsForLayoutTraits;

/// Map of horizontal component margins to use for a set of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSSet<HUBComponentLayoutTrait> *, NSNumber *> *horizontalComponentMarginsForLayoutTraits;

/// Map of vertical component margins to use for a set of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSSet<HUBComponentLayoutTrait> *, NSNumber *> *verticalComponentMarginsForLayoutTraits;

/// Map of horizontal component offsets to use for an array of sets of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSArray<NSSet<HUBComponentLayoutTrait> *> *, NSNumber *> *horizontalComponentOffsetsForArrayOfLayoutTraits;

@end
