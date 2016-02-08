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
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _featureIdentifier = [featureIdentifier copy];
    _rootViewURI = rootViewURI;
    _contentProviderFactory = contentProviderFactory;
    _customJSONSchemaIdentifier = customJSONSchemaIdentifier;
    _viewURIQualifier = viewURIQualifier;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
