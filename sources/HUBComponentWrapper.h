#import <Foundation/Foundation.h>

@protocol HUBComponent;
@protocol HUBComponentModel;
@class HUBComponentWrapper;
@class HUBComponentIdentifier;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol for `HUBComponentWrapper`
@protocol HUBComponentWrapperDelegate <NSObject>

/**
 *  Notify the delegate that the wrapped component is about to display a child component at a given index
 *
 *  @param childIndex The index of the child component that is about to be displayed
 */
- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper componentWillDisplayChildAtIndex:(NSUInteger)childIndex;

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
              componentIdentifier:(HUBComponentIdentifier *)componentIdentifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
