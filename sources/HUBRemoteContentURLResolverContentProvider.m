#import "HUBRemoteContentURLResolverContentProvider.h"

#import "HUBRemoteContentURLResolver.h"
#import "HUBDataLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBRemoteContentURLResolverContentProvider () <HUBDataLoaderDelegate>

@property (nonatomic, strong, readonly) id<HUBRemoteContentURLResolver> URLResolver;
@property (nonatomic, strong, readonly) id<HUBDataLoader> dataLoader;
@property (nonatomic, copy, nullable) NSURL *currentDataURL;

@end

@implementation HUBRemoteContentURLResolverContentProvider

@synthesize delegate = _delegate;

- (instancetype)initWithURLResolver:(id<HUBRemoteContentURLResolver>)URLResolver
                         dataLoader:(id<HUBDataLoader>)dataLoader
{
    NSParameterAssert(URLResolver != nil);
    NSParameterAssert(dataLoader != nil);
    
    self = [super init];
    
    if (self) {
        _URLResolver = URLResolver;
        _dataLoader = dataLoader;
        _dataLoader.delegate = self;
    }
    
    return self;
}

#pragma mark - HUBRemoteContentProvider

- (void)loadContentForViewWithURI:(NSURL *)viewURI
{
    NSURL * const contentURL = [self.URLResolver resolveRemoteContentURLForViewURI:viewURI];
    
    if (contentURL == nil) {
        return;
    }
    
    [self loadContentFromURL:contentURL];
}

- (void)loadContentFromURL:(NSURL *)contentURL
{
    [self cancelCurrentDataLoadingOperation];
    self.currentDataURL = contentURL;
    [self.dataLoader loadDataForURL:contentURL];
}

#pragma mark - HUBDataLoaderDelegate

- (void)dataLoader:(id<HUBDataLoader>)dataLoader didLoadData:(NSData *)data forURL:(NSURL *)dataURL
{
    if (![self.currentDataURL isEqual:dataURL]) {
        return;
    }
    
    [self.delegate remoteContentProvider:self didLoadJSONData:data];
    self.currentDataURL = nil;
}

- (void)dataLoader:(id<HUBDataLoader>)imageLoader didFailLoadingDataForURL:(NSURL *)dataURL error:(NSError *)error
{
    if (![self.currentDataURL isEqual:dataURL]) {
        return;
    }
    
    [self.delegate remoteContentProvider:self didFailLoadingWithError:error];
    self.currentDataURL = nil;
}

#pragma mark - Private utilities

- (void)cancelCurrentDataLoadingOperation
{
    NSURL * const currentDataURL = self.currentDataURL;
    
    if (currentDataURL == nil) {
        return;
    }
    
    [self.dataLoader cancelLoadingDataForURL:currentDataURL];
    self.currentDataURL = nil;
}

@end

NS_ASSUME_NONNULL_END
