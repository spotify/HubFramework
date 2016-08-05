#import <UIKit/UIKit.h>
#import "HUBHeaderMacros.h"

@protocol HUBViewModel;
@protocol HUBComponentLayoutManager;
@class HUBComponentRegistryImplementation;
@class HUBScrollBehaviorWrapper;

NS_ASSUME_NONNULL_BEGIN

/// Layout object used by collection views within the Hub Framework
@interface HUBCollectionViewLayout : UICollectionViewLayout

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewModel The view model to use to compute the layout
 *  @param componentRegistry The registry to use to retrieve components for calculations
 *  @param componentLayoutManager The manager responsible for component layout
 */
- (instancetype)initWithViewModel:(id<HUBViewModel>)viewModel
                componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                   scrollBehavior:(HUBScrollBehaviorWrapper *)scrollBehavior HUB_DESIGNATED_INITIALIZER;

/**
 *  Compute this layout for a given collection view size
 *
 *  @param collectionViewSize The size of the collection view that will use this layout
 */
- (void)computeForCollectionViewSize:(CGSize)collectionViewSize;

@end

NS_ASSUME_NONNULL_END
