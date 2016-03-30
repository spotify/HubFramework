#import "HUBViewControllerFactoryImplementation.h"

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBImageLoaderFactory.h"
#import "HUBFeatureRegistration.h"
#import "HUBViewControllerImplementation.h"
#import "HUBCollectionViewFactory.h"
#import "HUBInitialViewModelRegistry.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;
@property (nonatomic, strong, readonly) id<HUBImageLoaderFactory> imageLoaderFactory;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;

@end

@implementation HUBViewControllerFactoryImplementation

- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                            imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                      initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                        componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
{
    NSParameterAssert(viewModelLoaderFactory != nil);
    NSParameterAssert(imageLoaderFactory != nil);
    NSParameterAssert(componentRegistry != nil);
    NSParameterAssert(componentLayoutManager != nil);
    
    self = [super init];
    
    if (self) {
        _viewModelLoaderFactory = viewModelLoaderFactory;
        _imageLoaderFactory = imageLoaderFactory;
        _componentRegistry = componentRegistry;
        _componentLayoutManager = componentLayoutManager;
        _initialViewModelRegistry = initialViewModelRegistry;
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
    id<HUBViewModelLoader> const viewModelLoader = [self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI];
    
    if (viewModelLoader == nil) {
        return nil;
    }
    
    id<HUBImageLoader> const imageLoader = [self.imageLoaderFactory createImageLoader];
    HUBCollectionViewFactory * const collectionViewFactory = [HUBCollectionViewFactory new];
    
    return [[HUBViewControllerImplementation alloc] initWithViewModelLoader:viewModelLoader
                                                                imageLoader:imageLoader
                                                      collectionViewFactory:collectionViewFactory
                                                          componentRegistry:self.componentRegistry
                                                     componentLayoutManager:self.componentLayoutManager
                                                   initialViewModelRegistry:self.initialViewModelRegistry];
}

@end

NS_ASSUME_NONNULL_END
