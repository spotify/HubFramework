#import <XCTest/XCTest.h>

#import "HUBViewControllerImplementation.h"
#import "HUBViewModelLoaderImplementation.h"
#import "HUBLocalContentProviderMock.h"
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

@interface HUBViewControllerTests : XCTestCase <HUBViewControllerDelegate>

@property (nonatomic, strong) HUBLocalContentProviderMock *contentProvider;
@property (nonatomic, strong) HUBComponentIdentifier *componentIdentifier;
@property (nonatomic, strong) HUBComponentMock *component;
@property (nonatomic, strong) HUBCollectionViewMock *collectionView;
@property (nonatomic, strong) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong) HUBViewModelLoaderImplementation *viewModelLoader;
@property (nonatomic, strong) HUBImageLoaderMock *imageLoader;
@property (nonatomic, strong) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong) HUBViewControllerImplementation *viewController;
@property (nonatomic) NSInteger numberOfHeaderComponentVisibilityChangeDelegateCalls;

@end

@implementation HUBViewControllerTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.contentProvider = [HUBLocalContentProviderMock new];
    
    self.componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namspace" name:@"name"];
    self.componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackComponentIdentifier:self.componentIdentifier];
    self.component = [HUBComponentMock new];
    
    self.collectionView = [HUBCollectionViewMock new];
    HUBCollectionViewFactoryMock * const collectionViewFactory = [[HUBCollectionViewFactoryMock alloc] initWithCollectionView:self.collectionView];
    
    id<HUBComponentFactory> const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{self.componentIdentifier.componentName: self.component}];
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:self.componentIdentifier.componentNamespace];
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:@"namespace"];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    self.viewModelLoader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                                   featureIdentifier:@"feature"
                                                           defaultComponentNamespace:@"namespace"
                                                               remoteContentProvider:nil
                                                                localContentProvider:self.contentProvider
                                                                          JSONSchema:JSONSchema
                                                           connectivityStateResolver:connectivityStateResolver];
    
    self.imageLoader = [HUBImageLoaderMock new];
    
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    
    self.initialViewModelRegistry = [HUBInitialViewModelRegistry new];
    
    self.viewController = [[HUBViewControllerImplementation alloc] initWithViewModelLoader:self.viewModelLoader
                                                                               imageLoader:self.imageLoader
                                                                     collectionViewFactory:collectionViewFactory
                                                                         componentRegistry:self.componentRegistry
                                                                    componentLayoutManager:componentLayoutManager
                                                                          initialViewModel:nil
                                                                  initialViewModelRegistry:self.initialViewModelRegistry];
    
    self.viewController.delegate = self;
    
    self.numberOfHeaderComponentVisibilityChangeDelegateCalls = 0;
}

#pragma mark - Tests

- (void)testContentLoadedOnViewWillAppear
{
    __block BOOL contentLoaded = NO;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        contentLoaded = YES;
    };
    
    [self.viewController viewWillAppear:YES];
    
    XCTAssertTrue(contentLoaded);
}

- (void)testHeaderComponentImageLoading
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];
    NSURL * const customImageURL = [NSURL URLWithString:@"https://image.custom"];
    NSString * const customImageIdentifier = @"custom";
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        viewModelBuilder.headerComponentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        viewModelBuilder.headerComponentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        viewModelBuilder.headerComponentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [viewModelBuilder.headerComponentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
}

- (void)testBodyComponentImageLoading
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];
    NSURL * const customImageURL = [NSURL URLWithString:@"https://image.custom"];
    NSString * const customImageIdentifier = @"custom";
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        componentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        componentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [componentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
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
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        
        id<HUBComponentModelBuilder> const componentModelBuilderA = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"componentA"];
        componentModelBuilderA.componentNamespace = componentNamespace;
        componentModelBuilderA.componentName = componentNameA;
        componentModelBuilderA.mainImageDataBuilder.URL = imageURL;
        
        id<HUBComponentModelBuilder> const componentModelBuilderB = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"componentB"];
        componentModelBuilderB.componentNamespace = componentNamespace;
        componentModelBuilderB.componentName = componentNameB;
        componentModelBuilderB.mainImageDataBuilder.URL = imageURL;
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
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildComponentModelWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;
        childComponentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        childComponentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [childComponentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [component.childDelegate component:component willDisplayChildAtIndex:0];
    
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
}

- (void)testNoImagesLoadedIfComponentDoesNotHandleImages
{
    self.component.canHandleImages = NO;
    
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
        componentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    XCTAssertFalse([self.imageLoader hasLoadedImageForURL:mainImageURL]);
}

- (void)testDelegateNotifiedWhenHeaderComponentVisibilityChanged
{
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        viewModelBuilder.headerComponentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.numberOfHeaderComponentVisibilityChangeDelegateCalls, 1);
    XCTAssertTrue(self.viewController.isDisplayingHeaderComponent);
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {};
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqual(self.numberOfHeaderComponentVisibilityChangeDelegateCalls, 2);
    XCTAssertFalse(self.viewController.isDisplayingHeaderComponent);
}

- (void)testHeaderComponentReuse
{
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        viewModelBuilder.headerComponentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.component.numberOfReuses, (NSUInteger)0);
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqual(self.component.numberOfReuses, (NSUInteger)2);
}

- (void)testInitialViewModelForTargetViewControllerRegistered
{
    NSString * const initialViewModelIdentifier = @"initialViewModel";
    NSURL * const targetViewURI = [NSURL URLWithString:@"spotify:hub:target"];
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"id"];
        componentModelBuilder.componentName = @"component";
        componentModelBuilder.targetURL = targetViewURI;
        componentModelBuilder.targetInitialViewModelBuilder.viewIdentifier = initialViewModelIdentifier;
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
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.componentName;
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
    __weak __typeof(self) weakSelf = self;
    
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
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildComponentModelWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;
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
    __weak __typeof(self) weakSelf = self;
    
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
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBLocalContentProviderDelegate> const delegate = strongSelf.contentProvider.delegate;
        
        id<HUBViewModelBuilder> const viewModelBuilder = [delegate provideViewModelBuilderForLocalContentProvider:strongSelf.contentProvider];
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildComponentModelWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;
        childComponentModelBuilder.targetURL = childComponentTargetURL;
        childComponentModelBuilder.targetInitialViewModelBuilder.viewIdentifier = childComponentInitialViewModelIdentifier;
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

#pragma mark - HUBViewControllerDelegate

- (void)viewControllerHeaderComponentVisbilityDidChange:(UIViewController<HUBViewController> *)viewController
{
    self.numberOfHeaderComponentVisibilityChangeDelegateCalls++;
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

@end
