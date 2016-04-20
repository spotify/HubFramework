#import <XCTest/XCTest.h>

#import "HUBViewControllerImplementation.h"
#import "HUBViewModelLoaderImplementation.h"
#import "HUBContentProviderMock.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentIdentifier.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBImageLoaderMock.h"
#import "HUBViewModelBuilder.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentImageDataBuilder.h"
#import "HUBComponentFactoryMock.h"
#import "HUBComponentMock.h"
#import "HUBCollectionViewFactoryMock.h"
#import "HUBCollectionViewMock.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBViewModel.h"
#import "HUBContentReloadPolicyMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBIconImageResolverMock.h"

@interface HUBViewControllerTests : XCTestCase <HUBViewControllerDelegate>

@property (nonatomic, strong) HUBContentProviderMock *contentProvider;
@property (nonatomic, strong) HUBContentReloadPolicyMock *contentReloadPolicy;
@property (nonatomic, strong) HUBComponentIdentifier *componentIdentifier;
@property (nonatomic, strong) HUBComponentMock *component;
@property (nonatomic, strong) HUBCollectionViewMock *collectionView;
@property (nonatomic, strong) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong) HUBViewModelLoaderImplementation *viewModelLoader;
@property (nonatomic, strong) HUBImageLoaderMock *imageLoader;
@property (nonatomic, strong) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong) HUBViewControllerImplementation *viewController;
@property (nonatomic, strong) id<HUBViewModel> viewModelFromDelegateMethod;

@end

@implementation HUBViewControllerTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    
    self.contentProvider = [HUBContentProviderMock new];
    self.contentReloadPolicy = [HUBContentReloadPolicyMock new];
    self.componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:componentDefaults.componentNamespace name:componentDefaults.componentName];
    self.componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler];
    self.component = [HUBComponentMock new];
    
    self.collectionView = [HUBCollectionViewMock new];
    HUBCollectionViewFactoryMock * const collectionViewFactory = [[HUBCollectionViewFactoryMock alloc] initWithCollectionView:self.collectionView];
    
    id<HUBComponentFactory> const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{componentDefaults.componentName: self.component}];
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentDefaults.componentNamespace];
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults iconImageResolver:iconImageResolver];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    self.viewModelLoader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                                   featureIdentifier:@"feature"
                                                                    contentProviders:@[self.contentProvider]
                                                                          JSONSchema:JSONSchema
                                                                   componentDefaults:componentDefaults
                                                           connectivityStateResolver:connectivityStateResolver
                                                                   iconImageResolver:iconImageResolver
                                                                    initialViewModel:nil];
    
    self.imageLoader = [HUBImageLoaderMock new];
    
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    
    self.initialViewModelRegistry = [HUBInitialViewModelRegistry new];
    
    self.viewController = [[HUBViewControllerImplementation alloc] initWithViewURI:viewURI
                                                                   viewModelLoader:self.viewModelLoader
                                                                       imageLoader:self.imageLoader
                                                               contentReloadPolicy:self.contentReloadPolicy
                                                             collectionViewFactory:collectionViewFactory
                                                                 componentRegistry:self.componentRegistry
                                                            componentLayoutManager:componentLayoutManager
                                                          initialViewModelRegistry:self.initialViewModelRegistry];
    
    self.viewController.delegate = self;
    
    self.viewModelFromDelegateMethod = nil;
}

#pragma mark - Tests

- (void)testContentLoadedOnViewWillAppear
{;
    __block BOOL contentLoaded = NO;
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        contentLoaded = YES;
        return HUBContentProviderModeSynchronous;
    };
    
    [self.viewController viewWillAppear:YES];
    
    XCTAssertTrue(contentLoaded);
}

- (void)testDelegateNotifiedOfUpdatedViewModel
{
    NSString * const viewModelNavBarTitleA = @"View model A";
    NSString * const viewModelNavBarTitleB = @"View model B";
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = viewModelNavBarTitleA;
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqualObjects(self.viewModelFromDelegateMethod.navigationBarTitle, viewModelNavBarTitleA);
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = viewModelNavBarTitleB;
        return HUBContentProviderModeSynchronous;
    };
    
    self.contentReloadPolicy.shouldReload = YES;
    [self.viewController viewWillAppear:YES];
    
    XCTAssertEqualObjects(self.viewModelFromDelegateMethod.navigationBarTitle, viewModelNavBarTitleB);
}

