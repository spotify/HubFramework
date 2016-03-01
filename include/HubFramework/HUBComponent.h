#import <UIKit/UIKIt.h>

@protocol HUBComponent;
@protocol HUBComponentModel;
@protocol HUBComponentImageData;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HUBComponentDelegate

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
- (void)component:(id<HUBComponent>)component willDisplayChildAtIndex:(NSUInteger)childIndex;

@end

#pragma mark - HUBComponent

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
 *  through `-configureViewWithModel:`.
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
 *
 *  This message will also be sent to your component the very first time that is used. Once
 *  this method returns the Hub Framework expects the component to be ready to be displayed
 *  with suitable placeholders used for any remote images that are about to be downloaded.
 */
- (void)configureViewWithModel:(id<HUBComponentModel>)model;

@end

#pragma mark - HUBComponentImageHandling

/**
 *  Extended Hub component protocol that adds the ability to handle images
 *
 *  Use this protocol if your component will display images, either for itself or for any
 *  child components that it could potentially be managing. See `HUBComponent` for more info.
 */
@protocol HUBComponentImageHandling <HUBComponent>

/**
 *  Return the size that the component prefers that a certain image gets once loaded
 *
 *  @param imageData The data that will be used to load the image
 *  @param model The current model for the component
 *  @param containerViewSize The size of the container in which the view will be displayed
 */
- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData
                                  model:(id<HUBComponentModel>)model
                      containerViewSize:(CGSize)containerViewSize;

/**
 *  Update the view to display an image that was loaded
 *
 *  @param image The image that was loaded
 *  @param imageData The data that was used to load the image
 *  @param model The current model for the component
 */
- (void)updateViewForLoadedImage:(UIImage *)image
                        fromData:(id<HUBComponentImageData>)imageData
                           model:(id<HUBComponentModel>)model;

@end

#pragma mark - HUBComponentContentOffsetObserver

/**
 *  Extended Hub component protocol that adds the ability to observe content offset changes
 *
 *  Use this protocol if your component needs to react to content offset changes in the view that it
 *  is being displayed in. See `HUBComponent` for more info.
 */
@protocol HUBComponentContentOffsetObserver <HUBComponent>

/**
 *  Update the component’s view in reaction to that the content offset of the container view changed
 *
 *  @param contentOffset The new content offset of the container view
 *
 *  The Hub Framework will send this message every time that the content offset changed in the main
 *  container view. This is equivalent to `UIScrollView scrollViewDidScroll:`.
 */
- (void)updateViewForChangedContentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
