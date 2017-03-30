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

#import "HUBComponentImageDataImplementation.h"
#import "HUBComponentMock.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentGestureRecognizer.h"
#import "HUBComponentWrapper.h"
#import "HUBComponentWrapperImageLoader.h"
#import "HUBComponentUIStateManager.h"
#import "HUBIdentifier.h"
#import "HUBImageLoaderMock.h"
#import "HUBSingleGestureRecognizerSynchronizer.h"

@interface HUBComponentWrapper (HUBExposeInternalsForTesting)

@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, HUBComponentWrapper *> *childrenByIndex;

@end

@interface HUBComponentWrapperImageLoaderTests : XCTestCase <HUBComponentWrapperDelegate>

@property (nonatomic, strong) HUBComponentUIStateManager *stateManager;
@property (nonatomic, strong) HUBComponentGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) HUBImageLoaderMock *imageLoaderMock;
@property (nonatomic, strong) HUBComponentWrapperImageLoader *wrapperImageLoader;

@end

@implementation HUBComponentWrapperImageLoaderTests

- (void)setUp
{
    [super setUp];

    self.stateManager = [HUBComponentUIStateManager new];
    self.gestureRecognizer = [[HUBComponentGestureRecognizer alloc] initWithSynchronizer:[HUBSingleGestureRecognizerSynchronizer new]];
    self.imageLoaderMock = [HUBImageLoaderMock new];
    self.wrapperImageLoader = [[HUBComponentWrapperImageLoader alloc] initWithImageLoader:self.imageLoaderMock];
}

- (void)tearDown
{
    self.stateManager = nil;
    self.gestureRecognizer = nil;
    self.imageLoaderMock = nil;
    self.wrapperImageLoader = nil;

    [super tearDown];
}

- (HUBComponentWrapper *)createComponentWrapperWithComponent:(id<HUBComponent>)component
                                              componentModel:(id<HUBComponentModel>)componentModel
                                                      parent:(nullable HUBComponentWrapper *)parent
{
    HUBComponentWrapper *componentWrapper = [[HUBComponentWrapper alloc] initWithComponent:component
                                                                                     model:componentModel
                                                                            UIStateManager:self.stateManager
                                                                                  delegate:self
                                                                         gestureRecognizer:self.gestureRecognizer
                                                                                    parent:parent];
    return componentWrapper;
}

- (HUBComponentModelImplementation *)createComponentModelWithMainImageDataURI:(nullable NSURL *)mainImageDataURI
                                                       backgroundImageDataURI:(nullable NSURL *)backgroundImageDataURI
                                                                       parent:(nullable HUBComponentModelImplementation *)parent
{
    HUBComponentImageDataImplementation *mainImageData = nil;
    HUBComponentImageDataImplementation *backgroundImageData = nil;

    if (mainImageDataURI) {
        mainImageData = [[HUBComponentImageDataImplementation alloc] initWithIdentifier:nil
                                                                                   type:HUBComponentImageTypeMain
                                                                                    URL:mainImageDataURI
                                                                        placeholderIcon:nil
                                                                             localImage:nil
                                                                             customData:nil];
    }

    if (backgroundImageDataURI) {
        backgroundImageData = [[HUBComponentImageDataImplementation alloc] initWithIdentifier:nil
                                                                                         type:HUBComponentImageTypeBackground
                                                                                          URL:backgroundImageDataURI
                                                                              placeholderIcon:nil
                                                                                   localImage:nil
                                                                                   customData:nil];
    }

    static NSUInteger count = 0;

    HUBComponentModelImplementation *componentModel = [[HUBComponentModelImplementation alloc] initWithIdentifier:[NSString stringWithFormat:@"Testing%@", @(count++)]
                                                                                                             type:HUBComponentTypeBody
                                                                                                            index:0
                                                                                                  groupIdentifier:nil
                                                                                              componentIdentifier:[[HUBIdentifier alloc] initWithNamespace:@"ns" name:@"name"]
                                                                                                componentCategory:HUBComponentCategoryCard
                                                                                                            title:nil
                                                                                                         subtitle:nil
                                                                                                   accessoryTitle:nil
                                                                                                  descriptionText:nil
                                                                                                    mainImageData:mainImageData
                                                                                              backgroundImageData:backgroundImageData
                                                                                                  customImageData:[NSMutableDictionary new]
                                                                                                             icon:nil
                                                                                                           target:nil
                                                                                                         metadata:nil
                                                                                                      loggingData:nil
                                                                                                       customData:nil
                                                                                                           parent:parent];
    return componentModel;
}

- (void)fireLoadCompleteForURIs:(NSArray<NSURL *> *)URIs
{
    id<HUBImageLoaderDelegate> const imageLoaderDelegate = self.imageLoaderMock.delegate;
    for (NSURL *URI in URIs) {
        [imageLoaderDelegate imageLoader:self.imageLoaderMock didLoadImage:[UIImage new] forURL:URI];
    }
}

