#import <Foundation/Foundation.h>

@protocol HUBViewModel;

NS_ASSUME_NONNULL_BEGIN

/// Registry used to keep track of initial view models for view URIs
@interface HUBInitialViewModelRegistry : NSObject

/**
 *  Register an initial view model for a view URI
 *
 *  @param initialViewModel The initial view model to register
 *  @param viewURI The view URI to register the initial view model for
 *
 *  Calling this method with a view URI for which an initial view model has already been registered
 *  will cause the old registration to be overwritten.
 */
- (void)registerInitialViewModel:(id<HUBViewModel>)initialViewModel forViewURI:(NSURL *)viewURI;

/**
 *  Remove any previously registered initial view model for a view URI
 *
 *  @param viewURI The view URI to remove an initial view model for
 */
- (void)removeInitialViewModelForViewURI:(NSURL *)viewURI;

/**
 *  Return any previously registered initial view model for a view URI
 *
 *  @param viewURI The view URI to retrieve an initial view model for
 */
- (nullable id<HUBViewModel>)initialViewModelForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
