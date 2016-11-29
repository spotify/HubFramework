/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

#import <XCTest/XCTest.h>

#import "HUBViewController+Initializer.h"
#import "HUBViewModelLoaderImplementation.h"
#import "HUBContentOperationMock.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBIdentifier.h"
#import "HUBJSONSChemaRegistryImplementation.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBImageLoaderMock.h"
#import "HUBViewModelBuilder.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBComponentImageDataBuilder.h"
#import "HUBComponentTargetBuilder.h"
#import "HUBComponentTarget.h"
#import "HUBComponentFactoryMock.h"
#import "HUBComponentMock.h"
#import "HUBCollectionViewFactoryMock.h"
#import "HUBCollectionViewMock.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBActionHandlerMock.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBActionRegistryImplementation.h"
#import "HUBViewModel.h"
#import "HUBContentReloadPolicyMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBIconImageResolverMock.h"
#import "HUBFeatureInfoImplementation.h"
#import "HUBActionHandlerWrapper.h"
#import "HUBActionHandlerMock.h"
#import "HUBActionContext.h"
#import "HUBActionFactoryMock.h"
#import "HUBActionMock.h"
#import "HUBActionPerformer.h"
#import "HUBViewControllerScrollHandlerMock.h"
#import "HUBComponentCollectionViewCell.h"
#import "HUBUtilities.h"
#import "HUBTestUtilities.h"

@interface HUBViewControllerTests : XCTestCase <HUBViewControllerDelegate>

@property (nonatomic, strong) HUBContentOperationMock *contentOperation;
@property (nonatomic, strong) HUBContentReloadPolicyMock *contentReloadPolicy;
@property (nonatomic, strong) HUBIdentifier *componentIdentifier;
@property (nonatomic, strong) HUBComponentMock *component;
@property (nonatomic, strong) HUBComponentFactoryMock *componentFactory;
@property (nonatomic, strong) HUBCollectionViewMock *collectionView;
@property (nonatomic, strong) HUBCollectionViewFactoryMock *collectionViewFactory;
@property (nonatomic, strong) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong) HUBViewControllerScrollHandlerMock *scrollHandler;
@property (nonatomic, strong) HUBViewModelLoaderImplementation *viewModelLoader;
@property (nonatomic, strong) HUBImageLoaderMock *imageLoader;
@property (nonatomic, strong) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong) HUBActionHandlerMock *actionHandler;
@property (nonatomic, strong) HUBActionMock *selectionAction;
@property (nonatomic, strong) HUBActionRegistryImplementation *actionRegistry;
@property (nonatomic, strong) NSURL *viewURI;
@property (nonatomic, strong) HUBViewController *viewController;
@property (nonatomic, strong) id<HUBViewModel> viewModelFromDelegateMethod;
@property (nonatomic, strong) NSError *errorFromDelegateMethod;
@property (nonatomic, strong) NSMutableArray<id<HUBComponentModel>> *componentModelsFromAppearanceDelegateMethod;
@property (nonatomic, strong) NSMutableArray<NSSet<HUBComponentLayoutTrait> *> *componentLayoutTraitsFromAppearanceDelegateMethod;
@property (nonatomic, strong) NSMutableArray<id<HUBComponentModel>> *componentModelsFromDisapperanceDelegateMethod;
@property (nonatomic, strong) NSMutableArray<NSSet<HUBComponentLayoutTrait> *> *componentLayoutTraitsFromDisapperanceDelegateMethod;
@property (nonatomic, strong) NSMutableArray<id<HUBComponentModel>> *componentModelsFromSelectionDelegateMethod;
@property (nonatomic, strong) NSMutableArray<UIView *> *componentViewsFromApperanceDelegateMethod;
@property (nonatomic, strong) NSMutableArray<UIView *> *componentViewsFromReuseDelegateMethod;
@property (nonatomic, assign) BOOL didReceiveViewControllerDidFinishRendering;
@property (nonatomic, copy) void (^viewControllerDidFinishRenderingBlock)(void);
@property (nonatomic, copy) BOOL (^viewControllerShouldStartScrollingBlock)(void);
@property (nonatomic, copy) BOOL (^viewControllerShouldAutomaticallyManageTopContentInset)(void);
@property (nonatomic, assign) CGFloat topMarginForOverlayComponent;

@end

@implementation HUBViewControllerTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    HUBJSONSchemaRegistryImplementation * const JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                                                          iconImageResolver:iconImageResolver];
    
    self.contentOperation = [HUBContentOperationMock new];
    self.contentOperation.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"loadingIndicator"];
    };
    
    self.contentReloadPolicy = [HUBContentReloadPolicyMock new];
    self.componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:componentDefaults.componentNamespace name:componentDefaults.componentName];
    
    self.componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler
                                                                               componentDefaults:componentDefaults
                                                                              JSONSchemaRegistry:JSONSchemaRegistry
                                                                               iconImageResolver:iconImageResolver];
    
    self.scrollHandler = [HUBViewControllerScrollHandlerMock new];
    
    self.component = [HUBComponentMock new];
    self.componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{componentDefaults.componentName: self.component}];
    [self.componentRegistry registerComponentFactory:self.componentFactory forNamespace:componentDefaults.componentNamespace];
    
    self.collectionView = [HUBCollectionViewMock new];
    self.collectionViewFactory = [[HUBCollectionViewFactoryMock alloc] initWithCollectionView:self.collectionView];
    
    self.viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBFeatureInfoImplementation * const featureInfo = [[HUBFeatureInfoImplementation alloc] initWithIdentifier:@"id" title:@"title"];
    
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults iconImageResolver:iconImageResolver];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    self.viewModelLoader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:self.viewURI
                                                                         featureInfo:featureInfo
                                                                   contentOperations:@[self.contentOperation]
                                                                 contentReloadPolicy:self.contentReloadPolicy
                                                                          JSONSchema:JSONSchema
                                                                   componentDefaults:componentDefaults
                                                           connectivityStateResolver:connectivityStateResolver
                                                                   iconImageResolver:iconImageResolver
                                                                    initialViewModel:nil];
    
    self.imageLoader = [HUBImageLoaderMock new];
    
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    
    self.initialViewModelRegistry = [HUBInitialViewModelRegistry new];
    
    self.actionHandler = [HUBActionHandlerMock new];
    self.selectionAction = [[HUBActionMock alloc] initWithBlock:nil];
    self.actionRegistry = [[HUBActionRegistryImplementation alloc] initWithSelectionAction:self.selectionAction];
    
    
    id<HUBActionHandler> const actionHandler = [[HUBActionHandlerWrapper alloc] initWithActionHandler:self.actionHandler
                                                                                       actionRegistry:self.actionRegistry
                                                                             initialViewModelRegistry:self.initialViewModelRegistry
                                                                                      viewModelLoader:self.viewModelLoader];
    
    self.viewController = [[HUBViewController alloc] initWithViewURI:self.viewURI
                                                   featureIdentifier:featureInfo.identifier
                                                     viewModelLoader:self.viewModelLoader
                                               collectionViewFactory:self.collectionViewFactory
                                                   componentRegistry:self.componentRegistry
                                              componentLayoutManager:componentLayoutManager
                                                       actionHandler:actionHandler
                                                       scrollHandler:self.scrollHandler
                                                         imageLoader:self.imageLoader];
    
    self.viewController.delegate = self;
    
    self.viewModelFromDelegateMethod = nil;
    self.componentModelsFromAppearanceDelegateMethod = [NSMutableArray new];
    self.componentLayoutTraitsFromAppearanceDelegateMethod = [NSMutableArray new];
    self.componentModelsFromDisapperanceDelegateMethod = [NSMutableArray new];
    self.componentLayoutTraitsFromDisapperanceDelegateMethod = [NSMutableArray new];
    self.componentModelsFromSelectionDelegateMethod = [NSMutableArray new];
    self.componentViewsFromApperanceDelegateMethod = [NSMutableArray new];
    self.componentViewsFromReuseDelegateMethod = [NSMutableArray new];
    self.viewControllerShouldStartScrollingBlock = ^{ return YES; };
    self.viewControllerShouldAutomaticallyManageTopContentInset = ^{ return YES; };
    self.topMarginForOverlayComponent = 0;
}

#pragma mark - Tests

- (void)testContentLoadedOnViewWillAppear
{
    __block BOOL contentLoaded = NO;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        contentLoaded = YES;
        return YES;
    };
    
    [self.viewController viewWillAppear:YES];
    
    XCTAssertTrue(contentLoaded);
}

- (void)testThatComponentsAreLoadedIfViewWasLaidOutBeforeItAppeared
{
    // the content loading is async and is triggered on `viewWillAppear:`
    // so it is likely that the loading will finish after the `viewDidAppear:` was called
    __weak __typeof(self.viewController) weakViewController = self.viewController;
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [weakViewController viewDidAppear:YES];
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"one"].title = @"One";
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"two"].title = @"Two";
        return YES;
    };

    [self.viewController loadView];
    [self.viewController viewDidLoad];
    self.viewController.view.frame = CGRectMake(0, 0, 320, 400);
    [self.viewController viewDidLayoutSubviews];

    [self.viewController viewWillAppear:YES];

    XCTAssertEqual([self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0], 2);
}

- (void)testUpdatingComponentsWithBatchUpdateDoesntCrash
{
    __weak __typeof(self.viewController) weakViewController = self.viewController;
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [weakViewController viewDidAppear:YES];
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"one"].title = @"One";
        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    id<UICollectionViewDataSource> dataSource = self.collectionView.dataSource;
    XCTAssertEqual([dataSource collectionView:self.collectionView numberOfItemsInSection:0], 1);

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"one"].title = @"One";
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"two"].title = @"Two";
        return YES;
    };

    [self.contentOperation.delegate contentOperationRequiresRescheduling:self.contentOperation];
    XCTAssertEqual([dataSource collectionView:self.collectionView numberOfItemsInSection:0], 2);
}

- (void)testDelegateNotifiedOfUpdatedViewModel
{
    NSString * const viewModelNavBarTitleA = @"View model A";
    NSString * const viewModelNavBarTitleB = @"View model B";
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = viewModelNavBarTitleA;
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqualObjects(self.viewModelFromDelegateMethod.navigationItem.title, viewModelNavBarTitleA);
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = viewModelNavBarTitleB;
        return YES;
    };
    
    self.contentReloadPolicy.shouldReload = YES;
    [self.viewController viewWillAppear:YES];
    
    XCTAssertEqualObjects(self.viewModelFromDelegateMethod.navigationItem.title, viewModelNavBarTitleB);
}

- (void)testReloadViewModel
{
    NSString * const viewModelNavBarTitleA = @"View model A";
    NSString * const viewModelNavBarTitleB = @"View model B";
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = viewModelNavBarTitleA;
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqualObjects(self.viewModelFromDelegateMethod.navigationItem.title, viewModelNavBarTitleA);
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = viewModelNavBarTitleB;
        return YES;
    };
    
    [self.viewController reload];
    
    XCTAssertEqualObjects(self.viewModelFromDelegateMethod.navigationItem.title, viewModelNavBarTitleB);
}


- (void)testDelegateNotifiedOfViewModelUpdateError
{
    NSError * const error = [NSError errorWithDomain:@"hubFramework" code:4 userInfo:nil];
    self.contentOperation.error = error;
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.errorFromDelegateMethod, error);
}

- (void)testHeaderComponentImageLoading
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];
    NSURL * const customImageURL = [NSURL URLWithString:@"https://image.custom"];
    NSString * const customImageIdentifier = @"custom";
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        __typeof(self) strongSelf = weakSelf;
        
        builder.headerComponentModelBuilder.componentName = strongSelf.componentIdentifier.namePart;
        builder.headerComponentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        builder.headerComponentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [builder.headerComponentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    [self performAsynchronousTestWithDelay:0 block:^{
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
    }];
}

- (void)testBodyComponentImageLoading
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    UIImage * const localMainImage = [UIImage new];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];
    NSURL * const customImageURL = [NSURL URLWithString:@"https://image.custom"];
    NSString * const customImageIdentifier = @"custom";
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.namePart;
        componentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        componentModelBuilder.mainImageDataBuilder.localImage = localMainImage;
        componentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [componentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    XCTAssertEqual(self.component.mainImageData.localImage, localMainImage);
    XCTAssertNil(self.component.backgroundImageData);
    
    [self performAsynchronousTestWithDelay:0 block:^{
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
    }];
}

