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

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewControllerDefaultScrollHandler

- (BOOL)shouldShowScrollIndicatorsInViewController:(HUBViewController *)viewController
{
    return YES;
}

- (BOOL)shouldAutomaticallyAdjustContentInsetsInViewController:(HUBViewController *)viewController
{
    return YES;
}

- (CGFloat)scrollDecelerationRateForViewController:(HUBViewController *)viewController
{
    return UIScrollViewDecelerationRateNormal;
}

- (UIEdgeInsets)contentInsetsForViewController:(HUBViewController *)viewController
                         proposedContentInsets:(UIEdgeInsets)proposedContentInsets
{
    return proposedContentInsets;
}

- (void)scrollingWillStartInViewController:(HUBViewController *)viewController
                        currentContentRect:(CGRect)currentContentRect
{
    // No-op
}

- (void)scrollingDidEndInViewController:(HUBViewController *)viewController currentContentRect:(CGRect)currentContentRect
{
    // No-op
}

- (CGPoint)targetContentOffsetForEndedScrollInViewController:(HUBViewController *)viewController
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
                                       viewController:(HUBViewController *)viewController
                                proposedContentOffset:(CGPoint)proposedContentOffset
{
    return proposedContentOffset;
}

@end

NS_ASSUME_NONNULL_END
