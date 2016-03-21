#import "HUBRemoteContentURLResolverContentProviderFactory.h"

#import "HUBDataLoaderFactory.h"
#import "HUBRemoteContentURLResolverContentProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBRemoteContentURLResolverContentProviderFactory ()

@property (nonatomic, strong, readonly) id<HUBRemoteContentURLResolver> URLResolver;
@property (nonatomic, copy, readonly) NSString *featureIdentifier;
@property (nonatomic, strong, readonly) id<HUBDataLoaderFactory> dataLoaderFactory;

@end

@implementation HUBRemoteContentURLResolverContentProviderFactory

- (instancetype)initWithURLResolver:(id<HUBRemoteContentURLResolver>)URLResolver
                  featureIdentifier:(NSString *)featureIdentifier
                  dataLoaderFactory:(id<HUBDataLoaderFactory>)dataLoaderFactory
{
    NSParameterAssert(URLResolver != nil);
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(dataLoaderFactory != nil);
    
    self = [super init];
    
    if (self) {
        _URLResolver = URLResolver;
        _featureIdentifier = [featureIdentifier copy];
        _dataLoaderFactory = dataLoaderFactory;
    }
    
    return self;
}

#pragma mark - HUBRemoteContentProviderFactory

- (nullable id<HUBRemoteContentProvider>)createRemoteContentProviderForViewURI:(NSURL *)viewURI
{
    id<HUBDataLoader> const dataLoader = [self.dataLoaderFactory createDataLoaderForFeatureWithIdentifier:self.featureIdentifier];
    
    return [[HUBRemoteContentURLResolverContentProvider alloc] initWithURLResolver:self.URLResolver
                                                                        dataLoader:dataLoader];
}

@end

NS_ASSUME_NONNULL_END
