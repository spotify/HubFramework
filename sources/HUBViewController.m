#import "HUBViewController.h"

#import "HUBViewModelLoader.h"
#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponent.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewController () <HUBViewModelLoaderDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) id<HUBViewModelLoader> viewModelLoader;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, nullable) id<HUBViewModel> viewModel;

@end

@implementation HUBViewController

- (instancetype)initWithViewModelLoader:(id<HUBViewModelLoader> )viewModelLoader
                      componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
{
    if (!(self = [super initWithNibName:nil bundle:nil])) {
        return nil;
    }
    
    _viewModelLoader = viewModelLoader;
    _componentRegistry = componentRegistry;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:[UICollectionViewFlowLayout new]];
    
    _viewModelLoader.delegate = self;
    
    for (NSString * const componentIdentifier in _componentRegistry.allComponentIdentifiers) {
        [_collectionView registerClass:[HUBComponentCollectionViewCell class] forCellWithReuseIdentifier:componentIdentifier];
    }
    
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.collectionView.frame = self.view.bounds;
    [self.viewModelLoader loadViewModel];
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
    NSString * const componentIdentifier = [self.componentRegistry componentIdentifierForModel:componentModel];
    
    HUBComponentCollectionViewCell * const cell = [collectionView dequeueReusableCellWithReuseIdentifier:componentIdentifier forIndexPath:indexPath];
    
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
