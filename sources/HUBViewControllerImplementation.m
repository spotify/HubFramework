#import "HUBViewControllerImplementation.h"

#import "HUBViewModelLoader.h"
#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponentImageData.h"
#import "HUBComponentWithImageHandling.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBComponentViewObserver.h"
#import "HUBComponentWrapperImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentCollectionViewCell.h"
#import "HUBComponentIdentifier.h"
#import "HUBUtilities.h"
#import "HUBImageLoader.h"
#import "HUBComponentImageLoadingContext.h"
#import "HUBCollectionViewFactory.h"
#import "HUBCollectionViewLayout.h"
#import "HUBContainerView.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBContentReloadPolicy.h"
#import "HUBComponentUIStateManager.h"
#import "HUBComponentSelectionHandler.h"
#import "HUBComponentSelectionContextImplementation.h"
#import "HUBComponentReusePool.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerImplementation () <HUBViewModelLoaderDelegate, HUBImageLoaderDelegate, HUBComponentWrapperDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, copy, readonly) NSURL *viewURI;
@property (nonatomic, strong, readonly) id<HUBViewModelLoader> viewModelLoader;
@property (nonatomic, strong, readonly) HUBCollectionViewFactory *collectionViewFactory;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, nullable, readonly) id<HUBComponentSelectionHandler> componentSelectionHandler;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, weak, nullable) UIDevice *device;
@property (nonatomic, strong, nullable, readonly) id<HUBContentReloadPolicy> contentReloadPolicy;
@property (nonatomic, strong, nullable, readonly) id<HUBImageLoader> imageLoader;
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *registeredCollectionViewCellReuseIdentifiers;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, NSMutableArray<HUBComponentImageLoadingContext *> *> *componentImageLoadingContexts;
@property (nonatomic, strong, readonly) NSHashTable<HUBComponentWrapperImplementation *> *contentOffsetObservingComponentWrappers;
@property (nonatomic, strong, nullable) HUBComponentWrapperImplementation *headerComponentWrapper;
@property (nonatomic, strong, readonly) NSMutableArray<HUBComponentWrapperImplementation *> *overlayComponentWrappers;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSUUID *, HUBComponentWrapperImplementation *> *componentWrappersByIdentifier;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *componentUIStateManager;
@property (nonatomic, strong, readonly) HUBComponentReusePool *childComponentReusePool;
@property (nonatomic, strong, nullable) id<HUBViewModel> viewModel;
@property (nonatomic) BOOL viewModelIsInitial;
@property (nonatomic) BOOL viewModelHasChangedSinceLastLayoutUpdate;

@end

@implementation HUBViewControllerImplementation

@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (instancetype)initWithViewURI:(NSURL *)viewURI
                viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader
          collectionViewFactory:(HUBCollectionViewFactory *)collectionViewFactory
              componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
         componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
      componentSelectionHandler:(nullable id<HUBComponentSelectionHandler>)componentSelectionHandler
       initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                         device:(UIDevice *)device
            contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
                    imageLoader:(nullable id<HUBImageLoader>)imageLoader

