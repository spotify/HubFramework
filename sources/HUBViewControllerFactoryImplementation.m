#import "HUBViewControllerFactoryImplementation.h"

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBImageLoaderFactory.h"
#import "HUBFeatureRegistration.h"
#import "HUBViewControllerImplementation.h"
#import "HUBCollectionViewFactory.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentSelectionHandlerWrapper.h"
#import "HUBViewControllerDefaultScrollHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;
@property (nonatomic, strong, readonly) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly, nullable) id<HUBImageLoaderFactory> imageLoaderFactory;

@end

@implementation HUBViewControllerFactoryImplementation

- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                               featureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                      initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                        componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
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
    HUBCollectionViewFactory * const collectionViewFactory = [HUBCollectionViewFactory new];
    id<HUBComponentSelectionHandler> const componentSelectionHandler = [[HUBComponentSelectionHandlerWrapper alloc] initWithSelectionHandler:featureRegistration.componentSelectionHandler
                                                                                                                    initialViewModelRegistry:self.initialViewModelRegistry];
    
    id<HUBViewControllerScrollHandler> const scrollHandlerToUse = featureRegistration.viewControllerScrollHandler ?: [HUBViewControllerDefaultScrollHandler new];
    
    return [[HUBViewControllerImplementation alloc] initWithViewURI:viewURI
                                                  featureIdentifier:featureRegistration.featureIdentifier
                                                    viewModelLoader:viewModelLoader
                                              collectionViewFactory:collectionViewFactory
                                                  componentRegistry:self.componentRegistry
                                             componentLayoutManager:self.componentLayoutManager
                                          componentSelectionHandler:componentSelectionHandler
                                                      scrollHandler:scrollHandlerToUse
                                                             device:[UIDevice currentDevice]
                                                        imageLoader:imageLoader];
}

@end

NS_ASSUME_NONNULL_END
