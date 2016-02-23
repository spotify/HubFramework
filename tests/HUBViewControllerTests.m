#import <XCTest/XCTest.h>

#import "HUBViewController.h"
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

@interface HUBViewControllerTests : XCTestCase

@property (nonatomic, strong) HUBLocalContentProviderMock *contentProvider;
@property (nonatomic, strong) HUBComponentIdentifier *componentIdentifier;
@property (nonatomic, strong) HUBComponentMock *component;
@property (nonatomic, strong) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong) HUBViewModelLoaderImplementation *viewModelLoader;
@property (nonatomic, strong) HUBImageLoaderMock *imageLoader;
@property (nonatomic, strong) HUBViewController *viewController;

@end

@implementation HUBViewControllerTests

- (void)setUp
{
    [super setUp];
    
    self.contentProvider = [HUBLocalContentProviderMock new];
    
    self.componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namspace" name:@"name"];
    self.componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackComponentIdentifier:self.componentIdentifier];
    self.component = [HUBComponentMock new];
    
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
    
    self.viewController = [[HUBViewController alloc] initWithViewModelLoader:self.viewModelLoader
                                                                 imageLoader:self.imageLoader
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
        componentModelBuilder.componentName = @"component";
        componentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        componentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [componentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
        
        [delegate localContentProviderDidLoad:strongSelf.contentProvider];
    };
    
    [self.viewController loadView];
    [self.viewController viewDidLoad];
    [self.viewController viewWillAppear:YES];
    
    UICollectionView * const collectionView = self.viewController.collectionView;
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [collectionView.dataSource collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
    XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
}

- (void)testMissingImageLoadingContextHandled
{
    NSURL * const imageURL = [NSURL URLWithString:@"http://image.com"];
    [self.imageLoader.delegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL];
}

@end
