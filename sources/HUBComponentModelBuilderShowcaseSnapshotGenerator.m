#import "HUBComponentModelBuilderShowcaseSnapshotGenerator.h"

#import "HUBComponent.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentRegistryImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentModelBuilderShowcaseSnapshotGenerator ()

@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;

@end

@implementation HUBComponentModelBuilderShowcaseSnapshotGenerator

- (instancetype)initWithModelIdentifier:(nullable NSString *)modelIdentifier
                      featureIdentifier:(NSString *)featureIdentifier
                             JSONSchema:(id<HUBJSONSchema>)JSONSchema
                      componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                   mainImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)mainImageDataBuilder
             backgroundImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)backgroundImageDataBuilder
{
    NSParameterAssert(componentRegistry != nil);
    
    self = [super initWithModelIdentifier:modelIdentifier
                        featureIdentifier:featureIdentifier
                               JSONSchema:JSONSchema
                        componentDefaults:componentDefaults
                        iconImageResolver:iconImageResolver
                     mainImageDataBuilder:mainImageDataBuilder
               backgroundImageDataBuilder:backgroundImageDataBuilder];
    
    if (self) {
        _componentRegistry = componentRegistry;
    }
    
    return self;
}

#pragma mark - HUBComponentShowcaseSnapshotGenerator

- (UIImage *)generateShowcaseSnapshotForContainerViewSize:(CGSize)containerViewSize
{
    id<HUBComponentModel> const componentModel = [self buildForIndex:0];
    id<HUBComponent> const component = [self.componentRegistry createComponentForModel:componentModel];
    
    [component loadView];
    [component configureViewWithModel:componentModel];
    
    CGSize const preferredViewSize = [component preferredViewSizeForDisplayingModel:componentModel containerViewSize:containerViewSize];
    UIView * const componentView = component.view;
    componentView.frame = CGRectMake(0, 0, preferredViewSize.width, preferredViewSize.height);
    
    UIWindow * const window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, containerViewSize.width, containerViewSize.height)];
    [window addSubview:componentView];
    
    UIGraphicsBeginImageContextWithOptions(componentView.bounds.size, NO, 0);
    [componentView layoutIfNeeded];
    [componentView drawViewHierarchyInRect:componentView.bounds afterScreenUpdates:YES];
    UIImage * const snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [componentView removeFromSuperview];
    
    return snapshotImage;
}

@end

NS_ASSUME_NONNULL_END
