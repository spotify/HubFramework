#import <XCTest/XCTest.h>

#import "HUBViewModelLoaderImplementation.h"
#import "HUBViewModelBuilder.h"
#import "HUBViewModelImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBComponentIdentifier.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBContentOperationMock.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"

@interface HUBViewModelLoaderTests : XCTestCase <HUBViewModelLoaderDelegate>

@property (nonatomic, strong) HUBViewModelLoaderImplementation *loader;
@property (nonatomic, strong) HUBConnectivityStateResolverMock *connectivityStateResolver;
@property (nonatomic, strong) id<HUBViewModel> viewModelFromSuccessDelegateMethod;
@property (nonatomic, strong) NSError *errorFromFailureDelegateMethod;

@property (nonatomic, assign) NSUInteger didLoadViewModelCount;
@property (nonatomic, assign) NSUInteger didLoadViewModelErrorCount;

@end

@implementation HUBViewModelLoaderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    self.didLoadViewModelCount = 0;
    self.didLoadViewModelErrorCount = 0;
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
    
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        numberOfInitialViewModelRequests++;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationBarTitle, @"A title");
    
    // The initial view model should now be cached, so accessing it shouldn't increment the request count
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationBarTitle, @"A title");
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationBarTitle, @"A title");
    
    XCTAssertEqual(numberOfInitialViewModelRequests, (NSUInteger)1);
}

- (void)testInjectedInitialViewModelUsedInsteadOfContentOperations
{
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults iconImageResolver:iconImageResolver];
    
    HUBViewModelBuilderImplementation * const viewModelBuilder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                                           JSONSchema:JSONSchema
                                                                                                                    componentDefaults:componentDefaults
                                                                                                                    iconImageResolver:iconImageResolver];
    
    viewModelBuilder.navigationBarTitle = @"Pre-computed title";
    id<HUBViewModel> const initialViewModel = [viewModelBuilder build];
    
    __block BOOL contentOperationCalled = NO;
    
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        contentOperationCalled = YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:initialViewModel];
    
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationBarTitle, @"Pre-computed title");
    XCTAssertFalse(contentOperationCalled);
}

- (void)testSuccessfullyLoadingViewModel
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        return HUBContentOperationModeSynchronous;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    [contentOperation.delegate contentOperationDidFinish:contentOperation];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testSingleContentOperationError
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    contentOperation.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        return HUBContentOperationModeAsynchronous;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentOperation.delegate contentOperation:contentOperation didFailWithError:error];
    
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertEqual(error, self.errorFromFailureDelegateMethod);
}

- (void)testContentOperationErrorRecovery
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    contentOperationA.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        return HUBContentOperationModeAsynchronous;
    };
    
    contentOperationB.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        return HUBContentOperationModeSynchronous;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentOperationA.delegate contentOperation:contentOperationA didFailWithError:error];
    
    XCTAssertEqualObjects(contentOperationB.previousContentOperationError, error);
    [contentOperationB.delegate contentOperationDidFinish:contentOperationB];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testNoErrorRecoveryForUnusedContentOperation
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    contentOperationA.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        return HUBContentOperationModeAsynchronous;
    };
    
    contentOperationB.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        return HUBContentOperationModeNone;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentOperationA.delegate contentOperation:contentOperationA didFailWithError:error];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, error);
}

- (void)testSameViewModelBuilderUsedForMultipleContentOperations
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    __block id<HUBViewModelBuilder> builderA = nil;
    __block id<HUBViewModelBuilder> builderB = nil;
    
    contentOperationA.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        builderA = builder;
        return HUBContentOperationModeSynchronous;
    };
    
    contentOperationB.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        builderB = builder;
        return HUBContentOperationModeSynchronous;
    };
    
    XCTAssertEqual(builderA, builderB);
}

