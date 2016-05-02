#import "HUBFeatureRegistration.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureRegistration

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                         viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                contentOperationFactories:(NSArray<id<HUBContentOperationFactory>> *)contentOperationFactories
                      contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(viewURIPredicate != nil);
    NSParameterAssert(contentOperationFactories.count > 0);
    
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
        _viewURIPredicate = viewURIPredicate;
        _contentOperationFactories = [contentOperationFactories copy];
        _contentReloadPolicy = contentReloadPolicy;
        _customJSONSchemaIdentifier = [customJSONSchemaIdentifier copy];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