- (void)fireLoadCompleteForURI:(NSURL *)URI
{
    [self fireLoadCompleteForURIs:@[URI]];
}

- (void)testImageLoadingForMultipleImageDataSections
{
    NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.main"];
    NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.background"];

    CGSize const containerViewSize = CGSizeMake(320, 240);

    HUBComponentMock * const component = [HUBComponentMock new];
    id<HUBComponentModel> const componentModel = [self createComponentModelWithMainImageDataURI:mainImageURL backgroundImageDataURI:backgroundImageURL parent:nil];
    HUBComponentWrapper * const wrapper = [self createComponentWrapperWithComponent:component componentModel:componentModel parent:nil];

    // Load images
    [self.wrapperImageLoader loadImagesForComponentWrapper:wrapper containerViewSize:containerViewSize];

    XCTAssertNil(component.mainImageData.URL);
    XCTAssertNil(component.backgroundImageData.URL);

    // Fire a "load complete" for each URI
    [self fireLoadCompleteForURIs:@[mainImageURL, backgroundImageURL]];

    XCTAssertEqualObjects(component.mainImageData.URL, mainImageURL);
    XCTAssertEqualObjects(component.backgroundImageData.URL, backgroundImageURL);
}

- (void)testImageLoadingForMultipleComponentsSharingTheSameImageURL
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.url"];
    CGSize const containerViewSize = CGSizeMake(320, 240);

    HUBComponentMock * const componentA = [HUBComponentMock new];
    HUBComponentMock * const componentB = [HUBComponentMock new];
    id<HUBComponentModel> const componentModelA = [self createComponentModelWithMainImageDataURI:imageURL backgroundImageDataURI:nil parent:nil];
    id<HUBComponentModel> const componentModelB = [self createComponentModelWithMainImageDataURI:imageURL backgroundImageDataURI:nil parent:nil];
    HUBComponentWrapper * const wrapperA = [self createComponentWrapperWithComponent:componentA componentModel:componentModelA parent:nil];
    HUBComponentWrapper * const wrapperB = [self createComponentWrapperWithComponent:componentB componentModel:componentModelB parent:nil];

    // Try to load images for both wrappers
    [self.wrapperImageLoader loadImagesForComponentWrapper:wrapperA containerViewSize:containerViewSize];
    [self.wrapperImageLoader loadImagesForComponentWrapper:wrapperB containerViewSize:containerViewSize];

    XCTAssertNil(componentA.mainImageData.URL);
    XCTAssertNil(componentB.mainImageData.URL);

    // Fire a single "load complete"
    [self fireLoadCompleteForURI:imageURL];

    XCTAssertEqualObjects(componentA.mainImageData.URL, imageURL);
    XCTAssertEqualObjects(componentB.mainImageData.URL, imageURL);
}

- (void)testDownloadFromNetworkImageAnimation
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.url"];
    CGSize const containerViewSize = CGSizeMake(320, 240);

    HUBComponentMock * const component = [HUBComponentMock new];
    id<HUBComponentModel> const componentModel = [self createComponentModelWithMainImageDataURI:imageURL backgroundImageDataURI:nil parent:nil];
    HUBComponentWrapper * const wrapper = [self createComponentWrapperWithComponent:component componentModel:componentModel parent:nil];

    // Trigger the load
    [self.wrapperImageLoader loadImagesForComponentWrapper:wrapper containerViewSize:containerViewSize];

    XCTAssertFalse(component.imageWasAnimated);

    NSTimeInterval downloadFromNetworkTime = 2;
    [NSThread sleepForTimeInterval:downloadFromNetworkTime];

    // Trigger the load completion
    [self fireLoadCompleteForURI:imageURL];

    XCTAssertTrue(component.imageWasAnimated);
}

- (void)testDownloadFromCacheImageAnimation
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.url"];
    CGSize const containerViewSize = CGSizeMake(320, 240);

    HUBComponentMock * const component = [HUBComponentMock new];
    id<HUBComponentModel> const componentModel = [self createComponentModelWithMainImageDataURI:imageURL backgroundImageDataURI:nil parent:nil];
    HUBComponentWrapper * const wrapper = [self createComponentWrapperWithComponent:component componentModel:componentModel parent:nil];

    // Trigger the load
    [self.wrapperImageLoader loadImagesForComponentWrapper:wrapper containerViewSize:containerViewSize];

    XCTAssertFalse(component.imageWasAnimated);

    // Trigger the load completion
    [self fireLoadCompleteForURI:imageURL];

    XCTAssertFalse(component.imageWasAnimated);
}

