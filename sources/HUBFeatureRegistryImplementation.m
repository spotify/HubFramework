#import "HUBFeatureRegistryImplementation.h"

#import "HUBFeatureRegistration.h"
#import "HUBViewURIPredicate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBFeatureRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBFeatureRegistration *> *registrationsByIdentifier;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *registrationIdentifierOrder;

@end

@implementation HUBFeatureRegistryImplementation

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _registrationsByIdentifier = [NSMutableDictionary new];
        _registrationIdentifierOrder = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - API

- (nullable HUBFeatureRegistration *)featureRegistrationForViewURI:(NSURL *)viewURI
{
    for (NSString * const featureIdentifier in self.registrationIdentifierOrder) {
        HUBFeatureRegistration * const registration = self.registrationsByIdentifier[featureIdentifier];
        
        if ([registration.viewURIPredicate evaluateViewURI:viewURI]) {
            return registration;
        }
    }
    
    return nil;
}

#pragma mark - HUBFeatureRegistry

- (void)registerFeatureWithIdentifier:(NSString *)featureIdentifier
                     viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
             contentProviderFactories:(NSArray<id<HUBContentProviderFactory>> *)contentProviderFactories
           customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(viewURIPredicate != nil);
    
    NSAssert(self.registrationsByIdentifier[featureIdentifier] == nil,
             @"Attempted to register a Hub Framework feature for an identifier that is already registered: %@",
             featureIdentifier);
    
    NSAssert(contentProviderFactories.count > 0,
             @"Attempted to register a Hub Framework feature without any content provider factories. Feature identifier: %@",
             featureIdentifier);
    
    HUBFeatureRegistration * const registration = [[HUBFeatureRegistration alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                           viewURIPredicate:viewURIPredicate
                                                                                   contentProviderFactories:contentProviderFactories
                                                                                 customJSONSchemaIdentifier:customJSONSchemaIdentifier];
    
    self.registrationsByIdentifier[registration.featureIdentifier] = registration;
    [self.registrationIdentifierOrder addObject:registration.featureIdentifier];
}

- (void)unregisterFeatureWithIdentifier:(NSString *)featureIdentifier
{
    HUBFeatureRegistration * const registration = self.registrationsByIdentifier[featureIdentifier];
    
    if (registration == nil) {
        return;
    }
    
    self.registrationsByIdentifier[featureIdentifier] = nil;
}

@end

NS_ASSUME_NONNULL_END