- (void)testOverlayComponentImageLoading
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];
    NSURL * const customImageURL = [NSURL URLWithString:@"https://image.custom"];
    NSString * const customImageIdentifier = @"custom";
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBComponentModelBuilder> const overlayComponentModelBuilder = [builder builderForOverlayComponentModelWithIdentifier:@"overlay"];
        
        overlayComponentModelBuilder.componentNamespace = strongSelf.componentIdentifier.namespacePart;
        overlayComponentModelBuilder.componentName = strongSelf.componentIdentifier.namePart;
        overlayComponentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        overlayComponentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [overlayComponentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    [self performAsynchronousTestWithDelay:0 block:^{
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:mainImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:backgroundImageURL]);
        XCTAssertTrue([self.imageLoader hasLoadedImageForURL:customImageURL]);
    }];
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
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilderA = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"componentA"];
        componentModelBuilderA.componentNamespace = componentNamespace;
        componentModelBuilderA.componentName = componentNameA;
        componentModelBuilderA.mainImageDataBuilder.URL = imageURL;
        
        id<HUBComponentModelBuilder> const componentModelBuilderB = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"componentB"];
        componentModelBuilderB.componentNamespace = componentNamespace;
        componentModelBuilderB.componentName = componentNameB;
        componentModelBuilderB.mainImageDataBuilder.URL = imageURL;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    
    NSIndexPath * const indexPathA = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath * const indexPathB = [NSIndexPath indexPathForItem:1 inSection:0];
    
    self.collectionView.cells[indexPathA] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathA];
    self.collectionView.cells[indexPathB] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathB];
    
    [self.imageLoader.delegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL];
    
    XCTAssertEqualObjects(componentA.mainImageData.URL, imageURL);
    XCTAssertEqualObjects(componentB.mainImageData.URL, imageURL);
}

- (void)testReloadingImage
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.url"];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.mainImageURL = imageURL;
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    id<HUBImageLoaderDelegate> const imageLoaderDelegate = self.imageLoader.delegate;
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.collectionView.cells[indexPath] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    [imageLoaderDelegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL];
    XCTAssertEqualObjects(self.component.mainImageData.URL, imageURL);
    
    [self.component prepareViewForReuse];
    XCTAssertNil(self.component.mainImageData);
    
    [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    [imageLoaderDelegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL];
    XCTAssertEqualObjects(self.component.mainImageData.URL, imageURL);
}

- (void)testDownloadFromNetworkImageAnimation
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.url"];

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.mainImageURL = imageURL;
        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    id<HUBImageLoaderDelegate> const imageLoaderDelegate = self.imageLoader.delegate;
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.collectionView.cells[indexPath] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    NSTimeInterval downloadFromNetworkTime = 2;
    [NSThread sleepForTimeInterval:downloadFromNetworkTime];
    [imageLoaderDelegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL];
    XCTAssertTrue(self.component.imageWasAnimated);
}

- (void)testDownloadFromCacheImageAnimation
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.url"];

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.mainImageURL = imageURL;
        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    id<HUBImageLoaderDelegate> const imageLoaderDelegate = self.imageLoader.delegate;
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.collectionView.cells[indexPath] = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    [imageLoaderDelegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL];
    XCTAssertFalse(self.component.imageWasAnimated);
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
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;
        childComponentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        childComponentModelBuilder.backgroundImageDataBuilder.URL = backgroundImageURL;
        [childComponentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier].URL = customImageURL;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [component.childDelegate component:component willDisplayChildAtIndex:0 view:[UIView new]];
    
    [self performAsynchronousTestWithDelay:0 block:^{
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
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.namePart;
        componentModelBuilder.mainImageDataBuilder.URL = mainImageURL;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    XCTAssertFalse([self.imageLoader hasLoadedImageForURL:mainImageURL]);
}

- (void)testHeaderComponentReuse
{
    __weak __typeof(self) weakSelf = self;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        viewModelBuilder.headerComponentModelBuilder.componentName = strongSelf.componentIdentifier.namePart;
        viewModelBuilder.headerComponentModelBuilder.title = [NSUUID UUID].UUIDString;
        return YES;
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

- (void)testHeaderComponentNotReconfiguredForSameModel
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.title = @"Header";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqualObjects(self.component.model.title, @"Header");
    
    self.contentReloadPolicy.shouldReload = YES;
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqual(self.contentOperation.performCount, 3u);
    XCTAssertEqual(self.component.numberOfReuses, 0u);
}

- (void)testHeaderComponentNotifiedOfViewWillAppear
{
    self.component.isViewObserver = YES;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.title = @"Header";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.component.numberOfAppearances, (NSUInteger)1);
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewWillAppear:YES];
    
    XCTAssertEqual(self.component.numberOfAppearances, (NSUInteger)3);
}

- (void)testOverlayComponentReuse
{
    HUBComponentMock * const componentA = [HUBComponentMock new];
    HUBComponentMock * const componentB = [HUBComponentMock new];
    
    id<HUBComponentFactory> const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        @"a": componentA,
        @"b": componentB
    }];
    
    NSString * const componentNamespace = @"overlayReuse";
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    __block NSUInteger loadCount = 0;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const overlayComponentModelBuilder = [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"overlay"];
        overlayComponentModelBuilder.componentNamespace = componentNamespace;
        overlayComponentModelBuilder.title = [NSUUID UUID].UUIDString;
        
        if (loadCount < 3) {
            overlayComponentModelBuilder.componentName = @"a";
        } else {
            overlayComponentModelBuilder.componentName = @"b";
        }
        
        loadCount++;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(componentA.numberOfReuses, (NSUInteger)0);
    XCTAssertEqual(componentB.numberOfReuses, (NSUInteger)0);
    
    self.contentReloadPolicy.shouldReload = YES;
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqual(componentA.numberOfReuses, (NSUInteger)2);
    XCTAssertEqual(componentB.numberOfReuses, (NSUInteger)0);
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqual(componentA.numberOfReuses, (NSUInteger)2);
    XCTAssertEqual(componentB.numberOfReuses, (NSUInteger)1);
}

- (void)testOverlayComponentNotReconfiguredForSameModel
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"id"].title = @"Overlay";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqualObjects(self.component.model.title, @"Overlay");
    
    self.contentReloadPolicy.shouldReload = YES;
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqual(self.contentOperation.performCount, 3u);
    XCTAssertEqual(self.component.numberOfReuses, 0u);
}

- (void)testRemovedOverlayComponentsRemovedFromView
{
    __block BOOL isFirstLoad = YES;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        NSString * const overlayIdentifier = @"overlay";
        
        if (isFirstLoad) {
            [viewModelBuilder builderForOverlayComponentModelWithIdentifier:overlayIdentifier].title = @"Title";
        } else {
            [viewModelBuilder removeBuilderForOverlayComponentModelWithIdentifier:overlayIdentifier];
        }
        
        isFirstLoad = NO;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    XCTAssertNotNil(self.component.view.superview);
    
    [self.contentOperation.delegate contentOperationRequiresRescheduling:self.contentOperation];
    [self.viewController viewDidLayoutSubviews];
    XCTAssertNil(self.component.view.superview);
}

- (void)testUnreusedOverlayComponentsRemovedFromView
{
    __block BOOL isFirstLoad = YES;
    
    HUBComponentMock * const alternativeComponent = [HUBComponentMock new];
    HUBComponentFactoryMock * const alternativeComponentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{@"alternative": alternativeComponent}];
    [self.componentRegistry registerComponentFactory:alternativeComponentFactory forNamespace:@"alternative"];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"overlay"];
        
        if (!isFirstLoad) {
            componentModelBuilder.componentNamespace = @"alternative";
            componentModelBuilder.componentName = @"alternative";
        }
        
        isFirstLoad = NO;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    XCTAssertNotNil(self.component.view.superview);
    XCTAssertNil(alternativeComponent.view);
    
    [self.contentOperation.delegate contentOperationRequiresRescheduling:self.contentOperation];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertNotNil(alternativeComponent.view.superview);
    XCTAssertNil(self.component.view.superview);
}

- (void)testOverlayComponentsNotifiedOfViewWillAppear
{
    self.component.isViewObserver = YES;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"overlay"].title = @"Header";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.component.numberOfAppearances, (NSUInteger)1);
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewWillAppear:YES];
    
    XCTAssertEqual(self.component.numberOfAppearances, (NSUInteger)3);
}

- (void)testInitialViewModelForTargetViewControllerRegistered
{
    __weak __typeof(self) weakSelf = self;
    
    NSString * const initialViewModelIdentifier = @"initialViewModel";
    NSURL * const targetViewURI = [NSURL URLWithString:@"spotify:hub:target"];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"id"];
        componentModelBuilder.componentName = weakSelf.componentIdentifier.namePart;
        componentModelBuilder.targetBuilder.URI = targetViewURI;
        componentModelBuilder.targetBuilder.initialViewModelBuilder.viewIdentifier = initialViewModelIdentifier;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    __block id<HUBViewModel> targetInitialViewModel = nil;
    
    self.selectionAction.block = ^BOOL(id<HUBActionContext> context) {
        targetInitialViewModel = [self.initialViewModelRegistry initialViewModelForViewURI:targetViewURI];
        return YES;
    };
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    [self.viewController selectComponentWithModel:componentModel customData:nil];
    
    XCTAssertEqualObjects(targetInitialViewModel.identifier, initialViewModelIdentifier);
}

- (void)testComponentDeselectedAfterDefaultSelectionHandling
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const cellIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:cellIndexPath];
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    [self.viewController selectComponentWithModel:componentModel customData:nil];
    
    XCTAssertEqual(self.component.selectionState, HUBComponentSelectionStateSelected);
    
    [self performAsynchronousTestWithDelay:1 block:^{
        XCTAssertEqual(self.component.selectionState, HUBComponentSelectionStateNone);
    }];
}

- (void)testComponentDeselectedAfterCustomSelectionHandling
{
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const cellIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:cellIndexPath];
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    [self.viewController selectComponentWithModel:componentModel customData:nil];
    
    XCTAssertEqual(self.component.selectionState, HUBComponentSelectionStateSelected);
    
    [self performAsynchronousTestWithDelay:1 block:^{
        XCTAssertEqual(self.component.selectionState, HUBComponentSelectionStateNone);
    }];
}

- (void)testCreatingAndReusingChildComponent
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
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilderA = [componentModelBuilder builderForChildWithIdentifier:@"childA"];
        childComponentModelBuilderA.componentNamespace = componentNamespace;
        childComponentModelBuilderA.componentName = childComponentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilderB = [componentModelBuilder builderForChildWithIdentifier:@"childB"];
        childComponentModelBuilderB.componentNamespace = componentNamespace;
        childComponentModelBuilderB.componentName = childComponentName;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    id<HUBComponentChildDelegate> const childDelegate = component.childDelegate;
    
    id<HUBComponentModel> const childComponentModelA = [component.model childAtIndex:0];
    XCTAssertNotNil(childComponentModelA);
    
    id<HUBComponent> const childComponentWrapper = [childDelegate component:component childComponentForModel:childComponentModelA];
    XCTAssertEqual(childComponentWrapper.view, childComponent.view);
    XCTAssertTrue(CGSizeEqualToSize(childComponent.view.frame.size, childComponent.preferredViewSize),
                  @"Sizes not equal: %@ and %@",
                  NSStringFromCGSize(childComponent.view.frame.size),
                  NSStringFromCGSize(childComponent.preferredViewSize));
    
    [childComponentWrapper prepareViewForReuse];
    
    id<HUBComponentModel> const childComponentModelB = [component.model childAtIndex:1];
    XCTAssertNotNil(childComponentModelB);
    
    id<HUBComponent> const reusedChildComponentWrapper = [childDelegate component:component childComponentForModel:childComponentModelB];
    XCTAssertEqual(childComponentWrapper, reusedChildComponentWrapper);
}

