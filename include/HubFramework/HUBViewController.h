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

#import "HUBHeaderMacros.h"
#import "HUBComponentLayoutTraits.h"
#import "HUBComponentType.h"
#import "HUBScrollPosition.h"
#import "HUBActionPerformer.h"

@protocol HUBViewModel;
@protocol HUBComponentModel;
@protocol HUBImageLoader;
@class HUBViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBViewController`
 *
 *  Conform to this protocol in a custom object to get notified of events occuring in a Hub Framework view controller
 */
@protocol HUBViewControllerDelegate

/**
 *  Sent to a Hub Framework view controller's delegate when it is about to be updated with a new view model
 *
 *  @param viewController The view controller that will be updated
 *  @param viewModel The view model that the view controller will be updated with
 *
 *  You can use this method to perform any custom UI operations on the whole view controller right before
 *  a new model will be rendered.
 */
- (void)viewController:(HUBViewController *)viewController willUpdateWithViewModel:(id<HUBViewModel>)viewModel;

/**
 *  Sent to a Hub Framework view controller's delegate when it was updated with a new view model
 *
 *  @param viewController The view controller that was updated
 *
 *  You can use this method to perform any custom UI operations on the whole view controller when a new
 *  view model has been rendered.
 */
- (void)viewControllerDidUpdate:(HUBViewController *)viewController;

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
- (void)viewController:(HUBViewController *)viewController didFailToUpdateWithError:(NSError *)error;

/**
 *  Sent to a Hub Framework view controller's delegate when the view finished rendering, due to a view model update.
 
 *  @param viewController The view controller that finished rendering.
 *
 *  You can use this method to perform any custom UI operations on the whole view controller right after
 *  a new view model was rendered.
 */
- (void)viewControllerDidFinishRendering:(HUBViewController *)viewController;

/**
 *  Sent to a Hub Framework view controller's delegate to ask it whenever the view controller should start scrolling
 *
 *  @param viewController The view controller that is about to start scrolling
 *
 *  This method can be used to veto a scroll event from being started. It will be called every time the user starts
 *  scrolling the view that is rendering body components.
 */
- (BOOL)viewControllerShouldStartScrolling:(HUBViewController *)viewController;

/**
 *  Sent to a Hub Framework view controller's delegate when a component is about to appear on the screen
 *
 *  @param viewController The view controller in which a component is about to appear
 *  @param componentModel The model of the component that is about to appear
 *  @param layoutTraits The layout traits of the component that is about to appear
 *  @param componentView The view that the component is about to appear in
 */
- (void)viewController:(HUBViewController *)viewController
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
- (void)viewController:(HUBViewController *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
          layoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
  didDisappearFromView:(UIView *)componentView;

/**
 *  Sent to a Hub Framework view controller's delegate when a component view will be reused
 *
 *  @param viewController The view controller in which a component view will be reused
 *  @param componentView The component view that will be reused
 */
- (void)viewController:(HUBViewController *)viewController
        willReuseComponentWithView:(UIView *)componentView;

/**
 *  Sent to a Hub Framework view controller's delegate when a component was selected
 *
 *  @param viewController The view controller in which the component was selected
 *  @param componentModel The model of the component that was selected
 */
- (void)viewController:(HUBViewController *)viewController componentSelectedWithModel:(id<HUBComponentModel>)componentModel;

/**
 *  Sent to a Hub Framework view controller's delegate to ask if view controller should automatically
 *  manage content inset.
 *
 *  @param viewController The view controller which displays some components
 *
 *  @discussion When view controller automatically manages content inset it puts body components
 *  below header component and below navigation bar.
 */
- (BOOL)viewControllerShouldAutomaticallyManageTopContentInset:(HUBViewController *)viewController;

/**
 *  Return the center point of overlay coponents used in a view controller.
 *
 *  @param viewController The view controller in question
 *  @param proposedCenterPoint The center point that the Hub Framework is proposing
 *
 *  The Hub Framework will call this method every time a view controller is being laid out, which is usually in
 *  response to that its view model has been changed. The returned value will be set as a center point of the overlay.
 */
- (CGPoint)centerPointForOverlayComponentInViewController:(HUBViewController *)viewController
                                      proposedCenterPoint:(CGPoint)proposedCenterPoint;

@end

/**
 *  View controller used to render a Hub Framework-powered view
 *
 *  You don't create instances of this class directly. Instead, you use `HUBViewControllerFactory` to do so.
 *
 *  This view controller renders `HUBComponent` instances using a collection view. What components that are rendered
 *  are determined by `HUBContentOperation`s that build a `HUBViewModel`.
 */
@interface HUBViewController : UIViewController <HUBActionPerformer>

/// The view controller's delegate. See `HUBViewControllerDelegate` for more information.
@property (nonatomic, weak, nullable) id<HUBViewControllerDelegate> delegate;

/// The identifier of the feature that this view controller belongs to
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/// The URI that this view controller was resolved from
@property (nonatomic, copy, readonly) NSURL *viewURI;

/**
 *  The current view model that the view controller is using
 *
 *  To observe whenever the view model will be updated, use the `-viewController:willUpdateWithViewModel:` delegate
 *  method. You can also use `-viewControllerDidUpdate`, which gets called once a new view model has been assigned.
 */
@property (nonatomic, nullable, readonly) id<HUBViewModel> viewModel;

/// Whether the view controller's content view is currently being scrolled
@property (nonatomic, assign, readonly) BOOL isViewScrolling;

/// Whether the view controller's content view should bounce when scrolled
@property (nonatomic, assign) BOOL bounces;

/// Whether the view controller's content view should allow drag vertically even if content is smaller than bounds
@property (nonatomic, assign) BOOL alwaysBounceVertical;

/// Whether the view controller's content view should allow drag horizontally even if content is smaller than bounds
@property (nonatomic, assign) BOOL alwaysBounceHorizontal;

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
 *  Scroll to a desired component. Each index in the index path refers to one level of children.
 *  For example, in order to scroll to a root component at an index, you would provide an index
 *  path with that single index. If that component in turn has children, you can scroll between
 *  those by providing an index path with two index, starting with the root index, and so on.
 *
 *  In order for child components to support nested scrolling, they must implement @c HUBComponentWithScrolling.
 *
 *  @param componentType The type of component you want to scroll to.
 *  @param indexPath The index path of the component to scroll to.
 *  @param scrollPosition The preferred position of the component after scrolling.
 *  @param animated Whether or not the scrolling should be animated.
 *  @param completion A block that is called for each step of the scrolling, providing the index path of the component 
 *         that became visible.
 *
 *  @seealso HUBComponentWithScrolling
 */
- (void)scrollToComponentOfType:(HUBComponentType)componentType
                      indexPath:(NSIndexPath *)indexPath
                 scrollPosition:(HUBScrollPosition)scrollPosition
                       animated:(BOOL)animated
                     completion:(void (^ _Nullable)(NSIndexPath *))completion;

/**
 *  Returns the views of the components of the given type that are currently visible on screen, keyed by their index path
 *
 *  @param componentType The type of component to check for visiblilty.
 *
 *  The index paths used for keys contains the indexes for the components' views, starting from the root. For example,
 *  a root body component at index 4 will have an index path with just the index 4, while the child at index 2 of that
 *  component will have an index path with the indexes 4 and 2.
 *
 *  Note that if you are only interested in a single component's visible view, use the API that only returns a single view
 *  instead, since it has a lot faster lookup time.
 *
 *  @return A dictionary of index paths and visible views at that index path.
 */
- (NSDictionary<NSIndexPath *, UIView *> *)visibleComponentViewsForComponentType:(HUBComponentType)componentType;

/**
 *  Return any currently visible view of a single component
 *
 *  @param componentType The type of component to check for visibility.
 *  @param indexPath The index path of the component to check for visibility.
 *
 *  This method provides a fast way of looking up just a single component's visible view, but if you're interested in
 *  getting all currently visible component views - use `visibleComponentViewsForComponentType:` instead.
 */
- (nullable UIView *)visibleViewForComponentOfType:(HUBComponentType)componentType indexPath:(NSIndexPath *)indexPath;

/**
 *  Perform a programmatic selection of a component with a given model
 *
 *  @param componentModel The model of the component to select
 *  @param customData Any custom data to use when the selection is handled. Will be available on the `HUBActionContext` passed to any actions handling the selection.
 *
 *  Note that this method won't actually simulate a user interaction on a component view, but rather
 *  run the exact same code that gets run whenever that happens.
 *
 *  @return A boolean indicating whether selection handling was performed, that is if any target URI or action
 *          was executed as a result of the selection.
 */
- (BOOL)selectComponentWithModel:(id<HUBComponentModel>)componentModel customData:(nullable NSDictionary<NSString *, id> *)customData;

/**
 *  Cancel any ongoing component selection - including both highlights & selection
 *
 *  If no component is currently being selected, this method does nothing.
 */
- (void)cancelComponentSelection;

/**
 * Reload the view model of the view controller.
 */
- (void)reload;

#pragma mark - Unavailable initializers

/// Use `HUBViewControllerFactory` to create instances of this class
+ (instancetype)new NS_UNAVAILABLE;

/// Use `HUBViewControllerFactory` to create instances of this class
- (instancetype)init NS_UNAVAILABLE;

/// Use `HUBViewControllerFactory` to create instances of this class
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;

/// Use `HUBViewControllerFactory` to create instances of this class
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
