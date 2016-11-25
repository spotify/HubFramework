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

#import <XCTest/XCTest.h>

#import "HUBDefaultComponentLayoutManager.h"
#import "HUBTestUtilities.h"

@interface HUBDefaultComponentLayoutManagerTests : XCTestCase

@end

@implementation HUBDefaultComponentLayoutManagerTests

- (void)testApplyingMarginBetweenCompactWidthComponents
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraits = [NSSet setWithObject:HUBComponentLayoutTraitCompactWidth];
    
    CGFloat const horizontalMargin = [manager horizontalMarginForComponentWithLayoutTraits:layoutTraits
                                                            precedingComponentLayoutTraits:layoutTraits];
    
    CGFloat const verticalMargin = [manager verticalMarginBetweenComponentWithLayoutTraits:layoutTraits
                                                        andHeaderComponentWithLayoutTraits:layoutTraits];
    
    HUBAssertEqualFloatValues(horizontalMargin, 10);
    HUBAssertEqualFloatValues(verticalMargin, 10);
}

- (void)testApplyingMarginBetweenCompactWithComponentAndContentEdge
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraits = [NSSet setWithObject:HUBComponentLayoutTraitCompactWidth];
    
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeTop], 10);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeRight], 10);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeBottom], 10);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeLeft], 10);
}

- (void)testNotApplyingHorizontalMarginBetweenFullWidthComponents
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraits = [NSSet setWithObject:HUBComponentLayoutTraitFullWidth];
    
    CGFloat const horizontalMargin = [manager horizontalMarginForComponentWithLayoutTraits:layoutTraits
                                                            precedingComponentLayoutTraits:layoutTraits];
    
    CGFloat const verticalMargin = [manager verticalMarginBetweenComponentWithLayoutTraits:layoutTraits
                                                        andHeaderComponentWithLayoutTraits:layoutTraits];
    
    HUBAssertEqualFloatValues(horizontalMargin, 0);
    HUBAssertEqualFloatValues(verticalMargin, 10);
}

- (void)testNotApplyingHorizontalMarginBetweenFullWidthComponentAndContentEdge
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraits = [NSSet setWithObject:HUBComponentLayoutTraitFullWidth];
    
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeTop], 10);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeRight], 0);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeBottom], 10);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeLeft], 0);
}

- (void)testNotApplyingVerticalMarginBetweenStackableComponents
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraits = [NSSet setWithObject:HUBComponentLayoutTraitStackable];
    
    CGFloat const horizontalMargin = [manager horizontalMarginForComponentWithLayoutTraits:layoutTraits
                                                            precedingComponentLayoutTraits:layoutTraits];
    
    CGFloat const verticalMargin = [manager verticalMarginBetweenComponentWithLayoutTraits:layoutTraits
                                                        andHeaderComponentWithLayoutTraits:layoutTraits];
    
    HUBAssertEqualFloatValues(horizontalMargin, 10);
    HUBAssertEqualFloatValues(verticalMargin, 0);
}

- (void)testNotApplyingVerticalMarginBetweenStackableComponentAndContentEdge
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraits = [NSSet setWithObject:HUBComponentLayoutTraitStackable];
    
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeTop], 0);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeRight], 10);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeBottom], 0);
    HUBAssertEqualFloatValues([manager marginBetweenComponentWithLayoutTraits:layoutTraits andContentEdge:HUBComponentLayoutContentEdgeLeft], 10);
}

- (void)testApplyingVerticalMarginBetweenStackableAndNonStackableComponent
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraitsA = [NSSet setWithObject:HUBComponentLayoutTraitStackable];
    NSSet * const layoutTraitsB = [NSSet setWithObject:HUBComponentLayoutTraitCompactWidth];
    
    CGFloat const marginA = [manager verticalMarginForComponentWithLayoutTraits:layoutTraitsA
                                                 precedingComponentLayoutTraits:layoutTraitsB];
    
    // Now, invert the layout traits, to make sure that that case is also handled
    CGFloat const marginB = [manager verticalMarginForComponentWithLayoutTraits:layoutTraitsB
                                                 precedingComponentLayoutTraits:layoutTraitsA];
    
    HUBAssertEqualFloatValues(marginA, 10);
    HUBAssertEqualFloatValues(marginB, 10);
}

- (void)testNotApplyingVerticalMarginUpwardsForAlwaysStackUpwardsComponent
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraitsA = [NSSet setWithObject:HUBComponentLayoutTraitAlwaysStackUpwards];
    NSSet * const layoutTraitsB = [NSSet setWithObject:HUBComponentLayoutTraitCompactWidth];
    
    CGFloat const upwardsMargin = [manager verticalMarginForComponentWithLayoutTraits:layoutTraitsA
                                                       precedingComponentLayoutTraits:layoutTraitsB];
    
    CGFloat const downwardsMargin = [manager verticalMarginForComponentWithLayoutTraits:layoutTraitsB
                                                         precedingComponentLayoutTraits:layoutTraitsA];
    
    HUBAssertEqualFloatValues(upwardsMargin, 0);
    HUBAssertEqualFloatValues(downwardsMargin, 10);
}

- (void)testCentering
{
    HUBDefaultComponentLayoutManager * const manager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:10];
    NSSet * const layoutTraits = [NSSet setWithObject:HUBComponentLayoutTraitCentered];
    
    CGFloat const offset = [manager horizontalOffsetForComponentsWithLayoutTraits:@[layoutTraits]
                                            firstComponentLeadingHorizontalOffset:10
                                            lastComponentTrailingHorizontalOffset:300];
    
    HUBAssertEqualFloatValues(offset, 145);
}

@end
