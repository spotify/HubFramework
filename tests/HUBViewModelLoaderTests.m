#import <XCTest/XCTest.h>

#import "HUBViewModelLoaderImplementation.h"
#import "HUBViewModelBuilder.h"
#import "HUBViewModelImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBComponentIdentifier.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBContentProviderMock.h"
#import "HUBConnectivityStateResolverMock.h"

@interface HUBViewModelLoaderTests : XCTestCase <HUBViewModelLoaderDelegate>

@property (nonatomic, strong) HUBViewModelLoaderImplementation *loader;
@property (nonatomic, strong) HUBConnectivityStateResolverMock *connectivityStateResolver;
@property (nonatomic, strong) id<HUBViewModel> viewModelFromSuccessDelegateMethod;
@property (nonatomic, strong) NSError *errorFromFailureDelegateMethod;

@end

@implementation HUBViewModelLoaderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.connectivityStateResolver = [HUBConnectivityStateResolverMock new];
}

- (void)tearDown
{
    self.loader = nil;
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    self.viewModelFromSuccessDelegateMethod = nil;
    self.errorFromFailureDelegateMethod = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testInitialViewModel
{
    __block NSUInteger numberOfInitialViewModelRequests = 0;
    
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    contentProvider.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        numberOfInitialViewModelRequests++;
    };
    
    [self createLoaderWithContentProviders:@[contentProvider]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationBarTitle, @"A title");
    
    // The initial view model should now be cached, so accessing it shouldn't increment the request count
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationBarTitle, @"A title");
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationBarTitle, @"A title");
    
    XCTAssertEqual(numberOfInitialViewModelRequests, (NSUInteger)1);
}

- (void)testInjectedInitialViewModelUsedInsteadOfContentProviders
{
    NSString * const defaultComponentNamespace = @"namespace";
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:defaultComponentNamespace];
    HUBViewModelBuilderImplementation * const viewModelBuilder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                                           JSONSchema:JSONSchema defaultComponentNamespace:defaultComponentNamespace];
    
    viewModelBuilder.navigationBarTitle = @"Pre-computed title";
    id<HUBViewModel> const initialViewModel = [viewModelBuilder build];
    
    __block BOOL contentProviderCalled = NO;
    
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    contentProvider.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        contentProviderCalled = YES;
    };
    
    [self createLoaderWithContentProviders:@[contentProvider]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:initialViewModel];
    
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationBarTitle, @"Pre-computed title");
    XCTAssertFalse(contentProviderCalled);
}

- (void)testSuccessfullyLoadingViewModel
{
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        return HUBContentProviderModeSynchronous;
    };
    
    [self createLoaderWithContentProviders:@[contentProvider]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    [self.loader loadViewModel];
    [contentProvider.delegate contentProviderDidFinishLoading:contentProvider];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testSingleContentProviderError
{
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    
    contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        return HUBContentProviderModeAsynchronous;
    };
    
    [self createLoaderWithContentProviders:@[contentProvider]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentProvider.delegate contentProvider:contentProvider didFailLoadingWithError:error];
    
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertEqual(error, self.errorFromFailureDelegateMethod);
}

- (void)testContentProviderErrorRecovery
{
    HUBContentProviderMock * const contentProviderA = [HUBContentProviderMock new];
    HUBContentProviderMock * const contentProviderB = [HUBContentProviderMock new];
    
    contentProviderA.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        return HUBContentProviderModeAsynchronous;
    };
    
    contentProviderB.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        return HUBContentProviderModeSynchronous;
    };
    
    [self createLoaderWithContentProviders:@[contentProviderA, contentProviderB]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentProviderA.delegate contentProvider:contentProviderA didFailLoadingWithError:error];
    
    XCTAssertEqualObjects(contentProviderB.previousContentProviderError, error);
    [contentProviderB.delegate contentProviderDidFinishLoading:contentProviderB];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testNoErrorRecoveryForUnusedContentProvider
{
    HUBContentProviderMock * const contentProviderA = [HUBContentProviderMock new];
    HUBContentProviderMock * const contentProviderB = [HUBContentProviderMock new];
    
    contentProviderA.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        return HUBContentProviderModeAsynchronous;
    };
    
    contentProviderB.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        return HUBContentProviderModeNone;
    };
    
    [self createLoaderWithContentProviders:@[contentProviderA, contentProviderB]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentProviderA.delegate contentProvider:contentProviderA didFailLoadingWithError:error];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, error);
}

