#import "HUBContentOperationWithInitialContent.h"
#import "HUBContentOperationActionObserver.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content operation, for use in tests only
@interface HUBContentOperationMock : NSObject <HUBContentOperationWithInitialContent, HUBContentOperationActionObserver>

/// A block that gets called whenever the content operation is asked to add initial content to a view model builder.
@property (nonatomic, copy, nullable) void(^initialContentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// A block that gets called whenever the content operation is performed. Return whether the operation should call its delegate.
@property (nonatomic, copy, nullable) BOOL(^contentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// The number of times this operation has been performed
@property (nonatomic, assign, readonly) NSUInteger performCount;

/// The feature info that was most recently sent to this operation
@property (nonatomic, strong, readonly) id<HUBFeatureInfo> featureInfo;

/// The connectivity state that was most recently sent to this operation
@property (nonatomic, assign, readonly) HUBConnectivityState connectivityState;

/// Any previous content operation error that was passed to this content operation
@property (nonatomic, strong, readonly, nullable) NSError *previousContentOperationError;

/// Any action context that was most recently sent to this operation
@property (nonatomic, strong, readonly, nullable) id<HUBActionContext> actionContext;

/// Any error that the content operation should always produce
@property (nonatomic, strong, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
