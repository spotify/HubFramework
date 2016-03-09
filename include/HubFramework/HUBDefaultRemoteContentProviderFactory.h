#import <Foundation/Foundation.h>

@protocol HUBRemoteContentProvider;
@protocol HUBRemoteContentURLResolver;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by an object that acts as a default remote content provider factory
 *
 *  Conform to this protocol in a custom object and pass it when creating your application's `HUBManager`.
 *  A default remote content provider factory is used when a feature is using a `HUBRemoteContentURLResolver`,
 *  rather than a custom remote content provider factory.
 *
 *  This factory should be able to create a remote content provider for any view URI in the application, and
 *  may use the view URI & feature identifier to make decisions on how to setup any created content providers.
 */
@protocol HUBDefaultRemoteContentProviderFactory <NSObject>

/**
 *  Create a remote content provider for a feature using a remote content URL resolver
 *
 *  @param viewURI The view URI to create a remote content provider for
 *  @param featureIdentifier The identifier of the feature that the remote content provider is for
 *  @param remoteContentURLResolver The object the feature is using to resolve a remote content HTTP URL for
 *         a given view URI. The returned remote content provider should use this object to resolve HTTP URLs.
 */
- (id<HUBRemoteContentProvider>)createRemoteContentProviderForViewURI:(NSURL *)viewURI
                                                    featureIdentifier:(NSString *)featureIdentifier
                                             remoteContentURLResolver:(id<HUBRemoteContentURLResolver>)remoteContentURLResolver;

@end

NS_ASSUME_NONNULL_END
