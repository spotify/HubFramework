#import "HUBViewControllerImplementation.h"

#import "HUBViewModelLoader.h"
#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponentImageData.h"
#import "HUBComponentWithImageHandling.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBComponentWrapper.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentCollectionViewCell.h"
#import "HUBComponentIdentifier.h"
#import "HUBUtilities.h"
#import "HUBImageLoader.h"
#import "HUBComponentImageLoadingContext.h"
#import "HUBCollectionViewFactory.h"
#import "HUBCollectionViewLayout.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBContentReloadPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerImplementation () <HUBViewModelLoaderDelegate, HUBImageLoaderDelegate, HUBComponentWrapperDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readonly) id<HUBViewModelLoader> viewModelLoader;
@property (nonatomic, strong, readonly) id<HUBImageLoader> imageLoader;
@property (nonatomic, strong, readonly) id<HUBContentReloadPolicy> contentReloadPolicy;
@property (nonatomic, strong, readonly) HUBCollectionViewFactory *collectionViewFactory;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *registeredCollectionViewCellReuseIdentifiers;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, NSMutableArray<HUBComponentImageLoadingContext *> *> *componentImageLoadingContexts;
@property (nonatomic, strong, readonly) NSHashTable<id<HUBComponentContentOffsetObserver>> *contentOffsetObservingComponents;
@property (nonatomic, strong, nullable) HUBComponentWrapper *headerComponentWrapper;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSUUID *, HUBComponentWrapper *> *componentWrappersByIdentifier;
@property (nonatomic, strong, nullable) id<HUBViewModel> viewModel;
@property (nonatomic) BOOL viewModelIsInitial;
@property (nonatomic) BOOL viewModelHasChangedSinceLastLayoutUpdate;

@end

@implementation HUBViewControllerImplementation

@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (instancetype)initWithViewModelLoader:(id<HUBViewModelLoader>)viewModelLoader
                            imageLoader:(id<HUBImageLoader>)imageLoader
                    contentReloadPolicy:(id<HUBContentReloadPolicy>)contentReloadPolicy
                  collectionViewFactory:(HUBCollectionViewFactory *)collectionViewFactory
                      componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                 componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
               initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry

{
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }
    
    _viewModelLoader = viewModelLoader;
    _imageLoader = imageLoader;
    _contentReloadPolicy = contentReloadPolicy;
    _collectionViewFactory = collectionViewFactory;
    _componentRegistry = componentRegistry;
    _componentLayoutManager = componentLayoutManager;
    _initialViewModelRegistry = initialViewModelRegistry;
    _viewModel = viewModelLoader.initialViewModel;
    _viewModelIsInitial = YES;
    _registeredCollectionViewCellReuseIdentifiers = [NSMutableSet new];
    _componentImageLoadingContexts = [NSMutableDictionary new];
    _contentOffsetObservingComponents = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    _componentWrappersByIdentifier = [NSMutableDictionary new];
    
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
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
    }
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
    // Add glorious error handling here
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