- (void)testAsynchronousContentOperationMultipleDelegateCallbacks
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __block id<HUBViewModelBuilder> viewModelBuilder = nil;
    
    contentOperation.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        viewModelBuilder.navigationBarTitle = @"A title";
        return HUBContentOperationModeAsynchronous;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    
    id<HUBContentOperationDelegate> const contentOperationDelegate = contentOperation.delegate;
    
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    
    viewModelBuilder.navigationBarTitle = @"Another title";
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"Another title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    
    // Errors occuring mid-view lifecycle should be ignored
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentOperationDelegate contentOperation:contentOperation didFailWithError:error];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"Another title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testSynchronousContentOperationCallingSuccessCallback
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    __weak __typeof(contentOperationA) weakContentOperationA = contentOperationA;
    
    contentOperationA.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperationA) strongContentOperationA = weakContentOperationA;
        [strongContentOperationA.delegate contentOperationDidFinish:strongContentOperationA];
        return HUBContentOperationModeSynchronous;
    };
    
    __block NSUInteger contentOperationBRequestCount = 0;
    
    contentOperationB.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        contentOperationBRequestCount++;
        return HUBContentOperationModeSynchronous;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperationBRequestCount, (NSUInteger)1);
}

- (void)testSynchronousContentOperationDoesNotCallDelegateTwice
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __weak __typeof(contentOperation) weakContentOperation = contentOperation;
    contentOperation.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperation) strongContentOperation = weakContentOperation;
        [strongContentOperation.delegate contentOperationDidFinish:strongContentOperation];
        return HUBContentOperationModeSynchronous;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, nil);
    XCTAssertEqual(self.didLoadViewModelErrorCount, (NSUInteger)0);
    XCTAssertEqual(self.didLoadViewModelCount, (NSUInteger)1);
}

- (void)testSynchronousContentOperationCallingErrorCallback
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __weak __typeof(contentOperation) weakContentOperation = contentOperation;
    NSError * const error = [NSError errorWithDomain:@"domain" code:5 userInfo:nil];
    
    contentOperation.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperation) strongContentOperation = weakContentOperation;
        [strongContentOperation.delegate contentOperation:strongContentOperation didFailWithError:error];
        return HUBContentOperationModeSynchronous;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, error);
    XCTAssertEqual(self.didLoadViewModelErrorCount, (NSUInteger)1);
    XCTAssertEqual(self.didLoadViewModelCount, (NSUInteger)0);
}

- (void)testSubsequentlyLoadedContentNotAppendedToViewModel
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    contentOperation.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        NSString * const randomComponentIdentifier = [NSUUID UUID].UUIDString;
        [builder builderForBodyComponentModelWithIdentifier:randomComponentIdentifier].componentName = @"component";
        return HUBContentOperationModeSynchronous;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
    
    [self.loader loadViewModel];
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
}

- (void)testMiddleContentOperationReloadDoesNotReloadWholeChain
{
    HUBContentOperationMock * const contentOperation1 = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperation2 = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperation3 = [HUBContentOperationMock new];

    __block id<HUBViewModelBuilder> viewModelBuilder = nil;

    __block NSInteger contentOperation1Version = 1;
    contentOperation1.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        id<HUBComponentModelBuilder> component = [builder builderForBodyComponentModelWithIdentifier:@"component1"];
        component.componentName = @"component1";
        component.title = [NSString stringWithFormat:@"%@", @(contentOperation1Version++)];
        return HUBContentOperationModeSynchronous;
    };

    __block NSInteger contentOperation2Version = 1;
    contentOperation2.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        id<HUBComponentModelBuilder> component = [builder builderForBodyComponentModelWithIdentifier:@"component2"];
        component.componentName = @"component2";
        component.title = [NSString stringWithFormat:@"%@", @(contentOperation2Version++)];
        return HUBContentOperationModeSynchronous;
    };

    __block NSInteger contentOperation3Version = 1;
    contentOperation3.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        id<HUBComponentModelBuilder> component = [builder builderForBodyComponentModelWithIdentifier:@"component3"];
        component.componentName = @"component3";
        component.title = [NSString stringWithFormat:@"%@", @(contentOperation3Version++)];
        return HUBContentOperationModeSynchronous;
    };

    [self createLoaderWithContentOperations:@[contentOperation1, contentOperation2, contentOperation3]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];

    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)3);

    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[0] title], @"1");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[1] title], @"1");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[2] title], @"1");

    contentOperation2.contentLoadingBlock(viewModelBuilder);
    [contentOperation2.delegate contentOperationDidFinish:contentOperation2];

    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[0] title], @"1");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[1] title], @"2");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[2] title], @"2");

    contentOperation3.contentLoadingBlock(viewModelBuilder);
    [contentOperation3.delegate contentOperationDidFinish:contentOperation3];

    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[0] title], @"1");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[1] title], @"2");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[2] title], @"3");

    contentOperation1.contentLoadingBlock(viewModelBuilder);
    [contentOperation1.delegate contentOperationDidFinish:contentOperation1];

    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[0] title], @"2");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[1] title], @"3");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[2] title], @"4");

}

