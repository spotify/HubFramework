#import "HUBFeatureRegistration.h"

#import "HUBFeatureInfoImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureRegistration

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                                    title:(NSString *)featureTitle
                         viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                contentOperationFactories:(NSArray<id<HUBContentOperationFactory>> *)contentOperationFactories
                      contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                            actionHandler:(nullable id<HUBActionHandler>)actionHandler
              viewControllerScrollHandler:(nullable id<HUBViewControllerScrollHandler>)viewControllerScrollHandler
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(featureTitle != nil);
    NSParameterAssert(viewURIPredicate != nil);
    NSParameterAssert(contentOperationFactories.count > 0);
    
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
        _featureTitle = [featureTitle copy];
        _viewURIPredicate = viewURIPredicate;
        _contentOperationFactories = [contentOperationFactories copy];
        _contentReloadPolicy = contentReloadPolicy;
        _customJSONSchemaIdentifier = [customJSONSchemaIdentifier copy];
        _actionHandler = actionHandler;
        _viewControllerScrollHandler = viewControllerScrollHandler;
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
