#import "HUBFeatureRegistration.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureRegistration

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                         viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                 contentProviderFactories:(NSArray<id<HUBContentProviderFactory>> *)contentProviderFactories
                      contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(viewURIPredicate != nil);
    NSParameterAssert(contentProviderFactories.count > 0);
    
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
        _viewURIPredicate = viewURIPredicate;
        _contentProviderFactories = [contentProviderFactories copy];
        _contentReloadPolicy = contentReloadPolicy;
        _customJSONSchemaIdentifier = [customJSONSchemaIdentifier copy];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
