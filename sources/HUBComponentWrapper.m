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
#import "HUBComponentGestureRecognizer.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentWrapper () <HUBComponentChildDelegate, HUBComponentActionDelegate, HUBComponentResizeObservingViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) id<HUBComponentModel> model;
@property (nonatomic, assign) BOOL viewHasAppearedSinceLastModelChange;
@property (nonatomic, strong, readonly) id<HUBComponent> component;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, HUBComponentWrapper *> *childrenByIndex;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, UIView *> *visibleChildViewsByIndex;
@property (nonatomic, strong, readonly) HUBComponentGestureRecognizer *gestureRecognizer;
@property (nonatomic, assign) BOOL hasBeenConfigured;
@property (nonatomic, assign) BOOL shouldPerformDelayedHighlight;
@property (nonatomic, assign) HUBComponentSelectionState selectionState;

@end

@implementation HUBComponentWrapper

- (instancetype)initWithComponent:(id<HUBComponent>)component
                            model:(id<HUBComponentModel>)model
                   UIStateManager:(HUBComponentUIStateManager *)UIStateManager
                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                gestureRecognizer:(HUBComponentGestureRecognizer *)gestureRecognizer
                           parent:(nullable HUBComponentWrapper *)parent
{
    NSParameterAssert(component != nil);
    NSParameterAssert(model != nil);
    NSParameterAssert(UIStateManager != nil);
    NSParameterAssert(gestureRecognizer != nil);
    NSParameterAssert(delegate != nil);
    
    self = [super init];
    
    if (self) {
        _identifier = [NSUUID UUID];
        _model = model;
        _component = component;
        _UIStateManager = UIStateManager;
        _gestureRecognizer = gestureRecognizer;
        _delegate = delegate;
        _parent = parent;
        _childrenByIndex = [NSMutableDictionary new];
        _visibleChildViewsByIndex = [NSMutableDictionary new];

        _gestureRecognizer.delegate = self;
        [_gestureRecognizer addTarget:self action:@selector(handleGestureRecognizer:)];
        
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

- (void)viewDidMoveToSuperview:(UIView *)superview
{
    [self.gestureRecognizer.view removeGestureRecognizer:self.gestureRecognizer];
    [superview addGestureRecognizer:self.gestureRecognizer];
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

- (NSArray<HUBComponentWrapper *> *)visibleChildren
{
    NSMutableArray<HUBComponentWrapper *> *visibleChildren = [NSMutableArray array];
    for (NSNumber *visibleViewIndex in self.visibleChildViewsByIndex) {
        HUBComponentWrapper *childComponentWrapper = self.childrenByIndex[visibleViewIndex];
        if (childComponentWrapper != nil) {
            [visibleChildren addObject:childComponentWrapper];
        }
    }
    return [visibleChildren copy];
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
        HUBComponentWrapper * const childComponent = self.childrenByIndex[childIndex];
        UIView *childView = self.visibleChildViewsByIndex[childIndex];
        
        if (childComponent != nil) {
            [childComponent viewWillAppear];
        }
        
        [self.delegate componentWrapper:self
                         childComponent:childComponent
                              childView:childView
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

#pragma mark - HUBComponentContentOffsetObserver

- (void)updateViewForChangedContentOffset:(CGPoint)contentOffset
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)]) {
        return;
    }
    
    [(id<HUBComponentContentOffsetObserver>)self.component updateViewForChangedContentOffset:contentOffset];
}

#pragma mark - HUBComponentWithSelectionState

- (void)updateViewForSelectionState:(HUBComponentSelectionState)selectionState
{
    [self updateViewForSelectionState:selectionState notifyDelegate:NO];
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
    [self.delegate componentWrapper:self
                     childComponent:childComponent
                          childView:childView
                  willAppearAtIndex:childIndex];
}

- (void)component:(id<HUBComponentWithChildren>)component didStopDisplayingChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView
{
    if (self.component != component) {
        return;
    }
    
    HUBComponentWrapper * const childComponent = self.childrenByIndex[@(childIndex)];
    self.visibleChildViewsByIndex[@(childIndex)] = nil;

    [self.delegate componentWrapper:self
                     childComponent:childComponent
                          childView:childView
                didDisappearAtIndex:childIndex];
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![touch.view isKindOfClass:[UIButton class]];
}

#pragma mark - HUBComponentResizeObservingViewDelegate

- (void)resizeObservingViewDidResize:(HUBComponentResizeObservingView *)view
{
    [(id<HUBComponentViewObserver>)self.component viewDidResize];
}

#pragma mark - Gesture recognizer handling

- (void)handleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    id<HUBComponentWrapperDelegate> const delegate = self.delegate;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateBegan: {
            self.shouldPerformDelayedHighlight = YES;
            [delegate componentWrapper:self willUpdateSelectionState:HUBComponentSelectionStateHighlighted];
            
            // Delay highlight for a short time, to prevent the UI from flashing when the user scrolls over multiple components
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!self.shouldPerformDelayedHighlight) {
                    return;
                }
                
                [self updateViewForSelectionState:HUBComponentSelectionStateHighlighted notifyDelegate:YES];
            });
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [delegate componentWrapper:self willUpdateSelectionState:HUBComponentSelectionStateSelected];
            [self updateViewForSelectionState:HUBComponentSelectionStateSelected notifyDelegate:YES];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [delegate componentWrapper:self willUpdateSelectionState:HUBComponentSelectionStateNone];
            [self updateViewForSelectionState:HUBComponentSelectionStateNone notifyDelegate:YES];
            break;
        }
    }
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

- (void)updateViewForSelectionState:(HUBComponentSelectionState)selectionState notifyDelegate:(BOOL)notifyDelegate
{
    if (selectionState == HUBComponentSelectionStateNone) {
        [self.gestureRecognizer cancel];
    }
    
    self.shouldPerformDelayedHighlight = NO;
    
    if (self.selectionState == selectionState) {
        return;
    }
    
    self.selectionState = selectionState;
    
    if ([self.component conformsToProtocol:@protocol(HUBComponentWithSelectionState)]) {
        [(id<HUBComponentWithSelectionState>)self.component updateViewForSelectionState:selectionState];
    } else if ([self.view isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell * const tableViewCell = self.view;
        
        switch (selectionState) {
            case HUBComponentSelectionStateNone:
                tableViewCell.highlighted = NO;
                tableViewCell.selected = NO;
                break;
            case HUBComponentSelectionStateHighlighted:
                tableViewCell.highlighted = YES;
                tableViewCell.selected = NO;
                break;
            case HUBComponentSelectionStateSelected:
                tableViewCell.highlighted = NO;
                tableViewCell.selected = YES;
                break;
        }
    } else if ([self.view isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionViewCell * const collectionViewCell = self.view;
        
        switch (selectionState) {
            case HUBComponentSelectionStateNone:
                collectionViewCell.highlighted = NO;
                collectionViewCell.selected = NO;
                break;
            case HUBComponentSelectionStateHighlighted:
                collectionViewCell.highlighted = YES;
                collectionViewCell.selected = NO;
                break;
            case HUBComponentSelectionStateSelected:
                collectionViewCell.highlighted = NO;
                collectionViewCell.selected = YES;
                break;
        }
    }
    
    if (notifyDelegate) {
        [self.delegate componentWrapper:self didUpdateSelectionState:selectionState];
    }
}

@end

NS_ASSUME_NONNULL_END