- (void)testChildComponentsRemovedFromParentOnReuse
{
    HUBComponentMock * const componentA = [HUBComponentMock new];
    componentA.view = [[UIView alloc] initWithFrame:CGRectZero];

    HUBComponentMock * const componentB = [HUBComponentMock new];
    componentB.view = [[UIView alloc] initWithFrame:CGRectZero];

    HUBComponentMock * const childComponent = [HUBComponentMock new];
    UIView *childComponentView = [[UIView alloc] initWithFrame:CGRectZero];
    childComponent.view = childComponentView;

    self.componentFactory.components[@"A"] = componentA;
    self.componentFactory.components[@"B"] = componentB;
    self.componentFactory.components[@"child"] = childComponent;

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilderA = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"A"];
        componentModelBuilderA.componentName = @"A";
        [componentModelBuilderA builderForChildWithIdentifier:@"childA"].componentName = @"child";

        id<HUBComponentModelBuilder> const componentModelBuilderB = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"B"];
        componentModelBuilderB.componentName = @"B";
        [componentModelBuilderB builderForChildWithIdentifier:@"childB"].componentName = @"child";

        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;

    NSIndexPath * const indexPathA = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cellA = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathA];

    NSIndexPath * const indexPathB = [NSIndexPath indexPathForItem:1 inSection:0];
    UICollectionViewCell * const cellB = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathB];

    self.collectionView.mockedVisibleCells = @[cellA, cellB];
    self.collectionView.cells[indexPathA] = cellA;
    self.collectionView.cells[indexPathB] = cellB;

    id<HUBComponentChildDelegate> componentAChildDelegate = componentA.childDelegate;
    id<HUBComponentModel> const childComponentModelA = [componentA.model childAtIndex:0];
    id<HUBComponent> const childComponentWrapperA = [componentAChildDelegate component:componentA childComponentForModel:childComponentModelA];

    [componentAChildDelegate component:componentA willDisplayChildAtIndex:0 view:childComponentView];
    NSIndexPath * const indexPathChildA = [NSIndexPath indexPathForItem:0 inSection:0];
    XCTAssertEqual([self.viewController visibleViewForComponentOfType:HUBComponentTypeBody indexPath:indexPathChildA], childComponentView);

    [childComponentWrapperA prepareViewForReuse];
    XCTAssertNil([self.viewController visibleViewForComponentOfType:HUBComponentTypeBody indexPath:indexPathChildA]);

    id<HUBComponentChildDelegate> componentBChildDelegate = componentB.childDelegate;
    id<HUBComponentModel> const childComponentModelB = [componentB.model childAtIndex:0];
    id<HUBComponent> const childComponentWrapperB = [componentBChildDelegate component:componentB childComponentForModel:childComponentModelB];
    XCTAssertEqual(childComponentWrapperA, childComponentWrapperB);

    [componentBChildDelegate component:componentB willDisplayChildAtIndex:0 view:childComponentView];
    NSIndexPath * const indexPathChildB = [NSIndexPath indexPathForItem:0 inSection:1];
    XCTAssertEqual([self.viewController visibleViewForComponentOfType:HUBComponentTypeBody indexPath:indexPathChildB], childComponentView);

    [childComponentWrapperB prepareViewForReuse];
    XCTAssertNil([self.viewController visibleViewForComponentOfType:HUBComponentTypeBody indexPath:indexPathChildB]);
}

- (void)testSelectionForRootComponent
{
    NSString * const componentNamespace = @"selectionForRootComponent";
    NSString * const nonSelectableIdentifier = @"nonSelectable";
    NSString * const selectableIdentifier = @"selectable";
    
    HUBComponentMock * const nonSelectableComponent = [HUBComponentMock new];
    HUBComponentMock * const selectableComponent = [HUBComponentMock new];
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        nonSelectableIdentifier: nonSelectableComponent,
        selectableIdentifier: selectableComponent
    }];
    
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const nonSelectableBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:nonSelectableIdentifier];
        nonSelectableBuilder.componentNamespace = componentNamespace;
        nonSelectableBuilder.componentName = nonSelectableIdentifier;
        
        id<HUBComponentModelBuilder> const selectableBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:selectableIdentifier];
        selectableBuilder.componentNamespace = componentNamespace;
        selectableBuilder.componentName = selectableIdentifier;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    self.selectionAction.block = ^BOOL(id<HUBActionContext> context) {
        return [context.componentModel.identifier isEqualToString:selectableIdentifier];
    };
    
    id<HUBComponentModel> const nonSelectableComponentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    [self.viewController selectComponentWithModel:nonSelectableComponentModel customData:nil];
    XCTAssertEqual(self.componentModelsFromSelectionDelegateMethod.count, (NSUInteger)0);
    
    id<HUBComponentModel> const selectableComponentModel = self.viewModelFromDelegateMethod.bodyComponentModels[1];
    [self.viewController selectComponentWithModel:selectableComponentModel customData:nil];
    XCTAssertEqual(self.componentModelsFromSelectionDelegateMethod.count, (NSUInteger)1);
    XCTAssertEqualObjects(self.componentModelsFromSelectionDelegateMethod[0].identifier, selectableIdentifier);
    
    // Test custom selection action handling
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    [self.viewController selectComponentWithModel:selectableComponentModel customData:nil];
    XCTAssertEqual(self.actionHandler.contexts.count, (NSUInteger)1);

    id<HUBActionContext> actionContext = self.actionHandler.contexts.firstObject;
    XCTAssertEqualObjects(actionContext.componentModel.identifier, selectableIdentifier);
    XCTAssertEqualObjects(actionContext.viewURI, self.viewURI);
    XCTAssertEqualObjects(actionContext.viewModel, self.viewModelFromDelegateMethod);
    XCTAssertEqualObjects(actionContext.viewController, self.viewController);
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
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;
        
        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;
        childComponentModelBuilder.targetBuilder.URI = childComponentTargetURL;
        childComponentModelBuilder.targetBuilder.initialViewModelBuilder.viewIdentifier = childComponentInitialViewModelIdentifier;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    __block id<HUBViewModel> childComponentTargetInitialViewModel = nil;
    
    self.selectionAction.block = ^BOOL(id<HUBActionContext> context) {
        childComponentTargetInitialViewModel = [self.initialViewModelRegistry initialViewModelForViewURI:childComponentTargetURL];
        return YES;
    };
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    id<HUBComponentChildDelegate> const childDelegate = component.childDelegate;
    NSDictionary<NSString *, id> *customData = @{@"custom":@"data"};
    [childDelegate component:component childSelectedAtIndex:0 customData:customData];
    
    XCTAssertEqualObjects(childComponentTargetInitialViewModel.identifier, childComponentInitialViewModelIdentifier);
    
    // Make sure bounds-checking is performed for child component index
    [childDelegate component:component willDisplayChildAtIndex:99 view:[UIView new]];
    
    XCTAssertEqual(self.componentModelsFromSelectionDelegateMethod.count, (NSUInteger)1);
    XCTAssertEqualObjects(self.componentModelsFromSelectionDelegateMethod[0].target.URI, childComponentTargetURL);
    
    // Test custom selection handling
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    [childDelegate component:component childSelectedAtIndex:0 customData:customData];
    XCTAssertEqual(self.actionHandler.contexts.count, (NSUInteger)1);

    id<HUBActionContext> actionContext = self.actionHandler.contexts.firstObject;
    XCTAssertEqualObjects(actionContext.componentModel.target.URI, childComponentTargetURL);
    XCTAssertEqualObjects(actionContext.viewController, self.viewController);
    XCTAssertEqualObjects(actionContext.viewModel, self.viewModelFromDelegateMethod);
    XCTAssertEqualObjects(actionContext.viewURI, self.viewURI);
    XCTAssertEqualObjects(actionContext.customData, customData);
}

- (void)testProgrammaticSelectionForRootComponent
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].targetBuilder.URI = [NSURL URLWithString:@"spotify:hub:framework"];
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    XCTAssertTrue([self.viewController selectComponentWithModel:componentModel customData:nil]);
    XCTAssertEqualObjects(self.componentModelsFromSelectionDelegateMethod, @[componentModel]);
    XCTAssertEqualObjects(self.actionHandler.contexts.firstObject.componentModel, componentModel);
}

- (void)testProgrammaticSelectionForChildComponent
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const parentBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"parent"];
        id<HUBComponentModelBuilder> const childBuilder = [parentBuilder builderForChildWithIdentifier:@"child"];
        childBuilder.targetBuilder.URI = [NSURL URLWithString:@"spotify:hub:framework"];
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0].children[0];
    NSDictionary<NSString *, id> *customData = @{@"custom":@"data"};

    XCTAssertTrue([self.viewController selectComponentWithModel:componentModel customData:customData]);
    XCTAssertEqualObjects(self.componentModelsFromSelectionDelegateMethod, @[componentModel]);
    XCTAssertEqualObjects(self.actionHandler.contexts.firstObject.componentModel, componentModel);
    XCTAssertEqualObjects(self.actionHandler.contexts.firstObject.customData, customData);
}

- (void)testProgrammaticSelectionForNonSelectableComponentReturningFalse
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].title = @"Component title";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    XCTAssertFalse([self.viewController selectComponentWithModel:componentModel customData:nil]);
    XCTAssertEqual(self.componentModelsFromSelectionDelegateMethod.count, (NSUInteger)0);
}

- (void)testComponentNotifiedOfResize
{
    self.component.isViewObserver = YES;
    
    __weak __typeof(self) weakSelf = self;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentName = strongSelf.componentIdentifier.namePart;
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    cell.frame = CGRectMake(0, 0, 300, 200);
    [self simulateLayoutForViewHierarchyStartingWithView:cell];
    XCTAssertEqual(self.component.numberOfResizes, (NSUInteger)1);
    
    // Subsequent layout passes should not notify the component, unless the size has changed
    [self simulateLayoutForViewHierarchyStartingWithView:cell];
    [self simulateLayoutForViewHierarchyStartingWithView:cell];
    [self simulateLayoutForViewHierarchyStartingWithView:cell];
    XCTAssertEqual(self.component.numberOfResizes, (NSUInteger)1);
    
    cell.frame = CGRectMake(0, 0, 300, 100);
    [self simulateLayoutForViewHierarchyStartingWithView:cell];
    XCTAssertEqual(self.component.numberOfResizes, (NSUInteger)2);
}

