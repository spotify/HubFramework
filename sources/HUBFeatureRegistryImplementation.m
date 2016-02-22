#import "HUBFeatureRegistryImplementation.h"

#import "HUBFeatureConfigurationImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBViewURIQualifier.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBFeatureRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, HUBFeatureRegistration *> *registrationsByRootViewURI;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBFeatureRegistration *> *registrationsByIdentifier;

@end

@implementation HUBFeatureRegistryImplementation

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _registrationsByRootViewURI = [NSMutableDictionary new];
    _registrationsByIdentifier = [NSMutableDictionary new];
    
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
                                                    contentProviderFactory:(id<HUBContentProviderFactory>)contentProviderFactory
{
    return [[HUBFeatureConfigurationImplementation alloc] initWithFeatureIdentifier:featureIdentifier
                                                                        rootViewURI:rootViewURI
                                                             contentProviderFactory:contentProviderFactory];
}

- (void)registerFeatureWithConfiguration:(id<HUBFeatureConfiguration>)configuration
{
    NSAssert(self.registrationsByRootViewURI[configuration.rootViewURI] == nil,
             @"Attempted to register a Hub Framework feature for a root view URI that is already registered: %@",
             configuration.rootViewURI);
    
    NSAssert(self.registrationsByIdentifier[configuration.featureIdentifier] == nil,
             @"Attempted to register a Hub Framework feature for an identifier that is already registered: %@",
             configuration.featureIdentifier);
    
    HUBFeatureRegistration * const registration = [[HUBFeatureRegistration alloc] initWithFeatureIdentifier:configuration.featureIdentifier
                                                                                                rootViewURI:configuration.rootViewURI
                                                                                     contentProviderFactory:configuration.contentProviderFactory
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
