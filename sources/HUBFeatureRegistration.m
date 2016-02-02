#import "HUBFeatureRegistration.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureRegistration

- (instancetype)initWithRootViewURI:(NSURL *)rootViewURI contentProviderFactory:(id<HUBContentProviderFactory>)contentProviderFactory viewURIQualifier:(nullable id<HUBViewURIQualifier>)viewURIQualifier
{
    NSParameterAssert(rootViewURI != nil);
    NSParameterAssert(contentProviderFactory != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _rootViewURI = rootViewURI;
    _contentProviderFactory = contentProviderFactory;
    _viewURIQualifier = viewURIQualifier;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