- (void)testComponentNotifiedOfViewWillAppearWhenCellIsDisplayed
{
    [self.component.layoutTraits addObject:HUBComponentLayoutTraitCentered];
    self.component.isViewObserver = YES;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].title = @"title";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    self.collectionView.cells[indexPath] = cell;
    
    id<UICollectionViewDelegate> const collectionViewDelegate = self.collectionView.delegate;
    
    [collectionViewDelegate collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    [collectionViewDelegate collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    [collectionViewDelegate collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    
    XCTAssertEqual(self.component.numberOfAppearances, 1u);
    XCTAssertEqual(self.componentModelsFromAppearanceDelegateMethod.count, 1u);
    XCTAssertEqualObjects(self.componentModelsFromAppearanceDelegateMethod[0].title, @"title");
    XCTAssertEqualObjects(self.componentViewsFromApperanceDelegateMethod, @[self.component.view]);
    XCTAssertEqual(self.componentLayoutTraitsFromAppearanceDelegateMethod.count, 1u);
    XCTAssertEqualObjects(self.componentLayoutTraitsFromAppearanceDelegateMethod[0], [NSSet setWithObject:HUBComponentLayoutTraitCentered]);

    self.collectionView.mockedIndexPathsForVisibleItems = @[indexPath];
    [self.viewController viewWillAppear:NO];
    
    XCTAssertEqual(self.component.numberOfAppearances, 2u);
    XCTAssertEqual(self.componentModelsFromAppearanceDelegateMethod.count, 2u);
    XCTAssertEqualObjects(self.componentModelsFromAppearanceDelegateMethod[1].title, @"title");
    XCTAssertEqual(self.componentLayoutTraitsFromAppearanceDelegateMethod.count, 2u);
    XCTAssertEqualObjects(self.componentLayoutTraitsFromAppearanceDelegateMethod[1], [NSSet setWithObject:HUBComponentLayoutTraitCentered]);
}

- (void)testChildComponentsNotifiedWhenParentComponentIsDisplayed
{
    HUBComponentMock * const childComponentA = [HUBComponentMock new];
    HUBComponentMock * const childComponentB = [HUBComponentMock new];
    HUBComponentMock * const childComponentC = [HUBComponentMock new];
    
    childComponentA.isViewObserver = YES;
    childComponentB.isViewObserver = YES;
    childComponentC.isViewObserver = YES;
    
    self.componentFactory.components[@"childA"] = childComponentA;
    self.componentFactory.components[@"childB"] = childComponentB;
    self.componentFactory.components[@"childC"] = childComponentC;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const parentComponentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"parent"];
        [parentComponentModelBuilder builderForChildWithIdentifier:@"childA"].componentName = @"childA";
        [parentComponentModelBuilder builderForChildWithIdentifier:@"childB"].componentName = @"childB";
        [parentComponentModelBuilder builderForChildWithIdentifier:@"childC"].componentName = @"childC";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    self.collectionView.cells[indexPath] = cell;
    
    id<UICollectionViewDelegate> const collectionViewDelegate = self.collectionView.delegate;
    [collectionViewDelegate collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    NSArray<id<HUBComponentModel>> * const children = componentModel.children;
    id<HUBComponentChildDelegate> const childDelegate = self.component.childDelegate;
    
    [childDelegate component:self.component childComponentForModel:children[0]];
    [childDelegate component:self.component childComponentForModel:children[1]];
    [childDelegate component:self.component childComponentForModel:children[2]];
    
    [childDelegate component:self.component willDisplayChildAtIndex:0 view:(UIView *)childComponentA.view];
    [childDelegate component:self.component willDisplayChildAtIndex:1 view:(UIView *)childComponentB.view];
    [childDelegate component:self.component willDisplayChildAtIndex:2 view:(UIView *)childComponentC.view];
    
    XCTAssertEqual(childComponentA.numberOfAppearances, (NSUInteger)1);
    XCTAssertEqual(childComponentB.numberOfAppearances, (NSUInteger)1);
    XCTAssertEqual(childComponentC.numberOfAppearances, (NSUInteger)1);
    
    NSArray * const expectedAppearanceComponentModels = @[
        componentModel,
        children[0],
        children[1],
        children[2]
    ];
    
    XCTAssertEqualObjects(self.componentModelsFromAppearanceDelegateMethod, expectedAppearanceComponentModels);
    
    [collectionViewDelegate scrollViewWillBeginDragging:self.collectionView];
    [collectionViewDelegate collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    
    [collectionViewDelegate scrollViewDidEndDecelerating:self.collectionView];
    
    XCTAssertEqual(childComponentA.numberOfAppearances, (NSUInteger)2);
    XCTAssertEqual(childComponentB.numberOfAppearances, (NSUInteger)2);
    XCTAssertEqual(childComponentC.numberOfAppearances, (NSUInteger)2);
    
    /// All children + root component should now have appeared twice: (3 + 1) * 2 = 8.
    XCTAssertEqual(self.componentModelsFromAppearanceDelegateMethod.count, (NSUInteger)8);
}

- (void)testDelegateNotifiedWhenRootComponentDisappeared
{
    [self.component.layoutTraits addObject:HUBComponentLayoutTraitStackable];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].title = @"Title";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView.delegate collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    
    XCTAssertEqual(self.componentModelsFromDisapperanceDelegateMethod.count, 1u);
    XCTAssertEqualObjects(self.componentModelsFromDisapperanceDelegateMethod[0].title, @"Title");
    XCTAssertEqual(self.componentLayoutTraitsFromDisapperanceDelegateMethod.count, 1u);
    XCTAssertEqualObjects(self.componentLayoutTraitsFromDisapperanceDelegateMethod[0], [NSSet setWithObject:HUBComponentLayoutTraitStackable]);
}

- (void)testDelegateNotifiedWhenChildComponentDisappeared
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.title = @"Title";
        [componentModelBuilder builderForChildWithIdentifier:@"child"].title = @"Child title";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [self.component.childDelegate component:self.component didStopDisplayingChildAtIndex:0 view:[UIView new]];
    
    XCTAssertEqual(self.componentModelsFromDisapperanceDelegateMethod.count, (NSUInteger)1);
    XCTAssertEqualObjects(self.componentModelsFromDisapperanceDelegateMethod[0].title, @"Child title");
}

- (void)testDelegateNotifiedWhenLayoutChanged
{
    XCTAssertFalse(self.didReceiveViewControllerDidFinishRendering);
    [self simulateViewControllerLayoutCycle];
    XCTAssertTrue(self.didReceiveViewControllerDidFinishRendering);
}

- (void)testSavingAndRestoringHeaderComponentUIState
{
    __weak __typeof(self) weakSelf = self;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        viewModelBuilder.headerComponentModelBuilder.componentName = strongSelf.componentIdentifier.namePart;
        viewModelBuilder.headerComponentModelBuilder.title = [NSUUID UUID].UUIDString;
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id state = @"State!";
    self.component.currentUIState = state;
    self.component.supportsRestorableUIState = YES;
    
    self.contentReloadPolicy.shouldReload = YES;
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqualObjects(self.component.restoredUIStates, @[state]);
}

- (void)testSavingAndRestoringOverlayComponentUIState
{
    __block BOOL hasBeenLoadedBefore = NO;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"id"];
        
        if (hasBeenLoadedBefore) {
            componentModelBuilder.title = @"First title";
        } else {
            componentModelBuilder.title = @"Second title";
            hasBeenLoadedBefore = YES;
        }
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id state = @"State!";
    self.component.currentUIState = state;
    self.component.supportsRestorableUIState = YES;
    
    self.contentReloadPolicy.shouldReload = YES;
    
    [self.viewController viewWillAppear:YES];
    [self.viewController viewDidLayoutSubviews];
    
    XCTAssertEqualObjects(self.component.restoredUIStates, @[state]);
}

- (void)testSavingAndRestoringBodyComponentUIState
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"one"].title = @"One";
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"two"].title = @"Two";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    
    NSIndexPath * const firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath * const secondIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    UICollectionViewCell * const cell = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:firstIndexPath];
    self.collectionView.cells[firstIndexPath] = cell;
    self.collectionView.cells[secondIndexPath] = cell;
    
    id state = @"State!";
    self.component.currentUIState = state;
    self.component.supportsRestorableUIState = YES;
    
    [cell prepareForReuse];
    [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:secondIndexPath];
    [cell prepareForReuse];
    [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:firstIndexPath];
    XCTAssertEqualObjects(self.component.restoredUIStates, @[state]);
    
    // Make sure that the component was actually reused
    XCTAssertEqual(self.component.numberOfReuses, (NSUInteger)2);
}

- (void)testViewControllerDelegateIsNotifiedWhenComponentIsReused
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"one"].title = @"One";
        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    XCTAssertEqualObjects(self.componentViewsFromReuseDelegateMethod, @[]);

    [cell prepareForReuse];

    XCTAssertEqualObjects(self.componentViewsFromReuseDelegateMethod, @[self.component.view]);
}

- (void)testSettingBackgroundColorOfViewAlsoUpdatesCollectionView
{
    self.viewController.view.backgroundColor = [UIColor redColor];
    [self.viewController viewWillAppear:NO];
    XCTAssertEqualObjects(self.collectionView.backgroundColor, [UIColor redColor]);
}

- (void)testSettingBackgroundColorOfViewDoesNotUpdateHeaderComponentBackgroundColor
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.title = @"header";
        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    self.component.view.backgroundColor = [UIColor greenColor];
    self.viewController.view.backgroundColor = [UIColor redColor];
    XCTAssertEqualObjects(self.component.view.backgroundColor, [UIColor greenColor]);
}

- (void)testContainerViewSizeForNonReusedRootComponentsAreSameAsCollectionViewSize
{
    __weak __typeof(self) weakSelf = self;

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"one"].componentName = strongSelf.componentIdentifier.namePart;
        return YES;
    };

    [self simulateViewControllerLayoutCycle];
    NSIndexPath * const firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:firstIndexPath];

    XCTAssertTrue(CGSizeEqualToSize(self.component.currentContainerViewSize, self.collectionView.bounds.size));
}

- (void)testContainerViewSizeForReusedRootComponentsAreSameAsCollectionViewSize
{
    __weak __typeof(self) weakSelf = self;

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        __typeof(self) strongSelf = weakSelf;
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"one"].componentName = strongSelf.componentIdentifier.namePart;
        return YES;
    };

    [self simulateViewControllerLayoutCycle];
    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    NSIndexPath * const firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    UICollectionViewCell *cell = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:firstIndexPath];
    self.collectionView.cells[firstIndexPath] = cell;
    [cell prepareForReuse];
    
    [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:firstIndexPath];

    XCTAssertTrue(CGSizeEqualToSize(self.component.currentContainerViewSize, self.collectionView.bounds.size));
}

- (void)testContainerViewSizeForChildComponentsAreParentComponentsViewSize
{
    NSString * const componentNamespace = @"childComponentSelection";
    NSString * const componentName = @"component";
    NSString * const childComponentName = @"componentB";
    HUBComponentMock * const component = [HUBComponentMock new];
    component.preferredViewSize = CGSizeMake(200, 200);
    HUBComponentMock * const childComponent = [HUBComponentMock new];

    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        componentName: component,
        childComponentName: childComponent
    }];

    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;

        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;

        return YES;
    };

    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    id<HUBComponentChildDelegate> const childDelegate = component.childDelegate;

    id<HUBComponentModel> const childComponentModelA = [component.model childAtIndex:0];
    XCTAssertNotNil(childComponentModelA);

    [childDelegate component:component childComponentForModel:childComponentModelA];

    CGSize const expectedContainerViewSize = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame.size;
    XCTAssertTrue(CGSizeEqualToSize(expectedContainerViewSize, CGSizeMake(200, 200)));
    XCTAssertTrue(CGSizeEqualToSize(childComponent.currentContainerViewSize, expectedContainerViewSize));
}

- (void)testCollectionViewNotAddedOnTopOfInitialOverlayComponent
{
    self.contentOperation.contentLoadingBlock = ^BOOL(id<HUBViewModelBuilder> viewModelBuilder) {
        return NO;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSArray * const expectedSubviews = @[self.collectionView, self.component.view];
    XCTAssertEqualObjects(self.viewController.view.subviews, expectedSubviews);
}

- (void)testSetScrollOffsetForwardsOffsetToCollectionView
{
    [self simulateViewControllerLayoutCycle];
    const CGPoint expectedContentOffset = CGPointMake(99, 77);
    [self.viewController scrollToContentOffset:expectedContentOffset animated:NO];
    const CGPoint actualConentOffset = self.collectionView.appliedScrollViewOffset;
    XCTAssertTrue(CGPointEqualToPoint(expectedContentOffset, actualConentOffset));
}

- (void)testSetScrollOffsetIsCalculatedCorrectlyForTopInsetValue
{
    [self simulateViewControllerLayoutCycle];

    UIEdgeInsets inset = self.collectionView.contentInset;
    inset.top = 45.0;
    self.collectionView.contentInset = inset;

    const CGPoint contentOffset = CGPointMake(99, 77);
    const CGPoint expectedContentOffset = CGPointMake(contentOffset.x, contentOffset.y - inset.top);

    [self.viewController scrollToContentOffset:contentOffset animated:NO];
    const CGPoint actualConentOffset = self.collectionView.appliedScrollViewOffset;
    XCTAssertTrue(CGPointEqualToPoint(expectedContentOffset, actualConentOffset));
}

- (void)testSetScrollOffsetForwardsAnimatedFlagToCollectionView
{
    [self simulateViewControllerLayoutCycle];
    const CGPoint offset = CGPointMake(99, 77);
    [self.viewController scrollToContentOffset:offset animated:NO];
    XCTAssertFalse(self.collectionView.appliedScrollViewOffsetAnimatedFlag);
    [self.viewController scrollToContentOffset:offset animated:YES];
    XCTAssertTrue(self.collectionView.appliedScrollViewOffsetAnimatedFlag);
}

- (void)testRenderingUpdatesContentInsetBeforeAndAfterRendering
{
    UIEdgeInsets const firstInsets = UIEdgeInsetsMake(100, 30, 40, 200);
    UIEdgeInsets const secondInsets = UIEdgeInsetsMake(50, 0, 0, 0);

    __weak HUBViewControllerTests *weakSelf = self;
    void (^assertInsetsEqualToCollectionViewInsets)(UIEdgeInsets insets) = ^(UIEdgeInsets insets) {
        HUBViewControllerTests *strongSelf = weakSelf;
        XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(strongSelf.collectionView.contentInset, insets));
    };
    
    __block NSUInteger numberOfContentInsetCalls = 0;
    self.scrollHandler.contentInsetHandler = ^UIEdgeInsets(HUBViewController *controller, UIEdgeInsets insets) {
        numberOfContentInsetCalls += 1;
        if (numberOfContentInsetCalls == 1) {
            assertInsetsEqualToCollectionViewInsets(UIEdgeInsetsZero);
            return firstInsets;
        } else {
            assertInsetsEqualToCollectionViewInsets(firstInsets);
            return secondInsets;
        }
    };
    
    [self simulateViewControllerLayoutCycle];
    assertInsetsEqualToCollectionViewInsets(secondInsets);
}

