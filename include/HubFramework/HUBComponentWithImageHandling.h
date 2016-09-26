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

#import "HUBComponent.h"

@protocol HUBComponentImageData;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extended Hub component protocol that adds the ability to handle images
 *
 *  Use this protocol if your component will display images, either for itself or for any
 *  child components that it could potentially be managing. See `HUBComponent` for more info.
 */
@protocol HUBComponentWithImageHandling <HUBComponent>

/**
 *  Return the size that the component prefers that a certain image gets once loaded
 *
 *  @param imageData The data that will be used to load the image
 *  @param model The current model for the component
 *  @param containerViewSize The size of the container in which the view will be displayed
 */
- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData
                                  model:(id<HUBComponentModel>)model
                      containerViewSize:(CGSize)containerViewSize;

/**
 *  Update the view to display an image that was loaded
 *
 *  @param image The image that was loaded
 *  @param imageData The data that was used to load the image
 *  @param model The current model for the component
 *  @param animated Whether the update should be applied with an animation
 */
- (void)updateViewForLoadedImage:(UIImage *)image
                        fromData:(id<HUBComponentImageData>)imageData
                           model:(id<HUBComponentModel>)model
                        animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
