#import "HUBFeatureRegistration.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureRegistration

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                              rootViewURI:(NSURL *)rootViewURI
                   contentProviderFactory:(id<HUBContentProviderFactory>)contentProviderFactory
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                         viewURIQualifier:(nullable id<HUBViewURIQualifier>)viewURIQualifier
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(rootViewURI != nil);
    NSParameterAssert(contentProviderFactory != nil);
    
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
        _rootViewURI = [rootViewURI copy];
        _contentProviderFactory = contentProviderFactory;
        _customJSONSchemaIdentifier = [customJSONSchemaIdentifier copy];
        _viewURIQualifier = viewURIQualifier;
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
