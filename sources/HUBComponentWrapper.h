#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;
@class HUBComponentWrapper;
@class HUBComponentIdentifier;

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
 *  Notify the delegate that the wrapped component is about to display a child component at a given index
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childIndex The index of the child component that is about to be displayed
 */
- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper componentWillDisplayChildAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the delegate that a child component in the wrapped component was selected
 *
 *  @param componentWrapper The wrapper of the component in which the event occured
 *  @param childIndex The index of the child component that was selected
 */
- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper childComponentSelectedAtIndex:(NSUInteger)childIndex;

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
@property (nonatomic, strong, nullable) id<HUBComponentModel> currentModel;

/**
 *  Initialize an instance of this class with a component to wrap and its identifier
 *
 *  @param component The component to wrap
 *  @param componentIdentifier The identifier that the component was resolved using
 */
- (instancetype)initWithComponent:(id<HUBComponent>)component
              componentIdentifier:(HUBComponentIdentifier *)componentIdentifier HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
