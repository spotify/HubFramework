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

/**
 *  Extended Hub component protocol that adds the ability for a component to observe its view
 *
 *  Use this protocol when you want to customize the behavior of your component's view, such
 *  as starting animations when the component appears on the screen, or reacting to resizes.
 *
 *  See `HUBComponent` for more information.
 */
@protocol HUBComponentViewObserver <HUBComponent>

/**
 *  Sent to the component when it's view was resized by the layout system
 *
 *  This message will be sent on every resize, when the view already has its new frame. This is where the
 *  component should perform any manual repositioning or resizing of any subviews that its managing; it
 *  can be used as an equivalent of `-layoutSubviews` in a `UIView` subclass.
 */
- (void)viewDidResize;

/**
 *  Sent to the component when it's view is about to appear on the screen
 *
 *  This message will be sent both when the component's view is about to appear because the user has scrolled
 *  the viewport to include the view's frame, and also when the view controller that the component is presented
 *  in (re)appeared - if the component is in the initial viewport.
 *
 *  This method can be used to start animations or perform any other visual changes.
 */
- (void)viewWillAppear;

@end
