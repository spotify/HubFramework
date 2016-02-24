#import "HUBViewControllerFactory.h"

@class HUBViewModelLoaderFactoryImplementation;
@protocol HUBImageLoaderFactory;
@class HUBComponentRegistryImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewControllerFactory` API
@interface HUBViewControllerFactoryImplementation : NSObject <HUBViewControllerFactory>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewModelLoaderFactory The factory to use to create view model loaders
 *  @param imageLoaderFactory The factory to use to create image loaders
 *  @param componentRegistry The component registry to use in the view controllers that this factory creates
 */
- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                            imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
