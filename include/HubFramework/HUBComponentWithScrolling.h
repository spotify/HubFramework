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

#import "HUBComponentWithChildren.h"

/**
 * Extended Hub component protocol that adds the ability scroll between child components.
 *
 * Use this protocol if your component supports scrolling between components within it. 
 * See `HUBComponent` for more info.
 */
@protocol HUBComponentWithScrolling <HUBComponentWithChildren>

/**
 * Called when programmatically scrolling to a child within this parent component.
 *
 * @param childIndex The index of the component that is being scrolled to.
 * @param scrollPosition The preferred position of the component after scrolling.
 * @param animated Whether or not the scrolling should be animated.
 * @param completionHandler The block to call once the component is visible.
 */
- (void)scrollToComponentAtIndex:(NSUInteger)childIndex
                  scrollPosition:(UICollectionViewScrollPosition)scrollPosition
                        animated:(BOOL)animated
                      completion:(void (^)())completionHandler;

@end
