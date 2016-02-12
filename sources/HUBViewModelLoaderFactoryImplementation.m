#import "HUBViewModelLoaderFactoryImplementation.h"

#import "HUBViewModelLoaderImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBContentProviderFactory.h"
#import "HUBJSONSchemaRegistryImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelLoaderFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, strong, readonly) HUBJSONSchemaRegistryImplementation *JSONSchemaRegistry;
@property (nonatomic, copy, readonly) NSString *defaultComponentNamespace;
@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;

@end

@implementation HUBViewModelLoaderFactoryImplementation

- (instancetype)initWithFeatureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
              defaultComponentNamespace:(NSString *)defaultComponentNamespace
              connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _featureRegistry = featureRegistry;
    _JSONSchemaRegistry = JSONSchemaRegistry;
    _defaultComponentNamespace = [defaultComponentNamespace copy];
    _connectivityStateResolver = connectivityStateResolver;
    
    return self;
}

#pragma mark - HUBViewModelLoaderFactory

- (nullable id<HUBViewModelLoader>)createViewModelLoaderForViewURI:(NSURL *)viewURI
{
    HUBFeatureRegistration * const featureRegistration = [self.featureRegistry featureRegistrationForViewURI:viewURI];
    
    if (featureRegistration == nil) {
        return nil;
    }
    
    id<HUBRemoteContentProvider> const remoteContentProvider = [featureRegistration.contentProviderFactory createRemoteContentProviderForViewURI:viewURI];
    id<HUBLocalContentProvider> const localContentProvider = [featureRegistration.contentProviderFactory createLocalContentProviderForViewURI:viewURI];
    
    if (remoteContentProvider == nil && localContentProvider == nil) {
        NSAssert(NO,
                 @"Attempted to create a view model loader for a feature that could not create any content providers. View URI: %@",
                 viewURI.absoluteString);
        
        return nil;
    }
    
    id<HUBJSONSchema> const JSONSchema = [self JSONSchemaForFeatureWithRegistration:featureRegistration];
    
    return [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                   featureIdentifier:featureRegistration.featureIdentifier
                                           defaultComponentNamespace:self.defaultComponentNamespace
                                               remoteContentProvider:remoteContentProvider
                                                localContentProvider:localContentProvider
                                                          JSONSchema:JSONSchema
                                           connectivityStateResolver:self.connectivityStateResolver];
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
