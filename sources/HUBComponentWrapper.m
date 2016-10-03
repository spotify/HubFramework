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

#import "HUBComponentWrapper.h"

#import "HUBComponentWithChildren.h"
#import "HUBComponentWithRestorableUIState.h"
#import "HUBComponentViewObserver.h"
#import "HUBComponentWithImageHandling.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBComponentActionPerformer.h"
#import "HUBComponentModel.h"
#import "HUBComponentUIStateManager.h"
#import "HUBComponentResizeObservingView.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentWrapper () <HUBComponentChildDelegate, HUBComponentActionDelegate, HUBComponentResizeObservingViewDelegate>

@property (nonatomic, strong, readwrite) id<HUBComponentModel> model;
@property (nonatomic, assign) BOOL viewHasAppearedSinceLastModelChange;
@property (nonatomic, strong, readonly) id<HUBComponent> component;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, HUBComponentWrapper *> *childrenByIndex;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, UIView *> *visibleChildViewsByIndex;
@property (nonatomic, assign) BOOL hasBeenConfigured;

@end

@implementation HUBComponentWrapper

- (instancetype)initWithComponent:(id<HUBComponent>)component
                            model:(id<HUBComponentModel>)model
                   UIStateManager:(HUBComponentUIStateManager *)UIStateManager
                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                           parent:(nullable HUBComponentWrapper *)parent
{
    NSParameterAssert(component != nil);
    NSParameterAssert(model != nil);
    NSParameterAssert(UIStateManager != nil);
    NSParameterAssert(delegate != nil);
    
    self = [super init];
    
    if (self) {
        _identifier = [NSUUID UUID];
        _model = model;
        _component = component;
        _UIStateManager = UIStateManager;
        _delegate = delegate;
        _parent = parent;
        _childrenByIndex = [NSMutableDictionary new];
        _visibleChildViewsByIndex = [NSMutableDictionary new];

        if ([_component conformsToProtocol:@protocol(HUBComponentWithChildren)]) {
            ((id<HUBComponentWithChildren>)_component).childDelegate = self;
        }
        
        if ([_component conformsToProtocol:@protocol(HUBComponentActionPerformer)]) {
            ((id<HUBComponentActionPerformer>)_component).actionDelegate = self;
        }
    }
    
    return self;
}

#pragma mark - API

- (void)updateViewForChangedContentOffset:(CGPoint)contentOffset
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)]) {
        return;
    }
    
    [(id<HUBComponentContentOffsetObserver>)self.component updateViewForChangedContentOffset:contentOffset];
}

- (void)saveComponentUIState
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithRestorableUIState)]) {
        return;
    }
    
    id currentUIState = [(id<HUBComponentWithRestorableUIState>)self.component currentUIState];
    
    if (currentUIState == nil) {
        [self.UIStateManager removeSavedUIStateForComponentModel:self.model];
    } else {
        [self.UIStateManager saveUIState:currentUIState forComponentModel:self.model];
    }
}

#pragma mark - Property overrides

- (BOOL)handlesImages
{
    return [self.component conformsToProtocol:@protocol(HUBComponentWithImageHandling)];
}

- (BOOL)isContentOffsetObserver
{
    return [self.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)];
}

- (BOOL)isRootComponent
{
    return self.parent == nil;
}

#pragma mark - HUBComponent

- (NSSet<HUBComponentLayoutTrait> *)layoutTraits
{
    return self.component.layoutTraits;
}

- (nullable __kindof UIView *)view
{
    return self.component.view;
}

- (void)setView:(nullable __kindof UIView *)view
{
    self.component.view = view;
}

- (void)loadView
{
    BOOL const viewLoaded = (self.view != nil);
    UIView * const view = HUBComponentLoadViewIfNeeded(self.component);
    
    if (!viewLoaded) {
        if ([self.component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
            HUBComponentResizeObservingView * const resizeObservingView = [[HUBComponentResizeObservingView alloc] initWithFrame:view.bounds];
            resizeObservingView.delegate = self;
            [view addSubview:resizeObservingView];
        }
    }
}

- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return [self.component preferredViewSizeForDisplayingModel:model containerViewSize:containerViewSize];
}

- (void)configureViewWithModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    if (self.hasBeenConfigured) {
        if ([self.model isEqual:model]) {
            return;
        }
        
        [self saveComponentUIState];
        [self.component prepareViewForReuse];
    }
    
    self.model = model;
    
    [self.component configureViewWithModel:model containerViewSize:containerViewSize];
    [self restoreComponentUIStateForModel:model];
    
    self.viewHasAppearedSinceLastModelChange = NO;
    self.hasBeenConfigured = YES;
}

