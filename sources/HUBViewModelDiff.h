#import "HUBViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The @c HUBViewModelDiff class provides a way to visualise changes between
 * two different view models.
 */

@interface HUBViewModelDiff : NSObject

@property (nonatomic, strong, readonly) NSIndexSet *insertedIndices;
@property (nonatomic, strong, readonly) NSIndexSet *deletedIndices;
@property (nonatomic, strong, readonly) NSIndexSet *reloadedIndices;

+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel;

@end


NS_ASSUME_NONNULL_END
