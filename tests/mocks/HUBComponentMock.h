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

#import "HUBComponentWithChildren.h"
#import "HUBComponentWithImageHandling.h"
#import "HUBComponentWithRestorableUIState.h"
#import "HUBComponentWithSelectionState.h"
#import "HUBComponentViewObserver.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBComponentActionPerformer.h"
#import "HUBComponentActionObserver.h"
#import "HUBActionContext.h"

@protocol HUBComponentImageData;

NS_ASSUME_NONNULL_BEGIN

/// Mocked component, for use in tests only
@interface HUBComponentMock : NSObject <
    HUBComponentWithChildren,
    HUBComponentWithImageHandling,
    HUBComponentWithRestorableUIState,
    HUBComponentWithSelectionState,
    HUBComponentViewObserver,
    HUBComponentContentOffsetObserver,
    HUBComponentActionPerformer,
    HUBComponentActionObserver
>

/// The layout traits the component should act like it's having
@property (nonatomic, strong) NSMutableSet<HUBComponentLayoutTrait> *layoutTraits;

/// The size that the component should return as its preferred view size
@property (nonatomic) CGSize preferredViewSize;

/// The view that the component is using to render its content. Reset on `-loadView`.
@property (nonatomic, strong, nullable) UIView *view;

/// The current UI state of the component
@property (nonatomic, strong, nullable) id currentUIState;

/// The UI states that have been passed to this component when restored
@property (nonatomic, strong, readonly) NSArray<id> *restoredUIStates;

/// The current selection state of the component
@property (nonatomic, assign, readonly) HUBComponentSelectionState selectionState;

/// The model that the component is currently configured with
@property (nonatomic, strong, readonly, nullable) id<HUBComponentModel> model;

/// The current container view size that was provided when configured with model
@property (nonatomic) CGSize currentContainerViewSize;

/// The data for any main image the component is currently displaying
@property (nonatomic, strong, readonly, nullable) id<HUBComponentImageData> mainImageData;

/// The data for any background image the component is currently displaying
@property (nonatomic, strong, readonly, nullable) id<HUBComponentImageData> backgroundImageData;

/// The number of times `viewDidResize` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfResizes;

/// The number of times `viewWillAppear` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfAppearances;

/// The number of times `prepareViewForReuse` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfReuses;

/// The number of times `updateViewForChangedContentOffset` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfContentOffsetChanges;

/// The latest action context which was observed by this component
@property (nonatomic, strong, readonly, nullable) id<HUBActionContext> latestObservedActionContext;

/// Whether the component should act like it can handle images or not
@property (nonatomic) BOOL canHandleImages;

/// Whether the component should act like it supports restorable UI state
@property (nonatomic) BOOL supportsRestorableUIState;

/// Whether the component should act like it is a view observer or not
@property (nonatomic) BOOL isViewObserver;

/// Whether the component should act like it is a content offset observer or not
@property (nonatomic) BOOL isContentOffsetObserver;

/// Whether the component's image was recently animated
@property (nonatomic, readonly) BOOL imageWasAnimated;

@end

NS_ASSUME_NONNULL_END
