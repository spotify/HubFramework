#import <Foundation/Foundation.h>

@protocol HUBLocalContentProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that create local content providers for a Hub Framework feature
 *
 *  Conform to this protocol in a custom object in case you want to add local content (generated in code) to any
 *  view in your feature, and assign it to your feature's `HUBFeatureConfiguration`.
 *
 *  See `HUBLocalContentProvider` for more information.
 */
@protocol HUBLocalContentProviderFactory <NSObject>

/**
 *  Create a local content provider for a view with a certain view URI
 *
 *  @param viewURI The URI of the view that the content provider will be used for
 *
 *  For more information about local content providers, see the documentation for `HUBLocalContentProvider`.
 *  Return nil from this method in case no local content provider should be used for the view.
 */
- (nullable id<HUBLocalContentProvider>)createLocalContentProviderForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
