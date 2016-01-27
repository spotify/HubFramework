#import <Foundation/Foundation.h>

@protocol HUBRemoteContentProvider;
@protocol HUBLocalContentProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol that objects that create content providers for a Hub Framework view conform to
 *
 *  If you wish to implement custom content provider(s), you conform to this protocol in an object and
 *  supply it as part of your `HUBFeatureConfiguration`.
 *
 *  Content providers come in two variants, remote & local. A remote content provider loads content as
 *  JSON data and passes is back to the framework for parsing according to the defined `HUBJSONSchema`.
 *  A local content provider loads any offline/locally available content and adds it to a view using
 *  a `HUBViewModelBuilder`.
 *
 *  Depending on your feature's requirements, you can choose to implement whichever of these protocols
 *  that you need (or both). There's also the option of not using any custom `HUBContentProviderFactory`
 *  at all, by using the `HUBRemoteContentURLResolver` API (see the documentation for `HUBRemoteContentProvider`
 *  for more information about that).
 *
 *  A content provider factory has a 1:1 relationship with a feature, and creates content providers that
 *  each have a 1:1 relationship with the view they are providing content for. Whenever a new view is created
 *  by the framework, it will call its content provider factory to create content providers for that view.
 */
@protocol HUBContentProviderFactory <NSObject>

/**
 *  Create a remote content provider for a view with a certain view URI
 *
 *  @param viewURI The URI of the view that the content provider will be used for
 *
 *  For more information about remote content providers, see the documentation for `HUBRemoteContentProvider`.
 *  Return nil from this method in case no remote content provider should be used for the view.
 */
- (nullable id<HUBRemoteContentProvider>)createRemoteContentProviderForViewURI:(NSURL *)viewURI;

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
