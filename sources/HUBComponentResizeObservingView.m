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

#import "HUBComponentResizeObservingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentResizeObservingView ()

@property (nonatomic, assign) CGSize previousSize;
@property (nonatomic, weak, nullable) UIView *previousSuperview;

@end

@implementation HUBComponentResizeObservingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.previousSize = frame.size;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.userInteractionEnabled = NO;
        self.hidden = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(self.previousSize, self.frame.size)) {
        return;
    }
    
    self.previousSize = self.frame.size;
    [self.delegate resizeObservingViewDidResize:self];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    // This prevents accidental removal of the view by an API user
    if (self.superview == nil) {
        [self.previousSuperview addSubview:self];
    } else {
        self.previousSuperview = self.superview;
    }
}

@end

NS_ASSUME_NONNULL_END
