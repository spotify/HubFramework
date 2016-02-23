#import "HUBViewControllerFactoryImplementation.h"

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBImageLoaderFactory.h"
#import "HUBFeatureRegistration.h"
#import "HUBViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;
@property (nonatomic, strong, readonly) id<HUBImageLoaderFactory> imageLoaderFactory;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;

@end

@implementation HUBViewControllerFactoryImplementation

- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                            imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
{
    NSParameterAssert(viewModelLoaderFactory != nil);
    NSParameterAssert(imageLoaderFactory != nil);
    NSParameterAssert(componentRegistry != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _viewModelLoaderFactory = viewModelLoaderFactory;
    _imageLoaderFactory = imageLoaderFactory;
    _componentRegistry = componentRegistry;
    
    return self;
}

#pragma mark - HUBViewControllerFactory

- (nullable UIViewController *)createViewControllerForViewURI:(NSURL *)viewURI
{
    id<HUBViewModelLoader> const viewModelLoader = [self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI];
    
    if (viewModelLoader == nil) {
        return nil;
    }
    
    id<HUBImageLoader> const imageLoader = [self.imageLoaderFactory createImageLoader];
    
    return [[HUBViewController alloc] initWithViewModelLoader:viewModelLoader imageLoader:imageLoader componentRegistry:self.componentRegistry];
}

@end

NS_ASSUME_NONNULL_END
