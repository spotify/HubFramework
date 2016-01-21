#import "HUBComponentImageDataBuilder.h"

@class HUBComponentImageDataImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentImageDataBuilder` API
@interface HUBComponentImageDataBuilderImplementation : NSObject <HUBComponentImageDataBuilder>

/**
 *  Build an instance of `HUBComponentImageDataImplementation` from the data contained in this builder
 */
- (HUBComponentImageDataImplementation *)build;

@end

NS_ASSUME_NONNULL_END
