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

#import "HUBComponent.h"

@protocol HUBComponentWrapper;
@protocol HUBComponentWithChildren;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol used to send events related to a component's children back to the Hub Framework
 *
 *  You don't implement this protocol yourself. Instead, you \@synthesize your component's `childDelegate`
 *  property, and may choose to send any of these methods to it to notify it of events, as well as creating
 *  child component instances.
 *
 *  It's definitely recommended to use this protocol as much as possible when using child components, since
 *  you can leverage the framework's built-in capabilities for selection, image loading & other events.
 */
@protocol HUBComponentChildDelegate <NSObject>

/**
 *  Return a child component for a given model
 *
 *  @param component The parent component
 *  @param childComponentModel The model to return a child component for
 *
 *  You may choose to use this method to create components to use to represent any child component models that you
 *  wish to render in your component. Note that it is not required to use this method to create views or other
 *  visual representation for child components, but it's a convenient way - especially for components that wish
 *  to be truly dynamic with which child components they support.
 *
 *  Components created this way are retained and managed by the Hub Framework, and reused whenever they are sent the
 *  `prepareViewForReuse` message.
 *
 *  @return A component that was either newly created, or reused - if an inactive component of the same type was available.
 *          The component will have its view loaded and resized according to its parent and the component's `preferredViewSize`,
 *          and will be configured according to the passed `childComponentModel`.
 */
- (id<HUBComponent>)component:(id<HUBComponentWithChildren>)component childComponentForModel:(id<HUBComponentModel>)childComponentModel;

/**
 *  Notify the Hub Framework that a component is about to display a child component at a given index
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component that is about to be displayed
 *  @param childView The view of the child component that is about to be displayed
 *
 *  If your component has nested child components, you should call this method every time a child is about to
 *  appear on the screen, to enable the Hub Framework to load images and perform other setup work for it.
 */
- (void)component:(id<HUBComponentWithChildren>)component willDisplayChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView;

/**
 *  Notify the Hub Framework that a component has stopped displaying a child component at a given index
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component that is no longer being displayed
 *  @param childView The view of the child component that is no longer displayed
 */
- (void)component:(id<HUBComponentWithChildren>)component didStopDisplayingChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView;

/**
 *  Notify the Hub Framework that a component's child component has been selected
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component that was selected
 *
 *  If your component has nested child components, you should call this method every time a child component was
 *  selected by the user, to enable the Hub Framework to handle the selection.
 */
- (void)component:(id<HUBComponentWithChildren>)component childSelectedAtIndex:(NSUInteger)childIndex;

@end

/**
 *  Extended Hub component protocol that adds the ability to handle child components
 *
 *  Use this protocol if your component supports nesting other components within it. Use the assigned
 *  `childDelegate` to let the Hub Framework perform tasks for nested components for you. See `HUBComponent`
 *  for more info.
 */
@protocol HUBComponentWithChildren <HUBComponent>

/**
 *  The object that acts as a delegate for events related to the component's children
 *
 *  Don't assign any custom objects to this property. Instead, just \@sythensize it, so that the Hub Framework can
 *  assign an internal object to this property, to enable you to send events for the component's children back from
 *  the component to the framework, as well as creating child component instances.
 */
@property (nonatomic, weak, nullable) id<HUBComponentChildDelegate> childDelegate;

/**
 * Called when programmatically scrolling to a child within this parent component.
 *
 * @param childIndex The index of the component that is being scrolled to.
 * @param scrollPosition The preferred position of the component after scrolling.
 * @param animated Whether or not the scrolling should be animated.
 * @param completionHandler The block to call once the component is visible.
 */
- (void)scrollToComponentAtIndex:(NSUInteger)childIndex
                atScrollPosition:(UICollectionViewScrollPosition)scrollPosition
                        animated:(BOOL)animated
                      completion:(void (^)())completionHandler;

@end

NS_ASSUME_NONNULL_END