{
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }
    
    _viewURI = [viewURI copy];
    _viewModelLoader = viewModelLoader;
    _collectionViewFactory = collectionViewFactory;
    _componentRegistry = componentRegistry;
    _componentLayoutManager = componentLayoutManager;
    _componentSelectionHandler = componentSelectionHandler;
    _initialViewModelRegistry = initialViewModelRegistry;
    _device = device;
    _contentReloadPolicy = contentReloadPolicy;
    _imageLoader = imageLoader;
    _viewModel = viewModelLoader.initialViewModel;
    _viewModelIsInitial = YES;
    _registeredCollectionViewCellReuseIdentifiers = [NSMutableSet new];
    _componentImageLoadingContexts = [NSMutableDictionary new];
    _contentOffsetObservingComponentWrappers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    _overlayComponentWrappers = [NSMutableArray new];
    _componentWrappersByIdentifier = [NSMutableDictionary new];
    _componentUIStateManager = [HUBComponentUIStateManager new];
    _childComponentReusePool = [[HUBComponentReusePool alloc] initWithComponentRegistry:_componentRegistry
                                                                         UIStateManager:_componentUIStateManager];
    
    _viewModelLoader.delegate = self;
    _imageLoader.delegate = self;
    
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionView * const collectionView = [self.collectionViewFactory createCollectionView];
    self.collectionView = collectionView;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.view addSubview:collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadViewModelIfNeeded];
    
    for (NSIndexPath * const indexPath in self.collectionView.indexPathsForVisibleItems) {
        HUBComponentCollectionViewCell * const cell = (HUBComponentCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self collectionViewCellWillAppear:cell];
    }
    
    [self headerAndOverlayComponentViewsWillAppear];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    id<HUBViewModel> const viewModel = self.viewModel;
    
    if (viewModel == nil) {
        return;
    }
    
    if (!self.viewModelHasChangedSinceLastLayoutUpdate) {
        if (CGRectEqualToRect(self.collectionView.frame, self.view.bounds)) {
            return;
        }
    }
    
    self.collectionView.frame = self.view.bounds;
    
    [self configureHeaderComponent];
    [self configureOverlayComponents];
    [self headerAndOverlayComponentViewsWillAppear];
    
    HUBCollectionViewLayout * const layout = [[HUBCollectionViewLayout alloc] initWithViewModel:viewModel
                                                                              componentRegistry:self.componentRegistry
                                                                         componentLayoutManager:self.componentLayoutManager];
    
    [layout computeForCollectionViewSize:self.collectionView.frame.size];
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView reloadData];
    
    self.viewModelHasChangedSinceLastLayoutUpdate = NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    HUB_IGNORE_PARTIAL_AVAILABILTY_BEGIN
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    HUB_IGNORE_PARTIAL_AVAILABILTY_END

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

    self.view = nil;
    self.collectionView = nil;
    self.viewModel = nil;
}

#pragma mark - HUBViewModelLoaderDelegate

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel
{
    self.viewModel = viewModel;
    self.viewModelIsInitial = NO;
    self.viewModelHasChangedSinceLastLayoutUpdate = YES;
    [self.view setNeedsLayout];
    
    [self.delegate viewController:self didUpdateWithViewModel:viewModel];
}

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didFailLoadingWithError:(NSError *)error
{
    [self.delegate viewController:self didFailToUpdateWithError:error];
}

#pragma mark - HUBImageLoaderDelegate

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didLoadImage:(UIImage *)image forURL:(NSURL *)imageURL fromCache:(BOOL)loadedFromCache
{
    NSArray * const contexts = self.componentImageLoadingContexts[imageURL];
    
    for (HUBComponentImageLoadingContext * const context in contexts) {
        [self handleLoadedComponentImage:image forURL:imageURL fromCache:loadedFromCache context:context];
    }
}

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didFailLoadingImageForURL:(NSURL *)imageURL error:(NSError *)error
{
    self.componentImageLoadingContexts[imageURL] = nil;
}

#pragma mark - HUBComponentWrapperDelegate

- (id<HUBComponentWrapper>)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
                     childComponentForModel:(id<HUBComponentModel>)model
{
    HUBComponentWrapperImplementation * const childComponentWrapper = [self.childComponentReusePool componentWrapperForModel:model];
    childComponentWrapper.model = model;
    [self didAddComponentWrapper:childComponentWrapper];
    
    UIView * const componentView = componentWrapper.view;
    UIView * const childComponentView = childComponentWrapper.view;
    
    CGSize const preferredViewSize = [childComponentWrapper preferredViewSizeForContainerViewSize:componentView.frame.size];
    childComponentView.frame = CGRectMake(0, 0, preferredViewSize.width, preferredViewSize.height);
    
    [self loadImagesForComponentWrapper:childComponentWrapper childIndex:nil];
    
    return childComponentWrapper;
}

- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
       willAppearAtIndex:(NSUInteger)childIndex
{
    id<HUBComponentModel> const componentModel = componentWrapper.model;
    
    if (childIndex >= componentModel.childComponentModels.count) {
        return;
    }
    
    id<HUBComponentModel> const childComponentModel = componentModel.childComponentModels[childIndex];
    [self loadImagesForComponentWrapper:componentWrapper childIndex:@(childIndex)];
    [self.delegate viewController:self componentWithModel:childComponentModel willAppearInView:childComponentView];
}

- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
     didDisappearAtIndex:(NSUInteger)childIndex
{
    id<HUBComponentModel> const componentModel = componentWrapper.model;
    
    if (childIndex >= componentModel.childComponentModels.count) {
        return;
    }
    
    id<HUBComponentModel> const childComponentModel = componentModel.childComponentModels[childIndex];
    [self.delegate viewController:self componentWithModel:childComponentModel didDisappearFromView:childComponentView];
}

- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
         selectedAtIndex:(NSUInteger)childIndex
{
    id<HUBComponentModel> const componentModel = componentWrapper.model;
    
    if (childIndex >= componentModel.childComponentModels.count) {
        return;
    }
    
    id<HUBComponentModel> const childComponentModel = componentModel.childComponentModels[childIndex];
    [self handleSelectionForComponentWithModel:childComponentModel view:childComponentView cellIndexPath:nil];
}

- (void)sendComponentWrapperToReusePool:(HUBComponentWrapperImplementation *)componentWrapper
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
        cell.component = [self wrapComponent:component withModel:componentModel];
    }
    
    HUBComponentWrapperImplementation * const componentWrapper = [self componentWrapperFromCell:cell];
    componentWrapper.model = componentModel;
    
    [self loadImagesForComponentWrapper:componentWrapper
                             childIndex:nil];
    
    if (componentWrapper.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers addObject:componentWrapper];
    }
    
    UIDevice * const device = self.device;
    
    if (device != nil) {
        if (!HUBDeviceIsRunningSystemVersion8OrHigher(device)) {
            [self collectionViewCellWillAppear:cell];
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HUBComponentModel> const componentModel = self.viewModel.bodyComponentModels[(NSUInteger)indexPath.item];
    UICollectionViewCell * const cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self handleSelectionForComponentWithModel:componentModel view:cell cellIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self collectionViewCellWillAppear:(HUBComponentCollectionViewCell *)cell];
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HUBComponentModel> const componentModel = self.viewModel.bodyComponentModels[(NSUInteger)indexPath.item];
    [self.delegate viewController:self componentWithModel:componentModel didDisappearFromView:cell];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (HUBComponentWrapperImplementation * const componentWrapper in self.contentOffsetObservingComponentWrappers) {
        [componentWrapper contentOffsetDidChange:scrollView.contentOffset];
    }
}

#pragma mark - Private utilities

- (void)loadViewModelIfNeeded
{
    if (self.contentReloadPolicy != nil) {
        if (!self.viewModelIsInitial) {
            id<HUBViewModel> const currentViewModel = self.viewModel;
            
            if (currentViewModel != nil) {
                if (![self.contentReloadPolicy shouldReloadContentForViewURI:self.viewURI currentViewModel:currentViewModel]) {
                    return;
                }
            }
        }
    }
    
    [self.viewModelLoader loadViewModel];
}

- (HUBComponentWrapperImplementation *)wrapComponent:(id<HUBComponent>)component withModel:(id<HUBComponentModel>)model
{
    HUBComponentWrapperImplementation * const wrapper = [[HUBComponentWrapperImplementation alloc] initWithComponent:component
                                                                                                               model:model
                                                                                                      UIStateManager:self.componentUIStateManager
                                                                                                     isRootComponent:YES];
    
    [self didAddComponentWrapper:wrapper];
    return wrapper;
}

