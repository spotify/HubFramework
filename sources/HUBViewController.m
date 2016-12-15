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

#import "HUBViewController+Initializer.h"

#import "HUBIdentifier.h"
#import "HUBViewModelLoaderImplementation.h"
#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponentImageData.h"
#import "HUBComponentTarget.h"
#import "HUBComponentWithImageHandling.h"
#import "HUBComponentWithChildren.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBComponentViewObserver.h"
#import "HUBComponentWrapper.h"
#import "HUBComponentRegistry.h"
#import "HUBComponentCollectionViewCell.h"
#import "HUBUtilities.h"
#import "HUBImageLoader.h"
#import "HUBComponentImageLoadingContext.h"
#import "HUBCollectionViewFactory.h"
#import "HUBCollectionView.h"
#import "HUBCollectionViewLayout.h"
#import "HUBContainerView.h"
#import "HUBContentReloadPolicy.h"
#import "HUBViewControllerScrollHandler.h"
#import "HUBComponentReusePool.h"
#import "HUBActionContextImplementation.h"
#import "HUBActionHandlerWrapper.h"
#import "HUBViewModelRenderer.h"
#import "HUBFeatureInfo.h"

static NSTimeInterval const HUBImageDownloadTimeThreshold = 0.07;

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewController () <
    HUBViewModelLoaderDelegate,
    HUBImageLoaderDelegate,
    HUBComponentWrapperDelegate,
    UICollectionViewDataSource,
    HUBCollectionViewDelegate
>

@property (nonatomic, strong, readonly) id<HUBFeatureInfo> featureInfo;
@property (nonatomic, strong, readonly) HUBViewModelLoaderImplementation *viewModelLoader;
@property (nonatomic, strong, readonly) HUBCollectionViewFactory *collectionViewFactory;
@property (nonatomic, strong, readonly) id<HUBComponentRegistry> componentRegistry;
@property (nonatomic, strong, readonly) HUBComponentReusePool *componentReusePool;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly) id<HUBActionHandler> actionHandler;
@property (nonatomic, strong, readonly) id<HUBViewControllerScrollHandler> scrollHandler;
@property (nonatomic, strong, nullable, readonly) id<HUBContentReloadPolicy> contentReloadPolicy;
@property (nonatomic, strong, nullable, readonly) id<HUBImageLoader> imageLoader;
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) HUBViewModelRenderer *viewModelRenderer;
@property (nonatomic, assign) BOOL collectionViewIsScrolling;
@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *registeredCollectionViewCellReuseIdentifiers;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, NSMutableArray<HUBComponentImageLoadingContext *> *> *componentImageLoadingContexts;
@property (nonatomic, strong, readonly) NSHashTable<id<HUBComponentContentOffsetObserver>> *contentOffsetObservingComponentWrappers;
@property (nonatomic, strong, readonly) NSHashTable<id<HUBComponentActionObserver>> *actionObservingComponentWrappers;
@property (nonatomic, strong, nullable) HUBComponentWrapper *headerComponentWrapper;
@property (nonatomic, strong, readonly) NSMutableArray<HUBComponentWrapper *> *overlayComponentWrappers;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSUUID *, HUBComponentWrapper *> *componentWrappersByIdentifier;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSUUID *, HUBComponentWrapper *> *componentWrappersByCellIdentifier;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentWrapper *> *componentWrappersByModelIdentifier;
@property (nonatomic, strong, nullable) HUBComponentWrapper *highlightedComponentWrapper;
@property (nonatomic, strong, nullable) id<HUBViewModel> pendingViewModel;
@property (nonatomic, strong, nullable) id<HUBViewModel> viewModel;
@property (nonatomic, assign) BOOL viewHasAppeared;
@property (nonatomic, assign) BOOL viewHasBeenLaidOut;
@property (nonatomic) BOOL viewModelHasChangedSinceLastLayoutUpdate;
@property (nonatomic) CGFloat visibleKeyboardHeight;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, copy, nullable) void(^pendingScrollAnimationCallback)(void);
@property (nonatomic, getter=isRendering) BOOL rendering;

@end

@implementation HUBViewController

#pragma mark - Lifecycle

- (instancetype)initWithViewURI:(NSURL *)viewURI
                    featureInfo:(id<HUBFeatureInfo>)featureInfo
                viewModelLoader:(HUBViewModelLoaderImplementation *)viewModelLoader
              viewModelRenderer:(HUBViewModelRenderer *)viewModelRenderer
          collectionViewFactory:(HUBCollectionViewFactory *)collectionViewFactory
              componentRegistry:(id<HUBComponentRegistry>)componentRegistry
             componentReusePool:(HUBComponentReusePool *)componentReusePool
         componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                  actionHandler:(id<HUBActionHandler>)actionHandler
                  scrollHandler:(id<HUBViewControllerScrollHandler>)scrollHandler
                    imageLoader:(id<HUBImageLoader>)imageLoader
{
    NSParameterAssert(viewURI != nil);
    NSParameterAssert(featureInfo != nil);
    NSParameterAssert(viewModelLoader != nil);
    NSParameterAssert(viewModelRenderer != nil);
    NSParameterAssert(collectionViewFactory != nil);
    NSParameterAssert(componentRegistry != nil);
    NSParameterAssert(componentReusePool != nil);
    NSParameterAssert(componentLayoutManager != nil);
    NSParameterAssert(actionHandler != nil);
    NSParameterAssert(scrollHandler != nil);
    NSParameterAssert(imageLoader != nil);
    
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }
    
    _viewURI = [viewURI copy];
    _featureInfo = featureInfo;
    _viewModelLoader = viewModelLoader;
    _viewModelRenderer = viewModelRenderer;
    _collectionViewFactory = collectionViewFactory;
    _componentRegistry = componentRegistry;
    _componentReusePool = componentReusePool;
    _componentLayoutManager = componentLayoutManager;
    _actionHandler = actionHandler;
    _scrollHandler = scrollHandler;
    _imageLoader = imageLoader;
    _registeredCollectionViewCellReuseIdentifiers = [NSMutableSet new];
    _componentImageLoadingContexts = [NSMutableDictionary new];
    _contentOffsetObservingComponentWrappers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    _actionObservingComponentWrappers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    _overlayComponentWrappers = [NSMutableArray new];
    _componentWrappersByIdentifier = [NSMutableDictionary new];
    _componentWrappersByCellIdentifier = [NSMutableDictionary new];
    _componentWrappersByModelIdentifier = [NSMutableDictionary new];
    
    viewModelLoader.delegate = self;
    viewModelLoader.actionPerformer = self;
    imageLoader.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = [_scrollHandler shouldAutomaticallyAdjustContentInsetsInViewController:self];
    
    return self;
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

