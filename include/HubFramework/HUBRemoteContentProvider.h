#import <Foundation/Foundation.h>

@protocol HUBRemoteContentProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBRemoteContentProvider`
 *
 *  You don't conform to this protocol yourself. Instead, the Hub Framework will assign an internal object
 *  that conforms to this protocol as the delegate of any remote content provider. You use the methods defined
 *  in this protocol to communicate a remote content provider's outcome back to the framework.
 */
@protocol HUBRemoteContentProviderDelegate <NSObject>

/**
 *  Notify the Hub Framework that a remote content provider finished loading JSON data
 *
 *  @param contentProvider The content provider that finished loading
 *  @param JSONData The JSON data that was downloaded
 *
 *  Call this method whenever new content was downloaded. It's safe to call it multiple times during a remote content
 *  provider's lifecycle. Every time this method is called, the Hub Framework will attempt to parse the supplied data
 *  into content data that is used as the starting point for a `HUBViewModelBuilder`. This builder is then passed to
 *  any local content provider, and finally the content is rendered.
 */
- (void)remoteContentProvider:(id<HUBRemoteContentProvider>)contentProvider didLoadJSONData:(NSData *)JSONData;

/**
 *  Notify the Hub Framework that a remote content provider failed to load because of an error
 *
 *  @param contentProvider The content provider that failed loading
 *  @param error The error that was encountered
 *
 *  Call this method whenever an error was encountered that prevented JSON data from being loaded. It's safe to call
 *  it multiple times during a remote content provider's lifecycle. Every time this method is called, the Hub Framework
 *  will ask any local content provider for fallback content, or render a visualization of the error in an info view
 *  in case no content at all could be loaded.
 */
- (void)remoteContentProvider:(id<HUBRemoteContentProvider>)contentProvider didFailLoadingWithError:(NSError *)error;

@end

/**
 *  Protocol that objects that provide remote (server side) content to a Hub Framework view conform to
 *
 *  If you wish to implement a custom remote content provider, you conform to this protocol in an object and
 *  return it from your `HUBContentProviderFactory` implementation.
 *
 *  If all you're looking to do in your remote content provider is to load JSON data from an HTTP endpoint, consider
 *  using the `HUBRemoteContentURLResolver` API instead, which enables you to just write the viewURI -> HTTP URL mapping
 *  logic, instead of implementing networking code.
 *
 *  The Hub Framework will automatically call your remote content provider whenever new remote content is needed,
 *  such as when a user enters a view for the first time, when a view needs to be reloaded, or if additional paginated
 *  content is needed.
 *
 *  A remote content provider has a 1:1 relationship with a view.
 */
@protocol HUBRemoteContentProvider <NSObject>

/// The content provider's delegate. Don't assign this property yourself, it will be set by the Hub Framework.
@property (nonatomic, weak, nullable) id<HUBRemoteContentProviderDelegate> delegate;

/**
 *  Load remote content for a certain view
 *
 *  @param viewURI The view URI that this remote content provider is being used for
 *
 *  The remote content provider should immediately start to download JSON data for the view, and notify its delegate
 *  when the operation was finished, or if an error was encountered. It's safe to cancel any previously unfinished
 *  requests at the time this method is called.
 */
- (void)loadContentForViewWithURI:(NSURL *)viewURI;

/**
 *  Load remote content from a specific HTTP URL
 *
 *  @param contentURL The HTTP URL from which contnet should be downloaded
 *
 *  The remote content provider should immediately start to download JSON data from the supplied HTTP URL, and notify
 *  its delegate when the operation was finished, or if an error was encountered. It's safe to cancel any previously
 *  unfinished requests at the time this method is called.
 *
 *  The Hub Framework calls this method if the current view's model has an `extensionURL` defined and additional content
 *  is needed, or if the content provider is being used as part of the external data API.
 */
- (void)loadContentFromURL:(NSURL *)contentURL;

@end

NS_ASSUME_NONNULL_END
