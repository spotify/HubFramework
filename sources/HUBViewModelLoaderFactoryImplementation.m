#import "HUBViewModelLoaderFactoryImplementation.h"

#import "HUBViewModelLoaderImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBContentOperationFactory.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelLoaderFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, strong, readonly) HUBJSONSchemaRegistryImplementation *JSONSchemaRegistry;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, nullable, readonly) id<HUBContentOperationFactory> prependedContentOperationFactory;
@property (nonatomic, strong, nullable, readonly) id<HUBContentOperationFactory> appendedContentOperationFactory;

@end

@implementation HUBViewModelLoaderFactoryImplementation

- (instancetype)initWithFeatureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
               initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
              connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                      iconImageResolver:(id<HUBIconImageResolver>)iconImageResolver
       prependedContentOperationFactory:(nullable id<HUBContentOperationFactory>)prependedContentOperationFactory
        appendedContentOperationFactory:(nullable id<HUBContentOperationFactory>)appendedContentOperationFactory
{
    self = [super init];
    
    if (self) {
        _featureRegistry = featureRegistry;
        _JSONSchemaRegistry = JSONSchemaRegistry;
        _initialViewModelRegistry = initialViewModelRegistry;
        _componentDefaults = componentDefaults;
        _connectivityStateResolver = connectivityStateResolver;
        _iconImageResolver = iconImageResolver;
        _prependedContentOperationFactory = prependedContentOperationFactory;
        _appendedContentOperationFactory = appendedContentOperationFactory;
    }
    
    return self;
}

#pragma mark - API

- (id<HUBViewModelLoader>)createViewModelLoaderForViewURI:(NSURL *)viewURI featureRegistration:(HUBFeatureRegistration *)featureRegistration
{
    NSMutableArray<id<HUBContentOperation>> * const allContentOperations = [NSMutableArray new];
    
    NSArray * const prependedContentOperations = [self.prependedContentOperationFactory createContentOperationsForViewURI:viewURI];
    
    if (prependedContentOperations != nil) {
        [allContentOperations addObjectsFromArray:prependedContentOperations];
    }
    
    for (id<HUBContentOperationFactory> const factory in featureRegistration.contentOperationFactories) {
        NSArray<id<HUBContentOperation>> * const contentOperations = [factory createContentOperationsForViewURI:viewURI];
        [allContentOperations addObjectsFromArray:contentOperations];
    }
    
    NSArray * const appendedContentOperations = [self.appendedContentOperationFactory createContentOperationsForViewURI:viewURI];
    
    if (appendedContentOperations != nil) {
        [allContentOperations addObjectsFromArray:appendedContentOperations];
    }
    
    if (allContentOperations.count == 0) {
        NSAssert(NO, @"No Hub Framework content operations were created for view URI: %@", viewURI);
        return nil;
    }
    
    id<HUBJSONSchema> const JSONSchema = [self JSONSchemaForFeatureWithRegistration:featureRegistration];
    id<HUBViewModel> const initialViewModel = [self.initialViewModelRegistry initialViewModelForViewURI:viewURI];
    
    return [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                   featureIdentifier:featureRegistration.featureIdentifier
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