- (void)didAddComponentWrapper:(HUBComponentWrapperImplementation *)wrapper
{
    wrapper.delegate = self;
    self.componentWrappersByIdentifier[wrapper.identifier] = wrapper;
}

- (HUBComponentWrapperImplementation *)componentWrapperFromCell:(HUBComponentCollectionViewCell *)cell
{
    HUBComponentWrapperImplementation * const wrapper = self.componentWrappersByIdentifier[cell.component.identifier];
    return wrapper;
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
        
        [self adjustCollectionViewContentInsetWithTopValue:MIN(statusBarWidth, statusBarHeight) + MIN(navigationBarWidth, navigationBarHeight)];
        
        return;
    }
    
    self.headerComponentWrapper = [self configureHeaderOrOverlayComponentWrapperWithModel:componentModel
                                                                 previousComponentWrapper:self.headerComponentWrapper];
    
    CGFloat const headerViewHeight = CGRectGetHeight(self.headerComponentWrapper.view.frame);
    [self adjustCollectionViewContentInsetWithTopValue:headerViewHeight];
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
        HUBComponentWrapperImplementation *componentWrapper = nil;
        
        if (self.overlayComponentWrappers.count < currentOverlayComponentWrappers.count) {
            NSUInteger const componentIndex = self.overlayComponentWrappers.count;
            componentWrapper = currentOverlayComponentWrappers[componentIndex];
            [currentOverlayComponentWrappers removeObjectAtIndex:componentIndex];
        }
        
        componentWrapper = [self configureHeaderOrOverlayComponentWrapperWithModel:componentModel
                                                          previousComponentWrapper:componentWrapper];
        
        [self.overlayComponentWrappers addObject:componentWrapper];
        
        componentWrapper.view.center = self.collectionView.center;
    }
    
    for (HUBComponentWrapperImplementation * const unusedOverlayComponentWrapper in currentOverlayComponentWrappers) {
        [unusedOverlayComponentWrapper.view removeFromSuperview];
    }
}

- (HUBComponentWrapperImplementation *)configureHeaderOrOverlayComponentWrapperWithModel:(id<HUBComponentModel>)componentModel
                                                                previousComponentWrapper:(nullable HUBComponentWrapperImplementation *)previousComponentWrapper
{
    BOOL const shouldReuseCurrentComponent = [previousComponentWrapper.model.componentIdentifier isEqual:componentModel.componentIdentifier];
    HUBComponentWrapperImplementation *componentWrapper;
    
    if (shouldReuseCurrentComponent) {
        [previousComponentWrapper prepareForReuse];
        componentWrapper = previousComponentWrapper;
    } else {
        NSUUID * const previousComponentWrapperIdentifier = previousComponentWrapper.identifier;
        
        if (previousComponentWrapperIdentifier != nil) {
            self.componentWrappersByIdentifier[previousComponentWrapperIdentifier] = nil;
        }
        
        id<HUBComponent> const component = [self.componentRegistry createComponentForModel:componentModel];
        componentWrapper = [self wrapComponent:component withModel:componentModel];
    }
    
    componentWrapper.model = componentModel;
    
    CGSize const componentViewSize = [componentWrapper preferredViewSizeForContainerViewSize:self.view.frame.size];
    componentWrapper.view.frame = CGRectMake(0, 0, componentViewSize.width, componentViewSize.height);
    
    [self loadImagesForComponentWrapper:componentWrapper
                             childIndex:nil];
    
    if (!shouldReuseCurrentComponent) {
        [self.view addSubview:componentWrapper.view];
    }
    
    if (componentWrapper.isContentOffsetObserver) {
        [self.contentOffsetObservingComponentWrappers addObject:componentWrapper];
    }
    
    return componentWrapper;
}

