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

#import "HUBComponentWrapperImageLoader.h"

#import "HUBComponentImageLoadingContext.h"
#import "HUBComponentModel.h"
#import "HUBComponentWrapper.h"
#import "HUBImageLoader.h"
#import "HUBUtilities.h"

static NSTimeInterval const HUBImageDownloadTimeThreshold = 0.07;

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentWrapperImageLoader () <HUBImageLoaderDelegate>

@property (nonatomic, strong, nullable, readonly) id<HUBImageLoader> imageLoader;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, NSMutableArray<HUBComponentImageLoadingContext *> *> *componentImageLoadingContexts;

@end

@implementation HUBComponentWrapperImageLoader

- (instancetype)initWithImageLoader:(id<HUBImageLoader>)imageLoader
{
    self = [super init];
    if (self) {
        _imageLoader = imageLoader;
        _componentImageLoadingContexts = [NSMutableDictionary new];

        imageLoader.delegate = self;
    }
    return self;
}

- (void)loadImagesForComponentWrapper:(HUBComponentWrapper *)componentWrapper
                    containerViewSize:(CGSize)containerViewSize
{
    if (!componentWrapper.handlesImages) {
        return;
    }

    id<HUBComponentModel> componentModel = componentWrapper.model;

    if (componentModel == nil) {
        return;
    }

    id<HUBComponentImageData> const mainImageData = componentModel.mainImageData;
    id<HUBComponentImageData> const backgroundImageData = componentModel.backgroundImageData;

    if (mainImageData != nil) {
        [self loadImageFromData:mainImageData
                          model:componentModel
               componentWrapper:componentWrapper
              containerViewSize:containerViewSize];
    }

    if (backgroundImageData != nil) {
        [self loadImageFromData:backgroundImageData
                          model:componentModel
               componentWrapper:componentWrapper
              containerViewSize:containerViewSize];
    }

    for (id<HUBComponentImageData> const customImageData in componentModel.customImageData.allValues) {
        [self loadImageFromData:customImageData
                          model:componentModel
               componentWrapper:componentWrapper
              containerViewSize:containerViewSize];
    }
}

- (void)loadImageFromData:(id<HUBComponentImageData>)imageData
                    model:(id<HUBComponentModel>)model
         componentWrapper:(HUBComponentWrapper *)componentWrapper
        containerViewSize:(CGSize)containerViewSize
{
    if (imageData.localImage != nil) {
        UIImage * const localImage = imageData.localImage;
        [componentWrapper updateViewForLoadedImage:localImage
                                          fromData:imageData
                                             model:model
                                          animated:NO];
    }

    NSURL * const imageURL = imageData.URL;

    if (imageURL == nil) {
        return;
    }

    CGSize const preferredSize = [componentWrapper preferredSizeForImageFromData:imageData
                                                                           model:model
                                                               containerViewSize:containerViewSize];

    if (CGSizeEqualToSize(preferredSize, CGSizeZero)) {
        return;
    }

    HUBComponentImageLoadingContext * const context = [[HUBComponentImageLoadingContext alloc] initWithImageType:imageData.type
                                                                                                 imageIdentifier:imageData.identifier
                                                                                                         wrapper:componentWrapper
                                                                                                       timestamp:[NSDate date].timeIntervalSinceReferenceDate];

    NSMutableArray *contextsForURL = self.componentImageLoadingContexts[imageURL];

    if (contextsForURL == nil) {
        contextsForURL = [NSMutableArray arrayWithObject:context];
        self.componentImageLoadingContexts[imageURL] = contextsForURL;
        [self.imageLoader loadImageForURL:imageURL targetSize:preferredSize];
    } else {
        [contextsForURL addObject:context];
    }
}

- (void)handleLoadedComponentImage:(UIImage *)image forURL:(NSURL *)imageURL context:(HUBComponentImageLoadingContext *)context
{
    HUBComponentWrapper * const componentWrapper = context.wrapper;
    id<HUBComponentModel> componentModel = componentWrapper.model;

    if (componentModel == nil) {
        return;
    }

    id<HUBComponentImageData> imageData = nil;

    switch (context.imageType) {
        case HUBComponentImageTypeMain:
            imageData = componentModel.mainImageData;
            break;
        case HUBComponentImageTypeBackground:
            imageData = componentModel.backgroundImageData;
            break;
        case HUBComponentImageTypeCustom: {
            NSString * const imageIdentifier = context.imageIdentifier;

            if (imageIdentifier != nil) {
                imageData = componentModel.customImageData[imageIdentifier];
            }

            break;
        }
    }

    if (![imageData.URL isEqual:imageURL]) {
        return;
    }

    NSTimeInterval downloadTime = [NSDate date].timeIntervalSinceReferenceDate - context.timestamp;
    BOOL animated = downloadTime > HUBImageDownloadTimeThreshold;

    [componentWrapper updateViewForLoadedImage:image
                                      fromData:imageData
                                         model:componentModel
                                      animated:animated];
}

#pragma mark - HUBImageLoaderDelegate

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didLoadImage:(UIImage *)image forURL:(NSURL *)imageURL
{
    HUBPerformOnMainQueue(^{
        NSArray * const contexts = self.componentImageLoadingContexts[imageURL];
        self.componentImageLoadingContexts[imageURL] = nil;

        for (HUBComponentImageLoadingContext * const context in contexts) {
            [self handleLoadedComponentImage:image forURL:imageURL context:context];
        }
    });
}

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didFailLoadingImageForURL:(NSURL *)imageURL error:(NSError *)error
{
    HUBPerformOnMainQueue(^{
        self.componentImageLoadingContexts[imageURL] = nil;
    });
}

@end

NS_ASSUME_NONNULL_END