- (void)testImageLoadingForChildComponent
{
    NSURL * const parentImageURL = [NSURL URLWithString:@"https://image.parent"];
    NSURL * const childImageURL = [NSURL URLWithString:@"https://image.child"];
    CGSize const containerViewSize = CGSizeMake(320, 240);

    HUBComponentMock * const parentComponent = [HUBComponentMock new];
    HUBComponentMock * const childComponent = [HUBComponentMock new];
    HUBComponentModelImplementation * const parentComponentModel = [self createComponentModelWithMainImageDataURI:parentImageURL backgroundImageDataURI:nil parent:nil];
    HUBComponentModelImplementation * const childComponentModel = [self createComponentModelWithMainImageDataURI:childImageURL backgroundImageDataURI:nil parent:parentComponentModel];
    parentComponentModel.children = @[childComponentModel];
    HUBComponentWrapper * const parentWrapper = [self createComponentWrapperWithComponent:parentComponent componentModel:parentComponentModel parent:nil];
    HUBComponentWrapper * const childWrapper = [self createComponentWrapperWithComponent:childComponent componentModel:childComponentModel parent:parentWrapper];
    parentWrapper.childrenByIndex[@0] = childWrapper;

    // Trigger the load
    [self.wrapperImageLoader loadImagesForComponentWrapper:parentWrapper containerViewSize:containerViewSize];
    [self.wrapperImageLoader loadImagesForComponentWrapper:childWrapper containerViewSize:containerViewSize];

    XCTAssertNil(parentComponent.mainImageData.URL);
    XCTAssertNil(childComponent.mainImageData.URL);

    // Trigger the load completion
    [self fireLoadCompleteForURI:parentImageURL];
    [self fireLoadCompleteForURI:childImageURL];

    XCTAssertEqualObjects(parentComponent.mainImageData.URL, parentImageURL);
    XCTAssertEqualObjects(childComponent.mainImageData.URL, childImageURL);
}

- (void)testNoImagesLoadedIfComponentDoesNotHandleImages
{
    NSURL * const imageURLA = [NSURL URLWithString:@"https://image.url.A"];
    NSURL * const imageURLB = [NSURL URLWithString:@"https://image.url.B"];
    CGSize const containerViewSize = CGSizeMake(320, 240);

    HUBComponentMock * const componentA = [HUBComponentMock new];
    HUBComponentMock * const componentB = [HUBComponentMock new];
    componentA.canHandleImages = NO;
    componentB.canHandleImages = YES;
    id<HUBComponentModel> const componentModelA = [self createComponentModelWithMainImageDataURI:imageURLA backgroundImageDataURI:nil parent:nil];
    id<HUBComponentModel> const componentModelB = [self createComponentModelWithMainImageDataURI:imageURLB backgroundImageDataURI:nil parent:nil];
    HUBComponentWrapper * const wrapperA = [self createComponentWrapperWithComponent:componentA componentModel:componentModelA parent:nil];
    HUBComponentWrapper * const wrapperB = [self createComponentWrapperWithComponent:componentB componentModel:componentModelB parent:nil];

    // Trigger the loads
    [self.wrapperImageLoader loadImagesForComponentWrapper:wrapperA containerViewSize:containerViewSize];
    [self.wrapperImageLoader loadImagesForComponentWrapper:wrapperB containerViewSize:containerViewSize];

    XCTAssertNil(componentA.mainImageData.URL);
    XCTAssertNil(componentB.mainImageData.URL);

    // Trigger the load completions
    [self fireLoadCompleteForURIs:@[imageURLA, imageURLB]];

    XCTAssertNil(componentA.mainImageData.URL);
    XCTAssertEqualObjects(componentB.mainImageData.URL, imageURLB);
    XCTAssertFalse([self.imageLoaderMock hasLoadedImageForURL:imageURLA]);
    XCTAssertTrue([self.imageLoaderMock hasLoadedImageForURL:imageURLB]);
}

#pragma mark - HUBComponentWrapperDelegate

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper willUpdateSelectionState:(HUBComponentSelectionState)selectionState
{
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper didUpdateSelectionState:(HUBComponentSelectionState)selectionState
{
}

- (HUBComponentWrapper *)componentWrapper:(HUBComponentWrapper *)componentWrapper
                   childComponentForModel:(id<HUBComponentModel>)model
{
    return componentWrapper;
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
          childComponent:(nullable HUBComponentWrapper *)childComponent
               childView:(UIView *)childComponentView
       willAppearAtIndex:(NSUInteger)childIndex
{
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
          childComponent:(nullable HUBComponentWrapper *)childComponent
               childView:(UIView *)childComponentView
     didDisappearAtIndex:(NSUInteger)childIndex
{
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
    childSelectedAtIndex:(NSUInteger)childIndex
              customData:(nullable NSDictionary<NSString *, id> *)customData
{
}

- (BOOL)componentWrapper:(HUBComponentWrapper *)componentWrapper
performActionWithIdentifier:(HUBIdentifier *)identifier
              customData:(nullable NSDictionary<NSString *, id> *)customData
{
    return NO;
}

- (void)sendComponentWrapperToReusePool:(HUBComponentWrapper *)componentWrapper
{
}

@end
