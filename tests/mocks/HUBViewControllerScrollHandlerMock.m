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

#import "HUBViewControllerScrollHandlerMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerScrollHandlerMock ()

@property (nonatomic, assign, readwrite) UIEdgeInsets proposedContentInsets;
@property (nonatomic, assign, readwrite) CGRect startContentRect;
@property (nonatomic, assign, readwrite) CGRect endContentRect;

@end

@implementation HUBViewControllerScrollHandlerMock

- (BOOL)shouldShowScrollIndicatorsInViewController:(UIViewController<HUBViewController> *)viewController
{
    return self.shouldShowScrollIndicators;
}

- (BOOL)shouldAutomaticallyAdjustContentInsetsInViewController:(UIViewController<HUBViewController> *)viewController
{
    return self.shouldAutomaticallyAdjustContentInsets;
}

- (CGFloat)scrollDecelerationRateForViewController:(UIViewController<HUBViewController> *)viewController
{
    return self.scrollDecelerationRate;
}

- (UIEdgeInsets)contentInsetsForViewController:(UIViewController<HUBViewController> *)viewController
                         proposedContentInsets:(UIEdgeInsets)proposedContentInsets
{
    return self.contentInsets;
}

- (void)scrollingWillStartInViewController:(UIViewController<HUBViewController> *)viewController
                        currentContentRect:(CGRect)currentContentRect
{
    self.startContentRect = currentContentRect;

    if (self.scrollingWillStartHandler) {
        self.scrollingWillStartHandler(currentContentRect);
    }
}

- (void)scrollingDidEndInViewController:(UIViewController<HUBViewController> *)viewController
                     currentContentRect:(CGRect)currentContentRect
{
    self.endContentRect = currentContentRect;

    if (self.scrollingDidEndHandler) {
        self.scrollingDidEndHandler(currentContentRect);
    }
}

- (CGPoint)targetContentOffsetForEndedScrollInViewController:(UIViewController<HUBViewController> *)viewController
                                                    velocity:(CGVector)velocity
                                                contentInset:(UIEdgeInsets)contentInset
                                        currentContentOffset:(CGPoint)currentContentOffset
                                       proposedContentOffset:(CGPoint)proposedContentOffset
{
    return self.targetContentOffset;
}

- (CGPoint)contentOffsetForDisplayingComponentAtIndex:(NSUInteger)componentIndex
                                       scrollPosition:(UICollectionViewScrollPosition)scrollPosition
                                         contentInset:(UIEdgeInsets)contentInset
                                          contentSize:(CGSize)contentSize
                                       viewController:(UIViewController<HUBViewController> *)viewController
{
    return self.targetContentOffset;
}

@end

NS_ASSUME_NONNULL_END
