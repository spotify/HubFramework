#import "HUBViewController.h"

#import "HUBViewModelLoader.h"
#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponent.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentCollectionViewCell.h"
#import "HUBComponentIdentifier.h"


NS_ASSUME_NONNULL_BEGIN

@interface HUBViewController () <HUBViewModelLoaderDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) id<HUBViewModelLoader> viewModelLoader;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, nullable) id<HUBViewModel> viewModel;

@end

@implementation HUBViewController

#pragma mark - Lifecycle

- (instancetype)initWithViewModelLoader:(id<HUBViewModelLoader> )viewModelLoader
                      componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
{
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }
    
    _componentRegistry = componentRegistry;
    _viewModelLoader = viewModelLoader;
    _viewModelLoader.delegate = self;
    
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

    UICollectionView * const collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                                 collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView = collectionView;

    for (HUBComponentIdentifier *componentIdentifier in self.componentRegistry.allComponentIdentifiers) {
        [self.collectionView registerClass:[HUBComponentCollectionViewCell class] forCellWithReuseIdentifier:componentIdentifier.identifierString];
    }

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

    self.view = nil;
    self.collectionView = nil;
    self.viewModel = nil;
}

#pragma mark - HUBViewModelLoaderDelegate

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel
{
    self.viewModel = viewModel;
    [self.collectionView reloadData];
}

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didFailLoadingWithError:(NSError *)error
{
    // Add glorious error handling here
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
    id<HUBComponentModel> const componentModel = [self.viewModel.bodyComponentModels objectAtIndex:(NSUInteger)indexPath.item];
    HUBComponentIdentifier * const componentIdentifier = [self.componentRegistry componentIdentifierForModel:componentModel];
    
    HUBComponentCollectionViewCell * const cell = [collectionView dequeueReusableCellWithReuseIdentifier:componentIdentifier.identifierString forIndexPath:indexPath];
    
    if (cell.component == nil) {
        cell.component = [self.componentRegistry componentForModel:componentModel];
    }
    
    [cell.component configureViewWithModel:componentModel];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HUBComponentModel> const componentModel = [self.viewModel.bodyComponentModels objectAtIndex:(NSUInteger)indexPath.item];
    id<HUBComponent> const component = [self.componentRegistry componentForModel:componentModel];
    return [component preferredViewSizeForDisplayingModel:componentModel containedInViewWithSize:self.collectionView.frame.size];
}

@end

NS_ASSUME_NONNULL_END
