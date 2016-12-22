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

#import "HUBComponentLayoutManagerMock.h"

@implementation HUBComponentLayoutManagerMock

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _contentEdgeMarginsForLayoutTraits = [NSMutableDictionary new];
        _headerMarginsForLayoutTraits = [NSMutableDictionary new];
        _horizontalComponentMarginsForLayoutTraits = [NSMutableDictionary new];
        _verticalComponentMarginsForLayoutTraits = [NSMutableDictionary new];
        _horizontalComponentOffsetsForArrayOfLayoutTraits = [NSMutableDictionary new];
    }
    
    return self;
}

- (CGFloat)marginBetweenComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
                                   andContentEdge:(HUBComponentLayoutContentEdge)contentEdge
{
    return (CGFloat)[self.contentEdgeMarginsForLayoutTraits[layoutTraits] doubleValue];
}

- (CGFloat)verticalMarginBetweenComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
                       andHeaderComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)headerLayoutTraits
{
    return (CGFloat)[self.headerMarginsForLayoutTraits[layoutTraits] doubleValue];
}

- (CGFloat)horizontalMarginForComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
                         precedingComponentLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)precedingComponentLayoutTraits
{
    return (CGFloat)[self.horizontalComponentMarginsForLayoutTraits[layoutTraits] doubleValue];
}

- (CGFloat)verticalMarginForComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
                       precedingComponentLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)precedingComponentLayoutTraits
{
    return (CGFloat)[self.verticalComponentMarginsForLayoutTraits[layoutTraits] doubleValue];
}

- (CGFloat)horizontalOffsetForComponentsWithLayoutTraits:(NSArray<NSSet<HUBComponentLayoutTrait> *> *)componentsTraits
                   firstComponentLeadingHorizontalOffset:(CGFloat)firstComponentLeadingOffsetX
                   lastComponentTrailingHorizontalOffset:(CGFloat)lastComponentTrailingOffsetX
{
    return (CGFloat)[self.horizontalComponentOffsetsForArrayOfLayoutTraits[componentsTraits] doubleValue];
}

@end
