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

#import "HUBViewControllerImplementation.h"
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
#import "HUBViewControllerScrollHandlerMock.h"

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
@property (nonatomic, strong) HUBViewControllerImplementation *viewController;
@property (nonatomic, strong) id<HUBViewModel> viewModelFromDelegateMethod;
@property (nonatomic, strong) NSError *errorFromDelegateMethod;
@property (nonatomic, strong) NSMutableArray<id<HUBComponentModel>> *componentModelsFromAppearanceDelegateMethod;
@property (nonatomic, strong) NSMutableArray<id<HUBComponentModel>> *componentModelsFromDisapperanceDelegateMethod;
@property (nonatomic, strong) NSMutableArray<id<HUBComponentModel>> *componentModelsFromSelectionDelegateMethod;
@property (nonatomic, assign) BOOL didReceiveViewControllerDidFinishRendering;


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
    
    self.viewController = [[HUBViewControllerImplementation alloc] initWithViewURI:self.viewURI
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
    self.componentModelsFromDisapperanceDelegateMethod = [NSMutableArray new];
    self.componentModelsFromSelectionDelegateMethod = [NSMutableArray new];
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
    
    [self performAsynchronousTestWithBlock:^{
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
    
    [self performAsynchronousTestWithBlock:^{
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
    
    [self.imageLoader.delegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL fromCache:NO];
    
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
    
    [imageLoaderDelegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL fromCache:NO];
    XCTAssertEqualObjects(self.component.mainImageData.URL, imageURL);
    
    [self.component prepareViewForReuse];
    XCTAssertNil(self.component.mainImageData);
    
    [collectionViewDataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    [imageLoaderDelegate imageLoader:self.imageLoader didLoadImage:[UIImage new] forURL:imageURL fromCache:NO];
    XCTAssertEqualObjects(self.component.mainImageData.URL, imageURL);
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
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(targetInitialViewModel.identifier, initialViewModelIdentifier);
}

- (void)testComponentDeselectedAfterDefaultSelectionHandling
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(self.collectionView.selectedIndexPaths, [NSSet setWithObject:indexPath]);
    XCTAssertEqualObjects(self.collectionView.deselectedIndexPaths, [NSSet setWithObject:indexPath]);
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
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(self.collectionView.selectedIndexPaths, [NSSet setWithObject:indexPath]);
    XCTAssertEqualObjects(self.collectionView.deselectedIndexPaths, [NSSet setWithObject:indexPath]);
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
    
    id<UICollectionViewDelegate> const collectionViewDelegate = self.collectionView.delegate;
    
    NSIndexPath * const nonSelectableIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [collectionViewDelegate collectionView:self.collectionView didSelectItemAtIndexPath:nonSelectableIndexPath];
    XCTAssertEqual(self.componentModelsFromSelectionDelegateMethod.count, (NSUInteger)0);
    
    NSIndexPath * const selectableIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    [collectionViewDelegate collectionView:self.collectionView didSelectItemAtIndexPath:selectableIndexPath];
    XCTAssertEqual(self.componentModelsFromSelectionDelegateMethod.count, (NSUInteger)1);
    XCTAssertEqualObjects(self.componentModelsFromSelectionDelegateMethod[0].identifier, selectableIdentifier);
    
    // Test custom selection action handling
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    [collectionViewDelegate collectionView:self.collectionView didSelectItemAtIndexPath:selectableIndexPath];
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
    [childDelegate component:component childSelectedAtIndex:0];
    
    XCTAssertEqualObjects(childComponentTargetInitialViewModel.identifier, childComponentInitialViewModelIdentifier);
    
    // Make sure bounds-checking is performed for child component index
    [childDelegate component:component willDisplayChildAtIndex:99 view:[UIView new]];
    
    XCTAssertEqual(self.componentModelsFromSelectionDelegateMethod.count, (NSUInteger)1);
    XCTAssertEqualObjects(self.componentModelsFromSelectionDelegateMethod[0].target.URI, childComponentTargetURL);
    
    // Test custom selection handling
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    [childDelegate component:component childSelectedAtIndex:0];
    XCTAssertEqual(self.actionHandler.contexts.count, (NSUInteger)1);

    id<HUBActionContext> actionContext = self.actionHandler.contexts.firstObject;
    XCTAssertEqualObjects(actionContext.componentModel.target.URI, childComponentTargetURL);
    XCTAssertEqualObjects(actionContext.viewController, self.viewController);
    XCTAssertEqualObjects(actionContext.viewModel, self.viewModelFromDelegateMethod);
    XCTAssertEqualObjects(actionContext.viewURI, self.viewURI);
}

- (void)testProgrammaticSelectionForRootComponent
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].targetBuilder.URI = [NSURL URLWithString:@"spotify:hub:framework"];
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    self.actionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    XCTAssertTrue([self.viewController selectComponentWithModel:componentModel]);
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
    XCTAssertTrue([self.viewController selectComponentWithModel:componentModel]);
    XCTAssertEqualObjects(self.componentModelsFromSelectionDelegateMethod, @[componentModel]);
    XCTAssertEqualObjects(self.actionHandler.contexts.firstObject.componentModel, componentModel);
}

- (void)testProgrammaticSelectionForNonSelectableComponentReturningFalse
{
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].title = @"Component title";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    id<HUBComponentModel> const componentModel = self.viewModelFromDelegateMethod.bodyComponentModels[0];
    XCTAssertFalse([self.viewController selectComponentWithModel:componentModel]);
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
    
    XCTAssertEqual(self.component.numberOfAppearances, (NSUInteger)1);
    XCTAssertEqual(self.componentModelsFromAppearanceDelegateMethod.count, (NSUInteger)1);
    XCTAssertEqualObjects(self.componentModelsFromAppearanceDelegateMethod[0].title, @"title");
    
    self.collectionView.mockedIndexPathsForVisibleItems = @[indexPath];
    [self.viewController viewWillAppear:NO];
    
    XCTAssertEqual(self.component.numberOfAppearances, (NSUInteger)2);
    XCTAssertEqual(self.componentModelsFromAppearanceDelegateMethod.count, (NSUInteger)2);
    XCTAssertEqualObjects(self.componentModelsFromAppearanceDelegateMethod[1].title, @"title");
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
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].title = @"Title";
        return YES;
    };
    
    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewCell * const cell = [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView.delegate collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    
    XCTAssertEqual(self.componentModelsFromDisapperanceDelegateMethod.count, (NSUInteger)1);
    XCTAssertEqualObjects(self.componentModelsFromDisapperanceDelegateMethod[0].title, @"Title");
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

- (void)testSettingBackgroundColorOfViewAlsoUpdatesCollectionView
{
    self.viewController.view.backgroundColor = [UIColor redColor];
    [self.viewController viewWillAppear:NO];
    XCTAssertEqualObjects(self.collectionView.backgroundColor, [UIColor redColor]);
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

- (void)testContainerViewSizeForChildComponentsAreParerentComponentsViewSize
{
    NSString * const componentNamespace = @"childComponentSelection";
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

        return YES;
    };

    [self simulateViewControllerLayoutCycle];
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

    const CGRect expectedParentFrame = CGRectMake(0, 0, 88, 88);
    component.view.frame = expectedParentFrame;

    id<HUBComponentChildDelegate> const childDelegate = component.childDelegate;

    id<HUBComponentModel> const childComponentModelA = [component.model childAtIndex:0];
    XCTAssertNotNil(childComponentModelA);

    [childDelegate component:component childComponentForModel:childComponentModelA];

    XCTAssertTrue(CGSizeEqualToSize(childComponent.currentContainerViewSize, expectedParentFrame.size));
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

- (void)testSetScrollOffsetForwrdsOffsetToCollectionView
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

- (void)testCollectionViewCreatedInLoadView
{
    XCTAssertEqual(self.viewController.view.subviews[0], self.collectionView);
}

- (void)testCollectionViewSetupUsingScrollHandler
{
    self.scrollHandler.shouldShowScrollIndicators = YES;
    self.scrollHandler.shouldAutomaticallyAdjustContentInsets = YES;
    self.scrollHandler.scrollDecelerationRate = UIScrollViewDecelerationRateNormal;
    self.scrollHandler.contentInsets = UIEdgeInsetsMake(100, 30, 40, 200);
    
    [self simulateViewControllerLayoutCycle];
    
    XCTAssertEqual(self.collectionView.showsHorizontalScrollIndicator, YES);
    XCTAssertEqual(self.collectionView.showsVerticalScrollIndicator, YES);
    XCTAssertEqualWithAccuracy(self.collectionView.decelerationRate, UIScrollViewDecelerationRateNormal, 0.001);
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
    
    XCTAssertEqualWithAccuracy(CGRectGetMinX(self.scrollHandler.startContentRect), 0, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(self.scrollHandler.startContentRect), 200, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(self.scrollHandler.startContentRect), 320, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.scrollHandler.startContentRect), 480, 0.001);
    
    self.collectionView.contentOffset = CGPointMake(0, 800);
    [scrollViewDelegate scrollViewWillBeginDragging:self.collectionView];
    
    XCTAssertEqualWithAccuracy(CGRectGetMinX(self.scrollHandler.startContentRect), 0, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(self.scrollHandler.startContentRect), 800, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(self.scrollHandler.startContentRect), 320, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.scrollHandler.startContentRect), 480, 0.001);

    self.collectionView.contentOffset = CGPointMake(0, 1200);
    [scrollViewDelegate scrollViewDidEndDragging:self.collectionView willDecelerate:NO];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(self.scrollHandler.startContentRect), 0, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(self.scrollHandler.endContentRect), 1200, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(self.scrollHandler.endContentRect), 320, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.scrollHandler.endContentRect), 400, 0.001);

    self.collectionView.contentOffset = CGPointMake(0, 1240);
    [scrollViewDelegate scrollViewDidEndDecelerating:self.collectionView];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(self.scrollHandler.endContentRect), 0, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(self.scrollHandler.endContentRect), 1240, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetWidth(self.scrollHandler.endContentRect), 320, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetHeight(self.scrollHandler.endContentRect), 360, 0.001);
}

