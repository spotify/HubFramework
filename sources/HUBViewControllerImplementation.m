#import "HUBViewControllerImplementation.h"

#import "HUBViewModelLoader.h"
#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponentImageData.h"
#import "HUBComponent.h"
#import "HUBComponentWrapper.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentCollectionViewCell.h"
#import "HUBComponentIdentifier.h"
#import "HUBUtilities.h"
#import "HUBImageLoader.h"
#import "HUBComponentImageLoadingContext.h"
#import "HUBCollectionViewFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerImplementation () <HUBViewModelLoaderDelegate, HUBImageLoaderDelegate, HUBComponentWrapperDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) id<HUBViewModelLoader> viewModelLoader;
@property (nonatomic, strong, readonly) id<HUBImageLoader> imageLoader;
@property (nonatomic, strong, readonly) HUBCollectionViewFactory *collectionViewFactory;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) NSMutableDictionary<HUBComponentIdentifier *, id<HUBComponent>> *componentsForSizeCalculations;
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *registeredCollectionViewCellReuseIdentifiers;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, NSMutableArray<HUBComponentImageLoadingContext *> *> *componentImageLoadingContexts;
@property (nonatomic, strong, readonly) NSHashTable<id<HUBComponentContentOffsetObserver>> *contentOffsetObservingComponents;
@property (nonatomic, strong, nullable) HUBComponentWrapper *headerComponentWrapper;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSUUID *, HUBComponentWrapper *> *componentWrappersByIdentifier;
@property (nonatomic, strong, nullable) id<HUBViewModel> viewModel;

@end

@implementation HUBViewControllerImplementation

@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (instancetype)initWithViewModelLoader:(id<HUBViewModelLoader> )viewModelLoader
                            imageLoader:(id<HUBImageLoader>)imageLoader
                  collectionViewFactory:(HUBCollectionViewFactory *)collectionViewFactory
                      componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
{
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }
    
    _viewModelLoader = viewModelLoader;
    _imageLoader = imageLoader;
    _collectionViewFactory = collectionViewFactory;
    _componentRegistry = componentRegistry;
    _componentsForSizeCalculations = [NSMutableDictionary new];
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
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.view addSubview:collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModelLoader loadViewModel];
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

#pragma mark - HUBViewController

- (BOOL)isDisplayingHeaderComponent
{
    return self.headerComponentWrapper != nil;
}

#pragma mark - HUBViewModelLoaderDelegate

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel
{
    self.viewModel = viewModel;
    [self configureHeaderComponent];
    [self.collectionView reloadData];
}

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didFailLoadingWithError:(NSError *)error
{
    // Add glorious error handling here
}

#pragma mark - HUBImageLoaderDelegate

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didLoadImage:(UIImage *)image forURL:(NSURL *)imageURL
{
    NSArray * const contexts = self.componentImageLoadingContexts[imageURL];
    
    for (HUBComponentImageLoadingContext * const context in contexts) {
        [self handleLoadedComponentImage:image forURL:imageURL context:context];
    }
}

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didFailLoadingImageForURL:(NSURL *)imageURL error:(NSError *)error
{
    self.componentImageLoadingContexts[imageURL] = nil;
}

#pragma mark - HUBComponentWrapperDelegate

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

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HUBComponentModel> const componentModel = self.viewModel.bodyComponentModels[(NSUInteger)indexPath.item];
    HUBComponentIdentifier * const componentIdentifier = componentModel.componentIdentifier;
    
    id<HUBComponent> sizeComponent = self.componentsForSizeCalculations[componentIdentifier];
    
    if (sizeComponent == nil) {
        sizeComponent = [self.componentRegistry createComponentForIdentifier:componentIdentifier];
        self.componentsForSizeCalculations[componentIdentifier] = sizeComponent;
    }
    
    return [sizeComponent preferredViewSizeForDisplayingModel:componentModel containerViewSize:self.collectionView.frame.size];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (id<HUBComponentContentOffsetObserver> const component in self.contentOffsetObservingComponents) {
        [component updateViewForChangedContentOffset:scrollView.contentOffset];
    }
}

#pragma mark - Private utilities

- (void)configureHeaderComponent
{
    id<HUBComponentModel> const componentModel = self.viewModel.headerComponentModel;
    id<HUBViewControllerDelegate> const delegate = self.delegate;
    
    if (componentModel == nil) {
        if (self.headerComponentWrapper.componentIdentifier != nil) {
            [self removeHeaderComponent];
            [delegate viewControllerHeaderComponentVisbilityDidChange:self];
        }
        
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
        [delegate viewControllerHeaderComponentVisbilityDidChange:self];
    }
    
    if ([headerComponentWrapper.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)]) {
        [self.contentOffsetObservingComponents addObject:(id<HUBComponentContentOffsetObserver>)headerComponentWrapper.component];
    }
    
    UIEdgeInsets collectionViewContentInset = self.collectionView.contentInset;
    collectionViewContentInset.top = headerSize.height;
    self.collectionView.contentInset = collectionViewContentInset;
    
    UIEdgeInsets collectionViewScrollIndicatorInsets = self.collectionView.scrollIndicatorInsets;
    collectionViewScrollIndicatorInsets.top = headerSize.height;
    self.collectionView.scrollIndicatorInsets = collectionViewScrollIndicatorInsets;
}

- (void)removeHeaderComponent
{
    [self.headerComponentWrapper.component.view removeFromSuperview];
    self.headerComponentWrapper = nil;
}

- (void)loadImagesForComponent:(id<HUBComponent>)component
                         model:(id<HUBComponentModel>)model
             wrapperIdentifier:(NSUUID *)wrapperIdentifier
                    childIndex:(nullable NSNumber *)childIndex
{
    if (![component respondsToSelector:@selector(preferredSizeForImageFromData:model:containerViewSize:)]) {
        return;
    }
    
    if (![component respondsToSelector:@selector(updateViewForLoadedImage:fromData:model:)]) {
        return;
    }
    
    id<HUBComponentImageData> const mainImageData = model.mainImageData;
    
    if (mainImageData != nil) {
        [self loadImageFromData:mainImageData component:component model:model wrapperIdentifier:wrapperIdentifier childIndex:childIndex];
    }
    
    id<HUBComponentImageData> const backgroundImageData = model.backgroundImageData;
    
    if (backgroundImageData != nil) {
        [self loadImageFromData:backgroundImageData component:component model:model wrapperIdentifier:wrapperIdentifier childIndex:childIndex];
    }
    
    for (id<HUBComponentImageData> const customImageData in model.customImageData.allValues) {
        [self loadImageFromData:customImageData component:component model:model wrapperIdentifier:wrapperIdentifier childIndex:childIndex];
    }
}

- (void)loadImageFromData:(id<HUBComponentImageData>)imageData
                component:(id<HUBComponent>)component
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

- (void)handleLoadedComponentImage:(UIImage *)image forURL:(NSURL *)imageURL context:(HUBComponentImageLoadingContext *)context
{
    id<HUBViewModel> const viewModel = self.viewModel;
    
    if (context == nil || viewModel == nil) {
        return;
    }
    
    HUBComponentWrapper * const componentWrapper = self.componentWrappersByIdentifier[context.wrapperIdentifier];
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
    
    [componentWrapper.component updateViewForLoadedImage:image fromData:imageData model:componentModel];
}

@end

NS_ASSUME_NONNULL_END