- (void)testProposedContentInsetIsDefaultIfHeaderMissing
{
    CGFloat const statusBarWidth = CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
    CGFloat const statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    CGFloat const navigationBarWidth = CGRectGetWidth(self.viewController.navigationController.navigationBar.frame);
    CGFloat const navigationBarHeight = CGRectGetHeight(self.viewController.navigationController.navigationBar.frame);
    CGFloat const expectedTopInset = MIN(statusBarWidth, statusBarHeight) + MIN(navigationBarWidth, navigationBarHeight);
    UIEdgeInsets const expectedInsets = UIEdgeInsetsMake(expectedTopInset, 0.0, 0.0, 0.0);
    
    void (^assertInsetsEqualToCollectionViewInsets)(UIEdgeInsets, UIEdgeInsets) = ^(UIEdgeInsets insets, UIEdgeInsets otherInsets) {
        XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(insets, otherInsets));
    };

    __block NSUInteger numberOfInsetCalls = 0;
    __weak XCTestExpectation * const expectation = [self expectationWithDescription:@"The content inset handler should be asked for the content inset"];
    self.scrollHandler.contentInsetHandler = ^UIEdgeInsets(HUBViewController *controller, UIEdgeInsets proposedInsets) {
        assertInsetsEqualToCollectionViewInsets(proposedInsets, expectedInsets);
        numberOfInsetCalls += 1;
        if (numberOfInsetCalls == 2) {
            [expectation fulfill];
        }
        return proposedInsets;
    };

    [self simulateViewControllerLayoutCycle];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testProposedContentInsetNotAffectedByHeaderComponent
{
    NSString * const componentNamespace = @"proposedContentInset";
    NSString * const componentName = @"header";
    HUBComponentMock * const component = [HUBComponentMock new];
    component.preferredViewSize = CGSizeMake(320, 200);

    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        @"header": component
    }];

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.title = @"Header";
        viewModelBuilder.headerComponentModelBuilder.componentName = componentName;
        viewModelBuilder.headerComponentModelBuilder.componentNamespace = componentNamespace;
        return YES;
    };
    
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    void (^assertInsetsEqualToCollectionViewInsets)(UIEdgeInsets, UIEdgeInsets) = ^(UIEdgeInsets insets, UIEdgeInsets otherInsets) {
        XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(insets, otherInsets));
    };

    __block NSUInteger numberOfInsetCalls = 0;
    __weak XCTestExpectation * const expectation = [self expectationWithDescription:@"The content inset handler should be asked for the content inset"];
    self.scrollHandler.contentInsetHandler = ^UIEdgeInsets(HUBViewController *controller, UIEdgeInsets proposedInsets) {
        assertInsetsEqualToCollectionViewInsets(proposedInsets, UIEdgeInsetsZero);
        numberOfInsetCalls += 1;
        if (numberOfInsetCalls == 2) {
            [expectation fulfill];
        }
        return proposedInsets;
    };

    [self simulateViewControllerLayoutCycle];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testDisablingAutomaticTopInsetManagementWithoutHeaderComponent
{
    self.viewControllerShouldAutomaticallyManageTopContentInset = ^{ return NO; };
    
    UINavigationController * const navigationController = [UINavigationController new];
    navigationController.navigationBar.frame = CGRectMake(0, 0, 320, 44);
    navigationController.viewControllers = @[self.viewController];

    [self simulateViewControllerLayoutCycle];
    
    HUBAssertEqualFloatValues(self.collectionView.contentInset.top, 0);
    
    // Now, let's enable and reload - content inset should now be reset
    self.viewControllerShouldAutomaticallyManageTopContentInset = ^{ return YES; };
    [self.viewController reload];
    HUBAssertEqualFloatValues(self.collectionView.contentInset.top, 44);
}

- (void)testDisablingAutomaticTopInsetManagementWithHeaderComponent
{
    self.viewControllerShouldAutomaticallyManageTopContentInset = ^{ return NO; };
    
    HUBComponentMock * const headerComponent = [HUBComponentMock new];
    headerComponent.preferredViewSize = CGSizeMake(320, 400);
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        @"header": headerComponent
    }];
    
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:@"header"];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.componentNamespace = @"header";
        viewModelBuilder.headerComponentModelBuilder.componentName = @"header";
        
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"body"].title = @"Body component";
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes * const layoutAttributesA = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    
    HUBAssertEqualFloatValues(self.collectionView.contentInset.top, 0);
    HUBAssertEqualFloatValues(layoutAttributesA.frame.origin.y, 0);
    
    // Now, let's enable and reload - the first component should now have been pushed down by the header
    self.viewControllerShouldAutomaticallyManageTopContentInset = ^{ return YES; };
    [self.viewController reload];
    
    UICollectionViewLayoutAttributes * const layoutAttributesB = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    HUBAssertEqualFloatValues(layoutAttributesB.frame.origin.y, 400);
}

- (void)testHeaderMarginAlwaysBasedOnComponentPreferredViewSize
{
    self.contentReloadPolicy.shouldReload = YES;
    
    HUBComponentMock * const headerComponent = [HUBComponentMock new];
    headerComponent.preferredViewSize = CGSizeMake(320, 400);
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        @"header": headerComponent
    }];
    
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:@"header"];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.componentNamespace = @"header";
        viewModelBuilder.headerComponentModelBuilder.componentName = @"header";
        
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"body"].title = @"Body component";
        
        return YES;
    };
    
    self.scrollHandler.contentInsetHandler = ^(HUBViewController *viewController, UIEdgeInsets proposedContentInsets) {
        return proposedContentInsets;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes * const layoutAttributesA = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    HUBAssertEqualFloatValues(layoutAttributesA.frame.origin.y, 400);
    
    // If the header height is changed (for example, by the header itself, it shouldn't affect content inset)
    self.component.view.frame = CGRectMake(0, 0, 320, 100);
    [self.viewController viewWillAppear:YES];
    
    // Make sure that the view was reloaded
    XCTAssertEqual(self.contentOperation.performCount, 2u);
    
    UICollectionViewLayoutAttributes * const layoutAttributesB = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    HUBAssertEqualFloatValues(layoutAttributesB.frame.origin.y, 400);
}

- (void)testScrollingToRootComponentUsesScrollHandler
{
    [self registerAndGenerateComponentsWithNamespace:@"scrollToComponent"
                                       componentSize:CGSizeMake(200.0, 200.0)
                                      componentCount:20];

    [self simulateViewControllerLayoutCycle];
    // Makes sure the collection view updates its content size
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];

    self.scrollHandler.targetContentOffset = CGPointMake(0.0, 1400);

    __weak XCTestExpectation * const scrollingCompletedExpectation = [self expectationWithDescription:@"Scrolling should complete and call the handler"];
    NSIndexPath * const indexPath = [NSIndexPath indexPathWithIndex:8];
    [self.viewController scrollToComponentOfType:HUBComponentTypeBody
                                       indexPath:indexPath
                                  scrollPosition:HUBScrollPositionTop
                                        animated:YES
                                      completion:^(NSIndexPath *visibleIndexPath) {
        [scrollingCompletedExpectation fulfill];
        XCTAssertTrue(CGPointEqualToPoint(self.scrollHandler.targetContentOffset, self.collectionView.contentOffset));
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testScrollingToRootComponentDoesNotNotifyScrollHandler
{
    [self registerAndGenerateComponentsWithNamespace:@"scrollToComponent"
                                       componentSize:CGSizeMake(200.0, 200.0)
                                      componentCount:20];

    [self simulateViewControllerLayoutCycle];
    // Makes sure the collection view updates its content size
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];

    self.scrollHandler.targetContentOffset = CGPointMake(0.0, 1400);

    __block BOOL willStartScrollHandlerNotified = NO;
    self.scrollHandler.scrollingWillStartHandler = ^(CGRect contentRect) {
        willStartScrollHandlerNotified = YES;
    };

    __block BOOL didEndScrollHandlerNotified = NO;
    self.scrollHandler.scrollingDidEndHandler = ^(CGRect contentRect) {
        didEndScrollHandlerNotified = YES;
    };

    __weak XCTestExpectation * const expectation = [self expectationWithDescription:@"Scrolling should complete and call the handler"];
    NSIndexPath * const indexPath = [NSIndexPath indexPathWithIndex:8];
    [self.viewController scrollToComponentOfType:HUBComponentTypeBody
                                       indexPath:indexPath
                                  scrollPosition:HUBScrollPositionTop
                                        animated:YES
                                      completion:^(NSIndexPath *visibleIndexPath) {
        XCTAssertFalse(willStartScrollHandlerNotified);
        XCTAssertFalse(didEndScrollHandlerNotified);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testScrollingToNestedChildComponent
{
    NSString * const componentNamespace = @"scrollToChildComponent";
    NSString * const componentName = @"component";
    NSString * const childComponentName = @"childComponent";
    HUBComponentMock * const component = [HUBComponentMock new];
    component.preferredViewSize = CGSizeMake(200, 200);

    HUBComponentMock * const childComponent = [HUBComponentMock new];
    childComponent.preferredViewSize = CGSizeMake(200, 200);

    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        componentName: component,
        childComponentName: childComponent,
    }];

    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        for (NSInteger i = 0; i < 20; i++) {
            NSString * const identifier = [NSString stringWithFormat:@"component-%@", @(i)];
            id<HUBComponentModelBuilder> const componentBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:identifier];
            componentBuilder.componentNamespace = componentNamespace;
            componentBuilder.componentName = componentName;

            for (NSInteger j = 0; j < 10; j++) {
                NSString * const childIdentifier = [NSString stringWithFormat:@"childComponent-%@", @(j)];
                id<HUBComponentModelBuilder> const childBuilder = [componentBuilder builderForChildWithIdentifier:childIdentifier];
                childBuilder.componentNamespace = componentNamespace;
                childBuilder.componentName = childComponentName;
            }
        }
        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    // Makes sure the collection view updates its content size
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];

    self.scrollHandler.targetContentOffset = CGPointMake(0.0, 1200);

    NSUInteger indexes[2] = {6, 7};
    NSIndexPath * const indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2u];

    NSIndexPath * const rootIndexPath = [NSIndexPath indexPathForItem:(NSInteger)indexes[0] inSection:0];
    UICollectionViewCell *cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:rootIndexPath];
    self.collectionView.cells[rootIndexPath] = cell;
    self.collectionView.mockedVisibleCells = @[cell];

    __weak XCTestExpectation * const componentScrollExpectation = [self expectationWithDescription:@"The component should be asked to scroll to its child component"];
    component.scrollToComponentHandler = ^(NSUInteger childIndex, HUBScrollPosition position, BOOL animated) {
        [componentScrollExpectation fulfill];
        XCTAssertEqual([indexPath indexAtPosition:1], childIndex);
    };

    __weak XCTestExpectation * const scrollingToFirstExpectation = [self expectationWithDescription:@"Scrolling to the root component should complete and call the handler"];
    __weak XCTestExpectation * const scrollingCompletedExpectation = [self expectationWithDescription:@"Scrolling to the nested component should complete and call the handler"];
    [self.viewController scrollToComponentOfType:HUBComponentTypeBody
                                       indexPath:indexPath
                                  scrollPosition:HUBScrollPositionTop
                                        animated:YES
                                      completion:^(NSIndexPath *visibleIndexPath) {
        if (visibleIndexPath.length == 1 && [visibleIndexPath indexAtPosition:0] == 6) {
            [scrollingToFirstExpectation fulfill];
        } else if ([visibleIndexPath isEqual:indexPath]) {
            [scrollingCompletedExpectation fulfill];
        }
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testComponentNotifiedOfContentOffsetChange
{
    self.component.isContentOffsetObserver = YES;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    id<UICollectionViewDelegate> const collectionViewDelegate = self.collectionView.delegate;
    [collectionViewDelegate collectionView:self.collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)1);
    
    self.collectionView.cells[indexPath] = cell;
    self.collectionView.mockedIndexPathsForVisibleItems = @[indexPath];
    [self.viewController viewWillAppear:NO];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)2);
    
    const CGPoint expectedContentOffset = CGPointMake(99, 77);
    [self.viewController scrollToContentOffset:expectedContentOffset animated:NO];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)3);

    // Component shouldn't be notified because content offset hasn't changed
    [self.viewController viewWillAppear:NO];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)3);

    // Component isn't notified if view is reloaded
    self.contentReloadPolicy.shouldReload = YES;
    [self.viewController viewWillAppear:NO];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)3);
}

