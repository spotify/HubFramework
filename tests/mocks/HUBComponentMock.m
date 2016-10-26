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

#import "HUBComponentMock.h"
#import "HUBComponentImageData.h"

@interface HUBComponentMock ()

@property (nonatomic, assign, readwrite) HUBComponentSelectionState selectionState;
@property (nonatomic, strong, readwrite, nullable) id<HUBComponentModel> model;
@property (nonatomic, strong, readwrite, nullable) id<HUBComponentImageData> mainImageData;
@property (nonatomic, strong, readwrite, nullable) id<HUBComponentImageData> backgroundImageData;
@property (nonatomic, readwrite) NSUInteger numberOfResizes;
@property (nonatomic, readwrite) NSUInteger numberOfAppearances;
@property (nonatomic, readwrite) NSUInteger numberOfReuses;
@property (nonatomic, readwrite) NSUInteger numberOfContentOffsetChanges;
@property (nonatomic, strong, readwrite, nullable) id<HUBActionContext> latestObservedActionContext;
@property (nonatomic, strong, readonly) NSMutableArray<id> *mutableRestoredUIStates;
@property (nonatomic, readwrite) BOOL imageWasAnimated;

@end

@implementation HUBComponentMock

@synthesize view = _view;
@synthesize childDelegate = _childDelegate;
@synthesize actionPerformer = _actionPerformer;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _layoutTraits = [NSMutableSet new];
        _canHandleImages = YES;
        _mutableRestoredUIStates = [NSMutableArray new];
        _imageWasAnimated = NO;
    }
    
    return self;
}

#pragma mark - HUBComponent

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)prepareViewForReuse
{
    self.numberOfReuses++;
    self.mainImageData = nil;
    self.backgroundImageData = nil;
}

- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return self.preferredViewSize;
}

- (void)configureViewWithModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    NSAssert(self.view != nil, @"-configureViewWithModel should never be called before -loadView");
    self.currentContainerViewSize = containerViewSize;
    self.model = model;
}

#pragma mark - HUBComponentWithImageHandling

- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return CGSizeMake(100, 100);
}

- (void)updateViewForLoadedImage:(UIImage *)image fromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model animated:(BOOL)animated
{
    self.imageWasAnimated = animated;

    switch (imageData.type) {
        case HUBComponentImageTypeMain:
            self.mainImageData = imageData;
            break;
        case HUBComponentImageTypeBackground:
            self.backgroundImageData = imageData;
            break;
        case HUBComponentImageTypeCustom:
            break;
    }
}

#pragma mark - HUBComponentWithRestorableUIState

- (void)restoreUIState:(id)state
{
    self.currentUIState = state;
    [self.mutableRestoredUIStates addObject:state];
}

#pragma mark - HUBComponentWithSelectionState

- (void)updateViewForSelectionState:(HUBComponentSelectionState)selectionState
{
    // This assert ensures that components are never asked to update their view for the same selection state twice
    NSParameterAssert(selectionState != self.selectionState);
    self.selectionState = selectionState;
}

#pragma mark - HUBComponentViewObserver

- (void)viewDidResize
{
    self.numberOfResizes++;
}

- (void)viewWillAppear
{
    self.numberOfAppearances++;
}

#pragma mark - HUBComponentContentOffsetObserver

- (void)updateViewForChangedContentOffset:(CGPoint)contentOffset
{
    self.numberOfContentOffsetChanges++;
}

#pragma mark - HUBComponentActionObserver

- (void)actionPerformedWithContext:(id<HUBActionContext>)context
{
    self.latestObservedActionContext = context;
}

#pragma mark - Property overrides

- (NSArray<id> *)restoredUIStates
{
    return [self.mutableRestoredUIStates copy];
}

#pragma mark - Mocking tools

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    if (protocol == @protocol(HUBComponentWithImageHandling)) {
        return self.canHandleImages;
    }
    
    if (protocol == @protocol(HUBComponentWithRestorableUIState)) {
        return self.supportsRestorableUIState;
    }
    
    if (protocol == @protocol(HUBComponentViewObserver)) {
        return self.isViewObserver;
    }
    
    if (protocol == @protocol(HUBComponentContentOffsetObserver)) {
        return self.isContentOffsetObserver;
    }
    
    return [super conformsToProtocol:protocol];
}

@end
