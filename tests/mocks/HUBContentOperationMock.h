#import "HUBContentOperation.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content operation, for use in tests only
@interface HUBContentOperationMock : NSObject <HUBContentOperation>

/// A block that gets called whenever the content operation is asked to add initial content to a view model builder
@property (nonatomic, copy, nullable) void(^initialContentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// A block that gets called whenever the content operation is asked to load content
@property (nonatomic, copy, nullable) HUBContentOperationMode(^contentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// A block that gets called whenever the content operation is asked to load extension content
@property (nonatomic, copy, nullable) HUBContentOperationMode(^extensionContentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// Any previous content operation error that was passed to this content operation
@property (nonatomic, strong, readonly, nullable) NSError *previousContentOperationError;


@end

NS_ASSUME_NONNULL_END
