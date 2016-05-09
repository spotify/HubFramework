#import "HUBViewModelLoaderFactoryImplementation.h"

#import "HUBViewModelLoaderImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBContentOperationFactory.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentDefaults.h"
#import "HUBFeatureInfoImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelLoaderFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, strong, readonly) HUBJSONSchemaRegistryImplementation *JSONSchemaRegistry;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, readonly) id<HUBIconImageResolver> iconImageResolver;

@end

@implementation HUBViewModelLoaderFactoryImplementation

- (instancetype)initWithFeatureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
               initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
              connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                      iconImageResolver:(id<HUBIconImageResolver>)iconImageResolver
{
    self = [super init];
    
    if (self) {
        _featureRegistry = featureRegistry;
        _JSONSchemaRegistry = JSONSchemaRegistry;
        _initialViewModelRegistry = initialViewModelRegistry;
        _componentDefaults = componentDefaults;
        _connectivityStateResolver = connectivityStateResolver;
        _iconImageResolver = iconImageResolver;
    }
    
    return self;
}

#pragma mark - API

- (id<HUBViewModelLoader>)createViewModelLoaderForViewURI:(NSURL *)viewURI featureRegistration:(HUBFeatureRegistration *)featureRegistration
{
    id<HUBFeatureInfo> const featureInfo = [[HUBFeatureInfoImplementation alloc] initWithIdentifier:featureRegistration.featureIdentifier
                                                                                              title:featureRegistration.featureTitle];
    
    NSMutableArray<id<HUBContentOperation>> * const allContentOperations = [NSMutableArray new];
    
    for (id<HUBContentOperationFactory> const factory in featureRegistration.contentOperationFactories) {
        NSArray<id<HUBContentOperation>> * const contentOperations = [factory createContentOperationsForViewURI:viewURI];
        [allContentOperations addObjectsFromArray:contentOperations];
    }
    
    if (allContentOperations.count == 0) {
        NSAssert(NO, @"No Hub Framework content operations were created for view URI: %@", viewURI);
        return nil;
    }
    
    id<HUBJSONSchema> const JSONSchema = [self JSONSchemaForFeatureWithRegistration:featureRegistration];
    id<HUBViewModel> const initialViewModel = [self.initialViewModelRegistry initialViewModelForViewURI:viewURI];
    
    return [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                         featureInfo:featureInfo
                                                   contentOperations:allContentOperations
                                                          JSONSchema:JSONSchema
                                                   componentDefaults:self.componentDefaults
                                           connectivityStateResolver:self.connectivityStateResolver
                                                   iconImageResolver:self.iconImageResolver
                                                    initialViewModel:initialViewModel];
}

#pragma mark - HUBViewModelLoaderFactory

- (BOOL)canCreateViewModelLoaderForViewURI:(NSURL *)viewURI
{
    return [self.featureRegistry featureRegistrationForViewURI:viewURI] != nil;
}

- (nullable id<HUBViewModelLoader>)createViewModelLoaderForViewURI:(NSURL *)viewURI
{
    HUBFeatureRegistration * const featureRegistration = [self.featureRegistry featureRegistrationForViewURI:viewURI];
    
    if (featureRegistration == nil) {
        return nil;
    }
    
    return [self createViewModelLoaderForViewURI:viewURI featureRegistration:featureRegistration];
}

#pragma mark - Private utilities

- (id<HUBJSONSchema>)JSONSchemaForFeatureWithRegistration:(HUBFeatureRegistration *)featureRegistration
{
    NSString * const customJSONSchemaIdentifier = featureRegistration.customJSONSchemaIdentifier;
    
    if (customJSONSchemaIdentifier == nil) {
        return self.JSONSchemaRegistry.defaultSchema;
    }
    
    id<HUBJSONSchema> const customSchema = [self.JSONSchemaRegistry customSchemaForIdentifier:customJSONSchemaIdentifier];
    
    if (customSchema == nil) {
        return self.JSONSchemaRegistry.defaultSchema;
    }
    
    return customSchema;
}

@end

NS_ASSUME_NONNULL_END
