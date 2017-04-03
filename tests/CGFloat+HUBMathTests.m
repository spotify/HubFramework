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
#import "HUBTestUtilities.h"

#import "CGFloat+HUBMath.h"

@interface CGFloatHUBMathTests : XCTestCase
@end

@implementation CGFloatHUBMathTests

#pragma mark HUBCGFloatFloor

- (void)testFloorZeroIsZero
{
    XCTAssertLessThanOrEqual(HUBCGFloatFloor((CGFloat)0.0), (CGFloat)0.0, @"Flooring 0.0 should yield 0.0");
}

- (void)testFloorLowFraction
{
    XCTAssertLessThanOrEqual(HUBCGFloatFloor((CGFloat)3.1415), (CGFloat)3.0, @"Flooring 3.1415 should yield 3.0");
}

- (void)testFloorMidFraction
{
    XCTAssertLessThanOrEqual(HUBCGFloatFloor((CGFloat)25.5), (CGFloat)25.0, @"Flooring 25.5 should yield 25.0");
}

- (void)testFloorHighFraction
{
    XCTAssertLessThanOrEqual(HUBCGFloatFloor((CGFloat)3.8585), (CGFloat)3.0, @"Flooring 3.8585 should yield 3.0");
}


#pragma mark HUBCGFloatAbs

- (void)testAbsZeroIsZero
{
    XCTAssertLessThanOrEqual(HUBCGFloatAbs((CGFloat)0.0), (CGFloat)0.0, @"Absolute of ±0.0 should yield +0.0");
}

- (void)testAbsPositiveIsSame
{
    const CGFloat original = (CGFloat)3.1415;
    const CGFloat actual = HUBCGFloatAbs(original);
    const CGFloat epsilon = (CGFloat)0.00001;

    XCTAssertTrue((actual >= (original - epsilon)) || (actual <= (original + epsilon)), @"Absolute of +3.1415 should yield +3.1415");
}

- (void)testAbsNegativeIsPositive
{
    const CGFloat original = (CGFloat)-3.1415;
    const CGFloat actual = HUBCGFloatAbs(original);
    const CGFloat epsilon = (CGFloat)0.00001;

    XCTAssertTrue((actual >= (original - epsilon)) || (actual <= (original + epsilon)), @"Absolute of -3.1415 should yield +3.1415");
}


#pragma mark HUBCGFloatMax

- (void)testMaxWhenBothValuesAreEqual
{
    const CGFloat a = (CGFloat)12.2;
    const CGFloat b = (CGFloat)12.2;

    HUBAssertEqualCGFloatValues(HUBCGFloatMax(a, b), 12.2);
}

- (void)testMaxWhenFirstValueIsLarger
{
    const CGFloat a = (CGFloat)10.0;
    const CGFloat b = (CGFloat)9.9;

    HUBAssertEqualCGFloatValues(HUBCGFloatMax(a, b), 10.0);
}

- (void)testMaxWhenSecondValueIsLarger
{
    const CGFloat a = (CGFloat)9.8;
    const CGFloat b = (CGFloat)9.9;

    HUBAssertEqualCGFloatValues(HUBCGFloatMax(a, b), 9.9);
}


#pragma mark HUBCGFloatMin

- (void)testMinWhenBothValuesAreEqual
{
    const CGFloat a = (CGFloat)12.2;
    const CGFloat b = (CGFloat)12.2;

    HUBAssertEqualCGFloatValues(HUBCGFloatMin(a, b), 12.2);
}

- (void)testMinWhenFirstValueIsSmaller
{
    const CGFloat a = (CGFloat)4.1;
    const CGFloat b = (CGFloat)4.2;

    HUBAssertEqualCGFloatValues(HUBCGFloatMin(a, b), 4.1);
}

- (void)testMinWhenSecondValueIsSmaller
{
    const CGFloat a = (CGFloat)-3.13;
    const CGFloat b = (CGFloat)-3.14;

    HUBAssertEqualCGFloatValues(HUBCGFloatMin(a, b), -3.14);
}


#pragma mark HUBCGFloatIsNearlyEqual

- (void)testIsNearlyEqualForTruthyValues
{
    const CGFloat epsilon = (CGFloat)0.00001;
    const CGFloat lhs = (CGFloat)12.34;
    const CGFloat rhs = (CGFloat)(12.34 + 0.000001);

    XCTAssertTrue(HUBCGFloatIsNearlyEqual(lhs, rhs, epsilon), @"Almost equal values should be reported as such");
}

- (void)testIsNotNearlyEqualForFalseyValues
{
    const CGFloat epsilon = (CGFloat)0.00001;
    const CGFloat lhs = (CGFloat)12.34;
    const CGFloat rhs = (CGFloat)(12.34 + 0.0009);

    XCTAssertFalse(HUBCGFloatIsNearlyEqual(lhs, rhs, epsilon), @"Values that are apart greater than the epsilon should not be considered equal");
}


#pragma mark HUBCGFloatIsZero

- (void)testIsZeroForZero
{
    XCTAssertTrue(HUBCGFloatIsZero(0.0), @"The literal 0.0 should be reported as zero");
}

- (void)testIsZeroForAlmostZero
{
    const CGFloat original = HUBCGFloatDefaultEpsilon - HUBCGFloatDefaultEpsilon / (CGFloat)10.0;
    XCTAssertTrue(HUBCGFloatIsZero(original), @"A value within the tolerance (epsilon) should be reported as zero");
}

- (void)testIsZeroForAlmostButNotZero
{
    const CGFloat original = HUBCGFloatDefaultEpsilon * 2;
    XCTAssertFalse(HUBCGFloatIsZero(original), @"A value just outside of the tolerance (epsilon) should yield false");
}

- (void)testIsZeroForNotZero
{
    XCTAssertFalse(HUBCGFloatIsZero(4), @"A non-zero value should yield false");
}

@end
