#import "HUBFeatureRegistryImplementation.h"

#import "HUBFeatureConfigurationImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBViewURIQualifier.h"
#import "HUBRemoteContentURLResolverContentProviderFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBFeatureRegistryImplementation ()

@property (nonatomic, strong, readonly) id<HUBDataLoaderFactory> dataLoaderFactory;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, HUBFeatureRegistration *> *registrationsByRootViewURI;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBFeatureRegistration *> *registrationsByIdentifier;

@end

@implementation HUBFeatureRegistryImplementation

- (instancetype)initWithDataLoaderFactory:(id<HUBDataLoaderFactory>)dataLoaderFactory
{
    NSParameterAssert(dataLoaderFactory != nil);
    
    self = [super init];
    
    if (self) {
        _dataLoaderFactory = dataLoaderFactory;
        _registrationsByRootViewURI = [NSMutableDictionary new];
        _registrationsByIdentifier = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (nullable HUBFeatureRegistration *)featureRegistrationForViewURI:(NSURL *)viewURI
{
    HUBFeatureRegistration * const exactMatch = self.registrationsByRootViewURI[viewURI];
    
    if (exactMatch != nil && [self qualifyViewURI:viewURI forFeatureWithRegistration:exactMatch]) {
        return exactMatch;
    }
    
    for (HUBFeatureRegistration * const registration in self.registrationsByRootViewURI.allValues) {
        if (![viewURI.absoluteString hasPrefix:registration.rootViewURI.absoluteString]) {
            continue;
        }
        
        if ([self qualifyViewURI:viewURI forFeatureWithRegistration:registration]) {
            return registration;
        }
    }
    
    return nil;
}

#pragma mark - HUBFeatureRegistry

- (id<HUBFeatureConfiguration>)createConfigurationForFeatureWithIdentifier:(NSString *)featureIdentifier
                                                               rootViewURI:(NSURL *)rootViewURI
                                                  remoteContentURLResolver:(id<HUBRemoteContentURLResolver>)remoteContentURLResolver
{
    id<HUBFeatureConfiguration> const featureConfiguration = [[HUBFeatureConfigurationImplementation alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                                          rootViewURI:rootViewURI];
    
    featureConfiguration.remoteContentURLResolver = remoteContentURLResolver;
    return featureConfiguration;
}

- (id<HUBFeatureConfiguration>)createConfigurationForFeatureWithIdentifier:(NSString *)featureIdentifier
                                                               rootViewURI:(NSURL *)rootViewURI
                                              remoteContentProviderFactory:(nullable id<HUBRemoteContentProviderFactory>)remoteContentProviderFactory
                                               localContentProviderFactory:(nullable id<HUBLocalContentProviderFactory>)localContentProviderFactory
{
    id<HUBFeatureConfiguration> const featureConfiguration = [[HUBFeatureConfigurationImplementation alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                                          rootViewURI:rootViewURI];
    
    featureConfiguration.remoteContentProviderFactory = remoteContentProviderFactory;
    featureConfiguration.localContentProviderFactory = localContentProviderFactory;
    return featureConfiguration;
}

- (void)registerFeatureWithConfiguration:(id<HUBFeatureConfiguration>)configuration
{
    NSAssert(self.registrationsByRootViewURI[configuration.rootViewURI] == nil,
             @"Attempted to register a Hub Framework feature for a root view URI that is already registered: %@",
             configuration.rootViewURI);
    
    NSAssert(self.registrationsByIdentifier[configuration.featureIdentifier] == nil,
             @"Attempted to register a Hub Framework feature for an identifier that is already registered: %@",
             configuration.featureIdentifier);
    
    id<HUBRemoteContentURLResolver> const remoteContentURLResolver = configuration.remoteContentURLResolver;
    id<HUBRemoteContentProviderFactory> remoteContentProviderFactory = configuration.remoteContentProviderFactory;
    
    if (remoteContentURLResolver != nil) {
        NSAssert(remoteContentProviderFactory == nil,
                 @"Attempted to register a Hub Framework feature with both a remote content factory & URL resolver. Feature identifier: %@",
                 configuration.featureIdentifier);
        
        remoteContentProviderFactory = [[HUBRemoteContentURLResolverContentProviderFactory alloc] initWithURLResolver:remoteContentURLResolver
                                                                                                    featureIdentifier:configuration.featureIdentifier
                                                                                                    dataLoaderFactory:self.dataLoaderFactory];
    }
    
    NSAssert(remoteContentProviderFactory != nil || configuration.localContentProviderFactory != nil,
             @"Attempted to register a Hub Framework feature without either a remote or local content provider. Feature identifier: %@",
             configuration.featureIdentifier);
    
    HUBFeatureRegistration * const registration = [[HUBFeatureRegistration alloc] initWithFeatureIdentifier:configuration.featureIdentifier
                                                                                                rootViewURI:configuration.rootViewURI
                                                                               remoteContentProviderFactory:remoteContentProviderFactory
                                                                                localContentProviderFactory:configuration.localContentProviderFactory
                                                                                 customJSONSchemaIdentifier:configuration.customJSONSchemaIdentifier
                                                                                           viewURIQualifier:configuration.viewURIQualifier];
    
    self.registrationsByRootViewURI[registration.rootViewURI] = registration;
    self.registrationsByIdentifier[registration.featureIdentifier] = registration;
}

- (void)unregisterFeatureWithIdentifier:(NSString *)featureIdentifier
{
    HUBFeatureRegistration * const registration = self.registrationsByIdentifier[featureIdentifier];
    
    if (registration == nil) {
        return;
    }
    
    self.registrationsByIdentifier[featureIdentifier] = nil;
    self.registrationsByRootViewURI[registration.rootViewURI] = nil;
}

#pragma mark - Private utilities

- (BOOL)qualifyViewURI:(NSURL *)viewURI forFeatureWithRegistration:(HUBFeatureRegistration *)registration
{
    if (registration.viewURIQualifier == nil) {
        return YES;
    }
    
    return [registration.viewURIQualifier qualifyViewURI:viewURI];
}

@end

NS_ASSUME_NONNULL_END
