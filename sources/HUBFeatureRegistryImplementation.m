#import "HUBFeatureRegistryImplementation.h"

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
    self = [super init];
    
    if (self) {
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

- (void)registerFeatureWithIdentifier:(NSString *)featureIdentifier
                          rootViewURI:(NSURL *)rootViewURI
             contentProviderFactories:(NSArray<id<HUBContentProviderFactory>> *)contentProviderFactories
           customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                     viewURIQualifier:(nullable id<HUBViewURIQualifier>)viewURIQualifier
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(rootViewURI != nil);
    
    NSAssert(self.registrationsByIdentifier[featureIdentifier] == nil,
             @"Attempted to register a Hub Framework feature for an identifier that is already registered: %@",
             featureIdentifier);
    
    NSAssert(self.registrationsByRootViewURI[rootViewURI] == nil,
             @"Attempted to register a Hub Framework feature for a root view URI that is already registered: %@",
             rootViewURI);
    
    NSAssert(contentProviderFactories.count > 0,
             @"Attempted to register a Hub Framework feature without any content provider factories. Feature identifier: %@",
             featureIdentifier);
    
    HUBFeatureRegistration * const registration = [[HUBFeatureRegistration alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                rootViewURI:rootViewURI
                                                                                   contentProviderFactories:contentProviderFactories
                                                                                 customJSONSchemaIdentifier:customJSONSchemaIdentifier
                                                                                           viewURIQualifier:viewURIQualifier];
    
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
