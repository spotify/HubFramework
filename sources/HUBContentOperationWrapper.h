#import "HUBContentOperation.h"
#import "HUBHeaderMacros.h"
#import "HUBConnectivityState.h"

@class HUBContentOperationWrapper;
@protocol HUBContentOperation;
@protocol HUBFeatureInfo;
@protocol HUBViewModelBuilder;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol for `HUBContentOperationWrapper`
@protocol HUBContentOperationWrapperDelegate <NSObject>

/**
 *  Notify the operation wrapper's delegate that the underlying operation finished
 *
 *  @param operationWrapper The operation wrapper in question
 */
- (void)contentOperationWrapperDidFinish:(HUBContentOperationWrapper *)operationWrapper;

/**
 *  Notify the operation wrapper's delegate that the underlying operation failed with an error
 *
 *  @param operationWrapper The operation wrapper in question
 *  @param error The error that the underlying operation encountered
 */
- (void)contentOperationWrapper:(HUBContentOperationWrapper *)operationWrapper didFailWithError:(NSError *)error;

/**
 *  Notify the operation wrapper's delegate that the underlying operation requires rescheduling
 *
 *  @param operationWrapper The operation wrapper in question
 */
- (void)contentOperationWrapperRequiresRescheduling:(HUBContentOperationWrapper *)operationWrapper;

@end

/// Class wrapping a `HUBContentOperation`, adding additional data used interally in the Hub Framework.
@interface HUBContentOperationWrapper : NSObject

/// The operation wrapper's delegate. See `HUBContentOperationWrapperDelegate` for more information.
@property (nonatomic, weak, nullable) id<HUBContentOperationWrapperDelegate> delegate;

/// The index of the operation in the content loading chain
@property (nonatomic, assign, readonly) NSUInteger index;

/**
 *  Initialize an instance of this class with a content operation and an index
 *
 *  @param contentOperation The contetn operation to wrap
 *  @param index The index of the operation in the content loading chain
 */
- (instancetype)initWithContentOperation:(id<HUBContentOperation>)contentOperation
                                   index:(NSUInteger)index HUB_DESIGNATED_INITIALIZER;

/**
 *  Perform the underlying operation
 *
 *  @param viewURI The URI of the view that the content operation is being used in
 *  @param featureInfo An object containing information about the feature that the operation is used in
 *  @param connectivityState The current connectivity state, as resolved by `HUBConnectivityStateResolver`
 *  @param viewModelBuilder The builder that should be used to add, change or remove content to/from the view
 *  @param previousError Any error encountered by a previous content operation, that the wrapper's operation
 *         may attempt to recover.
 */
- (void)performOperationForViewURI:(NSURL *)viewURI
                       featureInfo:(id<HUBFeatureInfo>)featureInfo
                 connectivityState:(HUBConnectivityState)connectivityState
                  viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
                     previousError:(nullable NSError *)previousError;

@end

NS_ASSUME_NONNULL_END