- (void)testOutOfSyncContentOperationGetsReloadedEventually
{
    HUBContentOperationMock * const contentOperation1 = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperation2 = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperation3 = [HUBContentOperationMock new];

    __block id<HUBViewModelBuilder> viewModelBuilder = nil;

    __block NSInteger contentOperation1Version = 1;
    contentOperation1.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        id<HUBComponentModelBuilder> component = [builder builderForBodyComponentModelWithIdentifier:@"component1"];
        component.componentName = @"component1";
        component.title = [NSString stringWithFormat:@"%@", @(contentOperation1Version)];
        ++contentOperation1Version;
        return HUBContentOperationModeAsynchronous;
    };

    __block NSInteger contentOperation2Version = 1;
    contentOperation2.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        id<HUBComponentModelBuilder> component = [builder builderForBodyComponentModelWithIdentifier:@"component2"];
        component.componentName = @"component2";
        component.title = [NSString stringWithFormat:@"%@", @(contentOperation2Version)];
        ++contentOperation2Version;
        return HUBContentOperationModeSynchronous;
    };

    __block NSInteger contentOperation3Version = 1;
    contentOperation3.contentLoadingBlock = ^HUBContentOperationMode(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        id<HUBComponentModelBuilder> component = [builder builderForBodyComponentModelWithIdentifier:@"component3"];
        component.componentName = @"component3";
        component.title = [NSString stringWithFormat:@"%@", @(contentOperation3Version)];
        ++contentOperation3Version;
        return HUBContentOperationModeSynchronous;
    };

    [self createLoaderWithContentOperations:@[contentOperation1, contentOperation2, contentOperation3]
                            connectivityState:HUBConnectivityStateOnline
                            initialViewModel:nil];
    
    [self.loader loadViewModel];

    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)0);  // Not loaded yet

    contentOperation2.contentLoadingBlock(viewModelBuilder);
    [contentOperation2.delegate contentOperationDidFinish:contentOperation2];  // Load out of sync

    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)0);  // Not loaded yet

    [contentOperation1.delegate contentOperationDidFinish:contentOperation1];
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)3);  // All loaded

    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[0] title], @"1");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[1] title], @"2");
    XCTAssertEqualObjects([self.viewModelFromSuccessDelegateMethod.bodyComponentModels[2] title], @"1");
}

#pragma mark - HUBViewModelLoaderDelegate

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel
{
    XCTAssertNotNil(viewModel);
    self.viewModelFromSuccessDelegateMethod = viewModel;
    self.didLoadViewModelCount++;
}

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didFailLoadingWithError:(NSError *)error
{
    XCTAssertNotNil(error);
    self.errorFromFailureDelegateMethod = error;
    self.didLoadViewModelErrorCount++;
}

#pragma mark - Utilities

- (void)createLoaderWithContentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                        connectivityState:(HUBConnectivityState)connectivityState
                         initialViewModel:(nullable id<HUBViewModel>)initialViewModel
{
    self.connectivityStateResolver.state = connectivityState;
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:test"];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    HUBJSONSchemaImplementation * const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                                  iconImageResolver:iconImageResolver];
    
    self.loader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                          featureIdentifier:@"feature"
                                                          contentOperations:contentOperations
                                                                 JSONSchema:JSONSchema
                                                          componentDefaults:componentDefaults
                                                  connectivityStateResolver:self.connectivityStateResolver
                                                          iconImageResolver:iconImageResolver
                                                           initialViewModel:initialViewModel];
    
    self.loader.delegate = self;
}

@end
