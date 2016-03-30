#import "HUBContentProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content provider, for use in tests only
@interface HUBContentProviderMock : NSObject <HUBContentProvider>

/// A block that gets called whenever the content provider is asked to add initial content to a view model builder
@property (nonatomic, copy, nullable) void(^initialContentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// A block that gets called whenever the content provider is asked to load content
@property (nonatomic, copy, nullable) HUBContentProviderMode(^contentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// A block that gets called whenever the content provider is asked to load extension content
@property (nonatomic, copy, nullable) HUBContentProviderMode(^extensionContentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// Any previous content provider error that was passed to this content provider
@property (nonatomic, strong, readonly, nullable) NSError *previousContentProviderError;


@end

NS_ASSUME_NONNULL_END
