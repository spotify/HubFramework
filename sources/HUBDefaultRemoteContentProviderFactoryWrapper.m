#import "HUBDefaultRemoteContentProviderFactoryWrapper.h"

#import "HUBDefaultRemoteContentProviderFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBDefaultRemoteContentProviderFactoryWrapper ()

@property (nonatomic, strong, readonly) id<HUBDefaultRemoteContentProviderFactory> defaultRemoteContentProviderFactory;
@property (nonatomic, strong, readonly) id<HUBRemoteContentURLResolver> remoteContentURLResolver;
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

@end

@implementation HUBDefaultRemoteContentProviderFactoryWrapper

- (instancetype)initWithDefaultRemoteContentProviderFactory:(id<HUBDefaultRemoteContentProviderFactory>)defaultRemoteContentProviderFactory
                                                URLResolver:(id<HUBRemoteContentURLResolver>)URLResolver
                                          featureIdentifier:(NSString *)featureIdentifier
{
    self = [super init];
    
    if (self) {
        _defaultRemoteContentProviderFactory = defaultRemoteContentProviderFactory;
        _remoteContentURLResolver = URLResolver;
        _featureIdentifier = [featureIdentifier copy];
    }
    
    return self;
}

#pragma mark - HUBRemoteContentProviderFactory

- (nullable id<HUBRemoteContentProvider>)createRemoteContentProviderForViewURI:(NSURL *)viewURI
{
    return [self.defaultRemoteContentProviderFactory createRemoteContentProviderForViewURI:viewURI
                                                                         featureIdentifier:self.featureIdentifier
                                                                  remoteContentURLResolver:self.remoteContentURLResolver];
}

@end

NS_ASSUME_NONNULL_END
