#import "HUBRemoteContentProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked remote content provider, for use in tests only
@interface HUBRemoteContentProviderMock : NSObject <HUBRemoteContentProvider>

/// Whether the content provider has been called to load content
@property (nonatomic, readonly) BOOL called;

/// Any data that the content provider is always returning. Is ignored if `error != nil`.
@property (nonatomic, strong, nullable) NSData *data;

/// Any eror that the content provider is always returning
@property (nonatomic, strong, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
