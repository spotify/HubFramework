#import <Foundation/Foundation.h>

@protocol HUBRemoteContentProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that create remote content providers for a Hub Framework feature
 *
 *  Conform to this protocol in a custom object in case you want to add remote content (loaded over the network through
 *  JSON data) to any view in your feature, and you want to do so using custom networking code. You then assign the object
 *  to your feature's `HUBFeatureConfiguration`.
 *
 *  In case all you want to do is load data from a HTTP URL, consider using the `HUBRemoteContentURLResolver` API instead.
 *
 *  See `HUBRemoteContentProvider` for more information.
 */
@protocol HUBRemoteContentProviderFactory <NSObject>

/**
 *  Create a remote content provider for a view with a certain view URI
 *
 *  @param viewURI The URI of the view that the content provider will be used for
 *
 *  For more information about remote content providers, see the documentation for `HUBRemoteContentProvider`.
 *  Return nil from this method in case no remote content provider should be used for the view.
 */
- (nullable id<HUBRemoteContentProvider>)createRemoteContentProviderForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
