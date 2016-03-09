#import "HUBDefaultRemoteContentProviderFactory.h"
#import "HUBRemoteContentProviderFactory.h"
#import "HUBLocalContentProviderFactory.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content provider factory, for use in tests only
@interface HUBContentProviderFactoryMock : NSObject <HUBDefaultRemoteContentProviderFactory, HUBRemoteContentProviderFactory, HUBLocalContentProviderFactory>

/// The remote content provider that this factory always returns
@property (nonatomic, strong, nullable) id<HUBRemoteContentProvider> remoteContentProvider;

/// The local content provider that this factory always reeturns
@property (nonatomic, strong, nullable) id<HUBLocalContentProvider> localContentProvider;

@end

NS_ASSUME_NONNULL_END
