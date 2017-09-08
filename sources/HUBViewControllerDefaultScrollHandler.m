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

#import "HUBViewControllerDefaultScrollHandler.h"
#import "HUBViewController.h"

#import "CGFloat+HUBMath.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewControllerDefaultScrollHandler

- (BOOL)shouldShowScrollIndicatorsInViewController:(id<HUBViewController>)viewController
{
    return YES;
}

- (BOOL)shouldAutomaticallyAdjustContentInsetsInViewController:(id<HUBViewController>)viewController
{
    return YES;
}

- (UIScrollViewKeyboardDismissMode)keyboardDismissModeForViewController:(id<HUBViewController>)viewController
{
    return UIScrollViewKeyboardDismissModeNone;
}

- (CGFloat)scrollDecelerationRateForViewController:(id<HUBViewController>)viewController
{
    return UIScrollViewDecelerationRateNormal;
}

- (UIEdgeInsets)contentInsetsForViewController:(id<HUBViewController>)viewController
                         proposedContentInsets:(UIEdgeInsets)proposedContentInsets
{
    return proposedContentInsets;
}


- (void)scrollViewDidScrollInViewController:(id<HUBViewController>)viewController withContentOffset:(CGPoint)contentOffest
{
    // No-op
}

- (void)scrollingWillStartInViewController:(id<HUBViewController>)viewController
                        currentContentRect:(CGRect)currentContentRect
{
    // No-op
}

- (void)scrollingDidEndInViewController:(id<HUBViewController>)viewController currentContentRect:(CGRect)currentContentRect
{
    // No-op
}

- (CGPoint)targetContentOffsetForEndedScrollInViewController:(id<HUBViewController>)viewController
                                                    velocity:(CGVector)velocity
                                                contentInset:(UIEdgeInsets)contentInset
                                        currentContentOffset:(CGPoint)currentContentOffset
                                       proposedContentOffset:(CGPoint)proposedContentOffset
{
    return proposedContentOffset;
}

- (CGPoint)contentOffsetForDisplayingComponentAtIndex:(NSUInteger)componentIndex
                                       scrollPosition:(HUBScrollPosition)scrollPosition
                                         contentInset:(UIEdgeInsets)contentInset
                                          contentSize:(CGSize)contentSize
                                       viewController:(id<HUBViewController>)viewController
{
    CGRect const componentFrame = [viewController frameForBodyComponentAtIndex:componentIndex];
    CGFloat const viewHeight = CGRectGetHeight(viewController.view.frame);
    CGFloat targetOffset = 0.0;

    if (scrollPosition & HUBScrollPositionCenteredVertically) {
        targetOffset = CGRectGetMidY(componentFrame) - (viewHeight / (CGFloat)2.0);
    } else if (scrollPosition & HUBScrollPositionBottom) {
        targetOffset = CGRectGetMaxY(componentFrame) - viewHeight;
    } else {
        // Default to putting it at the top unless a proper position is provided
        targetOffset = CGRectGetMinY(componentFrame);
    }

    targetOffset = HUBCGFloatMax(-contentInset.top, HUBCGFloatMin(contentSize.height - viewHeight, targetOffset));
    return CGPointMake(0.0, HUBCGFloatFloor(targetOffset));
}

@end

NS_ASSUME_NONNULL_END