- (void)adjustCollectionViewContentInsetWithTopValue:(CGFloat)topContentInset
{
    UIEdgeInsets collectionViewContentInset = self.collectionView.contentInset;
    collectionViewContentInset.top = topContentInset;
    self.collectionView.contentInset = collectionViewContentInset;
    
    UIEdgeInsets collectionViewScrollIndicatorInsets = self.collectionView.scrollIndicatorInsets;
    collectionViewScrollIndicatorInsets.top = topContentInset;
    self.collectionView.scrollIndicatorInsets = collectionViewScrollIndicatorInsets;
}

- (void)collectionViewCellWillAppear:(HUBComponentCollectionViewCell *)cell
{
    HUBComponentWrapperImplementation * const wrapper = [self componentWrapperFromCell:cell];
    [wrapper viewWillAppear];
    [self.delegate viewController:self componentWithModel:cell.component.model willAppearInView:cell];
}

- (void)headerAndOverlayComponentViewsWillAppear
{
    [self.headerComponentWrapper viewWillAppear];
    
    for (HUBComponentWrapperImplementation * const overlayComponentWrapper in self.overlayComponentWrappers) {
        [overlayComponentWrapper viewWillAppear];
    }
}

- (void)loadImagesForComponentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
                           childIndex:(nullable NSNumber *)childIndex
{
    if (self.imageLoader == nil) {
        return;
    }
    
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
         componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
               childIndex:(nullable NSNumber *)childIndex
{
    if (self.imageLoader == nil) {
        return;
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
        contextsForURL = [NSMutableArray new];
        self.componentImageLoadingContexts[imageURL] = contextsForURL;
    }
    
    [contextsForURL addObject:context];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageLoader loadImageForURL:imageURL targetSize:preferredSize];
    });
}

- (void)handleLoadedComponentImage:(UIImage *)image forURL:(NSURL *)imageURL fromCache:(BOOL)loadedFromCache context:(HUBComponentImageLoadingContext *)context
{
    id<HUBViewModel> const viewModel = self.viewModel;
    
    if (context == nil || viewModel == nil) {
        return;
    }
    
    HUBComponentWrapperImplementation * const componentWrapper = self.componentWrappersByIdentifier[context.wrapperIdentifier];
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

- (void)handleSelectionForComponentWithModel:(id<HUBComponentModel>)componentModel view:(UIView *)view cellIndexPath:(nullable NSIndexPath *)cellIndexPath
{
    // self.viewModel is specified as nullable, but we can safely assume it exists at this point.
    id<HUBViewModel> const viewModel = self.viewModel;
    id<HUBComponentSelectionContext> const selectionContext =
        [[HUBComponentSelectionContextImplementation alloc] initWithViewURI:self.viewURI
                                                                  viewModel:viewModel
                                                             componentModel:componentModel
                                                             viewController:self];
    BOOL const selectionHandled = [self.componentSelectionHandler handleSelectionForComponentWithContext:selectionContext];
    
    if (!selectionHandled) {
        NSURL * const targetURL = componentModel.targetURL;
        id<HUBViewModel> const targetInitialViewModel = componentModel.targetInitialViewModel;
        
        if (targetURL != nil) {
            if (targetInitialViewModel != nil) {
                [self.initialViewModelRegistry registerInitialViewModel:targetInitialViewModel forViewURI:targetURL];
            }
            
            [[UIApplication sharedApplication] openURL:targetURL];
        }
    }
    
    if (cellIndexPath != nil) {
        NSIndexPath * const indexPath = cellIndexPath;
        [self.collectionView cellForItemAtIndexPath:indexPath].highlighted = NO;
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    
    if (selectionHandled || componentModel.targetURL != nil) {
        [self.delegate viewController:self componentWithModel:componentModel selectedInView:view];
    }
}

- (nullable id<HUBComponentModel>)childModelAtIndex:(NSUInteger)childIndex fromComponentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
{
    id<HUBComponentModel> parentModel = componentWrapper.model;
    
    if (childIndex >= parentModel.childComponentModels.count) {
        return nil;
    }
    
    return parentModel.childComponentModels[childIndex];
}

@end

NS_ASSUME_NONNULL_END
