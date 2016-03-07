#import <UIKit/UIKit.h>

#import "HUBViewController.h"

@protocol HUBViewModelLoader;
@protocol HUBImageLoader;
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
 *  @param viewModelLoader The object to use to load view models for the view controller
 *  @param imageLoader The object to use to load images for components
 *  @param collectionViewFactory The factory to use to create collection views
 *  @param componentRegistry The registry to use to retrieve components to render
 *  @param componentLayoutManager The object that manages layout for components in the view controller
 *  @oaram initialViewModel Any initial view model the view controller should use before loading its full one
 *  @param initialViewModelRegistry The registry to use to register initial view models for subsequent view controllers
 */
- (instancetype)initWithViewModelLoader:(id<HUBViewModelLoader>)viewModelLoader
                            imageLoader:(id<HUBImageLoader>)imageLoader
                  collectionViewFactory:(HUBCollectionViewFactory *)collectionViewFactory
                      componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                 componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                       initialViewModel:(nullable id<HUBViewModel>)initialViewModel
               initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

/// This class cannot be initialized with a decoder
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/// This class cannot be used with Interface Builder
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