- (__kindof id<HUBComponent>)componentWrapper:(HUBComponentWrapper *)componentWrapper createChildComponentWithModel:(id<HUBComponentModel>)model
{
    return [self.componentRegistry createComponentForIdentifier:model.componentIdentifier];
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper componentWillDisplayChildAtIndex:(NSUInteger)childIndex
{
    id<HUBComponentModel> const componentModel = componentWrapper.currentModel;
    
    if (childIndex >= componentModel.childComponentModels.count) {
        return;
    }
    
    id<HUBComponentModel> const childComponentModel = componentModel.childComponentModels[childIndex];
    
    [self loadImagesForComponent:componentWrapper.component
                           model:childComponentModel
               wrapperIdentifier:componentWrapper.identifier
                      childIndex:@(childIndex)];
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper childComponentSelectedAtIndex:(NSUInteger)childIndex
{
    id<HUBComponentModel> const componentModel = componentWrapper.currentModel;
    
    if (childIndex >= componentModel.childComponentModels.count) {
        return;
    }
    
    id<HUBComponentModel> const childComponentModel = componentModel.childComponentModels[childIndex];
    [self handleSelectionForComponentWithModel:childComponentModel];
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
    
    if (cell.componentWrapper == nil) {
        id<HUBComponent> const component = [self.componentRegistry createComponentForIdentifier:componentModel.componentIdentifier];
        HUBComponentWrapper * const componentWrapper = [[HUBComponentWrapper alloc] initWithComponent:component
                                                                                  componentIdentifier:componentModel.componentIdentifier];
        
        componentWrapper.delegate = self;
        cell.componentWrapper = componentWrapper;
        self.componentWrappersByIdentifier[componentWrapper.identifier] = componentWrapper;
    }
    
    HUBComponentWrapper * const componentWrapper = cell.componentWrapper;
    componentWrapper.currentModel = componentModel;
    [componentWrapper.component configureViewWithModel:componentModel];
    
    [self loadImagesForComponent:componentWrapper.component
                           model:componentModel
               wrapperIdentifier:componentWrapper.identifier
                      childIndex:nil];
    
    if ([componentWrapper.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)]) {
        [self.contentOffsetObservingComponents addObject:(id<HUBComponentContentOffsetObserver>)componentWrapper.component];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HUBComponentModel> const componentModel = self.viewModel.bodyComponentModels[(NSUInteger)indexPath.item];
    [self handleSelectionForComponentWithModel:componentModel];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (id<HUBComponentContentOffsetObserver> const component in self.contentOffsetObservingComponents) {
        [component updateViewForChangedContentOffset:scrollView.contentOffset];
    }
}

#pragma mark - Private utilities

- (void)loadViewModelIfNeeded
{
    if (!self.viewModelIsInitial) {
        id<HUBViewModel> const currentViewModel = self.viewModel;
        
        if (currentViewModel != nil) {
            if (![self.contentReloadPolicy shouldReloadContentForViewWithCurrentViewModel:currentViewModel]) {
                return;
            }
        }
    }
    
    [self.viewModelLoader loadViewModel];
}

- (void)configureHeaderComponent
{
    id<HUBComponentModel> const componentModel = self.viewModel.headerComponentModel;
    
    if (componentModel == nil) {
        if (self.headerComponentWrapper.componentIdentifier != nil) {
            [self removeHeaderComponent];
        }
        
        CGFloat const statusBarWidth = CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
        CGFloat const statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        CGFloat const navigationBarWidth = CGRectGetWidth(self.navigationController.navigationBar.frame);
        CGFloat const navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
        
        [self adjustCollectionViewContentInsetWithTopValue:MIN(statusBarWidth, statusBarHeight) + MIN(navigationBarWidth, navigationBarHeight)];
        
        return;
    }
    
    BOOL shouldReuseCurrentComponent = NO;
    
    if (self.headerComponentWrapper != nil) {
        if (![self.headerComponentWrapper.componentIdentifier isEqual:componentModel.componentIdentifier]) {
            [self removeHeaderComponent];
        } else {
            shouldReuseCurrentComponent = YES;
        }
    }
    
    if (!shouldReuseCurrentComponent) {
        id<HUBComponent> const component = [self.componentRegistry createComponentForIdentifier:componentModel.componentIdentifier];
        HUBComponentWrapper * const headerComponentWrapper = [[HUBComponentWrapper alloc] initWithComponent:component
                                                                                        componentIdentifier:componentModel.componentIdentifier];
        
        headerComponentWrapper.delegate = self;
        self.headerComponentWrapper = headerComponentWrapper;
        self.componentWrappersByIdentifier[headerComponentWrapper.identifier] = headerComponentWrapper;
        
        [component loadView];
    } else {
        [self.headerComponentWrapper.component prepareViewForReuse];
    }
    
    HUBComponentWrapper * const headerComponentWrapper = self.headerComponentWrapper;
    
    CGSize const headerSize = [headerComponentWrapper.component preferredViewSizeForDisplayingModel:componentModel containerViewSize:self.view.frame.size];
    UIView * const headerView = self.headerComponentWrapper.component.view;
    headerView.frame = CGRectMake(0, 0, headerSize.width, headerSize.height);
    
    [headerComponentWrapper.component configureViewWithModel:componentModel];
    headerComponentWrapper.currentModel = componentModel;
    
    [self loadImagesForComponent:headerComponentWrapper.component
                           model:componentModel
               wrapperIdentifier:headerComponentWrapper.identifier
                      childIndex:0];
    
    if (!shouldReuseCurrentComponent) {
        [self.view addSubview:headerView];
    }
    
    if ([headerComponentWrapper.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)]) {
        [self.contentOffsetObservingComponents addObject:(id<HUBComponentContentOffsetObserver>)headerComponentWrapper.component];
    }
    
    [self adjustCollectionViewContentInsetWithTopValue:headerSize.height];
}

- (void)removeHeaderComponent
{
    [self.headerComponentWrapper.component.view removeFromSuperview];
    self.headerComponentWrapper = nil;
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

- (void)loadImagesForComponent:(id<HUBComponent>)component
                         model:(id<HUBComponentModel>)model
             wrapperIdentifier:(NSUUID *)wrapperIdentifier
                    childIndex:(nullable NSNumber *)childIndex
{
    if (![component conformsToProtocol:@protocol(HUBComponentWithImageHandling)]) {
        return;
    }
    
    id<HUBComponentWithImageHandling> const imageHandlingComponent = (id<HUBComponentWithImageHandling>)component;
    id<HUBComponentImageData> const mainImageData = model.mainImageData;
    id<HUBComponentImageData> const backgroundImageData = model.backgroundImageData;
    
    if (mainImageData != nil) {
        [self loadImageFromData:mainImageData
                      component:imageHandlingComponent
                          model:model
              wrapperIdentifier:wrapperIdentifier
                     childIndex:childIndex];
    }
    
    if (backgroundImageData != nil) {
        [self loadImageFromData:backgroundImageData
                      component:imageHandlingComponent
                          model:model
              wrapperIdentifier:wrapperIdentifier
                     childIndex:childIndex];
    }
    
    for (id<HUBComponentImageData> const customImageData in model.customImageData.allValues) {
        [self loadImageFromData:customImageData
                      component:imageHandlingComponent
                          model:model
              wrapperIdentifier:wrapperIdentifier
                     childIndex:childIndex];
    }
}

- (void)loadImageFromData:(id<HUBComponentImageData>)imageData
                component:(id<HUBComponentWithImageHandling>)component
                    model:(id<HUBComponentModel>)model
        wrapperIdentifier:(NSUUID *)wrapperIdentifier
               childIndex:(nullable NSNumber *)childIndex
{
    NSURL * const imageURL = imageData.URL;
    
    if (imageURL == nil) {
        return;
    }
    
    CGSize const preferredSize = [component preferredSizeForImageFromData:imageData
                                                                    model:model
                                                        containerViewSize:self.collectionView.frame.size];
    
    if (CGSizeEqualToSize(preferredSize, CGSizeZero)) {
        return;
    }
    
    HUBComponentImageLoadingContext * const context = [[HUBComponentImageLoadingContext alloc] initWithImageType:imageData.type
                                                                                                 imageIdentifier:imageData.identifier
                                                                                               wrapperIdentifier:wrapperIdentifier
                                                                                                      childIndex:childIndex];
    
    NSMutableArray *contextsForURL = self.componentImageLoadingContexts[imageURL];
    
    if (contextsForURL == nil) {
        contextsForURL = [NSMutableArray new];
        self.componentImageLoadingContexts[imageURL] = contextsForURL;
    }
    
    [contextsForURL addObject:context];
    
    [self.imageLoader loadImageForURL:imageURL targetSize:preferredSize];
}

- (void)handleLoadedComponentImage:(UIImage *)image forURL:(NSURL *)imageURL fromCache:(BOOL)loadedFromCache context:(HUBComponentImageLoadingContext *)context
{
    id<HUBViewModel> const viewModel = self.viewModel;
    
    if (context == nil || viewModel == nil) {
        return;
    }
    
    HUBComponentWrapper * const componentWrapper = self.componentWrappersByIdentifier[context.wrapperIdentifier];
    
    if (![componentWrapper.component conformsToProtocol:@protocol(HUBComponentWithImageHandling)]) {
        return;
    }
    
    id<HUBComponentWithImageHandling> const component = (id<HUBComponentWithImageHandling>)componentWrapper.component;
    id<HUBComponentModel> componentModel = componentWrapper.currentModel;
    
    NSNumber * const childIndex = context.childIndex;
    
    if (childIndex != nil) {
        NSUInteger const decodedChildIndex = childIndex.unsignedIntegerValue;
        
        if (decodedChildIndex < componentModel.childComponentModels.count) {
            componentModel = componentModel.childComponentModels[decodedChildIndex];
        } else {
            componentModel = nil;
        }
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
    
    [component updateViewForLoadedImage:image fromData:imageData model:componentModel animated:!loadedFromCache];
}

- (void)handleSelectionForComponentWithModel:(id<HUBComponentModel>)componentModel
{
    NSURL * const targetURL = componentModel.targetURL;
    id<HUBViewModel> const targetInitialViewModel = componentModel.targetInitialViewModel;
    
    if (targetURL == nil) {
        return;
    }
    
    if (targetInitialViewModel != nil) {
        [self.initialViewModelRegistry registerInitialViewModel:targetInitialViewModel forViewURI:targetURL];
    }
    
    [[UIApplication sharedApplication] openURL:targetURL];
}

@end

NS_ASSUME_NONNULL_END
