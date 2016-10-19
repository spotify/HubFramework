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

#import "HUBViewControllerImplementation.h"

#import "HUBIdentifier.h"
#import "HUBViewModelLoader.h"
#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponentImageData.h"
#import "HUBComponentTarget.h"
#import "HUBComponentWithImageHandling.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBComponentViewObserver.h"
#import "HUBComponentWrapper.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentCollectionViewCell.h"
#import "HUBUtilities.h"
#import "HUBImageLoader.h"
#import "HUBComponentImageLoadingContext.h"
#import "HUBCollectionViewFactory.h"
#import "HUBCollectionViewLayout.h"
#import "HUBContainerView.h"
#import "HUBContentReloadPolicy.h"
#import "HUBComponentUIStateManager.h"
#import "HUBViewControllerScrollHandler.h"
#import "HUBComponentReusePool.h"
#import "HUBActionContextImplementation.h"
#import "HUBActionRegistry.h"
#import "HUBActionHandler.h"
#import "HUBViewModelDiff.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerImplementation () <HUBViewModelLoaderDelegate, HUBImageLoaderDelegate, HUBComponentWrapperDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, copy, readonly) NSURL *viewURI;
@property (nonatomic, strong, readonly) id<HUBViewModelLoader> viewModelLoader;
@property (nonatomic, strong, readonly) HUBCollectionViewFactory *collectionViewFactory;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly) id<HUBActionHandler> actionHandler;
@property (nonatomic, strong, readonly) id<HUBViewControllerScrollHandler> scrollHandler;
@property (nonatomic, strong, nullable, readonly) id<HUBContentReloadPolicy> contentReloadPolicy;
@property (nonatomic, strong, nullable, readonly) id<HUBImageLoader> imageLoader;
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL collectionViewIsScrolling;
@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *registeredCollectionViewCellReuseIdentifiers;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, NSMutableArray<HUBComponentImageLoadingContext *> *> *componentImageLoadingContexts;
@property (nonatomic, strong, readonly) NSHashTable<id<HUBComponentContentOffsetObserver>> *contentOffsetObservingComponentWrappers;
@property (nonatomic, strong, nullable) HUBComponentWrapper *headerComponentWrapper;
@property (nonatomic, strong, readonly) NSMutableArray<HUBComponentWrapper *> *overlayComponentWrappers;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSUUID *, HUBComponentWrapper *> *componentWrappersByIdentifier;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSUUID *, HUBComponentWrapper *> *componentWrappersByCellIdentifier;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *componentUIStateManager;
@property (nonatomic, strong, readonly) HUBComponentReusePool *childComponentReusePool;
@property (nonatomic, strong, nullable) id<HUBViewModel> viewModel;
@property (nonatomic, strong, nullable) NSArray<HUBViewModelDiff *> *pendingDiffs;
@property (nonatomic, assign) BOOL viewHasAppeared;
@property (nonatomic, assign) BOOL viewHasBeenLaidOut;
@property (nonatomic) BOOL viewModelIsInitial;
@property (nonatomic) BOOL viewModelHasChangedSinceLastLayoutUpdate;
@property (nonatomic) CGFloat visibleKeyboardHeight;

@end

@implementation HUBViewControllerImplementation

@synthesize delegate = _delegate;
@synthesize featureIdentifier = _featureIdentifier;

#pragma mark - Lifecycle

- (instancetype)initWithViewURI:(NSURL *)viewURI
              featureIdentifier:(NSString *)featureIdentifier
                viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader
          collectionViewFactory:(HUBCollectionViewFactory *)collectionViewFactory
              componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
         componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                  actionHandler:(id<HUBActionHandler>)actionHandler
                  scrollHandler:(id<HUBViewControllerScrollHandler>)scrollHandler
                    imageLoader:(id<HUBImageLoader>)imageLoader

