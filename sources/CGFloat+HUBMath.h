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

#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark Computing, testing and comparing values from CGFloats

#if CGFLOAT_IS_DOUBLE
#define HUBCGFloatFloor floor
#define HUBCGFloatAbs fabs
#define HUBCGFloatMax fmax
#define HUBCGFloatMin fmin
#else
#define HUBCGFloatFloor floorf
#define HUBCGFloatAbs fabsf
#define HUBCGFloatMax fmaxf
#define HUBCGFloatMin fminf
#endif

#pragma mark - Testing and Comparing CGFloats

/**
 The default epsilon value for `CGFloat` operations.
 
 This value should be good enough for most UI geometry calculations.
 */
static const CGFloat HUBCGFloatDefaultEpsilon = (CGFloat)0.00001;

/**
 Returns a Boolean value indicating if the given `lhs` is approximately equal to `rhs`, given an `epsilon`.
 
 @warning Do not use this function to test if a value is (nearly) equal to zero. Instead use
          `BOOL HUBCGFloatIsZero(CGFLoat)` to test whether a value is (nearly) equal to zero.

 @param lhs The first value.
 @param rhs The second value.
 @param epsilon The epsilon (i.e. tolerated deviance from true equality).
 @return `YES` if the `lhs` is approximately equal to `rhs` (±epsilon); otherwise `NO`.
 
 @seealso `HUBCGFloatIsZero(CGFloat)` for a function to check if a values is ≈0.
 */
static inline BOOL HUBCGFloatIsNearlyEqual(CGFloat lhs, CGFloat rhs, CGFloat epsilon)
{
    return HUBCGFloatAbs(lhs - rhs) <= epsilon * HUBCGFloatMax(HUBCGFloatAbs(lhs), HUBCGFloatAbs(lhs));
}

/**
 Returns a Boolean value indicating if the given `value` is (approximately) zero.
 
 @note The function uses the Hub Framework’s default epislon value. Which should be well enough for any geometry tests.

 @param value The value that should be compared to zero (0)
 @return `YES` if the `value` is (approximately; ±1e-5) equal to zero; otherwise `NO`.
 
 @seealso `HUBCGFloatDefaultEpsilon` for the details of the default
 */
static inline BOOL HUBCGFloatIsZero(CGFloat value)
{
    return HUBCGFloatAbs(value) <= HUBCGFloatDefaultEpsilon;
}

NS_ASSUME_NONNULL_END