- (void)testReloadPolicyPreventingReload
{
    NSString * const viewModelNavBarTitleA = @"View model A";
    NSString * const viewModelNavBarTitleB = @"View model B";
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = viewModelNavBarTitleA;
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqualObjects(self.viewModelFromDelegateMethod.navigationBarTitle, viewModelNavBarTitleA);
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = viewModelNavBarTitleB;
        return HUBContentProviderModeSynchronous;
    };
    
    self.contentReloadPolicy.shouldReload = NO;
    [self.viewController viewWillAppear:YES];
    
    XCTAssertEqualObjects(self.viewModelFromDelegateMethod.navigationBarTitle, viewModelNavBarTitleA);
}

- (void)testHeaderComponentImageLoading
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];
    NSURL * const customImageURL = [NSURL URLWithString:@"https://image.custom"];
    NSString * const customImageIdentifier = @"custom";
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> builder) {
        __typeof(self) strongSelf = weakSelf;
        builder.headerComponentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        builder.headerComponentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        builder.headerComponentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [builder.headerComponentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    [self performAsynchronousTestWithBlock:^{
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
    }];
}

- (void)testBodyComponentImageLoading
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];
    NSURL * const customImageURL = [NSURL URLWithString:@"https://image.custom"];
    NSString * const customImageIdentifier = @"custom";
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        componentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        componentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [componentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self performAsynchronousTestWithBlock:^{
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
    }];
}

- (void)testMissingImageLoadingContextHandled
{
    NSURL * const imageURL = [NSURL URLWithString:@"http://image.com"];
    [self.imageLoader.delegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL fromCache:NO];
}

- (void)testImageLoadingForMultipleComponentsSharingTheSameImageURL
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.url"];
    
    NSString * const componentNamespace = @"sameImage";
    NSString * const componentNameA = @"componentA";
    NSString * const componentNameB = @"componentB";
    HUBComponentMock * const componentA = [HUBComponentMock new];
    HUBComponentMock * const componentB = [HUBComponentMock new];
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        componentNameA: componentA,
        componentNameB: componentB
    }];
    
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilderA = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"componentA"];
        componentModelBuilderA.componentNamespace = componentNamespace;
        componentModelBuilderA.componentName = componentNameA;
        componentModelBuilderA.mainImageDataBuilder.URL = imageURL;
        
        id<HUBComponentModelBuilder> const componentModelBuilderB = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"componentB"];
        componentModelBuilderB.componentNamespace = componentNamespace;
        componentModelBuilderB.componentName = componentNameB;
        componentModelBuilderB.mainImageDataBuilder.URL = imageURL;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    
    NSIndexPath * const indexPathA = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath * const indexPathB = [NSIndexPath indexPathForItem:1 inSection:0];
    
    self.collectionView.cells[indexPathA] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathA];
    self.collectionView.cells[indexPathB] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathB];
    
    [self.imageLoader.delegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL fromCache:NO];
    
    XCTAssertEqualObjects(componentA.mainImageData.URL, imageURL);
    XCTAssertEqualObjects(componentB.mainImageData.URL, imageURL);
}

- (void)testImageLoadingForChildComponent
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];
    NSURL * const customImageURL = [NSURL URLWithString:@"https://image.custom"];
    NSString * const customImageIdentifier = @"custom";
    
    NSString * const componentNamespace = @"childComponentImageLoading";
    NSString * const componentName = @"component";
    NSString * const childComponentName = @"componentB";
    HUBComponentMock * const component = [HUBComponentMock new];
    HUBComponentMock * const childComponent = [HUBComponentMock new];
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        componentName: component,
        childComponentName: childComponent
    }];
    
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildComponentModelWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;
        childComponentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        childComponentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [childComponentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [component.childDelegate component:component willDisplayChildAtIndex:0];
    
    [self performAsynchronousTestWithBlock:^{
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
    }];
}

- (void)testNoImagesLoadedIfComponentDoesNotHandleImages
{
    self.component.canHandleImages = NO;
    
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        componentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    XCTAssertFalse([self.imageLoader hasLoadedImageForURL:mainImageURL]);
}

- (void)testHeaderComponentReuse
{
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        viewModelBuilder.headerComponentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.component.numberOfReuses, (NSUInteger)0);
    
    self.contentReloadPolicy.shouldReload = YES;
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqual(self.component.numberOfReuses, (NSUInteger)2);
}

- (void)testInitialViewModelForTargetViewControllerRegistered
{
    __weak __typeof(self) weakSelf = self;
    
    NSString * const initialViewModelIdentifier = @"initialViewModel";
    NSURL * const targetViewURI = [NSURL URLWithString:@"spotify:hub:target"];
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"id"];
        componentModelBuilder.componentName = weakSelf.componentIdentifier.componentName;
        componentModelBuilder.targetURL = targetViewURI;
        componentModelBuilder.targetInitialViewModelBuilder.viewIdentifier = initialViewModelIdentifier;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    
    id<HUBViewModel> const targetInitialViewModel = [self.initialViewModelRegistry initialViewModelForViewURI:targetViewURI];
    XCTAssertEqualObjects(targetInitialViewModel.identifier, initialViewModelIdentifier);
}

