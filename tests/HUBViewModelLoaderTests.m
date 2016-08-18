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
#import "HUBFeatureInfoImplementation.h"

@interface HUBViewModelLoaderTests : XCTestCase <HUBViewModelLoaderDelegate>

@property (nonatomic, strong) HUBViewModelLoaderImplementation *loader;
@property (nonatomic, strong) id<HUBFeatureInfo> featureInfo;
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
    
    self.featureInfo = [[HUBFeatureInfoImplementation alloc] initWithIdentifier:@"id" title:@"title"];
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
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        return YES;
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
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
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
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
    };
    
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        return YES;
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

- (void)testViewModelBuilderCopiedBetweenContentOperations
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    __block id<HUBViewModelBuilder> builderA = nil;
    __block id<HUBViewModelBuilder> builderB = nil;
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builderA = builder;
        return YES;
    };
    
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builderB = builder;
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNotEqual(builderA, builderB);
}

- (void)testAsynchronousContentOperationMultipleDelegateCallbacksIgnored
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __block id<HUBViewModelBuilder> viewModelBuilder = nil;
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        viewModelBuilder.navigationBarTitle = @"A title";
        return NO;
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
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);

    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentOperationDelegate contentOperation:contentOperation didFailWithError:error];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testSynchronousContentOperationCallingSuccessCallback
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    __weak __typeof(contentOperationA) weakContentOperationA = contentOperationA;
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperationA) strongContentOperationA = weakContentOperationA;
        [strongContentOperationA.delegate contentOperationDidFinish:strongContentOperationA];
        return YES;
    };
    
    __block NSUInteger contentOperationBRequestCount = 0;
    
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        contentOperationBRequestCount++;
        return YES;
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
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperation) strongContentOperation = weakContentOperation;
        [strongContentOperation.delegate contentOperationDidFinish:strongContentOperation];
        return YES;
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
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperation) strongContentOperation = weakContentOperation;
        [strongContentOperation.delegate contentOperation:strongContentOperation didFailWithError:error];
        return YES;
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
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        NSString * const randomComponentIdentifier = [NSUUID UUID].UUIDString;
        [builder builderForBodyComponentModelWithIdentifier:randomComponentIdentifier].componentName = @"component";
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
    
    [self.loader loadViewModel];
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, (NSUInteger)1);
}

- (void)testContentOperationRescheduling
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationC = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB, contentOperationC]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    id<HUBContentOperationDelegate> const contentOperationDelegate = contentOperationB.delegate;
    [contentOperationDelegate contentOperationRequiresRescheduling:contentOperationB];
    [contentOperationDelegate contentOperationRequiresRescheduling:contentOperationB];
    
    XCTAssertEqual(self.didLoadViewModelCount, (NSUInteger)3);
    XCTAssertEqual(contentOperationA.performCount, (NSUInteger)1);
    XCTAssertEqual(contentOperationB.performCount, (NSUInteger)3);
    XCTAssertEqual(contentOperationC.performCount, (NSUInteger)3);
}

- (void)testErrorFromFirstContentLoadingChainNotPassedToRescheduledOperation
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    id<HUBContentOperationDelegate> const contentOperationDelegate = contentOperation.delegate;
    [contentOperationDelegate contentOperation:contentOperation didFailWithError:error];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, error);
    self.errorFromFailureDelegateMethod = nil;
    contentOperation.contentLoadingBlock = nil;
    
    [contentOperationDelegate contentOperationRequiresRescheduling:contentOperation];
    
    XCTAssertNil(contentOperation.previousContentOperationError);
    XCTAssertEqual(contentOperation.performCount, (NSUInteger)2);
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    XCTAssertNotNil(self.viewModelFromSuccessDelegateMethod);
}

- (void)testSameConnectivityStateSentToAllContentOperations
{
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    self.connectivityStateResolver.state = HUBConnectivityStateOffline;
    
    [contentOperationA.delegate contentOperationDidFinish:contentOperationA];
    
    XCTAssertEqual(contentOperationA.connectivityState, HUBConnectivityStateOnline);
    XCTAssertEqual(contentOperationB.connectivityState, HUBConnectivityStateOnline);
}

- (void)testConnectivityStateStartsLoadingFromBlankState
{
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    
    __block NSInteger initialContentLoadingCount = 0;
    
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    contentOperationA.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        initialContentLoadingCount++;
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"initial"].title = @"Initial component";
    };
    
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    contentOperationB.contentLoadingBlock = ^BOOL(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"final"].title = @"Final component";
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperationA.performCount, (NSUInteger)1);
    XCTAssertEqual(contentOperationB.performCount, (NSUInteger)1);
    
    self.connectivityStateResolver.state = HUBConnectivityStateOffline;
    [self.connectivityStateResolver callObservers];
    
    XCTAssertEqual(initialContentLoadingCount, 1);
    XCTAssertEqual(contentOperationA.performCount, (NSUInteger)2);
    XCTAssertEqual(contentOperationB.performCount, (NSUInteger)2);
}

- (void)testIncorrectlyIndicatedConnectivityChangeIgnored
{
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperationA.performCount, (NSUInteger)1);
    XCTAssertEqual(contentOperationB.performCount, (NSUInteger)1);
    
    [self.connectivityStateResolver callObservers];
    [self.connectivityStateResolver callObservers];
    [self.connectivityStateResolver callObservers];
    [self.connectivityStateResolver callObservers];
    
    XCTAssertEqual(contentOperationA.performCount, (NSUInteger)1);
    XCTAssertEqual(contentOperationB.performCount, (NSUInteger)1);
}

- (void)testCorrectFeatureInfoSentToContentOperations
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNotNil(contentOperation.featureInfo);
    XCTAssertEqual(contentOperation.featureInfo, self.featureInfo);
}

- (void)testFeatureTitleAssignedAsViewTitleIfNil
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNotNil(self.viewModelFromSuccessDelegateMethod.navigationBarTitle);
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationBarTitle,
                          self.featureInfo.title);
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
                                                                featureInfo:self.featureInfo
                                                          contentOperations:contentOperations
                                                                 JSONSchema:JSONSchema
                                                          componentDefaults:componentDefaults
                                                  connectivityStateResolver:self.connectivityStateResolver
                                                          iconImageResolver:iconImageResolver
                                                           initialViewModel:initialViewModel];
    
    self.loader.delegate = self;
}

@end
