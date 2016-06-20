#import <UIKit/UIKit.h>
#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;
@class HUBComponentWrapper;
@class HUBComponentIdentifier;
@class HUBComponentUIStateManager;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol for `HUBComponentWrapper`
@protocol HUBComponentWrapperDelegate <NSObject>

/**
 *  Ask the delegate to create a child component for the wrapped component
 *
 *  @param componentWrapper The wrapper of the parent component
 *  @param model The model that a component should be created for
 */
- (id<HUBComponent>)componentWrapper:(HUBComponentWrapper *)componentWrapper
       createChildComponentWithModel:(id<HUBComponentModel>)model;

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

@end

/// Class wrapping a `HUBComponent`, adding additional data used internally in the Hub Framework
@interface HUBComponentWrapper : NSObject

/// The component wrapper's delegate. See `HUBComponentWrapperDelegate` for more info.
@property (nonatomic, weak, nullable) id<HUBComponentWrapperDelegate> delegate;

/// The identifier of the wrapper. Used to trace the component between various operations.
@property (nonatomic, strong, readonly) NSUUID *identifier;

/// The component that this instance is wrapping
@property (nonatomic, strong, readonly) id<HUBComponent> component;

/// The identifier that the wrapped component was resolved using
@property (nonatomic, copy, readonly) HUBComponentIdentifier *componentIdentifier;

/// The current model that the wrapped component is representing
@property (nonatomic, strong) id<HUBComponentModel> currentModel;

/**
 *  Initialize an instance of this class with a component to wrap and its identifier
 *
 *  @param component The component to wrap
 *  @param model The initial model used by the component
 *  @param UIStateManager The manager to use to save & restore UI states for the component
 */
- (instancetype)initWithComponent:(id<HUBComponent>)component
                            model:(id<HUBComponentModel>)model
                   UIStateManager:(HUBComponentUIStateManager *)UIStateManager HUB_DESIGNATED_INITIALIZER;

/// Save the current UI state of the wrapped component, if the component supports it
- (void)saveComponentUIState;

/// Restore a previously saved UI state for the wrapped component, if the component supports it
- (void)restoreComponentUIState;

@end

NS_ASSUME_NONNULL_END