#pragma mark - UIViewController

- (void)loadView
{
    self.view = [[HUBContainerView alloc] initWithFrame:CGRectZero];

    [self createCollectionViewIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter * const notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleKeyboardWillShowNotification:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(handleKeyboardWillHideNotification:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
    
    if (self.viewModel == nil) {
        self.viewModel = self.viewModelLoader.initialViewModel;
    }

    [self createCollectionViewIfNeeded];
    [self.viewModelLoader loadViewModel];
    
    for (NSIndexPath * const indexPath in self.collectionView.indexPathsForVisibleItems) {
        HUBComponentCollectionViewCell * const cell = (HUBComponentCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self collectionViewCellWillAppear:cell ignorePreviousAppearance:YES];
    }
    
    [self headerAndOverlayComponentViewsWillAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.viewHasAppeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter * const notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    self.viewHasBeenLaidOut = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.viewHasBeenLaidOut = YES;

    if (self.viewModel != nil) {
        if (self.viewModelHasChangedSinceLastLayoutUpdate || !CGRectEqualToRect(self.collectionView.frame, self.view.bounds)) {
            self.collectionView.frame = self.view.bounds;
            id<HUBViewModel> const viewModel = self.viewModel;
            [self reloadCollectionViewWithViewModel:viewModel animated:NO];
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if (!self.isViewLoaded) {
        return;
    }

    if (self.view.window != nil) {
        return;
    }

    if (self.collectionView != nil) {
        UICollectionView * const collectionView = self.collectionView;
        [collectionView removeFromSuperview];
        [self.view removeGestureRecognizer:collectionView.panGestureRecognizer];
        
        self.collectionView = nil;
    }
    
    self.viewModel = nil;
}

#pragma mark - HUBViewController

- (NSString *)featureIdentifier
{
    return self.featureInfo.identifier;
}

- (BOOL)isViewScrolling
{
    return self.collectionView.isDragging || self.collectionView.isDecelerating;
}

- (NSDictionary<NSIndexPath *, UIView *> *)visibleComponentViewsForComponentType:(HUBComponentType)componentType
{
    NSMutableDictionary<NSIndexPath *, UIView *> * const visibleViewIndexPaths = [NSMutableDictionary new];
    NSMutableArray<HUBComponentWrapper *> * const visibleComponents = [NSMutableArray array];

    for (HUBComponentWrapper * const rootComponentWrapper in [self rootComponentWrappersForComponentType:componentType]) {
        [self addComponentWrapper:rootComponentWrapper toArray:visibleComponents];
    }

    for (HUBComponentWrapper * const visibleComponent in visibleComponents) {
        NSIndexPath * const indexPath = visibleComponent.model.indexPath;
        visibleViewIndexPaths[indexPath] = HUBComponentLoadViewIfNeeded(visibleComponent);
    }

    return [visibleViewIndexPaths copy];
}

- (nullable UIView *)visibleViewForComponentOfType:(HUBComponentType)componentType indexPath:(NSIndexPath *)indexPath
{
    NSUInteger const rootIndex = [indexPath indexAtPosition:0];
    
    if (rootIndex == NSNotFound) {
        return nil;
    }
    
    HUBComponentWrapper *componentWrapper;
    
    switch (componentType) {
        case HUBComponentTypeHeader:
            componentWrapper = self.headerComponentWrapper;
            break;
        case HUBComponentTypeBody: {
            NSIndexPath * const rootIndexPath = [NSIndexPath indexPathForItem:(NSInteger)rootIndex inSection:0];
            HUBComponentCollectionViewCell * const cell = (HUBComponentCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:rootIndexPath];
            
            if (cell == nil) {
                return nil;
            }
            
            componentWrapper = [self componentWrapperFromCell:cell];
            break;
        }
        case HUBComponentTypeOverlay: {
            if (rootIndex >= self.overlayComponentWrappers.count) {
                return nil;
            }
            
            componentWrapper = self.overlayComponentWrappers[rootIndex];
            break;
        }
    }
    
    if (indexPath.length == 1) {
        return componentWrapper.view;
    }
    
    for (NSUInteger indexPosition = 1; indexPosition < indexPath.length; indexPosition++) {
        NSArray<HUBComponentWrapper *> * const visibleChildren = componentWrapper.visibleChildren;
        NSUInteger const childIndex = [indexPath indexAtPosition:indexPosition];
        
        if (childIndex >= visibleChildren.count) {
            return nil;
        }
        
        componentWrapper = visibleChildren[childIndex];
    }
    
    return componentWrapper.view;
}

- (NSArray<HUBComponentWrapper *> *)rootComponentWrappersForComponentType:(HUBComponentType)componentType
{
    NSMutableArray<HUBComponentWrapper *> * const rootComponentWrappers = [NSMutableArray array];

    switch (componentType) {
        case HUBComponentTypeHeader: {
            if (self.headerComponentWrapper != nil) {
                HUBComponentWrapper * const headerComponentWrapper = self.headerComponentWrapper;
                [rootComponentWrappers addObject:headerComponentWrapper];
            }
            break;
        }
        case HUBComponentTypeBody: {
            for (HUBComponentCollectionViewCell * const cell in self.collectionView.visibleCells) {
                HUBComponentWrapper * const wrapper = [self componentWrapperFromCell:cell];
                [rootComponentWrappers addObject:wrapper];
            }
            break;
        }
        case HUBComponentTypeOverlay: {
            // All root overlay components are implicitly visible.
            [rootComponentWrappers addObjectsFromArray:self.overlayComponentWrappers];
            break;
        }
    }

    return rootComponentWrappers;
}

- (void)addComponentWrapper:(HUBComponentWrapper *)componentWrapper toArray:(NSMutableArray<HUBComponentWrapper *> *)array
{
    [array addObject:componentWrapper];
    for (HUBComponentWrapper *childComponentWrapper in componentWrapper.visibleChildren) {
        [self addComponentWrapper:childComponentWrapper toArray:array];
    }
}

- (CGRect)frameForBodyComponentAtIndex:(NSUInteger)index
{
    if (index >= (NSUInteger)[self.collectionView numberOfItemsInSection:0]) {
        return CGRectZero;
    }
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
    return [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame;
}

- (NSUInteger)indexOfBodyComponentAtPoint:(CGPoint)point
{
    point.y += self.collectionView.contentOffset.y;
    
    NSIndexPath * const indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (indexPath == nil) {
        return NSNotFound;
    }
    
    return (NSUInteger)indexPath.item;
}

- (void)scrollToContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    const CGFloat x = contentOffset.x;
    const CGFloat y = contentOffset.y - self.collectionView.contentInset.top;
    
    [self setContentOffset:CGPointMake(x, y) animated:animated];
}

- (void)scrollToComponentOfType:(HUBComponentType)componentType
                      indexPath:(NSIndexPath *)indexPath
                 scrollPosition:(HUBScrollPosition)scrollPosition
                       animated:(BOOL)animated
                     completion:(void (^ _Nullable)(NSIndexPath *))completion
{
    if (componentType == HUBComponentTypeBody) {
        NSAssert([indexPath indexAtPosition:0] < (NSUInteger)[self.collectionView numberOfItemsInSection:0],
                 @"Root index %@ specified but there are only %@ components in the list.",
                 @([indexPath indexAtPosition:0]), @([self.collectionView numberOfItemsInSection:0]));
    } else if (componentType == HUBComponentTypeHeader) {
        NSAssert(self.headerComponentWrapper != nil, @"Attempted to scroll to component within header, but no header was found.");
    } else if (componentType == HUBComponentTypeOverlay) {
        NSAssert([indexPath indexAtPosition:0] < self.overlayComponentWrappers.count,
                 @"Root index %@ specified but there are only %@ overlays in the list.",
                 @([indexPath indexAtPosition:0]), @(self.overlayComponentWrappers.count));
    }
    
    [self scrollToRemainingComponentsOfType:componentType
                              startPosition:0
                                  indexPath:indexPath
                                  component:nil
                             scrollPosition:scrollPosition
                                   animated:animated
                                 completion:completion];
}

-(void)reload
{
    [self.viewModelLoader loadViewModelRegardlessOfReloadPolicy];
}

#pragma mark - HUBViewModelLoaderDelegate

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel
{
    if ([self.viewModel.buildDate isEqual:viewModel.buildDate]) {
        return;
    }

    if (self.isRendering) {
        self.pendingViewModel = viewModel;
        return;
    }

    self.rendering = YES;

    id<HUBViewControllerDelegate> const delegate = self.delegate;
    [delegate viewController:self willUpdateWithViewModel:viewModel];
    
    HUBCopyNavigationItemProperties(self.navigationItem, viewModel.navigationItem);
    
    self.viewModel = viewModel;
    self.viewModelHasChangedSinceLastLayoutUpdate = YES;
    [self.view setNeedsLayout];
    
    if (self.viewHasBeenLaidOut) {
        [self reloadCollectionViewWithViewModel:viewModel animated:NO];
    }
    
    [delegate viewControllerDidUpdate:self];
}

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didFailLoadingWithError:(NSError *)error
{
    [self.delegate viewController:self didFailToUpdateWithError:error];
}

- (BOOL)selectComponentWithModel:(id<HUBComponentModel>)componentModel customData:(nullable NSDictionary<NSString *, id> *)customData
{
    HUBComponentWrapper * const componentWrapper = self.componentWrappersByModelIdentifier[componentModel.identifier];
    
    if (componentWrapper != nil) {
        [componentWrapper updateViewForSelectionState:HUBComponentSelectionStateSelected];
        
        // Deselect after a short time, to enable the user to see the selection for a brief time
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [componentWrapper updateViewForSelectionState:HUBComponentSelectionStateNone];
        });
        
        if (componentWrapper == self.highlightedComponentWrapper) {
            self.highlightedComponentWrapper = nil;
        }
    }
    
    BOOL selectionHandled = NO;
    
    for (HUBIdentifier * const identifier in componentModel.target.actionIdentifiers) {
        selectionHandled = [self performActionForTrigger:HUBActionTriggerSelection
                                        customIdentifier:identifier
                                              customData:customData
                                          componentModel:componentModel];
        
        if (selectionHandled) {
            break;
        }
    }
    
    if (!selectionHandled) {
        selectionHandled = [self performActionForTrigger:HUBActionTriggerSelection
                                        customIdentifier:nil
                                              customData:customData
                                          componentModel:componentModel];
    }
    
    if (selectionHandled) {
        [self.delegate viewController:self componentSelectedWithModel:componentModel];
    }
    
    return selectionHandled;
}

- (void)cancelComponentSelection
{
    [self.highlightedComponentWrapper updateViewForSelectionState:HUBComponentSelectionStateNone];
}

#pragma mark - HUBImageLoaderDelegate

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didLoadImage:(UIImage *)image forURL:(NSURL *)imageURL
{
    HUBPerformOnMainQueue(^{
        NSArray * const contexts = self.componentImageLoadingContexts[imageURL];
        self.componentImageLoadingContexts[imageURL] = nil;
        
        for (HUBComponentImageLoadingContext * const context in contexts) {
            [self handleLoadedComponentImage:image forURL:imageURL context:context];
        }
    });
}

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didFailLoadingImageForURL:(NSURL *)imageURL error:(NSError *)error
{
    HUBPerformOnMainQueue(^{
        self.componentImageLoadingContexts[imageURL] = nil;
    });
}

#pragma mark - HUBComponentWrapperDelegate

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
willUpdateSelectionState:(HUBComponentSelectionState)selectionState
{
    if (selectionState == HUBComponentSelectionStateHighlighted) {
        self.highlightedComponentWrapper = componentWrapper;
    }
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
 didUpdateSelectionState:(HUBComponentSelectionState)selectionState
{
    switch (selectionState) {
        case HUBComponentSelectionStateNone:
            if (componentWrapper == (HUBComponentWrapper *)self.highlightedComponentWrapper) {
                self.highlightedComponentWrapper = nil;
            }
            
            break;
        case HUBComponentSelectionStateHighlighted:
            break;
        case HUBComponentSelectionStateSelected:
            [self selectComponentWithModel:componentWrapper.model customData:nil];
            break;
    }
}

- (HUBComponentWrapper *)componentWrapper:(HUBComponentWrapper *)componentWrapper
                   childComponentForModel:(id<HUBComponentModel>)model
{
    CGSize const containerViewSize = [self childComponentContainerViewSizeForParentWrapper:componentWrapper];
    
    HUBComponentWrapper * const childComponentWrapper = [self.componentReusePool componentWrapperForModel:model
                                                                                                 delegate:self
                                                                                                   parent:componentWrapper];
    
    UIView * const childComponentView = HUBComponentLoadViewIfNeeded(childComponentWrapper);
    [self configureComponentWrapper:childComponentWrapper withModel:model containerViewSize:containerViewSize];
    [self didAddComponentWrapper:childComponentWrapper];
    
    CGSize const preferredViewSize = [childComponentWrapper preferredViewSizeForDisplayingModel:model
                                                                              containerViewSize:containerViewSize];
    
    childComponentView.frame = CGRectMake(0, 0, preferredViewSize.width, preferredViewSize.height);
    
    [self loadImagesForComponentWrapper:childComponentWrapper childIndex:nil];
    [childComponentWrapper viewDidMoveToSuperview:HUBComponentLoadViewIfNeeded(componentWrapper)];
    
    return childComponentWrapper;
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
          childComponent:(nullable HUBComponentWrapper *)childComponent
               childView:(UIView *)childView
       willAppearAtIndex:(NSUInteger)childIndex
{
    id<HUBComponentModel> const componentModel = componentWrapper.model;
    
    if (childIndex >= componentModel.children.count) {
        return;
    }
    
    [self loadImagesForComponentWrapper:componentWrapper childIndex:@(childIndex)];

    id<HUBComponentModel> const childComponentModel = componentModel.children[childIndex];
    NSSet<HUBComponentLayoutTrait> * const layoutTraits = childComponent.layoutTraits ?: [NSSet new];
    
    [self.delegate viewController:self
               componentWithModel:childComponentModel
                     layoutTraits:layoutTraits
                 willAppearInView:childView];

    [self addComponentWrapperToLookupTables:childComponent];
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
          childComponent:(nullable HUBComponentWrapper *)childComponent
               childView:(UIView *)childView
     didDisappearAtIndex:(NSUInteger)childIndex
{
    id<HUBComponentModel> const componentModel = componentWrapper.model;
    
    if (childIndex >= componentModel.children.count) {
        return;
    }

    id<HUBComponentModel> const childComponentModel = componentModel.children[childIndex];
    NSSet<HUBComponentLayoutTrait> * const layoutTraits = childComponent.layoutTraits ?: [NSSet new];
    
    [self.delegate viewController:self
               componentWithModel:childComponentModel
                     layoutTraits:layoutTraits
             didDisappearFromView:childView];

    [self removeComponentWrapperFromLookupTables:childComponent];
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
    childSelectedAtIndex:(NSUInteger)childIndex
              customData:(nullable NSDictionary<NSString *, id> *)customData
{
    id<HUBComponentModel> const componentModel = componentWrapper.model;
    
    if (childIndex >= componentModel.children.count) {
        return;
    }
    
    id<HUBComponentModel> const childComponentModel = componentModel.children[childIndex];
    [self selectComponentWithModel:childComponentModel customData:customData];
}

- (BOOL)componentWrapper:(HUBComponentWrapper *)componentWrapper performActionWithIdentifier:(HUBIdentifier *)identifier customData:(nullable NSDictionary<NSString *, id> *)customData
{
    return [self performActionForTrigger:HUBActionTriggerComponent
                        customIdentifier:identifier
                              customData:customData
                          componentModel:componentWrapper.model];
}

- (void)sendComponentWrapperToReusePool:(HUBComponentWrapper *)componentWrapper
{
    [self.componentReusePool addComponentWrappper:componentWrapper];

    if (componentWrapper.view) {
        UIView *componentView = componentWrapper.view;
        [self.delegate viewController:self willReuseComponentWithView:componentView];
    }
}

#pragma mark - HUBActionPerformer

- (BOOL)performActionWithIdentifier:(HUBIdentifier *)identifier customData:(nullable NSDictionary<NSString *, id> *)customData
{
    return [self performActionForTrigger:HUBActionTriggerContentOperation
                        customIdentifier:identifier
                              customData:customData
                          componentModel:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (NSInteger)self.viewModel.bodyComponentModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HUBComponentModel> const componentModel = self.viewModel.bodyComponentModels[(NSUInteger)indexPath.item];
    NSString * const cellReuseIdentifier = componentModel.componentIdentifier.identifierString;
    
    if (![self.registeredCollectionViewCellReuseIdentifiers containsObject:cellReuseIdentifier]) {
        [collectionView registerClass:[HUBComponentCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
    }
    
    HUBComponentCollectionViewCell * const cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier
                                                                                            forIndexPath:indexPath];

    HUBComponentWrapper * const componentWrapper = [self.componentReusePool componentWrapperForModel:componentModel
                                                                                            delegate:self
                                                                                              parent:nil];

    self.componentWrappersByCellIdentifier[cell.identifier] = componentWrapper;
    cell.component = componentWrapper;
    [componentWrapper viewDidMoveToSuperview:cell];
    [self didAddComponentWrapper:componentWrapper];

    [self configureComponentWrapper:componentWrapper withModel:componentModel containerViewSize:collectionView.frame.size];
    
    [self loadImagesForComponentWrapper:componentWrapper
                             childIndex:nil];

    return cell;
}

#pragma mark - HUBCollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self collectionViewCellWillAppear:(HUBComponentCollectionViewCell *)cell
              ignorePreviousAppearance:self.collectionViewIsScrolling];
    
    HUBComponentWrapper * const componentWrapper = [self componentWrapperFromCell:(HUBComponentCollectionViewCell *)cell];

    [self addComponentWrapperToLookupTables:componentWrapper];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    HUBComponentWrapper * const componentWrapper = [self componentWrapperFromCell:(HUBComponentCollectionViewCell *)cell];
    
    [self.delegate viewController:self
               componentWithModel:componentWrapper.model
                     layoutTraits:componentWrapper.layoutTraits
             didDisappearFromView:cell];

    [self removeComponentWrapperFromLookupTables:componentWrapper];
}

- (BOOL)collectionViewShouldBeginScrolling:(HUBCollectionView *)collectionView
{
    id<HUBViewControllerDelegate> const delegate = self.delegate;
    
    if (delegate == nil) {
        return YES;
    }
    
    return [delegate viewControllerShouldStartScrolling:self];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (HUBComponentWrapper * const componentWrapper in self.contentOffsetObservingComponentWrappers) {
        [componentWrapper updateViewForChangedContentOffset:scrollView.contentOffset];
    }
    
    [self.highlightedComponentWrapper updateViewForSelectionState:HUBComponentSelectionStateNone];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGRect const contentRect = [self contentRectForScrollView:scrollView];
    [self.scrollHandler scrollingWillStartInViewController:self currentContentRect:contentRect];
    self.collectionViewIsScrolling = YES;
    
    [self.highlightedComponentWrapper updateViewForSelectionState:HUBComponentSelectionStateNone];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGVector const velocityVector = CGVectorMake(velocity.x, velocity.y);
    
    *targetContentOffset = [self.scrollHandler targetContentOffsetForEndedScrollInViewController:self
                                                                                        velocity:velocityVector
                                                                                    contentInset:scrollView.contentInset
                                                                            currentContentOffset:scrollView.contentOffset
                                                                           proposedContentOffset:*targetContentOffset];
    
    if (targetContentOffset->y >= (scrollView.contentSize.height - CGRectGetHeight(scrollView.frame))) {
        if (!self.viewModelLoader.isLoading) {
            [self.viewModelLoader loadNextPageForCurrentViewModel];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.collectionViewIsScrolling = NO;
    [self notifyScrollingDidEndInScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self notifyScrollingDidEndInScrollView:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.pendingScrollAnimationCallback) {
        self.pendingScrollAnimationCallback();
        self.pendingScrollAnimationCallback = nil;
    }
}

- (void)notifyScrollingDidEndInScrollView:(UIScrollView *)scrollView
{
    CGRect const contentRect = [self contentRectForScrollView:scrollView];
    [self.scrollHandler scrollingDidEndInViewController:self currentContentRect:contentRect];
}

- (CGRect)contentRectForScrollView:(UIScrollView *)scrollView
{
    CGRect contentRect = CGRectZero;
    contentRect.origin = scrollView.contentOffset;
    contentRect.size = scrollView.frame.size;
    contentRect.size.height = MIN(CGRectGetHeight(contentRect),
                                  scrollView.contentSize.height - CGRectGetMinY(contentRect));
    return contentRect;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Notification handling

- (void)handleKeyboardWillShowNotification:(NSNotification *)notification
{
    CGRect const keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.visibleKeyboardHeight = CGRectGetHeight(keyboardEndFrame);
    [self updateOverlayComponentCenterPointsWithKeyboardNotification:notification];
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification
{
    self.visibleKeyboardHeight = 0;
    [self updateOverlayComponentCenterPointsWithKeyboardNotification:notification];
}

#pragma mark - Private utilities

- (void)createCollectionViewIfNeeded
{
    if (self.collectionView != nil) {
        return;
    }
    
    HUBCollectionView * const collectionView = [self.collectionViewFactory createCollectionView];
    self.collectionView = collectionView;
    collectionView.showsVerticalScrollIndicator = [self.scrollHandler shouldShowScrollIndicatorsInViewController:self];
    collectionView.showsHorizontalScrollIndicator = collectionView.showsVerticalScrollIndicator;
    collectionView.keyboardDismissMode = [self.scrollHandler keyboardDismissModeForViewController:self];
    collectionView.decelerationRate = [self.scrollHandler scrollDecelerationRateForViewController:self];
    collectionView.dataSource = self;
    collectionView.delegate = self;

    self.lastContentOffset = self.collectionView.contentOffset;

    HUBContainerView *containerView = (HUBContainerView *)self.view;
    containerView.collectionView = self.collectionView;
}

- (void)reloadCollectionViewWithViewModel:(id<HUBViewModel>)viewModel animated:(BOOL)animated
{
    if (![self.collectionView.collectionViewLayout isKindOfClass:[HUBCollectionViewLayout class]]) {
        self.collectionView.collectionViewLayout = [[HUBCollectionViewLayout alloc] initWithComponentRegistry:self.componentRegistry
                                                                                       componentLayoutManager:self.componentLayoutManager];
    }

    [self saveStatesForVisibleComponents];

    [self configureHeaderComponent];
    [self configureOverlayComponents];
    [self adjustCollectionViewContentInsetWithProposedTopValue:[self calculateTopContentInset]];
    
    BOOL const shouldAddHeaderMargin = [self shouldAutomaticallyManageTopContentInset];
    
    UICollectionView * const nonnullCollectionView = self.collectionView;
    [self.viewModelRenderer renderViewModel:viewModel
                           inCollectionView:nonnullCollectionView
                          usingBatchUpdates:self.viewHasAppeared
                                   animated:animated
                            addHeaderMargin:shouldAddHeaderMargin
                                 completion:^{
        self.rendering = NO;

        if (self.pendingViewModel != nil) {
            id<HUBViewModel> pendingViewModel = self.pendingViewModel;
            self.pendingViewModel = nil;
            [self viewModelLoader:self.viewModelLoader didLoadViewModel:pendingViewModel];
            return;
        }

        id<HUBViewControllerDelegate> delegate = self.delegate;

        [self headerAndOverlayComponentViewsWillAppear];
        [self adjustCollectionViewContentInsetWithProposedTopValue:[self calculateTopContentInset]];
        [delegate viewControllerDidFinishRendering:self];
    }];
    
    self.viewModelHasChangedSinceLastLayoutUpdate = NO;
}

- (void)saveStatesForVisibleComponents
{
    for (HUBComponentCollectionViewCell *cell in self.collectionView.visibleCells) {
        HUBComponentWrapper *wrapper = [self componentWrapperFromCell:cell];
        [wrapper saveComponentUIState];
    }
}

- (void)didAddComponentWrapper:(HUBComponentWrapper *)wrapper
{
    wrapper.delegate = self;
    self.componentWrappersByIdentifier[wrapper.identifier] = wrapper;
}

- (void)configureComponentWrapper:(HUBComponentWrapper *)wrapper withModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    NSString * const currentModelIdentifier = wrapper.model.identifier;
    
    if (self.componentWrappersByModelIdentifier[currentModelIdentifier] == wrapper) {
        self.componentWrappersByModelIdentifier[currentModelIdentifier] = nil;
    }
    
    [wrapper configureViewWithModel:model containerViewSize:containerViewSize];
    self.componentWrappersByModelIdentifier[model.identifier] = wrapper;
}

- (CGSize)childComponentContainerViewSizeForParentWrapper:(HUBComponentWrapper *)parentWrapper
{
    if (parentWrapper.isRootComponent && parentWrapper.model.type == HUBComponentTypeBody) {
        NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:(NSInteger)parentWrapper.model.index inSection:0];
        return [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame.size;
    }
    
    return HUBComponentLoadViewIfNeeded(parentWrapper).frame.size;
}

- (nullable HUBComponentWrapper *)componentWrapperFromCell:(HUBComponentCollectionViewCell *)cell
{
    return self.componentWrappersByCellIdentifier[cell.identifier];
}

- (CGFloat)calculateTopContentInset
{
    if (![self shouldAutomaticallyManageTopContentInset]) {
        return 0;
    }

    if (self.headerComponentWrapper != nil) {
        return 0;
    }

    CGFloat const statusBarWidth = CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
    CGFloat const statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    CGFloat const navigationBarWidth = CGRectGetWidth(self.navigationController.navigationBar.frame);
    CGFloat const navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat const topBarHeight = MIN(statusBarWidth, statusBarHeight) + MIN(navigationBarWidth, navigationBarHeight);
    return topBarHeight;
}

- (BOOL)shouldAutomaticallyManageTopContentInset
{
    id<HUBViewControllerDelegate> delegate = self.delegate;
    
    if (delegate == nil) {
        return YES;
    }
    
    return [delegate viewControllerShouldAutomaticallyManageTopContentInset:self];
}

- (void)configureHeaderComponent
{
    id<HUBComponentModel> const componentModel = self.viewModel.headerComponentModel;
    
    if (componentModel == nil) {
        if (self.headerComponentWrapper != nil) {
            HUBComponentWrapper * const headerComponentWrapper = self.headerComponentWrapper;
            [self removeComponentWrapper:headerComponentWrapper];
            self.headerComponentWrapper = nil;
        }
        
        return;
    }
    
    self.headerComponentWrapper = [self configureHeaderOrOverlayComponentWrapperWithModel:componentModel
                                                                 previousComponentWrapper:self.headerComponentWrapper];
}

- (void)configureOverlayComponents
{
    NSMutableArray * const currentOverlayComponentWrappers = [self.overlayComponentWrappers mutableCopy];
    [self.overlayComponentWrappers removeAllObjects];
    
    for (id<HUBComponentModel> const componentModel in self.viewModel.overlayComponentModels) {
        HUBComponentWrapper *componentWrapper = nil;
        
        if (self.overlayComponentWrappers.count < currentOverlayComponentWrappers.count) {
            NSUInteger const componentIndex = self.overlayComponentWrappers.count;
            componentWrapper = currentOverlayComponentWrappers[componentIndex];
            [currentOverlayComponentWrappers removeObjectAtIndex:componentIndex];
        }
        
        componentWrapper = [self configureHeaderOrOverlayComponentWrapperWithModel:componentModel
                                                          previousComponentWrapper:componentWrapper];
        
        [self.overlayComponentWrappers addObject:componentWrapper];
        
        componentWrapper.view.center = [self overlayComponentCenterPoint];
    }
    
    for (HUBComponentWrapper * const unusedOverlayComponentWrapper in currentOverlayComponentWrappers) {
        [self removeComponentWrapper:unusedOverlayComponentWrapper];
    }
}

- (CGPoint)overlayComponentCenterPoint
{
    CGRect frame = self.view.bounds;
    frame.origin.y = self.collectionView.contentInset.top;
    frame.size.height -= self.visibleKeyboardHeight + CGRectGetMinY(frame);
    return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
}

- (void)updateOverlayComponentCenterPointsWithKeyboardNotification:(NSNotification *)notification
{
    NSTimeInterval const animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve const animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:@"com.spotify.hub.keyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    for (HUBComponentWrapper * const overlayComponentWrapper in self.overlayComponentWrappers) {
        overlayComponentWrapper.view.center = [self overlayComponentCenterPoint];
    }
    
    [UIView commitAnimations];
}

- (HUBComponentWrapper *)configureHeaderOrOverlayComponentWrapperWithModel:(id<HUBComponentModel>)componentModel
                                                  previousComponentWrapper:(nullable HUBComponentWrapper *)previousComponentWrapper
{
    if ([previousComponentWrapper.model isEqual:componentModel]) {
        return (HUBComponentWrapper *)previousComponentWrapper;
    }
    
    BOOL const shouldReuseCurrentComponent = [previousComponentWrapper.model.componentIdentifier isEqual:componentModel.componentIdentifier];
    HUBComponentWrapper *componentWrapper;
    
    if (shouldReuseCurrentComponent) {
        [previousComponentWrapper prepareViewForReuse];
        componentWrapper = previousComponentWrapper;
    } else {
        if (previousComponentWrapper != nil) {
            HUBComponentWrapper * const nonNilPreviousComponentWrapper = previousComponentWrapper;
            [self removeComponentWrapper:nonNilPreviousComponentWrapper];
        }
        
        componentWrapper = [self.componentReusePool componentWrapperForModel:componentModel delegate:self parent:nil];
        [self didAddComponentWrapper:componentWrapper];
    }
    
    CGSize const containerViewSize = self.view.frame.size;
    CGSize const componentViewSize = [componentWrapper preferredViewSizeForDisplayingModel:componentModel
                                                                         containerViewSize:containerViewSize];
    
    UIView * const componentView = HUBComponentLoadViewIfNeeded(componentWrapper);
    [self configureComponentWrapper:componentWrapper withModel:componentModel containerViewSize:containerViewSize];
    componentView.frame = CGRectMake(0, 0, componentViewSize.width, componentViewSize.height);
    
    [self loadImagesForComponentWrapper:componentWrapper
                             childIndex:nil];
    
    if (!shouldReuseCurrentComponent) {
        [self.view addSubview:componentView];
        [componentWrapper viewDidMoveToSuperview:self.view];
    }

    [self addComponentWrapperToLookupTables:componentWrapper];

    return componentWrapper;
}

- (void)removeComponentWrapper:(HUBComponentWrapper *)wrapper
{
    self.componentWrappersByIdentifier[wrapper.identifier] = nil;
    self.componentWrappersByModelIdentifier[wrapper.model.identifier] = nil;
    [wrapper.view removeFromSuperview];
}

- (void)adjustCollectionViewContentInsetWithProposedTopValue:(CGFloat)topContentInset
{
    UIEdgeInsets contentInsets = self.collectionView.contentInset;
    contentInsets.top = topContentInset;
    
    contentInsets = [self.scrollHandler contentInsetsForViewController:self
                                                 proposedContentInsets:contentInsets];

    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, contentInsets)) {
        self.collectionView.contentInset = contentInsets;
        CGPoint contentOffset = self.collectionView.contentOffset;
        contentOffset.y = -contentInsets.top;
        [self setContentOffset:contentOffset animated:NO];
    }

    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
}

- (void)collectionViewCellWillAppear:(HUBComponentCollectionViewCell *)cell
            ignorePreviousAppearance:(BOOL)ignorePreviousAppearance
{
    HUBComponentWrapper * const wrapper = [self componentWrapperFromCell:cell];
    
    if (wrapper == nil) {
        return;
    }
    
    if (wrapper.viewHasAppearedSinceLastModelChange) {
        if (!ignorePreviousAppearance) {
            return;
        }
    }
    
    [self componentWrapperWillAppear:wrapper];

    id<HUBComponent> const component = cell.component;
    
    if (component == nil) {
        return;
    }

    UIView * const componentView = HUBComponentLoadViewIfNeeded(component);
    
    [self.delegate viewController:self
               componentWithModel:wrapper.model
                     layoutTraits:wrapper.layoutTraits
                 willAppearInView:componentView];
}

- (void)headerAndOverlayComponentViewsWillAppear
{
    id<HUBViewControllerDelegate> const delegate = self.delegate;

    if (self.headerComponentWrapper != nil) {
        HUBComponentWrapper * const headerComponentWrapper = self.headerComponentWrapper;
        [self componentWrapperWillAppear:headerComponentWrapper];

        UIView * const componentView = HUBComponentLoadViewIfNeeded(headerComponentWrapper);

        [delegate viewController:self
              componentWithModel:headerComponentWrapper.model
                    layoutTraits:headerComponentWrapper.layoutTraits
                willAppearInView:componentView];
    }
    
    for (HUBComponentWrapper * const overlayComponentWrapper in self.overlayComponentWrappers) {
        [self componentWrapperWillAppear:overlayComponentWrapper];

        UIView * const componentView = HUBComponentLoadViewIfNeeded(overlayComponentWrapper);

        [delegate viewController:self
              componentWithModel:overlayComponentWrapper.model
                    layoutTraits:overlayComponentWrapper.layoutTraits
                willAppearInView:componentView];
    }
}

- (void)componentWrapperWillAppear:(HUBComponentWrapper *)componentWrapper
{
    [componentWrapper viewWillAppear];

    BOOL wasContentOffsetUpdated = componentWrapper.appearanceCount == 1 ||
                                   !CGPointEqualToPoint(self.lastContentOffset, self.collectionView.contentOffset);

    if (componentWrapper.isContentOffsetObserver && wasContentOffsetUpdated) {
        [componentWrapper updateViewForChangedContentOffset:self.collectionView.contentOffset];
    }
}

- (void)loadImagesForComponentWrapper:(HUBComponentWrapper *)componentWrapper
                           childIndex:(nullable NSNumber *)childIndex
{
    if (!componentWrapper.handlesImages) {
        return;
    }
    
    id<HUBComponentModel> componentModel = componentWrapper.model;
    
    if (childIndex != nil) {
        componentModel = [self childModelAtIndex:childIndex.unsignedIntegerValue
                            fromComponentWrapper:componentWrapper];
    }
    
    if (componentModel == nil) {
        return;
    }
    
    id<HUBComponentImageData> const mainImageData = componentModel.mainImageData;
    id<HUBComponentImageData> const backgroundImageData = componentModel.backgroundImageData;
    
    if (mainImageData != nil) {
        [self loadImageFromData:mainImageData
                          model:componentModel
               componentWrapper:componentWrapper
                     childIndex:childIndex];
    }
    
    if (backgroundImageData != nil) {
        [self loadImageFromData:backgroundImageData
                          model:componentModel
               componentWrapper:componentWrapper
                     childIndex:childIndex];
    }
    
    for (id<HUBComponentImageData> const customImageData in componentModel.customImageData.allValues) {
        [self loadImageFromData:customImageData
                          model:componentModel
               componentWrapper:componentWrapper
                     childIndex:childIndex];
    }
}

- (void)loadImageFromData:(id<HUBComponentImageData>)imageData
                    model:(id<HUBComponentModel>)model
         componentWrapper:(HUBComponentWrapper *)componentWrapper
               childIndex:(nullable NSNumber *)childIndex
{
    if (imageData.localImage != nil) {
        UIImage * const localImage = imageData.localImage;
        [componentWrapper updateViewForLoadedImage:localImage
                                          fromData:imageData
                                             model:model
                                          animated:NO];
    }
    
    NSURL * const imageURL = imageData.URL;
    
    if (imageURL == nil) {
        return;
    }
    
    CGSize const preferredSize = [componentWrapper preferredSizeForImageFromData:imageData
                                                                           model:model
                                                               containerViewSize:self.view.frame.size];
    
    if (CGSizeEqualToSize(preferredSize, CGSizeZero)) {
        return;
    }

    HUBComponentImageLoadingContext * const context = [[HUBComponentImageLoadingContext alloc] initWithImageType:imageData.type
                                                                                                 imageIdentifier:imageData.identifier
                                                                                               wrapperIdentifier:componentWrapper.identifier
                                                                                                      childIndex:childIndex
                                                                                                       timestamp:[NSDate date].timeIntervalSinceReferenceDate];
    
    NSMutableArray *contextsForURL = self.componentImageLoadingContexts[imageURL];

    if (contextsForURL == nil) {
        contextsForURL = [NSMutableArray arrayWithObject:context];
        self.componentImageLoadingContexts[imageURL] = contextsForURL;
        [self.imageLoader loadImageForURL:imageURL targetSize:preferredSize];
    } else {
        [contextsForURL addObject:context];
    }
}

- (void)handleLoadedComponentImage:(UIImage *)image forURL:(NSURL *)imageURL context:(HUBComponentImageLoadingContext *)context
{
    id<HUBViewModel> const viewModel = self.viewModel;
    
    if (context == nil || viewModel == nil) {
        return;
    }
    
    HUBComponentWrapper * const componentWrapper = self.componentWrappersByIdentifier[context.wrapperIdentifier];
    id<HUBComponentModel> componentModel = componentWrapper.model;
    NSNumber * const childIndex = context.childIndex;
    
    if (childIndex != nil) {
        componentModel = [self childModelAtIndex:childIndex.unsignedIntegerValue
                            fromComponentWrapper:componentWrapper];
    }
    
    if (componentModel == nil) {
        return;
    }
    
    id<HUBComponentImageData> imageData = nil;
    
    switch (context.imageType) {
        case HUBComponentImageTypeMain:
            imageData = componentModel.mainImageData;
            break;
        case HUBComponentImageTypeBackground:
            imageData = componentModel.backgroundImageData;
            break;
        case HUBComponentImageTypeCustom: {
            NSString * const imageIdentifier = context.imageIdentifier;
            
            if (imageIdentifier != nil) {
                imageData = componentModel.customImageData[imageIdentifier];
            }
            
            break;
        }
    }
    
    if (![imageData.URL isEqual:imageURL]) {
        return;
    }

    NSTimeInterval downloadTime = [NSDate date].timeIntervalSinceReferenceDate - context.timestamp;
    BOOL animated = downloadTime > HUBImageDownloadTimeThreshold;

    [componentWrapper updateViewForLoadedImage:image
                                      fromData:imageData
                                         model:componentModel
                                      animated:animated];
}

- (nullable id<HUBComponentModel>)childModelAtIndex:(NSUInteger)childIndex fromComponentWrapper:(HUBComponentWrapper *)componentWrapper
{
    id<HUBComponentModel> parentModel = componentWrapper.model;
    
    if (childIndex >= parentModel.children.count) {
        return nil;
    }
    
    return parentModel.children[childIndex];
}

- (BOOL)performActionForTrigger:(HUBActionTrigger)trigger
               customIdentifier:(nullable HUBIdentifier *)customIdentifier
                     customData:(nullable NSDictionary<NSString *, id> *)customData
                 componentModel:(nullable id<HUBComponentModel>)componentModel
{
    if (self.viewModel == nil) {
        return NO;
    }
    
    id<HUBViewModel> const viewModel = self.viewModel;
    
    id<HUBActionContext> const context = [[HUBActionContextImplementation alloc] initWithTrigger:trigger
                                                                          customActionIdentifier:customIdentifier
                                                                                      customData:customData
                                                                                     featureInfo:self.featureInfo
                                                                                         viewURI:self.viewURI
                                                                                       viewModel:viewModel
                                                                                  componentModel:componentModel
                                                                                  viewController:self];

    BOOL actionWasHandled = [self.actionHandler handleActionWithContext:context];

    for (HUBComponentWrapper *componentWrapper in self.actionObservingComponentWrappers) {
        id<HUBComponentActionObserver> observer = componentWrapper;
        [observer actionPerformedWithContext:context];
    }

    return actionWasHandled;
}

- (void)addComponentWrapperToLookupTables:(nullable HUBComponentWrapper *)componentWrapper
{
    if (componentWrapper.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers addObject:componentWrapper];
    }

    if (componentWrapper.isActionObserver) {
        [self.actionObservingComponentWrappers addObject:componentWrapper];
    }
}

- (void)removeComponentWrapperFromLookupTables:(nullable HUBComponentWrapper *)componentWrapper
{
    if (componentWrapper.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers removeObject:componentWrapper];
    }

    if (componentWrapper.isActionObserver) {
        [self.actionObservingComponentWrappers removeObject:componentWrapper];
    }
}

- (void)scrollToRootBodyComponentAtIndex:(NSUInteger)componentIndex
                          scrollPosition:(HUBScrollPosition)scrollPosition
                                animated:(BOOL)animated
                              completion:(void (^)())completion
{
    NSParameterAssert(componentIndex <= (NSUInteger)[self.collectionView numberOfItemsInSection:0]);

    CGPoint const contentOffset = [self.scrollHandler contentOffsetForDisplayingComponentAtIndex:componentIndex
                                                                                  scrollPosition:scrollPosition
                                                                                    contentInset:self.collectionView.contentInset
                                                                                     contentSize:self.collectionView.contentSize
                                                                                  viewController:self];
    
    // If the target offset is the same, the completion handler can be called instantly.
    if (CGPointEqualToPoint(contentOffset, self.collectionView.contentOffset)) {
        completion();
    // If the scrolling is animated, the animation has to end before the new component can be retrieved.
    } else if (animated) {
        self.pendingScrollAnimationCallback = completion;
        [self setContentOffset:contentOffset animated:animated];
    // If there's no animations, the UICollectionView will still not update its visible cells until having layouted.
    } else {
        [self setContentOffset:contentOffset animated:animated];
        [self.collectionView setNeedsLayout];
        [self.collectionView layoutIfNeeded];
        completion();
    }
}

- (void)scrollToRemainingComponentsOfType:(HUBComponentType)componentType
                            startPosition:(NSUInteger)startPosition
                                indexPath:(NSIndexPath *)indexPath
                                component:(nullable HUBComponentWrapper *)componentWrapper
                           scrollPosition:(HUBScrollPosition)scrollPosition
                                 animated:(BOOL)animated
                               completion:(void (^ _Nullable)(NSIndexPath *))completionHandler
{
    NSUInteger const childIndex = [indexPath indexAtPosition:startPosition];

    if (startPosition > 0) {
        NSAssert(childIndex < componentWrapper.model.children.count,
                 @"Attempted to scroll to child %@ in component %@, but it only has %@ children",
                 @(childIndex), componentWrapper.model.identifier, @(componentWrapper.model.children.count));
    }

    __weak HUBViewController *weakSelf = self;
    void (^stepCompletionHandler)() = ^{
        HUBViewController *strongSelf = weakSelf;

        HUBComponentWrapper *childComponentWrapper = nil;
        if (startPosition == 0) {
            if (componentType == HUBComponentTypeBody) {
                NSIndexPath * const rootIndexPath = [NSIndexPath indexPathForItem:(NSInteger)childIndex inSection:0];
                HUBComponentCollectionViewCell * const cell = (HUBComponentCollectionViewCell *)[strongSelf.collectionView cellForItemAtIndexPath:rootIndexPath];
                childComponentWrapper = [strongSelf componentWrapperFromCell:cell];
            } else if (componentType == HUBComponentTypeHeader) {
                childComponentWrapper = strongSelf.headerComponentWrapper;
            } else if (componentType == HUBComponentTypeOverlay) {
                childComponentWrapper = strongSelf.overlayComponentWrappers[startPosition];
            }
        } else {
            childComponentWrapper = [componentWrapper visibleChildComponentAtIndex:childIndex];
        }

        if (completionHandler != nil) {
            NSUInteger const currentIndexPathLength = startPosition + 1;
            NSUInteger currentIndexes[currentIndexPathLength];
            [indexPath getIndexes:currentIndexes range:NSMakeRange(0, currentIndexPathLength)];
            NSIndexPath * const currentIndexPath = [NSIndexPath indexPathWithIndexes:currentIndexes length:currentIndexPathLength];
            completionHandler(currentIndexPath);
        }

        NSUInteger const nextPosition = startPosition + 1;
        if (childComponentWrapper != nil && nextPosition < indexPath.length) {
            [strongSelf scrollToRemainingComponentsOfType:componentType
                                            startPosition:nextPosition
                                                indexPath:indexPath
                                                component:childComponentWrapper
                                           scrollPosition:scrollPosition
                                                 animated:animated
                                               completion:completionHandler];
        }
    };

    // Any other root components than body components don't need to be scrolled to, as they are always visible.
    if (startPosition == 0) {
        if (componentType == HUBComponentTypeBody) {
            [self scrollToRootBodyComponentAtIndex:childIndex
                                    scrollPosition:scrollPosition
                                          animated:animated
                                        completion:stepCompletionHandler];
        } else {
            stepCompletionHandler();
        }
    } else {
        [componentWrapper scrollToComponentAtIndex:childIndex
                                    scrollPosition:scrollPosition
                                          animated:animated
                                        completion:^{
            /* This solves a case where the UICollectionView hasn't updated its visible cells until the next cycle
               when changing the content offset without animations. */
            if (!animated) {
                dispatch_async(dispatch_get_main_queue(), stepCompletionHandler);
            } else {
                stepCompletionHandler();
            }
        }];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    self.lastContentOffset = contentOffset;
    [self.collectionView setContentOffset:contentOffset animated:animated];
}

@end

NS_ASSUME_NONNULL_END