- (void)testScrollHandlerModifyingTargetContentOffset
{
    [self simulateViewControllerLayoutCycle];
    
    self.scrollHandler.targetContentOffset = CGPointMake(300, 500);
    CGPoint targetContentOffset = CGPointZero;
    
    [self.collectionView.delegate scrollViewWillEndDragging:self.collectionView
                                               withVelocity:CGPointZero
                                        targetContentOffset:&targetContentOffset];
    
    XCTAssertEqualWithAccuracy(targetContentOffset.x, 300, 0.001);
    XCTAssertEqualWithAccuracy(targetContentOffset.y, 500, 0.001);
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
    
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(10, 10)], (NSUInteger)0);
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(299, 199)], (NSUInteger)0);
    
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(10, 210)], (NSUInteger)1);
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(99, 299)], (NSUInteger)1);
    
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(-10, -10)], NSNotFound);
    XCTAssertEqual([self.viewController indexOfBodyComponentAtPoint:CGPointMake(200, 1000)], NSNotFound);
}

- (void)testVisibleBodyComponents
{
    HUBComponentMock * const componentA = [HUBComponentMock new];
    componentA.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    HUBComponentMock * const componentB = [HUBComponentMock new];
    componentB.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    HUBComponentMock * const componentC = [HUBComponentMock new];
    componentC.view = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.componentFactory.components[@"A"] = componentA;
    self.componentFactory.components[@"B"] = componentB;
    self.componentFactory.components[@"C"] = componentC;
    
    self.contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"A"].componentName = @"A";
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"B"].componentName = @"B";
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"C"].componentName = @"C";
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
    
    NSDictionary<NSNumber *, UIView *> * const visibleViews = self.viewController.visibleBodyComponentViews;
    XCTAssertEqual(visibleViews.count, (NSUInteger)3);
    XCTAssertEqual(visibleViews[@0], componentA.view);
    XCTAssertEqual(visibleViews[@1], componentB.view);
    XCTAssertEqual(visibleViews[@2], componentC.view);
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
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView.dataSource collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    
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
    
    BOOL const actionOutcome = [self.component.actionDelegate component:self.component
                                            performActionWithIdentifier:actionIdentifier
                                                             customData:customActionData];
    
    XCTAssertTrue(actionOutcome);
    XCTAssertEqualObjects(actionContext.componentModel.identifier, @"A");
    XCTAssertEqualObjects(actionContext.customData, customActionData);
    XCTAssertEqual(actionContext.trigger, HUBActionTriggerComponent);
    XCTAssertEqualObjects(self.actionHandler.contexts, @[actionContext]);
    XCTAssertEqual(self.contentOperation.actionContext, actionContext);
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
    
    XCTAssertEqualWithAccuracy(self.component.view.center.x, 160, 0.001);
    XCTAssertEqualWithAccuracy(self.component.view.center.y, 200, 0.001);
    
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
    
    XCTAssertEqualWithAccuracy(self.component.view.center.x, 160, 0.001);
    XCTAssertEqualWithAccuracy(self.component.view.center.y, 100, 0.001);
    
    // Hide keyboard, which should pull the overlay component back down
    [notificationCenter postNotificationName:UIKeyboardWillHideNotification object:nil];
    
    XCTAssertEqualWithAccuracy(self.component.view.center.x, 160, 0.001);
    XCTAssertEqualWithAccuracy(self.component.view.center.y, 200, 0.001);
}