- (void)testHeaderComponentNotifiedOfContentOffsetChange
{
    self.component.isContentOffsetObserver = YES;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.title = @"Header";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)1);
    
    [self.viewController scrollToContentOffset:CGPointMake(0, 100) animated:NO];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)2);
}

- (void)testOverlayComponentNotifiedOfContentOffsetChange
{
    self.component.isContentOffsetObserver = YES;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"overlay"];
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)1);
    
    const CGPoint expectedContentOffset = CGPointMake(99, 77);
    [self.viewController scrollToContentOffset:expectedContentOffset animated:NO];
    XCTAssertEqual(self.component.numberOfContentOffsetChanges, (NSUInteger)2);
}

- (void)testChildComponentNotifiedOfContentOffsetChange
{
    NSString * const componentNamespace = @"childComponentSelection";
    NSString * const componentName = @"component";
    NSString * const childComponentName = @"componentB";
    HUBComponentMock * const component = [HUBComponentMock new];
    HUBComponentMock * const childComponent = [HUBComponentMock new];
    childComponent.isContentOffsetObserver = YES;

    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        componentName: component,
        childComponentName: childComponent
    }];
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        componentModelBuilder.componentNamespace = componentNamespace;
        componentModelBuilder.componentName = componentName;

        id<HUBComponentModelBuilder> const childComponentModelBuilder = [componentModelBuilder builderForChildWithIdentifier:@"child"];
        childComponentModelBuilder.componentNamespace = componentNamespace;
        childComponentModelBuilder.componentName = childComponentName;

        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    NSArray<id<HUBComponentModel>> * const children = componentModel.children;

    id<HUBComponentModel> const childComponentModel = children.firstObject;

    UIView *childView = HUBComponentLoadViewIfNeeded(childComponent);
    id<HUBComponentChildDelegate> childDelegate = component.childDelegate;
    [childDelegate component:component childComponentForModel:childComponentModel];
    [childDelegate component:component willDisplayChildAtIndex:0 view:childView];

    const CGPoint expectedContentOffset = CGPointMake(99, 77);
    [self.viewController scrollToContentOffset:expectedContentOffset animated:NO];
    XCTAssertEqual(childComponent.numberOfContentOffsetChanges, (NSUInteger)1);
}

- (void)testCollectionViewCreatedInLoadView
{
    XCTAssertEqual(self.viewController.view.subviews[0], self.collectionView);
}

- (void)testCollectionViewSetupUsingScrollHandler
{
    self.scrollHandler.shouldShowScrollIndicators = YES;
    self.scrollHandler.shouldAutomaticallyAdjustContentInsets = YES;
    self.scrollHandler.scrollDecelerationRate = UIScrollViewDecelerationRateNormal;
    self.scrollHandler.contentInsetHandler = ^(HUBViewController *viewController, UIEdgeInsets proposedContentInset) {
        return UIEdgeInsetsMake(100, 30, 40, 200);
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.collectionView.showsHorizontalScrollIndicator, YES);
    XCTAssertEqual(self.collectionView.showsVerticalScrollIndicator, YES);
    HUBAssertEqualFloatValues(self.collectionView.decelerationRate, UIScrollViewDecelerationRateNormal);
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, UIEdgeInsetsMake(100, 30, 40, 200)));
}

- (void)testCorrectContentRectSentToScrollHandler
{
    [self simulateViewControllerLayoutCycle];

    self.collectionView.frame = CGRectMake(0, 0, 320, 480);
    self.collectionView.contentOffset = CGPointMake(0, 200);
    self.collectionView.contentSize = CGSizeMake(320, 1600);
    
    id<UIScrollViewDelegate> const scrollViewDelegate = self.collectionView.delegate;
    [scrollViewDelegate scrollViewWillBeginDragging:self.collectionView];
    
    HUBAssertEqualFloatValues(CGRectGetMinX(self.scrollHandler.startContentRect), 0);
    HUBAssertEqualFloatValues(CGRectGetMinY(self.scrollHandler.startContentRect), 200);
    HUBAssertEqualFloatValues(CGRectGetWidth(self.scrollHandler.startContentRect), 320);
    HUBAssertEqualFloatValues(CGRectGetHeight(self.scrollHandler.startContentRect), 480);
    
    self.collectionView.contentOffset = CGPointMake(0, 800);
    [scrollViewDelegate scrollViewWillBeginDragging:self.collectionView];
    
    HUBAssertEqualFloatValues(CGRectGetMinX(self.scrollHandler.startContentRect), 0);
    HUBAssertEqualFloatValues(CGRectGetMinY(self.scrollHandler.startContentRect), 800);
    HUBAssertEqualFloatValues(CGRectGetWidth(self.scrollHandler.startContentRect), 320);
    HUBAssertEqualFloatValues(CGRectGetHeight(self.scrollHandler.startContentRect), 480);

    self.collectionView.contentOffset = CGPointMake(0, 1200);
    [scrollViewDelegate scrollViewDidEndDragging:self.collectionView willDecelerate:NO];
    HUBAssertEqualFloatValues(CGRectGetMinX(self.scrollHandler.startContentRect), 0);
    HUBAssertEqualFloatValues(CGRectGetMinY(self.scrollHandler.endContentRect), 1200);
    HUBAssertEqualFloatValues(CGRectGetWidth(self.scrollHandler.endContentRect), 320);
    HUBAssertEqualFloatValues(CGRectGetHeight(self.scrollHandler.endContentRect), 400);

    self.collectionView.contentOffset = CGPointMake(0, 1240);
    [scrollViewDelegate scrollViewDidEndDecelerating:self.collectionView];
    HUBAssertEqualFloatValues(CGRectGetMinX(self.scrollHandler.endContentRect), 0);
    HUBAssertEqualFloatValues(CGRectGetMinY(self.scrollHandler.endContentRect), 1240);
    HUBAssertEqualFloatValues(CGRectGetWidth(self.scrollHandler.endContentRect), 320);
    HUBAssertEqualFloatValues(CGRectGetHeight(self.scrollHandler.endContentRect), 360);
}

- (void)testScrollHandlerModifyingTargetContentOffset
{
    [self simulateViewControllerLayoutCycle];
    
    self.scrollHandler.targetContentOffset = CGPointMake(300, 500);
    CGPoint targetContentOffset = CGPointZero;
    
    [self.collectionView.delegate scrollViewWillEndDragging:self.collectionView
                                               withVelocity:CGPointZero
                                        targetContentOffset:&targetContentOffset];
    
    HUBAssertEqualFloatValues(targetContentOffset.x, 300);
    HUBAssertEqualFloatValues(targetContentOffset.y, 500);
}

- (void)testIsViewScrolling
{
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertFalse(self.viewController.isViewScrolling);
    self.collectionView.mockedIsDragging = YES;
    XCTAssertTrue(self.viewController.isViewScrolling);
}

- (void)testFrameForBodyComponentAtIndex
{
    HUBComponentMock * const componentA = [HUBComponentMock new];
    componentA.preferredViewSize = CGSizeMake(300, 200);
    
    HUBComponentMock * const componentB = [HUBComponentMock new];
    componentB.preferredViewSize = CGSizeMake(100, 300);
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{@"A": componentA, @"B": componentB}];
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:@"frameForBodyComponent"];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilderA = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"A"];
        componentModelBuilderA.componentNamespace = @"frameForBodyComponent";
        componentModelBuilderA.componentName = @"A";
        
        id<HUBComponentModelBuilder> const componentModelBuilderB = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"B"];
        componentModelBuilderB.componentNamespace = @"frameForBodyComponent";
        componentModelBuilderB.componentName = @"B";
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    CGRect const expectedComponentAFrame = CGRectMake(0, 0, 300, 200);
    CGRect const actualComponentAFrame = [self.viewController frameForBodyComponentAtIndex:0];
    XCTAssertTrue(CGRectEqualToRect(expectedComponentAFrame, actualComponentAFrame));
    
    CGRect const expectedComponentBFrame = CGRectMake(0, 200, 100, 300);
    CGRect const actualComponentBFrame = [self.viewController frameForBodyComponentAtIndex:1];
    XCTAssertTrue(CGRectEqualToRect(expectedComponentBFrame, actualComponentBFrame));
}

- (void)testIndexOfBodyComponentAtPoint
{
    HUBComponentMock * const componentA = [HUBComponentMock new];
    componentA.preferredViewSize = CGSizeMake(300, 200);
    
    HUBComponentMock * const componentB = [HUBComponentMock new];
    componentB.preferredViewSize = CGSizeMake(100, 300);
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{@"A": componentA, @"B": componentB}];
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:@"bodyComponentAtPoint"];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> const componentModelBuilderA = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"A"];
        componentModelBuilderA.componentNamespace = @"bodyComponentAtPoint";
        componentModelBuilderA.componentName = @"A";
        
        id<HUBComponentModelBuilder> const componentModelBuilderB = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"B"];
        componentModelBuilderB.componentNamespace = @"bodyComponentAtPoint";
        componentModelBuilderB.componentName = @"B";
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(10, 10)], 0u);
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(299, 199)], 0u);
    
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(10, 210)], 1u);
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(99, 299)], 1u);
    
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(-10, -10)], NSNotFound);
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(200, 1000)], NSNotFound);
    
    // Make sure we take content offset into account
    self.collectionView.contentOffset = CGPointMake(0, 250);
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(10, 10)], 1u);
    
}

- (void)testVisibleComponents
{
    HUBComponentMock * const headerComponent = [HUBComponentMock new];
    headerComponent.view = [[UIView alloc] initWithFrame:CGRectZero];

    HUBComponentMock * const componentA = [HUBComponentMock new];
    componentA.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    HUBComponentMock * const componentB = [HUBComponentMock new];
    componentB.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    HUBComponentMock * const componentC = [HUBComponentMock new];
    componentC.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    HUBComponentMock * const component1 = [HUBComponentMock new];
    component1.view = [[UIView alloc] initWithFrame:CGRectZero];

    HUBComponentMock * const component2 = [HUBComponentMock new];
    component2.view = [[UIView alloc] initWithFrame:CGRectZero];

    self.componentFactory.components[@"Header"] = headerComponent;
    self.componentFactory.components[@"A"] = componentA;
    self.componentFactory.components[@"B"] = componentB;
    self.componentFactory.components[@"C"] = componentC;
    self.componentFactory.components[@"1"] = component1;
    self.componentFactory.components[@"2"] = component2;

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder headerComponentModelBuilder].componentName = @"Header";
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"A"].componentName = @"A";
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"B"].componentName = @"B";
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"C"].componentName = @"C";
        [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"1"].componentName = @"1";
        [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"2"].componentName = @"2";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id<UICollectionViewDataSource> const collectionViewDataSource = self.collectionView.dataSource;
    
    NSIndexPath * const indexPathA = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cellA = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathA];
    
    NSIndexPath * const indexPathB = [NSIndexPath indexPathForItem:1 inSection:0];
    UICollectionViewCell * const cellB = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathB];
    
    NSIndexPath * const indexPathC = [NSIndexPath indexPathForItem:2 inSection:0];
    UICollectionViewCell * const cellC = [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPathC];
    
    self.collectionView.mockedVisibleCells = @[cellA, cellB, cellC];
    self.collectionView.cells[indexPathA] = cellA;
    self.collectionView.cells[indexPathB] = cellB;
    self.collectionView.cells[indexPathC] = cellC;

    NSDictionary<NSIndexPath *, UIView *> * const visibleHeaderViews = [self.viewController visibleComponentViewsForComponentType:HUBComponentTypeHeader];
    XCTAssertEqual(visibleHeaderViews.count, 1u);
    XCTAssertEqual(visibleHeaderViews[[NSIndexPath indexPathWithIndex:0]], headerComponent.view);
    
    NSIndexPath * const headerIndexPath = [NSIndexPath indexPathWithIndex:0];
    XCTAssertEqual([self.viewController visibleViewForComponentOfType:HUBComponentTypeHeader indexPath:headerIndexPath], headerComponent.view);

    NSDictionary<NSIndexPath *, UIView *> * const visibleBodyViews = [self.viewController visibleComponentViewsForComponentType:HUBComponentTypeBody];
    XCTAssertEqual(visibleBodyViews.count, 3u);
    
    NSIndexPath * const bodyIndexPathA = [NSIndexPath indexPathWithIndex:0];
    NSIndexPath * const bodyIndexPathB = [NSIndexPath indexPathWithIndex:1];
    NSIndexPath * const bodyIndexPathC = [NSIndexPath indexPathWithIndex:2];
    
    XCTAssertEqual(visibleBodyViews[bodyIndexPathA], componentA.view);
    XCTAssertEqual(visibleBodyViews[bodyIndexPathB], componentB.view);
    XCTAssertEqual(visibleBodyViews[bodyIndexPathC], componentC.view);
    
    XCTAssertEqual([self.viewController visibleViewForComponentOfType:HUBComponentTypeBody indexPath:bodyIndexPathA], componentA.view);
    XCTAssertEqual([self.viewController visibleViewForComponentOfType:HUBComponentTypeBody indexPath:bodyIndexPathB], componentB.view);
    XCTAssertEqual([self.viewController visibleViewForComponentOfType:HUBComponentTypeBody indexPath:bodyIndexPathC], componentC.view);

    NSDictionary<NSIndexPath *, UIView *> * const visibleOverlayViews = [self.viewController visibleComponentViewsForComponentType:HUBComponentTypeOverlay];
    XCTAssertEqual(visibleOverlayViews.count, 2u);
    XCTAssertEqual(visibleOverlayViews[[NSIndexPath indexPathWithIndex:0]], component1.view);
    XCTAssertEqual(visibleOverlayViews[[NSIndexPath indexPathWithIndex:1]], component2.view);
}

