#import <UIKit/UIKIt.h>

@protocol HUBComponent;
@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol used to communicate back to the Hub Framework from a component implementation
 *
 *  You don't implement this protocol yourself. Instead, you @synthesize your component's `delegate`
 *  property, and may choose to send any of these methods to it to notify it of events.
 */
@protocol HUBComponentDelegate <NSObject>

#pragma mark - Tracking the Addition and Removal of Child Components

/**
 *  Notify the Hub Framework that a component is about to display a child component at a given index
 *
 *  @param component The component in question
 *  @param childIndex The index of the child component that is about to be displayed
 *
 *  If your component has nested child components, you should call this method every time a child
 *  is about to appear on the screen, to enable the Hub Framework to load images and perform other
 *  setup work for it.
 */
- (void)hubComponent:(id<HUBComponent>)component willDisplayChildAtIndex:(NSUInteger)childIndex;

@end

/**
 *  Protocol implemented by objects that manage a Hub Framework component
 *
 *  A component acts as a controller between a `HUBComponentModel` and a `UIView` that should be added
 *  to the screen by the Hub Framework. Its responsibilities include model->view data binding, event
 *  handling and rendering.
 *
 *  You're free to setup your component object in whichever way you require, as long
 *  as you make sure any dependencies are carried over to new components returned from
 *  `-createNewComponent`.
 *
 *  Ideally, components should hold as little state as possible, and instead react
 *  to any model changes through `-prepareViewForReuseWithModel:`.
 */
@protocol HUBComponent <NSObject>

#pragma mark - Configuring the Component

/**
 *  The component's delegate
 *
 *  Don't assign any custom objects to this property. Instead, just @sythensize it, so that the
 *  Hub Framework can assign an internal object to this property, to enable you to send events
 *  back from the component to the framework.
 */
@property (nonatomic, weak, nullable) id<HUBComponentDelegate> delegate;

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
@property (nonatomic, strong, nullable) UIView *view;

/**
 *  Create a new component of the same type as this one
 *
 *  You are not strictly required to copy this object in the implementation of this method,
 *  but it's one possible implementation. You should make sure the returned component is
 *  ready to use, with any dependencies it needs carried over from the previous component
 *  that created it.
 */
- (instancetype)createNewComponent;

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
 *  @param containerViewSize The container in which the view will be displayed
 */
- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model
                      containedInViewWithSize:(CGSize)containerViewSize;

#pragma mark - Reusing Views

/**
 *  Prepare this component's view for reuse with a new model
 *
 *  @param model The new model that the view should reflect
 *
 *  This message will also be sent to your component the very first time that is used. Once
 *  this method returns the Hub Framework expects the component to be ready to be displayed
 *  with suitable placeholders used for any remote images that are about to be downloaded.
 */
- (void)prepareViewForReuseWithModel:(id<HUBComponentModel>)model;

#pragma mark - Managing Component Images

/**
 *  Update this component's view with an image that was loaded for a model
 *
 *  @param image The image that was loaded
 *  @param model The model that the image was loded for
 *
 *  You can assume that this method will always be called after `-prepareViewForReuseWithModel`,
 *  and that the model will be the same as when that message was sent.
 */
- (void)updateViewForLoadedImage:(UIImage *)image forModel:(id<HUBComponentModel>)model;

@end

NS_ASSUME_NONNULL_END