{
    NSParameterAssert(viewURI != nil);
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(viewModelLoader != nil);
    NSParameterAssert(collectionViewFactory != nil);
    NSParameterAssert(componentRegistry != nil);
    NSParameterAssert(componentLayoutManager != nil);
    NSParameterAssert(actionHandler != nil);
    NSParameterAssert(scrollHandler != nil);
    NSParameterAssert(imageLoader != nil);
    
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }
    
    _viewURI = [viewURI copy];
    _featureIdentifier = [featureIdentifier copy];
    _viewModelLoader = viewModelLoader;
    _collectionViewFactory = collectionViewFactory;
    _componentRegistry = componentRegistry;
    _componentLayoutManager = componentLayoutManager;
    _actionHandler = actionHandler;
    _scrollHandler = scrollHandler;
    _imageLoader = imageLoader;
    _viewModelIsInitial = YES;
    _registeredCollectionViewCellReuseIdentifiers = [NSMutableSet new];
    _componentImageLoadingContexts = [NSMutableDictionary new];
    _contentOffsetObservingComponentWrappers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    _overlayComponentWrappers = [NSMutableArray new];
    _componentWrappersByIdentifier = [NSMutableDictionary new];
    _componentWrappersByCellIdentifier = [NSMutableDictionary new];
    _pendingDiffs = [NSArray array];
    _componentUIStateManager = [HUBComponentUIStateManager new];
    _childComponentReusePool = [[HUBComponentReusePool alloc] initWithComponentRegistry:_componentRegistry
                                                                         UIStateManager:_componentUIStateManager];

    _viewModelLoader.delegate = self;
    _imageLoader.delegate = self;
    
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
        id<HUBViewModel> const viewModel = self.viewModel;
        [self reloadCollectionViewWithViewModel:viewModel animated:NO];
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

    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    self.viewModel = nil;
}

#pragma mark - HUBViewController

- (NSDictionary<NSNumber *, UIView *> *)visibleBodyComponentViews
{
    NSMutableDictionary<NSNumber *, UIView *> * const visibleViews = [NSMutableDictionary new];
    
    for (HUBComponentCollectionViewCell * const cell in self.collectionView.visibleCells) {
        HUBComponentWrapper * const wrapper = [self componentWrapperFromCell:cell];
        visibleViews[@(wrapper.model.index)] = HUBComponentLoadViewIfNeeded(wrapper);
    }
    
    return [visibleViews copy];
}

