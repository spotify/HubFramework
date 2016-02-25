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

@interface HUBViewControllerTests : XCTestCase

@property (nonatomic, strong) HUBLocalContentProviderMock *contentProvider;
@property (nonatomic, strong) HUBComponentIdentifier *componentIdentifier;
@property (nonatomic, strong) HUBComponentMock *component;
@property (nonatomic, strong) HUBCollectionViewMock *collectionView;
@property (nonatomic, strong) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong) HUBViewModelLoaderImplementation *viewModelLoader;
@property (nonatomic, strong) HUBImageLoaderMock *imageLoader;
@property (nonatomic, strong) HUBViewControllerImplementation *viewController;

@end

@implementation HUBViewControllerTests

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
    id<HUBJSONSchema> const JSONSchema = [HUBJSONSchemaImplementation new];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    self.viewModelLoader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                                   featureIdentifier:@"feature"
                                                           defaultComponentNamespace:@"namespace"
                                                               remoteContentProvider:nil
                                                                localContentProvider:self.contentProvider
                                                                          JSONSchema:JSONSchema
                                                           connectivityStateResolver:connectivityStateResolver];
    
    self.imageLoader = [HUBImageLoaderMock new];
    
    self.viewController = [[HUBViewControllerImplementation alloc] initWithViewModelLoader:self.viewModelLoader
                                                                               imageLoader:self.imageLoader
                                                                     collectionViewFactory:collectionViewFactory
                                                                         componentRegistry:self.componentRegistry];
}

- (void)testContentLoadedOnViewWillAppear
{
    __block BOOL contentLoaded = NO;
    
    self.contentProvider.contentLoadingBlock = ^(BOOL loadFallbackContent) {
        contentLoaded = YES;
    };
    
    [self.viewController viewWillAppear:YES];
    
    XCTAssertTrue(contentLoaded);
}

- (void)testImageLoading
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
        
        [delegate localContentProviderDidLoad:strongSelf.contentProvider];
    };
    
    [self.viewController loadView];
    [self.viewController viewDidLoad];
    [self.viewController viewWillAppear:YES];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
}

- (void)testMissingImageLoadingContextHandled
{
    NSURL * const imageURL = [NSURL URLWithString:@"http://image.com"];
    [self.imageLoader.delegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL];
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
        
        [delegate localContentProviderDidLoad:strongSelf.contentProvider];
    };
    
    [self.viewController loadView];
    [self.viewController viewDidLoad];
    [self.viewController viewWillAppear:YES];
    
    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    
    NSIndexPath * const indexPathA = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath * const indexPathB = [NSIndexPath indexPathForItem:1 inSection:0];
    
    self.collectionView.cells[indexPathA] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathA];
    self.collectionView.cells[indexPathB] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathB];
    
    [self.imageLoader.delegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL];
    
    XCTAssertEqualObjects(componentA.mainImageData.URL, imageURL);
    XCTAssertEqualObjects(componentB.mainImageData.URL, imageURL);
}

@end
