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

#import "HUBComponentCollectionViewCell.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "HUBComponent.h"
#import "HUBComponentViewObserver.h"
#import "HUBUtilities.h"
#import "HUBComponentCellWrapperView.h"
#import "HUBTouchPhase.h"
#import "UIView+HUBTouchForwardingTarget.h"
#import "UIGestureRecognizer+HUBTouchForwardingTarget.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentCollectionViewCell ()

@property (nonatomic, strong, readonly) NSMutableSet<UIEvent *> *forwardedEvents;
@property (nonatomic, strong, nullable) HUBComponentCellWrapperView *cellWrapperView;

@end

@implementation HUBComponentCollectionViewCell

#pragma mark - Initializer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _identifier = [NSUUID UUID];
        _forwardedEvents = [NSMutableSet new];
    }
    
    return self;
}

#pragma mark - Property overrides

- (void)setComponent:(nullable id<HUBComponent>)component
{
    if (_component == component) {
        return;
    }
    
    [_component.view removeFromSuperview];
    _component = component;
    
    if (component == nil) {
        return;
    }
    
    id<HUBComponent> const nonNilComponent = component;
    UIView * const componentView = HUBComponentLoadViewIfNeeded(nonNilComponent);
    
    if ([componentView isKindOfClass:[UICollectionViewCell class]] || [componentView isKindOfClass:[UITableViewCell class]]) {
        if (self.cellWrapperView == nil) {
            HUBComponentCellWrapperView * const wrapperView = [HUBComponentCellWrapperView new];
            self.cellWrapperView = wrapperView;
            [self.contentView addSubview:wrapperView];
        }
        
        self.cellWrapperView.componentView = componentView;
    } else {
        [self.cellWrapperView removeFromSuperview];
        self.cellWrapperView = nil;
        
        [self.contentView addSubview:componentView];
    }
}

#pragma mark - UICollectionViewCell

- (void)prepareForReuse
{
    [self.component prepareViewForReuse];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    UIView * const componentView = self.component.view;
    
    if ([componentView isKindOfClass:[UICollectionViewCell class]]) {
        ((UICollectionViewCell *)componentView).selected = selected;
    } else if ([componentView isKindOfClass:[UITableViewCell class]]) {
        ((UITableViewCell *)componentView).selected = selected;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    UIView * const componentView = self.component.view;
    
    if ([componentView isKindOfClass:[UICollectionViewCell class]]) {
        ((UICollectionViewCell *)componentView).highlighted = highlighted;
    } else if ([componentView isKindOfClass:[UITableViewCell class]]) {
        ((UITableViewCell *)componentView).highlighted = highlighted;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.component.view.bounds = self.contentView.bounds;
    self.component.view.center = self.contentView.center;
    
    self.cellWrapperView.bounds = self.contentView.bounds;
    self.cellWrapperView.center = self.contentView.center;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self forwardTouches:touches event:event phase:HUBTouchPhaseBegan];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self forwardTouches:touches event:event phase:HUBTouchPhaseMoved];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self forwardTouches:touches event:event phase:HUBTouchPhaseEnded];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self forwardTouches:touches event:event phase:HUBTouchPhaseCancelled];
}

// For the reasoning behind this code, please see the documentation for `HUBComponentCellWrapperView`
- (void)forwardTouches:(NSSet<UITouch *> *)touches event:(nullable UIEvent *)event phase:(HUBTouchPhase)phase
{
    if (self.cellWrapperView == nil || self.component.view == nil || event == nil) {
        return;
    }
    
    UIEvent * const nonNilEvent = event;
    UIView * const componentView = self.component.view;
    
    if ([self.forwardedEvents containsObject:nonNilEvent]) {
        [self.forwardedEvents removeObject:nonNilEvent];
        return;
    }
    
    [self.forwardedEvents addObject:nonNilEvent];
    
    NSMutableArray<id<HUBTouchForwardingTarget>> * const targets = [NSMutableArray arrayWithObject:componentView];
    NSArray * const gestureRecognizers = componentView.gestureRecognizers;
    
    if (gestureRecognizers != nil) {
        [targets addObjectsFromArray:gestureRecognizers];
    }
    
    for (id<HUBTouchForwardingTarget> const target in targets) {
        switch (phase) {
            case HUBTouchPhaseBegan:
                [target touchesBegan:touches withEvent:nonNilEvent];
                break;
            case HUBTouchPhaseMoved:
                [target touchesMoved:touches withEvent:nonNilEvent];
                break;
            case HUBTouchPhaseEnded:
                [target touchesEnded:touches withEvent:nonNilEvent];
                break;
            case HUBTouchPhaseCancelled:
                [target touchesCancelled:touches withEvent:nonNilEvent];
                break;
        }
    }
}

@end

NS_ASSUME_NONNULL_END
