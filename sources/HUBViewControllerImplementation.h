#import "HUBViewController.h"
#import "HUBHeaderMacros.h"

@protocol HUBViewModelLoader;
@protocol HUBImageLoader;
@protocol HUBContentReloadPolicy;
@protocol HUBComponentLayoutManager;
@protocol HUBViewModel;
@class HUBCollectionViewFactory;
@class HUBComponentRegistryImplementation;
@class HUBInitialViewModelRegistry;

NS_ASSUME_NONNULL_BEGIN

/// View controller that manages a Hub Framework-powered User Interface with a collection view of components
@interface HUBViewControllerImplementation : UIViewController <HUBViewController>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewURI The view URI that this view controller is for
 *  @param viewModelLoader The object to use to load view models for the view controller
 *  @param imageLoader The object to use to load images for components
 *  @param contentReloadPolicy The reload policy to use to determine when to load new content
 *  @param collectionViewFactory The factory to use to create collection views
 *  @param componentRegistry The registry to use to retrieve components to render
 *  @param componentLayoutManager The object that manages layout for components in the view controller
 *  @param initialViewModelRegistry The registry to use to register initial view models for subsequent view controllers
 */
- (instancetype)initWithViewURI:(NSURL *)viewURI
                viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader
                    imageLoader:(id<HUBImageLoader>)imageLoader
            contentReloadPolicy:(id<HUBContentReloadPolicy>)contentReloadPolicy
          collectionViewFactory:(HUBCollectionViewFactory *)collectionViewFactory
              componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
         componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
       initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry HUB_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class cannot be used with Interface Builder
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
