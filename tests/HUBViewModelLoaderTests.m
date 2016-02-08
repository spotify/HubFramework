#import <XCTest/XCTest.h>

#import "HUBViewModelLoaderImplementation.h"
#import "HUBViewModelBuilder.h"
#import "HUBViewModel.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBRemoteContentProviderMock.h"
#import "HUBLocalContentProviderMock.h"
#import "HUBConnectivityStateResolverMock.h"

@interface HUBViewModelLoaderTests : XCTestCase <HUBViewModelLoaderDelegate>

@property (nonatomic, strong) HUBViewModelLoaderImplementation *loader;
@property (nonatomic, strong) HUBRemoteContentProviderMock *remoteContentProvider;
@property (nonatomic, strong) HUBLocalContentProviderMock *localContentProvider;
@property (nonatomic, strong) HUBConnectivityStateResolverMock *connectivityStateResolver;
@property (nonatomic, strong) id<HUBViewModel> viewModelFromSuccessDelegateMethod;
@property (nonatomic, strong) NSError *errorFromFailureDelegateMethod;

@end

@implementation HUBViewModelLoaderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.remoteContentProvider = [HUBRemoteContentProviderMock new];
    self.localContentProvider = [HUBLocalContentProviderMock new];
    self.connectivityStateResolver = [HUBConnectivityStateResolverMock new];
}

- (void)tearDown
{
    self.loader = nil;
    self.remoteContentProvider.data = nil;
    self.remoteContentProvider.error = nil;
    self.localContentProvider.contentLoadingBlock = nil;
    self.localContentProvider.error = nil;
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    self.viewModelFromSuccessDelegateMethod = nil;
    self.errorFromFailureDelegateMethod = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testSuccessfullyLoadingRemoteDictionaryContent
{
    [self createLoaderWithRemoteContentProvider:YES localContentProvider:NO connectivityState:HUBConnectivityStateOnline];
    self.remoteContentProvider.data = [NSJSONSerialization dataWithJSONObject:@{} options:(NSJSONWritingOptions)0 error:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertTrue(self.remoteContentProvider.called);
    XCTAssertNotNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testSuccessfullyLoadingRemoteArrayContent
{
    [self createLoaderWithRemoteContentProvider:YES localContentProvider:NO connectivityState:HUBConnectivityStateOnline];
    self.remoteContentProvider.data = [NSJSONSerialization dataWithJSONObject:@[] options:(NSJSONWritingOptions)0 error:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertTrue(self.remoteContentProvider.called);
    XCTAssertNotNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testUnexpectedRemoteContentTypeCausingError
{
    [self createLoaderWithRemoteContentProvider:YES localContentProvider:NO connectivityState:HUBConnectivityStateOnline];
    self.remoteContentProvider.data = [@"Clearly not JSON" dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.loader loadViewModel];
    
    XCTAssertTrue(self.remoteContentProvider.called);
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertNotNil(self.errorFromFailureDelegateMethod);
}

- (void)testRemoteContentLoadingError
{
    [self createLoaderWithRemoteContentProvider:YES localContentProvider:NO connectivityState:HUBConnectivityStateOnline];
    self.remoteContentProvider.error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertTrue(self.remoteContentProvider.called);
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertEqual(self.remoteContentProvider.error, self.errorFromFailureDelegateMethod);
}

- (void)testSucccessfullyLoadingLocalContent
{
    [self createLoaderWithRemoteContentProvider:NO localContentProvider:YES connectivityState:HUBConnectivityStateOnline];
    
    __block BOOL contentLoadingBlockCalled = NO;
    __block BOOL contentLoadingBlockCalledToLoadFallbackContent = NO;
    __weak __typeof(self) weakSelf = self;
    
    self.localContentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        
        contentLoadingBlockCalled = YES;
        contentLoadingBlockCalledToLoadFallbackContent = loadFallbackContent;
        id<HUBViewModelBuilder> const builder = [strongSelf.localContentProvider.delegate provideViewModelBuilderForLocalContentProvider:strongSelf.localContentProvider];
        [builder builderForBodyComponentModelWithIdentifier:@"component"];
    };
    
    [self.loader loadViewModel];
    
    XCTAssertTrue(contentLoadingBlockCalled);
    XCTAssertFalse(contentLoadingBlockCalledToLoadFallbackContent);
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
}

- (void)testLocalContentLoadingError
{
    [self createLoaderWithRemoteContentProvider:NO localContentProvider:YES connectivityState:HUBConnectivityStateOnline];
    self.localContentProvider.error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertEqual(self.localContentProvider.error, self.errorFromFailureDelegateMethod);
}

- (void)testManipulatingRemoteContentUsingLocalContentProvider
{
    [self createLoaderWithRemoteContentProvider:YES localContentProvider:YES connectivityState:HUBConnectivityStateOnline];
    
    NSString * const bodyComponentIdentifier = @"component";
    
    NSDictionary * const remoteContentDictionary = @{
        @"header": @{
            @"title": @"Remote content header title"
        },
        @"body": @[
            @{
                @"id": bodyComponentIdentifier,
                @"title": @"Local content body title"
            }
        ]
    };
    
    NSString * const localContentProviderAssignedComponentTitle = @"Local content title";
    
    __weak __typeof(self) weakSelf = self;
    
    self.remoteContentProvider.data = [NSJSONSerialization dataWithJSONObject:remoteContentDictionary options:(NSJSONWritingOptions)0 error:nil];
    self.localContentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBViewModelBuilder> const builder = [strongSelf.localContentProvider.delegate provideViewModelBuilderForLocalContentProvider:strongSelf.localContentProvider];
        builder.headerComponentModelBuilder.componentIdentifier = @"component";
        builder.headerComponentModelBuilder.title = localContentProviderAssignedComponentTitle;
        [builder builderForBodyComponentModelWithIdentifier:bodyComponentIdentifier].title = localContentProviderAssignedComponentTitle;
    };
    
    [self.loader loadViewModel];
    
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.headerComponentModel.title, localContentProviderAssignedComponentTitle);
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels firstObject].title, localContentProviderAssignedComponentTitle);
}

