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

#import <UIKit/UIKIt.h>

#import "HUBComponentLayoutTraits.h"

@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that manage a Hub Framework component
 *
 *  A component acts as a controller between a `HUBComponentModel` and a `UIView` that should be added
 *  to the screen by the Hub Framework. Its responsibilities include model->view data binding, event
 *  handling and rendering.
 *
 *  You are free to implement your component in whatever way you desire, and register it for use with
 *  the Hub Framework using a `HUBComponentFactory` implementation registered with `HUBComponentRegistry`.
 *
 *  Ideally, components should hold as little state as possible, and instead react to any model changes
 *  through `-configureViewWithModel:`. Components of the same class are also reused as much as possible,
 *  so a component can never assume a 1:1 relationship with a certain model, rather it needs to be able to
 *  render any `HUBComponentModel`.
 *
 *  This is the base protocol that all components must conform to. For extensions that adds additional
 *  functionality see:
 *
 *  `HUBComponentWithChildren`: For components that can contain nested child components
 *
 *  `HUBComponentWithImageHandling`: For handling downloaded images.
 *
 *  `HUBComponentWithRestorableUIState`: For saving & restoring the UI state of a component.
 *
 *  `HUBComponentWithSelectionState`: For responding to highlight & selection events in a component.
 *
 *  `HUBComponentContentOffsetObserver`: For components that react to the view's content offset.
 *
 *  `HUBComponentViewObserver`: For components that observe their view for various events.
 *
 *  `HUBComponentActionPerformer`: For components that can perform actions (see `HUBAction`).
 *
 *  `HUBComponentActionObserver`: For components that can observe actions (see `HUBAction`).
 */
@protocol HUBComponent <NSObject>

#pragma mark - Configuring the Component's layout

/**
 *  The set of layout traits that should be used to compute a layout for the component
 *
 *  The Hub Framework will use these layout traits together with its current `HUBComponentLayoutManager`
 *  to compute the margins that an instance of this component will have to other components within the
 *  same view, or to the content edge of that view.
 *
 *  Please note that the layout traits this property contains may be used for another instance of the same
 *  class, so they need to be consistent across instances of the same component class.
 *
 *  For more information, see `HUBComponentLayoutTrait`.
 */
@property (nonatomic, strong, readonly) NSSet<HUBComponentLayoutTrait> *layoutTraits;

#pragma mark - Managing the View

/**
 *  The view that the component uses to render its content
 *
 *  This property should start out as `nil`, and when the Hub Framework will call `-loadView`
 *  on the component, the view should be loaded and this property assigned. This pattern works
 *  similar to the view loading mechanism of `UIViewController`.
 *
 *  The view will be resized by the Hub Framework, taking the size returned from the component's
 *  `-preferredViewSizeForDisplayingModel:containedInViewWithSize:` method into account.
 *
 *  A component has a 1:1 relationship with its view.
 */
@property (nonatomic, strong, nullable) __kindof UIView *view;

/**
 *  Load the component's view
 *
 *  The Hub Framework will send this message to a component when a new instance of it is about
 *  to be displayed. The component should at this point create its view, and assign it to its
 *  `view` property. When this method returns, the `view` property of the component must not
 *  be `nil`.
 *
 *  You don't have to set any particular frame for the view, since it will be resized and
 *  repositioned by the Hub Framework.
 *
 *  See the documentation for `view` for more information.
 */
- (void)loadView;

/**
 *  Return the size that the component prefers that it view gets resized to when used for a certain model
 *
 *  @param model The model that the view should reflect
 *  @param containerViewSize The size of the container in which the view will be displayed
 *
 *  The Hub Framework will use the size returned from this method into account when computing the final
 *  frame for the component's view. In most scenarios the size is fully respected, but might be adjusted
 *  depending on the component's `layoutTraits`.
 *
 *  To get notified when the component's view was resized, conform to `HUBComponentViewObserver`.
 */
- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model
                            containerViewSize:(CGSize)containerViewSize;

#pragma mark - Reusing Views

/**
 *  Prepare the component’s view for reuse
 *
 *  The Hub Framework will send this message to your component when it’s about to be reused for
 *  displaying another model. This is the point in time where any state held in the components view
 *  (such as highlighting) should be reset.
 *
 *  Once the view has been prepared for reuse, the Hub Framework will send your component the
 *  `-configureViewForModel:` message, which should be used for data binding.
 */
- (void)prepareViewForReuse;

/**
 *  Configure the component’s view for displaying data from a model
 *
 *  @param model The new model that the view should reflect
 *  @param containerViewSize The size of the container in which the view will be displayed
 *
 *  This message will also be sent to your component the very first time that is used. Once
 *  this method returns the Hub Framework expects the component to be ready to be displayed
 *  with suitable placeholders used for any remote images that are about to be downloaded.
 */
- (void)configureViewWithModel:(id<HUBComponentModel>)model
             containerViewSize:(CGSize)containerViewSize;

@end

NS_ASSUME_NONNULL_END
