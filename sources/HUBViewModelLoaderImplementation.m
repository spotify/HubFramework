#import "HUBViewModelLoaderImplementation.h"

#import "HUBConnectivityStateResolver.h"
#import "HUBRemoteContentProvider.h"
#import "HUBLocalContentProvider.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelLoaderImplementation () <HUBRemoteContentProviderDelegate, HUBLocalContentProviderDelegate>

@property (nonatomic, copy, readonly) NSURL *viewURI;
@property (nonatomic, copy, readonly) NSString *featureIdentifier;
@property (nonatomic, copy, readonly) NSString *defaultComponentNamespace;
@property (nonatomic, strong, readonly, nullable) id<HUBRemoteContentProvider> remoteContentProvider;
@property (nonatomic, strong, readonly, nullable) id<HUBLocalContentProvider> localContentProvider;
@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *builder;

@end

@implementation HUBViewModelLoaderImplementation

@synthesize delegate = _delegate;

#pragma mark - Public API

- (instancetype)initWithViewURI:(NSURL *)viewURI
              featureIdentifier:(NSString *)featureIdentifier
      defaultComponentNamespace:(NSString *)defaultComponentNamespace
          remoteContentProvider:(nullable id<HUBRemoteContentProvider>)remoteContentProvider
           localContentProvider:(nullable id<HUBLocalContentProvider>)localContentProvider
                     JSONSchema:(id<HUBJSONSchema>)JSONSchema
      connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
{
    NSParameterAssert(viewURI != nil);
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(defaultComponentNamespace != nil);
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(connectivityStateResolver != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _viewURI = [viewURI copy];
    _featureIdentifier = [featureIdentifier copy];
    _defaultComponentNamespace = [defaultComponentNamespace copy];
    _remoteContentProvider = remoteContentProvider;
    _localContentProvider = localContentProvider;
    _JSONSchema = JSONSchema;
    _connectivityStateResolver = connectivityStateResolver;
    
    _remoteContentProvider.delegate = self;
    _localContentProvider.delegate = self;
    
    return self;
}

#pragma mark - HUBViewModelLoader

- (void)loadViewModel
{
    self.builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier
                                                              defaultComponentNamespace:self.defaultComponentNamespace];
    
    switch ([self.connectivityStateResolver resolveConnectivityState]) {
        case HUBConnectivityStateOnline: {
            if (self.remoteContentProvider != nil) {
                [self.remoteContentProvider loadContentForViewWithURI:self.viewURI];
            } else {
                [self remoteContentPhaseCompletedWithError:nil];
            }
            
            break;
        }
        case HUBConnectivityStateOffline:
            [self remoteContentPhaseCompletedWithError:nil];
            break;
    }
}

#pragma mark - HUBRemoteContentProviderDelegate

- (void)remoteContentProvider:(id<HUBRemoteContentProvider>)contentProvider didLoadJSONData:(NSData *)JSONData
{
    NSError *JSONError;
    NSObject *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&JSONError];
    
    if (JSONError || JSONObject == nil) {
        [self remoteContentProvider:contentProvider didFailLoadingWithError:JSONError];
        return;
    }
    
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        [self.builder addDataFromJSONDictionary:(NSDictionary *)JSONObject usingSchema:self.JSONSchema];
    } else if ([JSONObject isKindOfClass:[NSArray class]]) {
        [self.builder addDataFromJSONArray:(NSArray *)JSONObject usingSchema:self.JSONSchema];
    } else {
        NSError * const invalidJSONTypeError = [NSError errorWithDomain:@"spotify.com.hubFramework.invalidJSON" code:0 userInfo:nil];
        [self remoteContentProvider:contentProvider didFailLoadingWithError:invalidJSONTypeError];
        return;
    }
    
    [self remoteContentPhaseCompletedWithError:nil];
}

- (void)remoteContentProvider:(id<HUBRemoteContentProvider>)contentProvider didFailLoadingWithError:(NSError *)error
{
    [self remoteContentPhaseCompletedWithError:error];
}

#pragma mark - HUBLocalContentProviderDelegate

- (id<HUBViewModelBuilder>)provideViewModelBuilderForLocalContentProvider:(id<HUBLocalContentProvider>)contentProvider
{
    if (self.builder == nil) {
        self.builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier
                                                                  defaultComponentNamespace:self.defaultComponentNamespace];
    }
    
    return (id<HUBViewModelBuilder>)self.builder;
}

- (void)localContentProviderDidLoad:(id<HUBLocalContentProvider>)contentProvider
{
    [self allPhasesCompletedWithError:nil];
}

- (void)localContentProvider:(id<HUBLocalContentProvider>)contentProvider didFailLoadingWithError:(NSError *)error
{
    [self allPhasesCompletedWithError:error];
}

#pragma mark - Private utilities

- (void)remoteContentPhaseCompletedWithError:(nullable NSError *)error
{
    if (self.localContentProvider == nil) {
        [self allPhasesCompletedWithError:error];
    } else {
        [self.localContentProvider loadContentForViewWithURI:self.viewURI];
    }
}

- (void)allPhasesCompletedWithError:(nullable NSError *)error
{
    id<HUBViewModelLoaderDelegate> const delegate = self.delegate;
    
    if (delegate == nil) {
        return;
    }
    
    if (error == nil) {
        if (self.builder == nil) {
            return;
        }
        
        id<HUBViewModel> const viewModel = [self.builder build];
        [delegate viewModelLoader:self didLoadViewModel:viewModel];
    } else {
        NSError * const nonNilError = error;
        [delegate viewModelLoader:self didFailLoadingWithError:nonNilError];
    }
}

@end

NS_ASSUME_NONNULL_END
