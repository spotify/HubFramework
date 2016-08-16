#import "HUBComponentWrapper.h"
#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;
@protocol HUBComponentImageData;
@class HUBComponentWrapperImplementation;
@class HUBComponentIdentifier;
@class HUBComponentUIStateManager;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol for `HUBComponentWrapperImplementation`
@protocol HUBComponentWrapperDelegate <NSObject>

/**
 *  Return a child component wrapper for a given model
 *
 *  @param componentWrapper The wrapper of the parent component
 *  @param model The model that a component should be created for
 */
- (id<HUBComponentWrapper>)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
                     childComponentForModel:(id<HUBComponentModel>)model;

/**
 *  Notify the delegate that one of the wrapped component's children is about to appear on the screen
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childComponentView The view of the child component that is about to appear
 *  @param childIndex The index of the child component that is about to appear
 */
- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
       willAppearAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the delegate that one of the wrapped component's children disappeared from the screen
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childComponentView The view of the child component that disappared
 *  @param childIndex The index of the child component that disappared
 */
- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
     didDisappearAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the delegate that a child component in the wrapped component was selected
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childComponentView The view of the child component that was selected
 *  @param childIndex The index of the child component that was selected
 */
- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
         selectedAtIndex:(NSUInteger)childIndex;

- (void)sendComponentWrapperToReusePool:(HUBComponentWrapperImplementation *)componentWrapper;

@end

/// Class wrapping a `HUBComponent`, adding additional data used internally in the Hub Framework
@interface HUBComponentWrapperImplementation : NSObject <HUBComponentWrapper>

/// The component wrapper's delegate. See `HUBComponentWrapperDelegate` for more info.
@property (nonatomic, weak, nullable) id<HUBComponentWrapperDelegate> delegate;

/// The model that the component wrapper is currently using. Set to configure the component with a new model.
@property (nonatomic, strong) id<HUBComponentModel> model;

/// Whether the wrapper is for a root component, or for a child component
@property (nonatomic, readonly) BOOL isRootComponent;

/// Whether the wrapped component is capable of handling images
@property (nonatomic, readonly) BOOL handlesImages;

/// Whether the wrapped component is observing the container view's content offset
@property (nonatomic, readonly) BOOL isContentOffsetObserver;

/**
 *  Initialize an instance of this class with a component to wrap and its identifier
 *
 *  @param component The component to wrap
 *  @param model The initial model used by the component
 *  @param UIStateManager The manager to use to save & restore UI states for the component
 *  @param isRootComponent Whether the wrapped component is a root component, or a child of another one
 */
- (instancetype)initWithComponent:(id<HUBComponent>)component
                            model:(id<HUBComponentModel>)model
                   UIStateManager:(HUBComponentUIStateManager *)UIStateManager
                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                  isRootComponent:(BOOL)isRootComponent HUB_DESIGNATED_INITIALIZER;

/**
 *  Return the wrapped component's preferred size for an image
 *
 *  @param imageData The data for the image in question
 *  @param model The model that the image data is contained in. May either be the wrapper's own model, or
 *         the model of a child component.
 *  @param containerViewSize The current size of the component's container view
 *
 *  @return A size retrieved by asking any wrapped image handling component for its preferred image size, or
 *          `CGSizeZero` if `handlesImages` is `NO`.
 */
- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData
                                  model:(id<HUBComponentModel>)model
                      containerViewSize:(CGSize)containerViewSize;

/**
 *  Update the component's view after an image was downloaded
 *
 *  @param image The image that was loaded
 *  @param imageData The image data that the image was loaded using. 
 *  @param model The model that the image data is contained in. May either be the wrapper's own model, or
 *         the model of a child component.
 *  @param animated Whether the image should be rendered using an animation.
 */
- (void)updateViewForLoadedImage:(UIImage *)image
                        fromData:(id<HUBComponentImageData>)imageData
                           model:(id<HUBComponentModel>)model
                        animated:(BOOL)animated;

/**
 *  Notify the component that its view is about to appear on the screen
 */
- (void)viewWillAppear;

/**
 *  Notify the component that the container view's content offset was changed
 *
 *  @param contentOffset The new content offset of the container view
 */
- (void)contentOffsetDidChange:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