- (void)prepareViewForReuse
{
    NSNumber * const index = @(self.model.index);
    
    HUBComponentWrapper * const parent = self.parent;
    parent.childrenByIndex[index] = nil;
    parent.visibleChildViewsByIndex[index] = nil;
    
    [self.delegate sendComponentWrapperToReusePool:self];
}

#pragma mark - HUBComponentWithImageHandling

- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithImageHandling)]) {
        return CGSizeZero;
    }
    
    return [(id<HUBComponentWithImageHandling>)self.component preferredSizeForImageFromData:imageData
                                                                                      model:model
                                                                          containerViewSize:containerViewSize];
}

- (void)updateViewForLoadedImage:(UIImage *)image fromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model animated:(BOOL)animated
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithImageHandling)]) {
        return;
    }
    
    [(id<HUBComponentWithImageHandling>)self.component updateViewForLoadedImage:image
                                                                       fromData:imageData
                                                                          model:model
                                                                       animated:animated];
}

#pragma mark - HUBComponentViewObserver

- (void)viewWillAppear
{
    if ([self.component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
        [(id<HUBComponentViewObserver>)self.component viewWillAppear];
    }
    
    for (NSNumber * const childIndex in self.visibleChildViewsByIndex) {
        UIView * const childView = self.visibleChildViewsByIndex[childIndex];
        HUBComponentWrapper * const childComponent = self.childrenByIndex[childIndex];
        
        if (childComponent != nil) {
            [childComponent viewWillAppear];
        }
        
        [self.delegate componentWrapper:self
                 childComponentWithView:childView
                      willAppearAtIndex:childIndex.unsignedIntegerValue];
    }
    
    self.viewHasAppearedSinceLastModelChange = YES;
}

- (void)viewDidResize
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
        return;
    }
    
    [(id<HUBComponentViewObserver>)self.component viewDidResize];
}

#pragma mark - HUBComponentChildDelegate

- (id<HUBComponent>)component:(id<HUBComponentWithChildren>)component childComponentForModel:(id<HUBComponentModel>)childComponentModel
{
    HUBComponentWrapper * const childComponent = [self.delegate componentWrapper:self childComponentForModel:childComponentModel];
    self.childrenByIndex[@(childComponentModel.index)] = childComponent;
    return childComponent;
}

- (void)component:(id<HUBComponentWithChildren>)component willDisplayChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView
{
    if (self.component != component) {
        return;
    }
    
    HUBComponentWrapper * const childComponent = self.childrenByIndex[@(childIndex)];
    
    if (childComponent != nil) {
        [childComponent viewWillAppear];
    }
    
    self.visibleChildViewsByIndex[@(childIndex)] = childView;
    [self.delegate componentWrapper:self childComponentWithView:childView willAppearAtIndex:childIndex];
}

- (void)component:(id<HUBComponentWithChildren>)component didStopDisplayingChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView
{
    if (self.component != component) {
        return;
    }
    
    self.visibleChildViewsByIndex[@(childIndex)] = nil;
    [self.delegate componentWrapper:self childComponentWithView:childView didDisappearAtIndex:childIndex];
}

- (void)component:(id<HUBComponentWithChildren>)component childSelectedAtIndex:(NSUInteger)childIndex
{
    if (self.component != component) {
        return;
    }
    
    [self.delegate componentWrapper:self childSelectedAtIndex:childIndex];
}

#pragma mark - HUBComponentActionDelegate

- (BOOL)component:(id<HUBComponentActionPerformer>)component performActionWithIdentifier:(HUBIdentifier *)identifier customData:(nullable NSDictionary<NSString *, id> *)customData
{
    if (self.component != component) {
        return NO;
    }
    
    return [self.delegate componentWrapper:self performActionWithIdentifier:identifier customData:customData];
}

#pragma mark - HUBComponentResizeObservingViewDelegate

- (void)resizeObservingViewDidResize:(HUBComponentResizeObservingView *)view
{
    [(id<HUBComponentViewObserver>)self.component viewDidResize];
}

#pragma mark - Private utilities

- (void)restoreComponentUIStateForModel:(id<HUBComponentModel>)model
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithRestorableUIState)]) {
        return;
    }
    
    id restoredUIState = [self.UIStateManager restoreUIStateForComponentModel:model];
    
    if (restoredUIState != nil) {
        [(id<HUBComponentWithRestorableUIState>)self.component restoreUIState:restoredUIState];
    }
}

@end

NS_ASSUME_NONNULL_END
