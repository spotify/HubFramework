#import "HUBViewControllerFactoryImplementation.h"

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBImageLoaderFactory.h"
#import "HUBFeatureRegistration.h"
#import "HUBViewControllerImplementation.h"
#import "HUBCollectionViewFactory.h"
#import "HUBInitialViewModelRegistry.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;
@property (nonatomic, strong, readonly) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly, nullable) id<HUBContentReloadPolicy> defaultContentReloadPolicy;
@property (nonatomic, strong, readonly, nullable) id<HUBImageLoaderFactory> imageLoaderFactory;

@end

@implementation HUBViewControllerFactoryImplementation

- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                               featureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                      initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                        componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                    defaultContentReloadPolicy:(nullable id<HUBContentReloadPolicy>)defaultContentReloadPolicy
                            imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory
{
    NSParameterAssert(viewModelLoaderFactory != nil);
    NSParameterAssert(featureRegistry != nil);
    NSParameterAssert(componentRegistry != nil);
    NSParameterAssert(initialViewModelRegistry != nil);
    NSParameterAssert(componentLayoutManager != nil);
    
    self = [super init];
    
    if (self) {
        _viewModelLoaderFactory = viewModelLoaderFactory;
        _featureRegistry = featureRegistry;
        _componentRegistry = componentRegistry;
        _initialViewModelRegistry = initialViewModelRegistry;
        _defaultContentReloadPolicy = defaultContentReloadPolicy;
        _componentLayoutManager = componentLayoutManager;
        _imageLoaderFactory = imageLoaderFactory;
    }
    
    return self;
}

#pragma mark - HUBViewControllerFactory

- (BOOL)canCreateViewControllerForViewURI:(NSURL *)viewURI
{
    return [self.viewModelLoaderFactory canCreateViewModelLoaderForViewURI:viewURI];
}

- (nullable UIViewController<HUBViewController> *)createViewControllerForViewURI:(NSURL *)viewURI
{
    HUBFeatureRegistration * const featureRegistration = [self.featureRegistry featureRegistrationForViewURI:viewURI];
    
    if (featureRegistration == nil) {
        return nil;
    }
    
    id<HUBViewModelLoader> const viewModelLoader = [self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI
                                                                                            featureRegistration:featureRegistration];
    
    id<HUBImageLoader> const imageLoader = [self.imageLoaderFactory createImageLoader];
    id<HUBContentReloadPolicy> const contentReloadPolicy = featureRegistration.contentReloadPolicy ?: self.defaultContentReloadPolicy;
    HUBCollectionViewFactory * const collectionViewFactory = [HUBCollectionViewFactory new];
    
    return [[HUBViewControllerImplementation alloc] initWithViewURI:viewURI
                                                    viewModelLoader:viewModelLoader
                                              collectionViewFactory:collectionViewFactory
                                                  componentRegistry:self.componentRegistry
                                             componentLayoutManager:self.componentLayoutManager
                                           initialViewModelRegistry:self.initialViewModelRegistry
                                                             device:[UIDevice currentDevice]
                                                contentReloadPolicy:contentReloadPolicy
                                                        imageLoader:imageLoader];
}

@end

NS_ASSUME_NONNULL_END
