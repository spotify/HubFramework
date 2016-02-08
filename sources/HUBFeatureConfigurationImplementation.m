#import "HUBFeatureConfigurationImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureConfigurationImplementation

@synthesize featureIdentifier = _featureIdentifier;
@synthesize rootViewURI = _rootViewURI;
@synthesize contentProviderFactory = _contentProviderFactory;
@synthesize customJSONSchemaIdentifier = _customJSONSchemaIdentifier;
@synthesize viewURIQualifier = _viewURIQualifier;

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                              rootViewURI:(NSURL *)rootViewURI
                   contentProviderFactory:(id<HUBContentProviderFactory>)contentProviderFactory
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(rootViewURI != nil);
    NSParameterAssert(contentProviderFactory != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _featureIdentifier = [featureIdentifier copy];
    _rootViewURI = [rootViewURI copy];
    _contentProviderFactory = contentProviderFactory;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
