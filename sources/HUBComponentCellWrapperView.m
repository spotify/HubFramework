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

#import "HUBComponentCellWrapperView.h"

@implementation HUBComponentCellWrapperView

#pragma mark - Property overrides

- (void)setComponentView:(UIView *)componentView
{
    [_componentView removeFromSuperview];
    _componentView = componentView;
    [self addSubview:componentView];
}

#pragma mark - UIView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * const viewAtPoint = [self.componentView hitTest:point withEvent:event];
    
    if (viewAtPoint == self.componentView) {
        return NO;
    }
    
    if ([self.componentView isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionViewCell * const cell = (UICollectionViewCell *)self.componentView;
        return viewAtPoint != cell.contentView;
    }
    
    if ([self.componentView isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell * const cell = (UITableViewCell *)self.componentView;
        return viewAtPoint != cell.contentView;
    }
    
    return NO;
}

@end
