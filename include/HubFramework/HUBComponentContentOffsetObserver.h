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

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extended Hub component protocol that adds the ability to observe content offset changes
 *
 *  Use this protocol if your component needs to react to content offset changes in the view that it
 *  is being displayed in. See `HUBComponent` for more info.
 */
@protocol HUBComponentContentOffsetObserver <HUBComponent>

/**
 *  Update the component’s view in reaction to that the content offset of the container view changed
 *
 *  @param contentOffset The new content offset of the container view
 *
 *  The Hub Framework will send this message every time that the content offset changed in the main
 *  container view. This is equivalent to `UIScrollView scrollViewDidScroll:`.
 */
- (void)updateViewForChangedContentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