- (void)testNoVisibleComponents
{
    [self simulateViewControllerLayoutCycle];

    self.collectionView.mockedVisibleCells = @[];

    NSDictionary<NSIndexPath *, UIView *> * const visibleHeaderViews = [self.viewController visibleComponentViewsForComponentType:HUBComponentTypeHeader];
    NSDictionary<NSIndexPath *, UIView *> * const visibleBodyViews = [self.viewController visibleComponentViewsForComponentType:HUBComponentTypeBody];
    NSDictionary<NSIndexPath *, UIView *> * const visibleOverlayViews = [self.viewController visibleComponentViewsForComponentType:HUBComponentTypeOverlay];

    XCTAssertEqual(visibleHeaderViews.count, 0u);
    XCTAssertEqual(visibleBodyViews.count, 0u);
    XCTAssertEqual(visibleOverlayViews.count, 0u);
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathWithIndex:0];
    
    XCTAssertNil([self.viewController visibleViewForComponentOfType:HUBComponentTypeHeader indexPath:indexPath]);
    XCTAssertNil([self.viewController visibleViewForComponentOfType:HUBComponentTypeBody indexPath:indexPath]);
    XCTAssertNil([self.viewController visibleViewForComponentOfType:HUBComponentTypeOverlay indexPath:indexPath]);
}

- (void)testContentOperationNotifiedOfSelectionAction
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"A"].title = @"A";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    __block id<HUBActionContext> actionContext = nil;
    
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        actionContext = context;
        return YES;
    };
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    [self.viewController selectComponentWithModel:componentModel customData:nil];
    XCTAssertEqual(self.contentOperation.actionContext, actionContext);
}

- (void)testPerformingActionFromComponent
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"A"].title = @"A";
        return YES;
    };
    
    __block id<HUBActionContext> actionContext = nil;
    
    HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"component" name:@"action"];
    
    HUBActionMock * const action = [[HUBActionMock alloc] initWithBlock:^BOOL(id<HUBActionContext> context) {
        actionContext = context;
        return YES;
    }];
    
    HUBActionFactoryMock * const actionFactory = [[HUBActionFactoryMock alloc] initWithActions:@{
        actionIdentifier.namePart: action
    }];
    
    [self.actionRegistry registerActionFactory:actionFactory forNamespace:actionIdentifier.namespacePart];
    
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return NO;
    };
    
    [self simulateViewControllerLayoutCycle];
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    NSDictionary * const customActionData = @{@"custom": @"data"};
    
    BOOL const actionOutcome = [self.component.actionPerformer performActionWithIdentifier:actionIdentifier
                                                                                customData:customActionData];
    
    XCTAssertTrue(actionOutcome);
    XCTAssertEqualObjects(actionContext.componentModel.identifier, @"A");
    XCTAssertEqualObjects(actionContext.customData, customActionData);
    XCTAssertEqual(actionContext.trigger, HUBActionTriggerComponent);
    XCTAssertEqualObjects(self.actionHandler.contexts, @[actionContext]);
    XCTAssertEqual(self.contentOperation.actionContext, actionContext);
}

- (void)testObservingActionsByComponent
{
    self.component.isActionObserver = YES;

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.title = @"header";
        return YES;
    };

    __block id<HUBActionContext> actionContext = nil;

    HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"component" name:@"action"];

    HUBActionMock * const action = [[HUBActionMock alloc] initWithBlock:^BOOL(id<HUBActionContext> context) {
        actionContext = context;
        return YES;
    }];

    HUBActionFactoryMock * const actionFactory = [[HUBActionFactoryMock alloc] initWithActions:@{
        actionIdentifier.namePart: action
    }];

    [self.actionRegistry registerActionFactory:actionFactory forNamespace:actionIdentifier.namespacePart];

    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return NO;
    };

    [self simulateViewControllerLayoutCycle];

    NSDictionary * const customActionData = @{@"custom": @"data"};

    BOOL const actionOutcome = [self.component.actionPerformer performActionWithIdentifier:actionIdentifier
                                                                                customData:customActionData];

    XCTAssertTrue(actionOutcome);
    XCTAssertNotNil(self.component.latestObservedActionContext);
    XCTAssertEqualObjects(actionContext, self.component.latestObservedActionContext);
    XCTAssertEqualObjects(actionContext.componentModel.identifier, @"header");
    XCTAssertEqualObjects(actionContext.customData, customActionData);
    XCTAssertEqual(actionContext.trigger, HUBActionTriggerComponent);
    XCTAssertEqualObjects(self.actionHandler.contexts, @[actionContext]);
    XCTAssertEqual(self.contentOperation.actionContext, actionContext);
}

- (void)testPerformingActionFromContentOperation
{
    __block id<HUBActionContext> actionContext = nil;
    
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        actionContext = context;
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"contentOperation" name:@"action"];
    NSDictionary * const customActionData = @{@"custom": @"data"};
    BOOL const actionOutcome = [self.contentOperation.actionPerformer performActionWithIdentifier:actionIdentifier
                                                                                       customData:customActionData];
    
    XCTAssertTrue(actionOutcome);
    XCTAssertNil(actionContext.componentModel);
    XCTAssertEqualObjects(actionContext.customData, customActionData);
    XCTAssertEqual(actionContext.trigger, HUBActionTriggerContentOperation);
    XCTAssertEqualObjects(self.actionHandler.contexts, @[actionContext]);
    XCTAssertEqual(self.contentOperation.actionContext, actionContext);
}

- (void)testPerformingAsyncAction
{
    __weak HUBActionMock *actionWeakRef;
    __block id<HUBActionContext> chainedActionContext;
    
    HUBIdentifier * const chainedActionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"chained" name:@"action"];
    NSDictionary * const chainedActionCustomData = @{@"custom": @"data"};
    
    // Here we use an auto release pool to control the lifecycles of the objects locally
    @autoreleasepool {
        HUBActionMock *action = [[HUBActionMock alloc] initWithBlock:^(id<HUBActionContext> context) {
            return YES;
        }];
        action.isAsync = YES;
        
        HUBActionFactoryMock *actionFactory = [[HUBActionFactoryMock alloc] initWithActions:@{@"name": action}];
        [self.actionRegistry registerActionFactory:actionFactory forNamespace:@"namespace"];
        
        actionWeakRef = action;
        
        [self simulateViewControllerLayoutCycle];
        
        HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
        BOOL const actionOutcome = [self.contentOperation.actionPerformer performActionWithIdentifier:actionIdentifier
                                                                                           customData:nil];
        
        // Here we unregister the action factory, to release our mocked reference to the action
        // We also nil out our local reference, to be able to assert that the Hub Framework is retaining it
        [self.actionRegistry unregisterActionFactoryForNamespace:@"namespace"];
        actionFactory = nil;
        action = nil;
        
        XCTAssertTrue(actionOutcome);
        XCTAssertNotNil(actionWeakRef);
        
        // Capture action strongly again, to avoid compiler error
        action = actionWeakRef;
        
        self.actionHandler.block = ^(id<HUBActionContext> context) {
            chainedActionContext = context;
            return YES;
        };
        
        [action.delegate actionDidFinish:action chainToActionWithIdentifier:chainedActionIdentifier customData:chainedActionCustomData];
    }
    
    // Make sure that the action has now been released, and that the chained action was performed
    XCTAssertNil(actionWeakRef);
    XCTAssertNotNil(chainedActionContext);
    XCTAssertEqualObjects(chainedActionContext.customActionIdentifier, chainedActionIdentifier);
    XCTAssertEqualObjects(chainedActionContext.customData, chainedActionCustomData);
}

- (void)testAssigningNavigationItemProperties
{
    UIBarButtonItem * const rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.navigationBarTitle = @"Nav bar title";
        viewModelBuilder.navigationItem.rightBarButtonItem = rightBarButtonItem;
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqualObjects(self.viewController.navigationItem.title, @"Nav bar title");
    XCTAssertEqualObjects(self.viewController.navigationItem.rightBarButtonItem, rightBarButtonItem);
}

- (void)testAdaptingOverlayComponentCenterPointToKeyboard
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"overlay"].title = @"Overlay";
        return YES;
    };
    
    // Sets view controller's view frame to {0, 0, 320, 400}
    [self simulateViewControllerLayoutCycle];
    
    HUBAssertEqualFloatValues(self.component.view.center.x, 160);
    HUBAssertEqualFloatValues(self.component.view.center.y, 200);
    
    CGRect const keyboardEndFrame = CGRectMake(0, 200, 320, 200);
    NSDictionary * const notificationUserInfo = @{
        UIKeyboardFrameEndUserInfoKey: [NSValue valueWithCGRect:keyboardEndFrame]
    };
    NSNotification * const keyboardNotification = [NSNotification notificationWithName:UIKeyboardWillShowNotification
                                                                                object:nil
                                                                              userInfo:notificationUserInfo];
    
    // Show keyboard, which should push the overlay component
    NSNotificationCenter * const notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotification:keyboardNotification];
    
    HUBAssertEqualFloatValues(self.component.view.center.x, 160);
    HUBAssertEqualFloatValues(self.component.view.center.y, 100);
    
    // Hide keyboard, which should pull the overlay component back down
    [notificationCenter postNotificationName:UIKeyboardWillHideNotification object:nil];
    
    HUBAssertEqualFloatValues(self.component.view.center.x, 160);
    HUBAssertEqualFloatValues(self.component.view.center.y, 200);
}

- (void)testAdaptingOverlayComponentCenterPointToKeyboardAndTopMargin
{
    self.topMarginForOverlayComponent = 64;

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        id<HUBComponentModelBuilder> overlayModelBuilder = [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"overlay"];
        overlayModelBuilder.title = @"Overlay";
        return YES;
    };

    // Sets view controller's view frame to {0, 0, 320, 400}
    [self simulateViewControllerLayoutCycle];

    HUBAssertEqualFloatValues(self.component.view.center.x, 160);
    HUBAssertEqualFloatValues(self.component.view.center.y, 264);

    CGRect const keyboardEndFrame = CGRectMake(0, 200, 320, 200);
    NSDictionary * const notificationUserInfo = @{
                                                  UIKeyboardFrameEndUserInfoKey: [NSValue valueWithCGRect:keyboardEndFrame]
                                                  };
    NSNotification * const keyboardNotification = [NSNotification notificationWithName:UIKeyboardWillShowNotification
                                                                                object:nil
                                                                              userInfo:notificationUserInfo];

    // Show keyboard, which should push the overlay component
    NSNotificationCenter * const notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotification:keyboardNotification];

    HUBAssertEqualFloatValues(self.component.view.center.x, 160);
    HUBAssertEqualFloatValues(self.component.view.center.y, 164);

    // Hide keyboard, which should pull the overlay component back down
    [notificationCenter postNotificationName:UIKeyboardWillHideNotification object:nil];

    HUBAssertEqualFloatValues(self.component.view.center.x, 160);
    HUBAssertEqualFloatValues(self.component.view.center.y, 264);
}

