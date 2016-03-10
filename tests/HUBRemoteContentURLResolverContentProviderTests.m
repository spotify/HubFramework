#import <XCTest/XCTest.h>

#import "HUBRemoteContentURLResolverContentProvider.h"
#import "HUBRemoteContentURLResolverMock.h"
#import "HUBDataLoaderMock.h"

@interface HUBRemoteContentURLResolverContentProviderTests : XCTestCase <HUBRemoteContentProviderDelegate>

@property (nonatomic, strong) HUBRemoteContentURLResolverMock *URLResolver;
@property (nonatomic, strong) HUBDataLoaderMock *dataLoader;
@property (nonatomic, strong) HUBRemoteContentURLResolverContentProvider *contentProvider;
@property (nonatomic, strong) NSData *loadedData;
@property (nonatomic, strong) NSError *encounteredError;

@end

@implementation HUBRemoteContentURLResolverContentProviderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.URLResolver = [HUBRemoteContentURLResolverMock new];
    self.URLResolver.contentURL = [NSURL URLWithString:@"https://spotify.content.url"];
    
    self.dataLoader = [[HUBDataLoaderMock alloc] initWithFeatureIdentifier:@"feature"];
    self.contentProvider = [[HUBRemoteContentURLResolverContentProvider alloc] initWithURLResolver:self.URLResolver
                                                                                        dataLoader:self.dataLoader];
    
    self.contentProvider.delegate = self;
}

#pragma mark - Tests

- (void)testURLResolverUsed
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    [self.contentProvider loadContentForViewWithURI:viewURI];
    
    XCTAssertEqualObjects(self.URLResolver.viewURIs, [NSSet setWithObject:viewURI]);
    XCTAssertEqualObjects(self.dataLoader.currentDataURL, self.URLResolver.contentURL);
}

- (void)testSuccessfullyLoadingData
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    [self.contentProvider loadContentForViewWithURI:viewURI];
    
    NSData * const loadedData = [@"content data" dataUsingEncoding:NSUTF8StringEncoding];
    [self.dataLoader.delegate dataLoader:self.dataLoader didLoadData:loadedData forURL:self.URLResolver.contentURL];
    
    XCTAssertEqualObjects(self.loadedData, loadedData);
}

- (void)testErrorReporting
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    [self.contentProvider loadContentForViewWithURI:viewURI];
    
    NSError * const error = [NSError errorWithDomain:@"hubFramework" code:23 userInfo:nil];
    [self.dataLoader.delegate dataLoader:self.dataLoader didFailLoadingDataForURL:self.URLResolver.contentURL error:error];
    
    XCTAssertEqualObjects(self.encounteredError, error);
}

#pragma mark - HUBRemoteContentProviderDelegate

- (void)remoteContentProvider:(id<HUBRemoteContentProvider>)contentProvider didLoadJSONData:(NSData *)JSONData
{
    self.loadedData = JSONData;
}

- (void)remoteContentProvider:(id<HUBRemoteContentProvider>)contentProvider didFailLoadingWithError:(NSError *)error
{
    self.encounteredError = error;
}

@end
