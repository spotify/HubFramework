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

#import <UIKit/UIKit.h>

/**
 *  View that is used to wrap component views that are implemented as cells
 *
 *  When a component choses to implement its `view` as either a `UICollectionViewCell` or
 *  `UITableViewCell`, this view is used to wrap that view before its added as part of the
 *  container view. The reason for this is to work around a UIKit behavior where it will
 *  try to perform selection on the component cell, instead of the cell that is managed by
 *  the Hub Framework - resulting in an untappable view.
 *
 *  The work around is achieved by returning NO from `pointInside:withEvent:` from this view
 *  and then forwarding all touch handling events to the component from the container view
 *  collection view cell.
 */
@interface HUBComponentCellWrapperView : UIView

/// The component view to wrap. Setting this property will add the view as a subview.
@property (nonatomic, strong, nullable) UIView *componentView;

@end