- (void)testComponentDeselectedOnViewWillDisappear
{
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    
    XCTAssertEqualObjects(self.collectionView.selectedIndexPaths, [NSSet setWithObject:indexPath]);
    
    [self.viewController viewWillDisappear:NO];
    
    XCTAssertEqual(self.collectionView.selectedIndexPaths.count, (NSUInteger)0);
}

- (void)testCreatingChildComponent
{
    NSString * const componentNamespace = @"childComponentSelection";
    NSString * const componentName = @"component";
    NSString * const childComponentName = @"componentB";
    HUBComponentMock * const component = [HUBComponentMock new];
    HUBComponentMock * const childComponent = [HUBComponentMock new];
    childComponent.preferredViewSize = CGSizeMake(100, 200);
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        componentName: component,
        childComponentName: childComponent
    }];
    
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildComponentModelWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    id<HUBComponentChildDelegate> const childDelegate = component.childDelegate;
    
    XCTAssertEqual([childDelegate component:component createChildComponentAtIndex:0], childComponent);
    XCTAssertTrue(CGSizeEqualToSize(childComponent.view.frame.size, childComponent.preferredViewSize));
    
    XCTAssertNil([childDelegate component:component createChildComponentAtIndex:5]);
}

- (void)testSelectionForChildComponent
{
    NSString * const componentNamespace = @"childComponentSelection";
    NSString * const componentName = @"component";
    NSString * const childComponentName = @"componentB";
    NSURL * const childComponentTargetURL = [NSURL URLWithString:@"spotify:hub:child-component"];
    NSString * const childComponentInitialViewModelIdentifier = @"viewModel";
    HUBComponentMock * const component = [HUBComponentMock new];
    HUBComponentMock * const childComponent = [HUBComponentMock new];
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        componentName: component,
        childComponentName: childComponent
    }];
    
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildComponentModelWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;
        childComponentModelBuilder.targetURL = childComponentTargetURL;
        childComponentModelBuilder.targetInitialViewModelBuilder.viewIdentifier = childComponentInitialViewModelIdentifier;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    id<HUBComponentChildDelegate> const childDelegate = component.childDelegate;
    
    [childDelegate component:component childSelectedAtIndex:0];
    
    id<HUBViewModel> const childComponentTargetInitialViewModel = [self.initialViewModelRegistry initialViewModelForViewURI:childComponentTargetURL];
    XCTAssertEqualObjects(childComponentTargetInitialViewModel.identifier, childComponentInitialViewModelIdentifier);
    
    // Make sure bounds-checking is performed for child component index
    [childDelegate component:component willDisplayChildAtIndex:99];
}

- (void)testComponentNotifiedOfResize
{
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^HUBContentProviderMode(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        
        return HUBContentProviderModeSynchronous;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    cell.frame = CGRectMake(0, 0, 300, 200);
    [cell layoutSubviews];
    XCTAssertEqual(self.component.numberOfResizes, (NSUInteger)1);
    
    // Subsequent layout passes should not notify the component, unless the size has changed
    [cell layoutSubviews];
    [cell layoutSubviews];
    [cell layoutSubviews];
    XCTAssertEqual(self.component.numberOfResizes, (NSUInteger)1);
    
    cell.frame = CGRectMake(0, 0, 300, 100);
    [cell layoutSubviews];
    XCTAssertEqual(self.component.numberOfResizes, (NSUInteger)2);
}

- (void)testSettingBackgroundColorOfViewAlsoUpdatesCollectionView
{
    self.viewController.view.backgroundColor = [UIColor redColor];
    XCTAssertEqualObjects(self.collectionView.backgroundColor, [UIColor redColor]);
}

#pragma mark - HUBViewControllerDelegate

- (void)viewController:(UIViewController<HUBViewController> *)viewController didUpdateWithViewModel:(id<HUBViewModel>)viewModel
{
    XCTAssertEqual(viewController, self.viewController);
    self.viewModelFromDelegateMethod = viewModel;
}

#pragma mark - Utilities

- (void)simulateViewControllerLayoutCycle
{
    [self.viewController loadView];
    [self.viewController viewDidLoad];
    [self.viewController viewWillAppear:YES];
    self.viewController.view.frame = CGRectMake(0, 0, 320, 400);
    [self.viewController viewDidLayoutSubviews];
}

- (void)performAsynchronousTestWithBlock:(void(^)(void))block
{
    XCTestExpectation * const expectation = [self expectationWithDescription:@"Async test"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        block();
    }];
}

@end
