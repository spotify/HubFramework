#import <UIKit/UIKit.h>

@protocol HUBViewModelLoader;
@class HUBComponentRegistryImplementation;

NS_ASSUME_NONNULL_BEGIN

/// View controller that manages a Hub Framework-powered User Interface with a collection view of components
@interface HUBViewController : UIViewController

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewModelLoader The object to use to load view models for the view controller
 *  @param componentRegistry The registry to use to retrieve components to render
 */
- (instancetype)initWithViewModelLoader:(id<HUBViewModelLoader>)viewModelLoader
                      componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry NS_DESIGNATED_INITIALIZER;

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
