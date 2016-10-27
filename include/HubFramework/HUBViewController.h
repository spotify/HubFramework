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

#import <UIKit/UIKit.h>

#import "HUBComponentType.h"
#import "HUBComponentLayoutTraits.h"

@protocol HUBViewController;
@protocol HUBViewModel;
@protocol HUBComponent;
@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBViewController`
 *
 *  Conform to this protocol in a custom object to get notified of events occuring in a Hub Framework view controller
 */
@protocol HUBViewControllerDelegate <NSObject>

/**
 *  Sent to a Hub Framework view controller's delegate when it is about to be updated with a new view model
 *
 *  @param viewController The view controller that will be updated
 *  @param viewModel The view model that the view controller will be updated with
 *
 *  You can use this method to perform any custom UI operations on the whole view controller right before
 *  a new model will be rendered.
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController willUpdateWithViewModel:(id<HUBViewModel>)viewModel;

/**
 *  Sent to a Hub Framework view controller's delegate when it was updated with a new view model
 *
 *  @param viewController The view controller that was updated
 *
 *  You can use this method to perform any custom UI operations on the whole view controller when a new
 *  view model has been rendered.
 */
- (void)viewControllerDidUpdate:(UIViewController<HUBViewController> *)viewController;

/**
 *  Sent to a Hub Framework view controller's delegate when it failed to be updated because of an error
 *
 *  @param viewController The view controller that failed to update
 *  @param error The error that was encountered
 *
 *  You can use this method to perform any custom UI operations to visualize that an error occured. Any previously
 *  loaded view model will still be used even if an error was encountered.
 *
 *  Note that you can also use content operations (`HUBContentOperation`) to react to errors, and adjust the UI.
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController didFailToUpdateWithError:(NSError *)error;

/**
 *  Sent to a Hub Framework view controller's delegate when the view finished rendering, due to a view model update.

 *  @param viewController The view controller that finished rendering.
 *
 *  You can use this method to perform any custom UI operations on the whole view controller right after
 *  a new view model was rendered.
 */
- (void)viewControllerDidFinishRendering:(UIViewController<HUBViewController> *)viewController;

/**
 *  Sent to a Hub Framework view controller's delegate when a component is about to appear on the screen
 *
 *  @param viewController The view controller in which a component is about to appear
 *  @param componentModel The model of the component that is about to appear
 *  @param layoutTraits The layout traits of the component that is about to appear
 *  @param componentView The view that the component is about to appear in
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
          layoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
      willAppearInView:(UIView *)componentView;

/**
 *  Sent to a Hub Framework view controller's delegate when a component disappeared from the screen
 *
 *  @param viewController The view controller in which a component disappeared
 *  @param componentModel The model of the component that disappeared
 *  @param layoutTraits The layout traits of the component that disappeared
 *  @param componentView The view that the component disappeared from
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
          layoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
  didDisappearFromView:(UIView *)componentView;

/**
 *  Sent to a Hub Framework view controller's delegate when a component was selected
 *
 *  @param viewController The view controller in which the component was selected
 *  @param componentModel The model of the component that was selected
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController componentSelectedWithModel:(id<HUBComponentModel>)componentModel;

@end

/**
 *  Protocol defining the public API of a Hub Framework view controller
 *
 *  You don't conform to this protocol yourself, instead the Hub Framework will create view controllers conforming
 *  to this protocol through `HUBViewControllerFactory`.
 */
@protocol HUBViewController <NSObject>

/// The view controller's delegate. See `HUBViewControllerDelegate` for more information.
@property (nonatomic, weak, nullable) id<HUBViewControllerDelegate> delegate;

/// The identifier of the feature that this view controller belongs to
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/**
 *  The current view model that the view controller is using
 *
 *  To observe whenever the view model will be updated, use the `-viewController:willUpdateWithViewModel:` delegate
 *  method. You can also use `-viewControllerDidUpdate`, which gets called once a new view model has been assigned.
 */
@property (nonatomic, nullable, readonly) id<HUBViewModel> viewModel;

/// Whether the view controller's content view is currently being scrolled
@property (nonatomic, assign, readonly) BOOL isViewScrolling;

/**
 *  Return the frame used to render a body component at a given index
 *
 *  @param index The index of the body component to get the frame for
 *
 *  This method guards against out of bound indexes, so it's safe to call it with whatever index. If an out-of-bounds
 *  index was given, `CGRectZero` is returned.
 */
- (CGRect)frameForBodyComponentAtIndex:(NSUInteger)index;

/**
 *  Return the index of a body component being rendered at a given point
 *
 *  @param point The point of the body component to get the index of (in the view controller's coordinate system)
 *
 *  @return An index, if a body component was found at the given point, or `NSNotFound`.
 */
- (NSUInteger)indexOfBodyComponentAtPoint:(CGPoint)point;

/**
 *  Scroll to a desired content offset.
 *
 *  @param contentOffset The offset which to scroll to.
 *  @param animated Defines if scrolling should be animated.
 */
- (void)scrollToContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

/**
 *  Returns the views of the components of the given type that are currently visible on screen, keyed by their index path
 *
 *  The index paths used for keys contains the indexes for the components' views, starting from the root. For example,
 *  a root body component at index 4 will have an index path with just the index 4, while the child at index 2 of that
 *  component will have an index path with the indexes 4 and 2.
 *
 *  @param componentType The type of component to check for visiblilty.
 *
 *  @return A dictionary of index paths and visible views at that index path.
 */
- (NSDictionary<NSIndexPath *, UIView *> *)visibleComponentViewsForComponentType:(HUBComponentType)componentType;

/**
 *  Perform a programmatic selection of a component with a given model
 *
 *  @param componentModel The model of the component to select
 *
 *  Note that this method won't actually simulate a user interaction on a component view, but rather
 *  run the exact same code that gets run whenever that happens.
 *
 *  @return A boolean indicating whether selection handling was performed, that is if any target URI or action
 *          was executed as a result of the selection.
 */
- (BOOL)selectComponentWithModel:(id<HUBComponentModel>)componentModel;

/**
 *  Cancel any ongoing component selection - including both highlights & selection
 *
 *  If no component is currently being selected, this method does nothing.
 */
- (void)cancelComponentSelection;

@end

NS_ASSUME_NONNULL_END
