#import "HUBViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The @c HUBViewModelDiff class provides a way to visualise changes between
 * two different view models.
 */

@interface HUBViewModelDiff : NSObject

/// The index paths of any body components that were added in the new view model. 
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *insertedBodyComponentIndexPaths;

/// The index paths of any body components that were removed from the new view model. 
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *deletedBodyComponentIndexPaths;

/// The index paths of any body components that were modified in the new view model. 
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *reloadedBodyComponentIndexPaths;

/**
 * Initializes a @c HUBViewModelDiff using the two view models by finding the longest common subsequence
 * between the two models' body components.
 *
 * @param fromViewModel The view model that is being transitioned from.
 * @param toViewModel The view model that is being transitioned to.
 * 
 * @returns An instance of @c HUBViewModelDiff.
 */
+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