#pragma mark - HUBViewControllerDelegate

- (void)viewController:(UIViewController<HUBViewController> *)viewController willUpdateWithViewModel:(id<HUBViewModel>)viewModel
{
    XCTAssertEqual(viewController, self.viewController);
    self.viewModelFromDelegateMethod = viewModel;
}

- (void)viewControllerDidUpdate:(UIViewController<HUBViewController> *)viewController
{
    XCTAssertEqual(viewController, self.viewController);
    XCTAssertEqual(self.viewModelFromDelegateMethod, viewController.viewModel);
}

- (void)viewController:(UIViewController<HUBViewController> *)viewController didFailToUpdateWithError:(NSError *)error
{
    XCTAssertEqual(viewController, self.viewController);
    self.errorFromDelegateMethod = error;
}

- (void)viewControllerDidFinishRendering:(UIViewController<HUBViewController> *)viewController
{
    XCTAssertEqual(viewController, self.viewController);
    self.didReceiveViewControllerDidFinishRendering = YES;
}

- (void)viewController:(UIViewController<HUBViewController> *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
      willAppearInView:(UIView *)componentView
{
    XCTAssertEqual(viewController, self.viewController);
    [self.componentModelsFromAppearanceDelegateMethod addObject:componentModel];
}

- (void)viewController:(UIViewController<HUBViewController> *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
  didDisappearFromView:(UIView *)componentView
{
    XCTAssertEqual(viewController, self.viewController);
    [self.componentModelsFromDisapperanceDelegateMethod addObject:componentModel];
}

- (void)viewController:(UIViewController<HUBViewController> *)viewController componentSelectedWithModel:(id<HUBComponentModel>)componentModel
{
    XCTAssertEqual(viewController, self.viewController);
    [self.componentModelsFromSelectionDelegateMethod addObject:componentModel];
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
