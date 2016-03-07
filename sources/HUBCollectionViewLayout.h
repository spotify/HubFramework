#import <UIKit/UIKit.h>

@protocol HUBViewModel;
@protocol HUBComponentLayoutManager;
@class HUBComponentRegistryImplementation;

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
           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager NS_DESIGNATED_INITIALIZER;

/**
 *  Compute this layout for a given collection view size
 *
 *  @param collectionViewSize The size of the collection view that will use this layout
 */
- (void)computeForCollectionViewSize:(CGSize)collectionViewSize;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

/// This class cannot be initialized with a decoder
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