- (void)testSameViewModelBuilderUsedForMultipleContentProviders
{
    HUBContentProviderMock * const contentProviderA = [HUBContentProviderMock new];
    HUBContentProviderMock * const contentProviderB = [HUBContentProviderMock new];
    
    __block id<HUBViewModelBuilder> builderA = nil;
    __block id<HUBViewModelBuilder> builderB = nil;
    
    contentProviderA.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        builderA = builder;
        return HUBContentProviderModeSynchronous;
    };
    
    contentProviderB.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        builderB = builder;
        return HUBContentProviderModeSynchronous;
    };
    
    XCTAssertEqual(builderA, builderB);
}

- (void)testAsynchronousContentProviderMultipleDelegateCallbacks
{
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    
    __block id<HUBViewModelBuilder> viewModelBuilder = nil;
    
    contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        viewModelBuilder.navigationBarTitle = @"A title";
        return HUBContentProviderModeAsynchronous;
    };
    
    [self createLoaderWithContentProviders:@[contentProvider]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    
    id<HUBContentProviderDelegate> const contentProviderDelegate = contentProvider.delegate;
    
    [contentProviderDelegate contentProviderDidFinishLoading:contentProvider];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    
    viewModelBuilder.navigationBarTitle = @"Another title";
    [contentProviderDelegate contentProviderDidFinishLoading:contentProvider];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"Another title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    
    // Errors occuring mid-view lifecycle should be ignored
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentProviderDelegate contentProvider:contentProvider didFailLoadingWithError:error];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"Another title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testSynchronousContentProviderCallingSuccessCallback
{
    HUBContentProviderMock * const contentProviderA = [HUBContentProviderMock new];
    HUBContentProviderMock * const contentProviderB = [HUBContentProviderMock new];
    
    __weak __typeof(contentProviderA) weakContentProviderA = contentProviderA;
    
    contentProviderA.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentProviderA) strongContentProviderA = weakContentProviderA;
        [strongContentProviderA.delegate contentProviderDidFinishLoading:strongContentProviderA];
        return HUBContentProviderModeSynchronous;
    };
    
    __block NSUInteger contentProviderBRequestCount = 0;
    
    contentProviderB.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        contentProviderBRequestCount++;
        return HUBContentProviderModeSynchronous;
    };
    
    [self createLoaderWithContentProviders:@[contentProviderA, contentProviderB]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentProviderBRequestCount, (NSUInteger)1);
}

- (void)testSynchronousContentProviderCallingErrorCallback
{
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    
    __weak __typeof(contentProvider) weakContentProvider = contentProvider;
    NSError * const error = [NSError errorWithDomain:@"domain" code:5 userInfo:nil];
    
    contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentProvider) strongContentProvider = weakContentProvider;
        [strongContentProvider.delegate contentProvider:strongContentProvider didFailLoadingWithError:error];
        return HUBContentProviderModeSynchronous;
    };
    
    [self createLoaderWithContentProviders:@[contentProvider]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, error);
}

- (void)testSubsequentlyLoadedContentNotAppendedToViewModel
{
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    
    contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        NSString * const randomComponentIdentifier = [NSUUID UUID].UUIDString;
        [builder builderForBodyComponentModelWithIdentifier:randomComponentIdentifier].componentName = @"component";
        return HUBContentProviderModeSynchronous;
    };
    
    [self createLoaderWithContentProviders:@[contentProvider]
                         connectivityState:HUBConnectivityStateOnline
                          initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
    
    [self.loader loadViewModel];
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
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

- (void)createLoaderWithContentProviders:(NSArray<id<HUBContentProvider>> *)contentProviders
                       connectivityState:(HUBConnectivityState)connectivityState
                        initialViewModel:(nullable id<HUBViewModel>)initialViewModel
{
    self.connectivityStateResolver.state = connectivityState;
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:test"];
    NSString * const defaultComponentNamespace = @"default";
    HUBJSONSchemaImplementation * const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:defaultComponentNamespace];
    
    self.loader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                          featureIdentifier:@"feature"
                                                  defaultComponentNamespace:defaultComponentNamespace
                                                           contentProviders:contentProviders
                                                                 JSONSchema:JSONSchema
                                                  connectivityStateResolver:self.connectivityStateResolver
                                                           initialViewModel:initialViewModel];
    
    self.loader.delegate = self;
}

@end
