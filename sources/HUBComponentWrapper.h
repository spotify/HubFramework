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

#import "HUBComponentWithImageHandling.h"
#import "HUBComponentViewObserver.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBComponentWithRestorableUIState.h"
#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;
@protocol HUBComponentImageData;
@class HUBIdentifier;
@class HUBComponentWrapper;
@class HUBComponentUIStateManager;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol for `HUBComponentWrapper`
@protocol HUBComponentWrapperDelegate <NSObject>

/**
 *  Return a child component wrapper for a given model
 *
 *  @param componentWrapper The wrapper of the parent component
 *  @param model The model that a component should be created for
 */
- (HUBComponentWrapper *)componentWrapper:(HUBComponentWrapper *)componentWrapper
                   childComponentForModel:(id<HUBComponentModel>)model;

/**
 *  Notify the delegate that one of the wrapped component's children is about to appear on the screen
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childComponentView The view of the child component that is about to appear
 *  @param childIndex The index of the child component that is about to appear
 */
- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
          childComponent:(nullable HUBComponentWrapper *)childComponent
               childView:(UIView *)childComponentView
       willAppearAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the delegate that one of the wrapped component's children disappeared from the screen
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childComponentView The view of the child component that disappared
 *  @param childIndex The index of the child component that disappared
 */
- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
          childComponent:(nullable HUBComponentWrapper *)childComponent
               childView:(UIView *)childComponentView
     didDisappearAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the delegate that a child component in the wrapped component was selected
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childIndex The index of the child component that was selected
 */
- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
    childSelectedAtIndex:(NSUInteger)childIndex;

/**
 *  Ask the delegate to perform an action on behalf of a component wrapper
 *
 *  @param componentWrapper The wrapper of the component that wants an action to be performed
 *  @param identifier The identifier of the action to perform
 *  @param customData Any custom data that should be passed to the action
 *
 *  @return A boolean indicating whether an action was successfully performed or not
 */
- (BOOL)componentWrapper:(HUBComponentWrapper *)componentWrapper
        performActionWithIdentifier:(HUBIdentifier *)identifier
        customData:(nullable NSDictionary<NSString *, id> *)customData;

/**
 *  Send a component wrapper to its reuse pool
 *
 *  @param componentWrapper The component wrapper that should be sent to its reuse pool
 *
 *  Sending a component wrapper to a its reuse pool will open it up to be reused for
 *  rendering other models.
 */
- (void)sendComponentWrapperToReusePool:(HUBComponentWrapper *)componentWrapper;

@end

/// Class wrapping a `HUBComponent`, adding additional data used internally in the Hub Framework
@interface HUBComponentWrapper : NSObject <
    HUBComponentWithImageHandling,
    HUBComponentViewObserver,
    HUBComponentContentOffsetObserver
>

/// A unique identifier for this component wrapper. Can be used to track it accross various operations.
@property (nonatomic, strong, readonly) NSUUID *identifier;

/// The current model that the component wrapper is representing
@property (nonatomic, strong, readonly) id<HUBComponentModel> model;

/// The component wrapper's delegate. See `HUBComponentWrapperDelegate` for more info.
@property (nonatomic, weak, nullable) id<HUBComponentWrapperDelegate> delegate;

/// The components parent wrapper if it is a child component
@property (nonatomic, weak, nullable, readonly) HUBComponentWrapper *parent;

/// Whether the wrapper is for a root component, or for a child component
@property (nonatomic, readonly) BOOL isRootComponent;

/// Whether the wrapped component is capable of handling images
@property (nonatomic, readonly) BOOL handlesImages;

/// Whether the wrapped component is observing the container view's content offset
@property (nonatomic, readonly) BOOL isContentOffsetObserver;

/// Whether the wrapped component's view has appeared since the model was last changed
@property (nonatomic, readonly) BOOL viewHasAppearedSinceLastModelChange;

/**
 *  Initialize an instance of this class with a component to wrap and its identifier
 *
 *  @param component The component to wrap
 *  @param model The model that the component wrapper will represent
 *  @param UIStateManager The manager to use to save & restore UI states for the component
 *  @param delegate The object that will act as the component wrapper's delegate
 *  @param parent The parent component wrapper if this component wrapper is a child component
 */
- (instancetype)initWithComponent:(id<HUBComponent>)component
                            model:(id<HUBComponentModel>)model
                   UIStateManager:(HUBComponentUIStateManager *)UIStateManager
                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                           parent:(nullable HUBComponentWrapper *)parent HUB_DESIGNATED_INITIALIZER;

/** 
 * Manually saves the underlying component's UI state. This is normally called before the component
 * is prepared for reuse.
 */
- (void)saveComponentUIState;

@end

NS_ASSUME_NONNULL_END
