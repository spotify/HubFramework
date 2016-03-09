#import "HUBFeatureRegistration.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureRegistration

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                              rootViewURI:(NSURL *)rootViewURI
             remoteContentProviderFactory:(nullable id<HUBRemoteContentProviderFactory>)remoteContentProviderFactory
              localContentProviderFactory:(nullable id<HUBLocalContentProviderFactory>)localContentProviderFactory
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                         viewURIQualifier:(nullable id<HUBViewURIQualifier>)viewURIQualifier
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(rootViewURI != nil);
    NSParameterAssert(remoteContentProviderFactory != nil || localContentProviderFactory != nil);
    
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
        _rootViewURI = [rootViewURI copy];
        _remoteContentProviderFactory = remoteContentProviderFactory;
        _localContentProviderFactory = localContentProviderFactory;
        _customJSONSchemaIdentifier = [customJSONSchemaIdentifier copy];
        _viewURIQualifier = viewURIQualifier;
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
