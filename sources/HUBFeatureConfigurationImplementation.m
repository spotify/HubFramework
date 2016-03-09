#import "HUBFeatureConfigurationImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureConfigurationImplementation

@synthesize featureIdentifier = _featureIdentifier;
@synthesize rootViewURI = _rootViewURI;
@synthesize remoteContentURLResolver = _remoteContentURLResolver;
@synthesize remoteContentProviderFactory = _remoteContentProviderFactory;
@synthesize localContentProviderFactory = _localContentProviderFactory;
@synthesize customJSONSchemaIdentifier = _customJSONSchemaIdentifier;
@synthesize viewURIQualifier = _viewURIQualifier;

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier rootViewURI:(NSURL *)rootViewURI
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(rootViewURI != nil);
    
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
        _rootViewURI = [rootViewURI copy];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
