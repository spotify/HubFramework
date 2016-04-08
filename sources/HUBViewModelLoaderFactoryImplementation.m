#import "HUBViewModelLoaderFactoryImplementation.h"

#import "HUBViewModelLoaderImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBContentProviderFactory.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBInitialViewModelRegistry.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelLoaderFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, strong, readonly) HUBJSONSchemaRegistryImplementation *JSONSchemaRegistry;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, copy, readonly) NSString *defaultComponentNamespace;
@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;

@end

@implementation HUBViewModelLoaderFactoryImplementation

- (instancetype)initWithFeatureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
               initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
              defaultComponentNamespace:(NSString *)defaultComponentNamespace
              connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
{
    self = [super init];
    
    if (self) {
        _featureRegistry = featureRegistry;
        _JSONSchemaRegistry = JSONSchemaRegistry;
        _initialViewModelRegistry = initialViewModelRegistry;
        _defaultComponentNamespace = [defaultComponentNamespace copy];
        _connectivityStateResolver = connectivityStateResolver;
    }
    
    return self;
}

#pragma mark - API

- (id<HUBViewModelLoader>)createViewModelLoaderForViewURI:(NSURL *)viewURI featureRegistration:(HUBFeatureRegistration *)featureRegistration
{
    NSMutableArray<id<HUBContentProvider>> * const allContentProviders = [NSMutableArray new];
    
    for (id<HUBContentProviderFactory> const factory in featureRegistration.contentProviderFactories) {
        NSArray<id<HUBContentProvider>> * const contentProviders = [factory createContentProvidersForViewURI:viewURI];
        [allContentProviders addObjectsFromArray:contentProviders];
    }
    
    if (allContentProviders.count == 0) {
        NSAssert(NO, @"No Hub Framework content providers were created for view URI: %@", viewURI);
        return nil;
    }
    
    id<HUBJSONSchema> const JSONSchema = [self JSONSchemaForFeatureWithRegistration:featureRegistration];
    id<HUBViewModel> const initialViewModel = [self.initialViewModelRegistry initialViewModelForViewURI:viewURI];
    
    return [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                   featureIdentifier:featureRegistration.featureIdentifier
                                           defaultComponentNamespace:self.defaultComponentNamespace
                                                    contentProviders:allContentProviders
                                                          JSONSchema:JSONSchema
                                           connectivityStateResolver:self.connectivityStateResolver
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
