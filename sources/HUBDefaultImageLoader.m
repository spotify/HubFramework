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


#import "HUBDefaultImageLoader.h"
#import "HUBErrors.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBDefaultImageLoader ()

@property (nonatomic, strong, readonly) NSURLSession *session;

@end

@implementation HUBDefaultImageLoader

@synthesize delegate = _delegate;

#pragma mark - Initializer

- (instancetype)initWithSession:(NSURLSession *)session
{
    NSParameterAssert(session != nil);
    
    self = [super init];
    
    if (self) {
        _session = session;
    }
    
    return self;
}

#pragma mark - HUBImageLoader

- (void)loadImageForURL:(NSURL *)imageURL targetSize:(CGSize)targetSize
{
    __weak __typeof(self) weakSelf = self;

    NSURLSessionTask * const task = [self.session dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBImageLoaderDelegate> const delegate = strongSelf.delegate;
        
        if (data == nil || error != nil) {
            NSError * const nonNilError = error ?: [NSError errorWithDomain:HUBImageLoaderErrorDomain code:HUBImageLoaderErrorCodeUnknown userInfo:nil];
            [delegate imageLoader:strongSelf didFailLoadingImageForURL:imageURL error:nonNilError];
            return;
        }
        
        NSData * const nonNilData = data;
        UIImage *image = [UIImage imageWithData:nonNilData scale:[UIScreen mainScreen].scale];
        
        if (image == nil) {
            NSError * const dataError = [NSError errorWithDomain:HUBImageLoaderErrorDomain code:HUBImageLoaderErrorCodeInvalidData userInfo:nil];
            [delegate imageLoader:strongSelf didFailLoadingImageForURL:imageURL error:dataError];
            return;
        }
        
        if (!CGSizeEqualToSize(image.size, targetSize)) {
            BOOL const imageIsJPEG = [response.MIMEType isEqualToString:@"image/jpeg"];
            UIGraphicsBeginImageContextWithOptions(targetSize, imageIsJPEG, image.scale);
            [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }

        [delegate imageLoader:strongSelf didLoadImage:image forURL:imageURL];
    }];

    [task resume];
}

@end

NS_ASSUME_NONNULL_END
