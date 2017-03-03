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

#import "HUBDefaultComponentLayoutManager.h"
#import "CGFloat+HUBMath.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBDefaultComponentLayoutManager ()

@property (nonatomic, assign, readonly) CGFloat margin;

@end

@implementation HUBDefaultComponentLayoutManager

#pragma mark - Initializer

- (instancetype)initWithMargin:(CGFloat)margin
{
    self = [super init];
    
    if (self) {
        _margin = margin;
    }
    
    return self;
}

#pragma mark - HUBComponentLayoutManager

- (CGFloat)marginBetweenComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
                                   andContentEdge:(HUBComponentLayoutContentEdge)contentEdge
{
    switch (contentEdge) {
        case HUBComponentLayoutContentEdgeTop:
        case HUBComponentLayoutContentEdgeBottom:
            if ([layoutTraits containsObject:HUBComponentLayoutTraitStackable]) {
                return 0;
            }
            
            break;
        case HUBComponentLayoutContentEdgeLeft:
        case HUBComponentLayoutContentEdgeRight:
            if ([layoutTraits containsObject:HUBComponentLayoutTraitFullWidth]) {
                return 0;
            }
            
            break;
    }
    
    return self.margin;
}

- (CGFloat)verticalMarginBetweenComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
                       andHeaderComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)headerLayoutTraits
{
    return [self verticalMarginForComponentWithLayoutTraits:layoutTraits
                             precedingComponentLayoutTraits:headerLayoutTraits];
}

- (CGFloat)horizontalMarginForComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
                         precedingComponentLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)precedingComponentLayoutTraits
{
    if ([layoutTraits containsObject:HUBComponentLayoutTraitFullWidth]) {
        return 0;
    } else {
        BOOL const isCentered = [layoutTraits containsObject:HUBComponentLayoutTraitCentered];
        BOOL const precedingIsCentered = [precedingComponentLayoutTraits containsObject:HUBComponentLayoutTraitCentered];
        
        // Centered components are always grouped toghether
        if (isCentered != precedingIsCentered) {
            return CGFLOAT_MAX;
        }
    }
    
    return self.margin;
}

- (CGFloat)verticalMarginForComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
                       precedingComponentLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)precedingComponentLayoutTraits
{
    BOOL const shouldStack = [self shouldStackComponentWithLayoutTraits:layoutTraits
                                         belowComponentWithLayoutTraits:precedingComponentLayoutTraits];
    
    return shouldStack ? 0 : self.margin;
}

- (CGFloat)horizontalOffsetForComponentsWithLayoutTraits:(NSArray<NSSet<HUBComponentLayoutTrait> *> *)componentsTraits
                   firstComponentLeadingHorizontalOffset:(CGFloat)firstComponentLeadingOffsetX
                   lastComponentTrailingHorizontalOffset:(CGFloat)lastComponentTrailingOffsetX
{
    if (componentsTraits.count == 0) {
        return 0;
    }
    
    for (NSSet<HUBComponentLayoutTrait> *layoutTraits in componentsTraits) {
        if ([layoutTraits containsObject:HUBComponentLayoutTraitCentered] == NO) {
            return 0;
        }
    }
    
    /// Center the component
    return HUBCGFloatFloor((firstComponentLeadingOffsetX + lastComponentTrailingOffsetX) / 2 - firstComponentLeadingOffsetX);
}

#pragma mark - Private utilities

- (BOOL)shouldStackComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)bottomLayoutTraits
              belowComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait> *)topLayoutTraits
{
    if ([bottomLayoutTraits containsObject:HUBComponentLayoutTraitAlwaysStackUpwards]) {
        return YES;
    }
    
    return [topLayoutTraits containsObject:HUBComponentLayoutTraitStackable] &&
           [bottomLayoutTraits containsObject:HUBComponentLayoutTraitStackable];
}

@end

NS_ASSUME_NONNULL_END
