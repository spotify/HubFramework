#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol defining the public API of a Hub Framework component model. To be implemented.
@protocol HUBComponentModel <NSObject>

/**
 *  The identifier of the component that this model should be rendered using
 *
 *  The component identifier should be fully namespaced and match a namespace:component
 *  combination of a component that has been registered with the Hub Framework.
 *
 *  If no component can be resolved for this identifier, a fallback one will be used.
 */
@property (nonatomic, copy, readonly) NSString *componentIdentifier;

@end

NS_ASSUME_NONNULL_END
