#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol defining the public API of a Hub Framework component model. To be implemented.
@protocol HUBComponentModel <NSObject>

/// The identifier of the component to render the model using
@property (nonatomic, copy, readonly) NSString *componentIdentifier;

@end

NS_ASSUME_NONNULL_END
