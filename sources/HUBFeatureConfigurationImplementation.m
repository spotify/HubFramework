#import "HUBFeatureConfigurationImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureConfigurationImplementation

@synthesize featureIdentifier = _featureIdentifier;
@synthesize rootViewURI = _rootViewURI;
@synthesize contentProviderFactories = _contentProviderFactories;
@synthesize customJSONSchemaIdentifier = _customJSONSchemaIdentifier;
@synthesize viewURIQualifier = _viewURIQualifier;

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                              rootViewURI:(NSURL *)rootViewURI
                 contentProviderFactories:(NSArray<id<HUBContentProviderFactory>> *)contentProviderFactories
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(rootViewURI != nil);
    NSParameterAssert(contentProviderFactories != nil);
    
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
        _rootViewURI = [rootViewURI copy];
        _contentProviderFactories = [contentProviderFactories mutableCopy];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