- (void)testUsingOnlyLocalContentProviderWhenOffline
{
    [self createLoaderWithRemoteContentProvider:YES localContentProvider:YES connectivityState:HUBConnectivityStateOffline];
    
    __weak __typeof(self) weakSelf = self;
    
    self.localContentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBViewModelBuilder> const builder = [strongSelf.localContentProvider.delegate provideViewModelBuilderForLocalContentProvider:strongSelf.localContentProvider];
        builder.headerComponentModelBuilder.componentIdentifier = @"component";
    };
    
    [self.loader loadViewModel];
    
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    XCTAssertFalse(self.remoteContentProvider.called);
    XCTAssertNotNil(self.viewModelFromSuccessDelegateMethod.headerComponentModel);
}

- (void)testSubsequentlyLoadedContentNotAppendedToViewModel
{
    [self createLoaderWithRemoteContentProvider:YES localContentProvider:YES connectivityState:HUBConnectivityStateOnline];
    
    __weak __typeof(self) weakSelf = self;
    
    self.remoteContentProvider.data = [NSJSONSerialization dataWithJSONObject:@{} options:(NSJSONWritingOptions)0 error:nil];
    self.localContentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBViewModelBuilder> const builder = [strongSelf.localContentProvider.delegate provideViewModelBuilderForLocalContentProvider:strongSelf.localContentProvider];
        [builder builderForBodyComponentModelWithIdentifier:@"componentA"].title = @"Component title";
    };
    
    [self.loader loadViewModel];
    
    self.localContentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBViewModelBuilder> const builder = [strongSelf.localContentProvider.delegate provideViewModelBuilderForLocalContentProvider:strongSelf.localContentProvider];
        [builder builderForBodyComponentModelWithIdentifier:@"componentB"].title = @"Component title";
    };
    
    [self.loader loadViewModel];
    
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels firstObject].identifier, @"componentB");
}

#pragma mark - HUBViewModelLoaderDelegate

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel
{
    XCTAssertNotNil(viewModel);
    self.viewModelFromSuccessDelegateMethod = viewModel;
}

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didFailLoadingWithError:(NSError *)error
{
    XCTAssertNotNil(error);
    self.errorFromFailureDelegateMethod = error;
}

#pragma mark - Utilities

- (void)createLoaderWithRemoteContentProvider:(BOOL)useRemoteContentProvider
                         localContentProvider:(BOOL)useLocalContentProvider
                            connectivityState:(HUBConnectivityState)connectivityState
{
    self.connectivityStateResolver.state = connectivityState;
    
    self.loader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:(NSURL *)[NSURL URLWithString:@"spotify:hub:test"]
                                                          featureIdentifier:@"feature"
                                                      remoteContentProvider:(useRemoteContentProvider ? self.remoteContentProvider : nil)
                                                       localContentProvider:(useLocalContentProvider ? self.localContentProvider : nil)
                                                                 JSONSchema:[HUBJSONSchemaImplementation new]
                                                  connectivityStateResolver:self.connectivityStateResolver];
    
    self.loader.delegate = self;
}

@end
