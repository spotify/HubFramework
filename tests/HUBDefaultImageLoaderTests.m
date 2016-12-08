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

#import "HUBDefaultImageLoader.h"
#import "HUBURLSessionMock.h"
#import "HUBURLSessionDataTaskMock.h"
#import "HUBURLProtocolMock.h"

@interface HUBDefaultImageLoaderTests : XCTestCase <HUBImageLoaderDelegate>

@property (nonatomic, strong) HUBURLSessionMock *session;
@property (nonatomic, strong) HUBDefaultImageLoader *imageLoader;
@property (nonatomic, strong) UIImage *loadedImage;
@property (nonatomic, strong) NSURL *loadedImageURL;
@property (nonatomic, strong) NSError *loadingError;
@property (nonatomic, assign) BOOL loadedImageFromCache;

@property (nonatomic, weak) XCTestExpectation *imageLoadedExpectation;

@end

@implementation HUBDefaultImageLoaderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.session = [HUBURLSessionMock new];
    self.imageLoader = [[HUBDefaultImageLoader alloc] initWithSession:self.session];
    self.imageLoader.delegate = self;
}

- (void)tearDown
{
    self.session = nil;
    self.imageLoader = nil;
    self.loadedImage = nil;
    self.loadedImageURL = nil;
    self.loadingError = nil;

    [super tearDown];
}

#pragma mark - Tests

- (void)testLoadingImage
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.spotify.com/123"];
    CGSize const targetSize = CGSizeMake(200, 200);
    [self.imageLoader loadImageForURL:imageURL targetSize:targetSize];
    
    HUBURLSessionDataTaskMock * const dataTask = self.session.dataTasks.firstObject;
    XCTAssertTrue(dataTask.started);

    UIGraphicsBeginImageContext(targetSize);
    [[UIColor redColor] setFill];
    UIRectFill(CGRectMake(0, 0, targetSize.width, targetSize.height));
    UIImage * const image = UIGraphicsGetImageFromCurrentImageContext();

    NSData * const data = UIImagePNGRepresentation(image);
    [dataTask finishWithData:data];
    
    XCTAssertNotNil(self.loadedImage);
    XCTAssertTrue(CGSizeEqualToSize(self.loadedImage.size, image.size));
    XCTAssertEqualObjects(self.loadedImageURL, imageURL);
    XCTAssertNil(self.loadingError);
}

- (void)testImageResizing
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.spotify.com/123"];
    CGSize const targetSize = CGSizeMake(200, 200);
    [self.imageLoader loadImageForURL:imageURL targetSize:targetSize];
    
    HUBURLSessionDataTaskMock * const dataTask = self.session.dataTasks.firstObject;
    XCTAssertTrue(dataTask.started);
    
    UIGraphicsBeginImageContext(targetSize);
    [[UIColor redColor] setFill];
    UIRectFill(CGRectMake(0, 0, 100, 100));
    UIImage * const image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData * const data = UIImagePNGRepresentation(image);
    [dataTask finishWithData:data];
    
    XCTAssertNotNil(self.loadedImage);
    XCTAssertTrue(CGSizeEqualToSize(self.loadedImage.size, targetSize));
    XCTAssertEqualObjects(self.loadedImageURL, imageURL);
    XCTAssertNil(self.loadingError);
}

- (void)testNetworkErrorHandling
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.spotify.com/123"];
    CGSize const targetSize = CGSizeMake(200, 200);
    [self.imageLoader loadImageForURL:imageURL targetSize:targetSize];
    
    HUBURLSessionDataTaskMock * const dataTask = self.session.dataTasks.firstObject;
    XCTAssertTrue(dataTask.started);
    
    NSError * const error = [NSError errorWithDomain:@"com.spotify.hubFramework" code:-1 userInfo:nil];
    [dataTask failWithError:error];
    
    XCTAssertNil(self.loadedImage);
    XCTAssertEqualObjects(self.loadingError, error);
}

- (void)testInvalidImageDataProducingError
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.spotify.com/123"];
    CGSize const targetSize = CGSizeMake(200, 200);
    [self.imageLoader loadImageForURL:imageURL targetSize:targetSize];
    
    HUBURLSessionDataTaskMock * const dataTask = self.session.dataTasks.firstObject;
    XCTAssertTrue(dataTask.started);
    
    NSData * const data = [@"Clearly not an image" dataUsingEncoding:NSUTF8StringEncoding];
    [dataTask finishWithData:data];
    
    XCTAssertNil(self.loadedImage);
    XCTAssertNotNil(self.loadingError);
}

#pragma mark - Utilities

- (NSURLSession *)customURLSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.protocolClasses = @[HUBURLProtocolMock.class];
    return [NSURLSession sessionWithConfiguration:configuration];
}

#pragma mark - HUBImageLoaderDelegate

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didLoadImage:(UIImage *)image forURL:(NSURL *)imageURL
{
    XCTAssertEqual(self.imageLoader, imageLoader);
    
    self.loadedImage = image;
    self.loadedImageURL = imageURL;

    [self.imageLoadedExpectation fulfill];
}

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didFailLoadingImageForURL:(NSURL *)imageURL error:(NSError *)error
{
    XCTAssertEqual(self.imageLoader, imageLoader);
    
    self.loadingError = error;
}

@end
