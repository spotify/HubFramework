#import "HUBViewControllerFactoryImplementation.h"

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;

@end

@implementation HUBViewControllerFactoryImplementation

- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
{
    NSParameterAssert(viewModelLoaderFactory != nil);
    NSParameterAssert(componentRegistry != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _viewModelLoaderFactory = viewModelLoaderFactory;
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
    
    return [[HUBViewController alloc] initWithViewModelLoader:viewModelLoader componentRegistry:self.componentRegistry];
}

@end

NS_ASSUME_NONNULL_END
