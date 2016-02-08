#import "HUBLocalContentProvider.h"

/// Mock local content provider, for use in tests only
@interface HUBLocalContentProviderMock : NSObject <HUBLocalContentProvider>

/// A block that gets called whenever the content provider is asked to load content
@property (nonatomic, copy, nullable) void(^contentLoadingBlock)(BOOL loadFallbackContent);

/// Any eror that the content provider is always returning
@property (nonatomic, strong, nullable) NSError *error;

@end
