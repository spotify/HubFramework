#import "HUBComponentFallbackHandler.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked component fallback handler, for use in tests only
@interface HUBComponentFallbackHandlerMock : NSObject <HUBComponentFallbackHandler>

/// The namespace of the component identifier that this mock is always returning
@property (nonatomic, copy, readonly) NSString *fallbackComponentNamespace;

/// The fallback component identifier that this mock is always returning
@property (nonatomic, copy, readonly) NSString *fallbackComponentIdentifier;

@end

NS_ASSUME_NONNULL_END