- (void)testScrollingToComponentAfterViewModelFinishesRendering
{
    HUBComponentMock * const componentA = [HUBComponentMock new];
    componentA.preferredViewSize = CGSizeMake(300, 200);
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{@"A": componentA}];
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:@"frameForBodyComponent"];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.title = @"header";

        for (NSUInteger i = 0; i < 4; i++) {
            id<HUBComponentModelBuilder> builder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:[NSString stringWithFormat:@"%@", @(i)]];
            builder.componentNamespace = @"frameForBodyComponent";
            builder.componentName = @"A";
        }

        return YES;
    };
    
    self.scrollHandler.contentInsetHandler = ^(HUBViewController *viewController, UIEdgeInsets proposedContentInset) {
        return UIEdgeInsetsMake(100, 30, 40, 200);
    };

    __weak HUBViewControllerTests *weakSelf = self;
    __block CGPoint expectedOffset = CGPointZero;
    self.viewControllerDidFinishRenderingBlock = ^{
        HUBViewControllerTests *strongSelf = weakSelf;
        CGRect componentFrame = [strongSelf.viewController frameForBodyComponentAtIndex:3];
        CGPoint offset = CGPointMake(0.0, CGRectGetMinY(componentFrame));
        expectedOffset = CGPointMake(offset.x, offset.y - 100);
        [strongSelf.viewController scrollToContentOffset:offset animated:NO];
    };

    [self simulateViewControllerLayoutCycle];
    XCTAssertTrue(CGPointEqualToPoint(expectedOffset, self.collectionView.appliedScrollViewOffset));
}

- (void)testLoadingPaginatedContentWhenScrollingIsAboutToReachBottom
{
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithBlock:^(NSString *name) {
        HUBComponentMock * const component = [HUBComponentMock new];
        component.preferredViewSize = CGSizeMake(320, 100);
        return component;
    }];
    
    NSString * const componentNamespace = @"paginated-reach-bottom";
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        // Add 5 components, as it will be enough to extend the height of the view
        for (NSUInteger index = 0; index < 5; index++) {
            NSString * const componentIdentifier = [NSString stringWithFormat:@"component-%@", @(index)];
            [builder builderForBodyComponentModelWithIdentifier:componentIdentifier].componentNamespace = componentNamespace;
        }
        
        return YES;
    };
    
    self.contentOperation.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        NSString * const componentIdentifier = [NSString stringWithFormat:@"extended-component-page-%@", @(pageIndex)];
        [builder builderForBodyComponentModelWithIdentifier:componentIdentifier].componentNamespace = componentNamespace;
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.viewController.viewModel.bodyComponentModels.count, 5u);
    
    // Here we force update the collection view's content size as it doesn't do it automatically when not attached to a proper window
    self.collectionView.contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
    HUBAssertEqualFloatValues(self.collectionView.contentSize.height, 500);
    
    CGPoint targetContentOffset = CGPointMake(0, 500);
    self.scrollHandler.targetContentOffset = targetContentOffset;
    
    id<UIScrollViewDelegate> const scrollViewDelegate = self.collectionView.delegate;
    
    [scrollViewDelegate scrollViewWillEndDragging:self.collectionView
                                     withVelocity:CGPointZero
                              targetContentOffset:&targetContentOffset];
    
    XCTAssertEqual(self.viewController.viewModel.bodyComponentModels.count, 6u);
    XCTAssertEqualObjects(self.viewController.viewModel.bodyComponentModels[5].identifier, @"extended-component-page-1");
    
    self.collectionView.contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
    HUBAssertEqualFloatValues(self.collectionView.contentSize.height, 600);
    
    targetContentOffset = CGPointMake(0, 600);
    self.scrollHandler.targetContentOffset = targetContentOffset;
    
    [scrollViewDelegate scrollViewWillEndDragging:self.collectionView
                                     withVelocity:CGPointZero
                              targetContentOffset:&targetContentOffset];
    
    XCTAssertEqual(self.viewController.viewModel.bodyComponentModels.count, 7u);
    XCTAssertEqualObjects(self.viewController.viewModel.bodyComponentModels[6].identifier, @"extended-component-page-2");
}

- (void)testPreventingViewControllerScrolling
{
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithBlock:^(NSString *name) {
        HUBComponentMock * const component = [HUBComponentMock new];
        component.preferredViewSize = CGSizeMake(320, 100);
        return component;
    }];
    
    NSString * const componentNamespace = @"preventing-scrolling";
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        for (NSUInteger index = 0; index < 10; index++) {
            NSString * const componentIdentifier = [NSString stringWithFormat:@"component-%@", @(index)];
            [builder builderForBodyComponentModelWithIdentifier:componentIdentifier].componentNamespace = componentNamespace;
        }
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    // First verify that we can scroll the view per default
    self.collectionView.contentOffset = CGPointMake(0, 500);
    HUBAssertEqualFloatValues(self.collectionView.contentOffset.y, 500);
    
    self.viewControllerShouldStartScrollingBlock = ^{ return NO; };
    self.collectionView.contentOffset = CGPointMake(0, 600);
    HUBAssertEqualFloatValues(self.collectionView.contentOffset.y, 500);
    
    // Verify that scrolling works again as soon as we switch back
    self.viewControllerShouldStartScrollingBlock = ^{ return YES; };
    self.collectionView.contentOffset = CGPointMake(0, 700);
    HUBAssertEqualFloatValues(self.collectionView.contentOffset.y, 700);
}

- (void)testViewControllerWithoutDelegateIsAlwaysScrollable
{
    self.viewController.delegate = nil;
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithBlock:^(NSString *name) {
        HUBComponentMock * const component = [HUBComponentMock new];
        component.preferredViewSize = CGSizeMake(320, 100);
        return component;
    }];
    
    NSString * const componentNamespace = @"no-delegate-always-scrollable";
    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        for (NSUInteger index = 0; index < 10; index++) {
            NSString * const componentIdentifier = [NSString stringWithFormat:@"component-%@", @(index)];
            [builder builderForBodyComponentModelWithIdentifier:componentIdentifier].componentNamespace = componentNamespace;
        }
        
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    // Here we force update the collection view's content size as it doesn't do it automatically when not attached to a proper window
    self.collectionView.contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
    HUBAssertEqualFloatValues(self.collectionView.contentSize.height, 1000);
    XCTAssertGreaterThan(self.collectionView.contentSize.height, CGRectGetHeight(self.collectionView.frame));
    
    self.collectionView.contentOffset = CGPointMake(0, 500);
    HUBAssertEqualFloatValues(self.collectionView.contentOffset.y, 500);
}

- (void)testThatDelegateIsNotifiedWhenOverlayAppears
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForOverlayComponentModelWithIdentifier:@"id"].title = @"Overlay";
        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    XCTAssertEqual(self.componentModelsFromAppearanceDelegateMethod.count, 1u);
    XCTAssertEqualObjects(self.componentModelsFromAppearanceDelegateMethod[0].title, @"Overlay");
    XCTAssertEqualObjects(self.componentViewsFromApperanceDelegateMethod, @[self.component.view]);
}

- (void)testThatDelegateIsNotifiedWhenHeaderAppears
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        viewModelBuilder.headerComponentModelBuilder.title = @"Header";
        return YES;
    };

    [self simulateViewControllerLayoutCycle];

    XCTAssertEqual(self.componentModelsFromAppearanceDelegateMethod.count, 1u);
    XCTAssertEqualObjects(self.componentModelsFromAppearanceDelegateMethod[0].title, @"Header");
    XCTAssertEqualObjects(self.componentViewsFromApperanceDelegateMethod, @[self.component.view]);
}

#pragma mark - HUBViewControllerDelegate

- (void)viewController:(HUBViewController *)viewController willUpdateWithViewModel:(id<HUBViewModel>)viewModel
{
    XCTAssertEqual(viewController, self.viewController);
    self.viewModelFromDelegateMethod = viewModel;
}

- (void)viewControllerDidUpdate:(HUBViewController *)viewController
{
    XCTAssertEqual(viewController, self.viewController);
    XCTAssertEqual(self.viewModelFromDelegateMethod, viewController.viewModel);
}

- (void)viewController:(HUBViewController *)viewController didFailToUpdateWithError:(NSError *)error
{
    XCTAssertEqual(viewController, self.viewController);
    self.errorFromDelegateMethod = error;
}

- (void)viewControllerDidFinishRendering:(HUBViewController *)viewController
{
    XCTAssertEqual(viewController, self.viewController);
    self.didReceiveViewControllerDidFinishRendering = YES;

    if (self.viewControllerDidFinishRenderingBlock) {
        self.viewControllerDidFinishRenderingBlock();
    }
}

- (BOOL)viewControllerShouldStartScrolling:(HUBViewController *)viewController
{
    return self.viewControllerShouldStartScrollingBlock();
}

- (void)viewController:(HUBViewController *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
          layoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
      willAppearInView:(nonnull UIView *)componentView
{
    XCTAssertEqual(viewController, self.viewController);
    XCTAssertFalse([componentView isKindOfClass:[HUBComponentCollectionViewCell class]]);

    [self.componentViewsFromApperanceDelegateMethod addObject:componentView];
    [self.componentModelsFromAppearanceDelegateMethod addObject:componentModel];
    [self.componentLayoutTraitsFromAppearanceDelegateMethod addObject:layoutTraits];
}

- (void)viewController:(HUBViewController *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
          layoutTraits:(NSSet<HUBComponentLayoutTrait> *)layoutTraits
  didDisappearFromView:(UIView *)componentView
{
    XCTAssertEqual(viewController, self.viewController);
    
    [self.componentModelsFromDisapperanceDelegateMethod addObject:componentModel];
    [self.componentLayoutTraitsFromDisapperanceDelegateMethod addObject:layoutTraits];
}

- (void)viewController:(HUBViewController *)viewController willReuseComponentWithView:(UIView *)componentView
{
    XCTAssertEqual(viewController, self.viewController);

    [self.componentViewsFromReuseDelegateMethod addObject:componentView];
}

- (void)viewController:(HUBViewController *)viewController componentSelectedWithModel:(id<HUBComponentModel>)componentModel
{
    XCTAssertEqual(viewController, self.viewController);
    [self.componentModelsFromSelectionDelegateMethod addObject:componentModel];
}

- (BOOL)viewControllerShouldAutomaticallyManageTopContentInset:(HUBViewController *)viewController
{
    XCTAssertEqual(viewController, self.viewController);
    return self.viewControllerShouldAutomaticallyManageTopContentInset();
}

- (CGFloat)viewController:(HUBViewController *)viewController topMarginForOverlayComponentWithModel:(id<HUBComponentModel>)componentModel
{
    XCTAssertEqual(viewController, self.viewController);
    return self.topMarginForOverlayComponent;
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

- (void)simulateLayoutForViewHierarchyStartingWithView:(UIView *)rootView
{
    [rootView layoutSubviews];
    
    for (UIView * const subviews in rootView.subviews) {
        [self simulateLayoutForViewHierarchyStartingWithView:subviews];
    }
}

- (void)performAsynchronousTestWithDelay:(NSTimeInterval)delay block:(void(^)(void))block
{
    __weak XCTestExpectation * const expectation = [self expectationWithDescription:@"Async test"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:MAX(delay, 5) * 2 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        block();
    }];
}

- (void)registerAndGenerateComponentsWithNamespace:(NSString *)namespace
                                     componentSize:(CGSize)componentSize
                                    componentCount:(NSUInteger)componentCount
{
    NSString * const componentNamespace = namespace;
    NSString * const componentName = @"component";
    HUBComponentMock * const component = [HUBComponentMock new];
    component.preferredViewSize = componentSize;

    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        componentName: component,
    }];

    [self.componentRegistry registerComponentFactory:componentFactory forNamespace:componentNamespace];

    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        for (NSUInteger i = 0; i < componentCount; i++) {
            NSString * const identifier = [NSString stringWithFormat:@"component-%@", @(i)];
            id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:identifier];
            componentModelBuilder.componentNamespace = componentNamespace;
            componentModelBuilder.componentName = componentName;
        }
        return YES;
    };
}

@end
