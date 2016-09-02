#import "HUBComponentWithImageHandling.h"
#import "HUBComponentViewObserver.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;
@protocol HUBComponentImageData;
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
  childComponentWithView:(UIView *)childComponentView
       willAppearAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the delegate that one of the wrapped component's children disappeared from the screen
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childComponentView The view of the child component that disappared
 *  @param childIndex The index of the child component that disappared
 */
- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
     didDisappearAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the delegate that a child component in the wrapped component was selected
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childComponentView The view of the child component that was selected
 *  @param childIndex The index of the child component that was selected
 */
- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
         selectedAtIndex:(NSUInteger)childIndex;

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

@end

NS_ASSUME_NONNULL_END