- (CGRect)frameForBodyComponentAtIndex:(NSUInteger)index
{
    if (index >= self.viewModel.bodyComponentModels.count) {
        return CGRectZero;
    }
    
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
    return [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
}

- (NSUInteger)indexOfBodyComponentAtPoint:(CGPoint)point
{
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
    
    [self.collectionView setContentOffset:CGPointMake(x, y) animated:animated];
}

#pragma mark - HUBViewModelLoaderDelegate

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel
{
    if ([self.viewModel.buildDate isEqual:viewModel.buildDate]) {
        return;
    }
    
    id<HUBViewControllerDelegate> const delegate = self.delegate;
    [delegate viewController:self willUpdateWithViewModel:viewModel];

    if (self.viewModel != nil && !self.viewModelIsInitial) {
        id<HUBViewModel> const currentModel = self.viewModel;
        self.pendingDiffs = [self.pendingDiffs arrayByAddingObject:[HUBViewModelDiff diffFromViewModel:currentModel toViewModel:viewModel]];
    }
    
    HUBCopyNavigationItemProperties(self.navigationItem, viewModel.navigationItem);
    
    self.viewModel = viewModel;
    self.viewModelIsInitial = NO;
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

- (BOOL)selectComponentWithModel:(id<HUBComponentModel>)componentModel
{
    return [self handleSelectionForComponentWithModel:componentModel cellIndexPath:nil];
}

#pragma mark - HUBImageLoaderDelegate

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didLoadImage:(UIImage *)image forURL:(NSURL *)imageURL fromCache:(BOOL)loadedFromCache
{
    HUBPerformOnMainQueue(^{
        NSArray * const contexts = self.componentImageLoadingContexts[imageURL];
        self.componentImageLoadingContexts[imageURL] = nil;
        
        for (HUBComponentImageLoadingContext * const context in contexts) {
            [self handleLoadedComponentImage:image forURL:imageURL fromCache:loadedFromCache context:context];
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

- (HUBComponentWrapper *)componentWrapper:(HUBComponentWrapper *)componentWrapper
                   childComponentForModel:(id<HUBComponentModel>)model
{
    CGSize const containerViewSize = HUBComponentLoadViewIfNeeded(componentWrapper).frame.size;
    
    HUBComponentWrapper * const childComponentWrapper = [self.childComponentReusePool componentWrapperForModel:model
                                                                                                      delegate:self
                                                                                                        parent:componentWrapper];
    
    UIView * const childComponentView = HUBComponentLoadViewIfNeeded(childComponentWrapper);
    [childComponentWrapper configureViewWithModel:model containerViewSize:containerViewSize];
    [self didAddComponentWrapper:childComponentWrapper];
    
    CGSize const preferredViewSize = [childComponentWrapper preferredViewSizeForDisplayingModel:model
                                                                              containerViewSize:containerViewSize];
    
    childComponentView.frame = CGRectMake(0, 0, preferredViewSize.width, preferredViewSize.height);
    
    [self loadImagesForComponentWrapper:childComponentWrapper childIndex:nil];
    
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

    id<HUBComponentModel> const childComponentModel = componentModel.children[childIndex];
    [self loadImagesForComponentWrapper:componentWrapper childIndex:@(childIndex)];
    [self.delegate viewController:self componentWithModel:childComponentModel willAppearInView:childView];

    if (childComponent.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers addObject:childComponent];
    }
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
    [self.delegate viewController:self componentWithModel:childComponentModel didDisappearFromView:childView];

    if (childComponent.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers removeObject:childComponent];
    }
    
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper
    childSelectedAtIndex:(NSUInteger)childIndex
{
    id<HUBComponentModel> const componentModel = componentWrapper.model;
    
    if (childIndex >= componentModel.children.count) {
        return;
    }
    
    id<HUBComponentModel> const childComponentModel = componentModel.children[childIndex];
    [self handleSelectionForComponentWithModel:childComponentModel cellIndexPath:nil];
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
    if (componentWrapper.isRootComponent) {
        return;
    }
    
    [self.childComponentReusePool addComponentWrappper:componentWrapper];
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
    
    if (cell.component == nil) {
        id<HUBComponent> const component = [self.componentRegistry createComponentForModel:componentModel];
        HUBComponentWrapper * const componentWrapper = [self wrapComponent:component withModel:componentModel];
        self.componentWrappersByCellIdentifier[cell.identifier] = componentWrapper;
        cell.component = componentWrapper;
    }
    
    HUBComponentWrapper * const componentWrapper = [self componentWrapperFromCell:cell];
    [componentWrapper configureViewWithModel:componentModel containerViewSize:collectionView.frame.size];
    
    [self loadImagesForComponentWrapper:componentWrapper
                             childIndex:nil];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HUBComponentModel> const componentModel = self.viewModel.bodyComponentModels[(NSUInteger)indexPath.item];
    [self handleSelectionForComponentWithModel:componentModel cellIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self collectionViewCellWillAppear:(HUBComponentCollectionViewCell *)cell
              ignorePreviousAppearance:self.collectionViewIsScrolling];
    
    HUBComponentWrapper * const componentWrapper = [self componentWrapperFromCell:(HUBComponentCollectionViewCell *)cell];
    if (componentWrapper.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers addObject:componentWrapper];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HUBComponentModel> const componentModel = [self componentWrapperFromCell:(HUBComponentCollectionViewCell *)cell].model;
    [self.delegate viewController:self componentWithModel:componentModel didDisappearFromView:cell];
    
    HUBComponentWrapper * const componentWrapper = [self componentWrapperFromCell:(HUBComponentCollectionViewCell *)cell];
    if (componentWrapper.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers removeObject:componentWrapper];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (HUBComponentWrapper * const componentWrapper in self.contentOffsetObservingComponentWrappers) {
        [componentWrapper updateViewForChangedContentOffset:scrollView.contentOffset];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGRect const contentRect = [self contentRectForScrollView:scrollView];
    [self.scrollHandler scrollingWillStartInViewController:self currentContentRect:contentRect];
    self.collectionViewIsScrolling = YES;
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

#pragma mark - NSNotification selectors

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
    
    UICollectionView * const collectionView = [self.collectionViewFactory createCollectionView];
    self.collectionView = collectionView;
    collectionView.showsVerticalScrollIndicator = [self.scrollHandler shouldShowScrollIndicatorsInViewController:self];
    collectionView.showsHorizontalScrollIndicator = collectionView.showsVerticalScrollIndicator;
    collectionView.decelerationRate = [self.scrollHandler scrollDecelerationRateForViewController:self];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [self.view insertSubview:collectionView atIndex:0];
}

- (void)reloadCollectionViewWithViewModel:(id<HUBViewModel>)viewModel animated:(BOOL)animated
{
    if (!self.viewModelHasChangedSinceLastLayoutUpdate) {
        if (CGRectEqualToRect(self.collectionView.frame, self.view.bounds)) {
            return;
        }
    }
    
    self.collectionView.frame = self.view.bounds;
    
    [self saveStatesForVisibleComponents];
    
    if (![self.collectionView.collectionViewLayout isKindOfClass:[HUBCollectionViewLayout class]]) {
        self.collectionView.collectionViewLayout = [[HUBCollectionViewLayout alloc] initWithComponentRegistry:self.componentRegistry
                                                                                       componentLayoutManager:self.componentLayoutManager];
    }
    
    HUBCollectionViewLayout * const layout = (HUBCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    /* Performing batch updates inbetween viewDidLoad and viewDidAppear is seemingly not allowed, as it
     causes an assertion inside a private UICollectionView method. If no diff exists, fall back to
     a complete reload. */
    if (!self.viewHasAppeared || self.pendingDiffs.count == 0) {
        [self.collectionView reloadData];
        
        [layout computeForCollectionViewSize:self.collectionView.frame.size viewModel:viewModel diff:self.pendingDiffs.lastObject];

        if (self.viewHasAppeared) {
            /* Forcing a re-layout as the reloadData-call doesn't trigger the numberOfItemsInSection:-calls
             by itself, and batch update calls don't play well without having an initial item count. */
            [self.collectionView setNeedsLayout];
            [self.collectionView layoutIfNeeded];
        }
        
        self.pendingDiffs = @[];
    } else {
        void (^updateBlock)() = ^{
            [self.collectionView performBatchUpdates:^{
                for (HUBViewModelDiff *diff in self.pendingDiffs) {
                    [self.collectionView insertItemsAtIndexPaths:diff.insertedBodyComponentIndexPaths];
                    [self.collectionView deleteItemsAtIndexPaths:diff.deletedBodyComponentIndexPaths];
                    [self.collectionView reloadItemsAtIndexPaths:diff.reloadedBodyComponentIndexPaths];
                }
                
                [layout computeForCollectionViewSize:self.collectionView.frame.size viewModel:viewModel diff:self.pendingDiffs.lastObject];
            } completion:^(BOOL finished) {
                self.pendingDiffs = @[];
            }];
        };
        
        if (animated) {
            updateBlock();
        } else {
            [UIView performWithoutAnimation:updateBlock];
        }
    }
    
    [self configureHeaderComponent];
    [self configureOverlayComponents];
    [self headerAndOverlayComponentViewsWillAppear];
    
    self.viewModelHasChangedSinceLastLayoutUpdate = NO;
    [self.delegate viewControllerDidFinishRendering:self];
}

- (void)saveStatesForVisibleComponents
{
    for (HUBComponentCollectionViewCell *cell in self.collectionView.visibleCells) {
        HUBComponentWrapper *wrapper = [self componentWrapperFromCell:cell];
        [wrapper saveComponentUIState];
    }
}

- (HUBComponentWrapper *)wrapComponent:(id<HUBComponent>)component withModel:(id<HUBComponentModel>)model
{
    HUBComponentWrapper * const wrapper = [[HUBComponentWrapper alloc] initWithComponent:component
                                                                                   model:model
                                                                          UIStateManager:self.componentUIStateManager
                                                                                delegate:self
                                                                                  parent:nil];
    
    [self didAddComponentWrapper:wrapper];
    return wrapper;
}

- (void)didAddComponentWrapper:(HUBComponentWrapper *)wrapper
{
    wrapper.delegate = self;
    self.componentWrappersByIdentifier[wrapper.identifier] = wrapper;
}

- (nullable HUBComponentWrapper *)componentWrapperFromCell:(HUBComponentCollectionViewCell *)cell
{
    return self.componentWrappersByCellIdentifier[cell.identifier];
}

- (void)configureHeaderComponent
{
    id<HUBComponentModel> const componentModel = self.viewModel.headerComponentModel;
    
    if (componentModel == nil) {
        [self removeHeaderComponent];
        
        CGFloat const statusBarWidth = CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
        CGFloat const statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        CGFloat const navigationBarWidth = CGRectGetWidth(self.navigationController.navigationBar.frame);
        CGFloat const navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
        CGFloat const proposedTopInset = MIN(statusBarWidth, statusBarHeight) + MIN(navigationBarWidth, navigationBarHeight);

        [self adjustCollectionViewContentInsetWithProposedTopValue:proposedTopInset];
        
        return;
    }
    
    self.headerComponentWrapper = [self configureHeaderOrOverlayComponentWrapperWithModel:componentModel
                                                                 previousComponentWrapper:self.headerComponentWrapper];
    
    CGFloat const headerViewHeight = CGRectGetHeight(self.headerComponentWrapper.view.frame);
    [self adjustCollectionViewContentInsetWithProposedTopValue:headerViewHeight];
}

- (void)removeHeaderComponent
{
    [self.headerComponentWrapper.view removeFromSuperview];
    self.headerComponentWrapper = nil;
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
        [self removeOverlayComponentWrapper:unusedOverlayComponentWrapper];
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

- (void)removeOverlayComponentWrapper:(HUBComponentWrapper *)wrapper
{
    self.componentWrappersByIdentifier[wrapper.identifier] = nil;
    [wrapper.view removeFromSuperview];
}

- (HUBComponentWrapper *)configureHeaderOrOverlayComponentWrapperWithModel:(id<HUBComponentModel>)componentModel
                                                                previousComponentWrapper:(nullable HUBComponentWrapper *)previousComponentWrapper
{
    BOOL const shouldReuseCurrentComponent = [previousComponentWrapper.model.componentIdentifier isEqual:componentModel.componentIdentifier];
    HUBComponentWrapper *componentWrapper;
    
    if (shouldReuseCurrentComponent) {
        [previousComponentWrapper prepareViewForReuse];
        componentWrapper = previousComponentWrapper;
    } else {
        if (previousComponentWrapper != nil) {
            HUBComponentWrapper * const nonNilPreviousComponentWrapper = previousComponentWrapper;
            [self removeOverlayComponentWrapper:nonNilPreviousComponentWrapper];
        }
        
        id<HUBComponent> const component = [self.componentRegistry createComponentForModel:componentModel];
        componentWrapper = [self wrapComponent:component withModel:componentModel];
    }
    
    CGSize const containerViewSize = self.view.frame.size;
    CGSize const componentViewSize = [componentWrapper preferredViewSizeForDisplayingModel:componentModel
                                                                         containerViewSize:containerViewSize];
    
    UIView * const componentView = HUBComponentLoadViewIfNeeded(componentWrapper);
    [componentWrapper configureViewWithModel:componentModel containerViewSize:containerViewSize];
    componentView.frame = CGRectMake(0, 0, componentViewSize.width, componentViewSize.height);
    
    [self loadImagesForComponentWrapper:componentWrapper
                             childIndex:nil];
    
    if (!shouldReuseCurrentComponent) {
        [self.view addSubview:componentView];
    }
    
    if (componentWrapper.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers addObject:componentWrapper];
    }
    
    return componentWrapper;
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
        self.collectionView.contentOffset = contentOffset;
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
    [self.delegate viewController:self componentWithModel:wrapper.model willAppearInView:cell];
}

- (void)headerAndOverlayComponentViewsWillAppear
{
    if (self.headerComponentWrapper != nil) {
        HUBComponentWrapper * const headerComponentWrapper = self.headerComponentWrapper;
        [self componentWrapperWillAppear:headerComponentWrapper];
    }
    
    for (HUBComponentWrapper * const overlayComponentWrapper in self.overlayComponentWrappers) {
        [self componentWrapperWillAppear:overlayComponentWrapper];
    }
}

- (void)componentWrapperWillAppear:(HUBComponentWrapper *)componentWrapper
{
    [componentWrapper viewWillAppear];
    
    if (componentWrapper.isContentOffsetObserver) {
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
                                                                                                      childIndex:childIndex];
    
    NSMutableArray *contextsForURL = self.componentImageLoadingContexts[imageURL];
    
    if (contextsForURL == nil) {
        contextsForURL = [NSMutableArray arrayWithObject:context];
        self.componentImageLoadingContexts[imageURL] = contextsForURL;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageLoader loadImageForURL:imageURL targetSize:preferredSize];
        });
    } else {
        [contextsForURL addObject:context];
    }
}

- (void)handleLoadedComponentImage:(UIImage *)image forURL:(NSURL *)imageURL fromCache:(BOOL)loadedFromCache context:(HUBComponentImageLoadingContext *)context
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
    
    [componentWrapper updateViewForLoadedImage:image
                                      fromData:imageData
                                         model:componentModel
                                      animated:!loadedFromCache];
}

- (BOOL)handleSelectionForComponentWithModel:(id<HUBComponentModel>)componentModel cellIndexPath:(nullable NSIndexPath *)cellIndexPath
{
    if (cellIndexPath != nil) {
        NSIndexPath * const indexPath = cellIndexPath;
        [self.collectionView cellForItemAtIndexPath:indexPath].highlighted = NO;
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    
    BOOL selectionHandled = NO;
    
    for (HUBIdentifier * const identifier in componentModel.target.actionIdentifiers) {
        selectionHandled = [self performActionForTrigger:HUBActionTriggerSelection
                                        customIdentifier:identifier
                                              customData:nil
                                          componentModel:componentModel];
        
        if (selectionHandled) {
            break;
        }
    }
    
    if (!selectionHandled) {
        selectionHandled = [self performActionForTrigger:HUBActionTriggerSelection
                                        customIdentifier:nil
                                              customData:nil
                                          componentModel:componentModel];
    }
    
    if (selectionHandled) {
        [self.delegate viewController:self componentSelectedWithModel:componentModel];
    }
    
    return selectionHandled;
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
                 componentModel:(id<HUBComponentModel>)componentModel
{
    if (self.viewModel == nil) {
        return NO;
    }
    
    id<HUBViewModel> const viewModel = self.viewModel;
    
    id<HUBActionContext> const context = [[HUBActionContextImplementation alloc] initWithTrigger:trigger
                                                                          customActionIdentifier:customIdentifier
                                                                                      customData:customData
                                                                                         viewURI:self.viewURI
                                                                                       viewModel:viewModel
                                                                                  componentModel:componentModel
                                                                                  viewController:self];
    
    return [self.actionHandler handleActionWithContext:context];
}

@end

NS_ASSUME_NONNULL_END
