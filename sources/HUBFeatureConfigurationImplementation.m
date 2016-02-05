#import "HUBFeatureConfigurationImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureConfigurationImplementation

@synthesize rootViewURI = _rootViewURI;
@synthesize contentProviderFactory = _contentProviderFactory;
@synthesize customJSONSchemaIdentifier = _customJSONSchemaIdentifier;
@synthesize viewURIQualifier = _viewURIQualifier;

- (instancetype)initWithRootViewURI:(NSURL *)rootViewURI contentProviderFactory:(id<HUBContentProviderFactory>)contentProviderFactory
{
    NSParameterAssert(rootViewURI != nil);
    NSParameterAssert(contentProviderFactory != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _rootViewURI = rootViewURI;
    _contentProviderFactory = contentProviderFactory;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
