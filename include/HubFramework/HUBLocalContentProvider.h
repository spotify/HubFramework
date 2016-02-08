#import <Foundation/Foundation.h>

@protocol HUBLocalContentProvider;
@protocol HUBViewModelBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBLocalContentProvider`
 *
 *  You don't conform to this protocol yourself. Instead, the Hub Framework will assign an internal object
 *  that conforms to this protocol as the delegate of any local content provider. You use the methods defined
 *  in this protocol to communicate a local content provider's outcome back to the framework, as well as having
 *  the framework provide you with `HUBViewModelBuilder` objects.
 */
@protocol HUBLocalContentProviderDelegate <NSObject>

/**
 *  Ask the Hub Framework to provide a `HUBViewModelBuilder`, that can be used to add content to a view
 *
 *  @param contentProvider The content provider in need of a view model builder
 *
 *  Call this method when you have finished loading local content data and want to add it to a view. You should not
 *  hold onto any view model builder objects as they are bound to change during a view's lifecycle. Instead, request
 *  a new builder each time you need one.
 */
- (id<HUBViewModelBuilder>)provideViewModelBuilderForLocalContentProvider:(id<HUBLocalContentProvider>)contentProvider;

/**
 *  Notify the Hub Framework that a local content provider finished loading
 *
 *  @param contentProvider The content provider that finished loading
 *
 *  Call this method whenever new content was downloaded. It's safe to call it multiple times during a local content
 *  provider's lifecycle. Every time this method is called, the Hub Framework will use the current view model builder
 *  to create a view model, which is then rendered.
 */
- (void)localContentProviderDidLoad:(id<HUBLocalContentProvider>)contentProvider;

/**
 *  Notify the Hub Framework that a local content provider failed to load because of an error
 *
 *  @param contentProvider The content provider that failed loading
 *  @param error The error that was encountered
 *
 *  Call this method whenever an error was encountered that prevented local content from being loaded. It's safe to call
 *  it multiple times during a local content provider's lifecycle. Every time this method is called, the Hub Framework
 *  will render any remote content that was previously loaded, or render a visualization of the error in an info view
 *  in case no content at all could be loaded.
 */
- (void)localContentProvider:(id<HUBLocalContentProvider>)contentProvider didFailLoadingWithError:(NSError *)error;

@end

/**
 *  Protocol that objects that provide local (offline) content to a Hub Framework view conform to
 *
 *  If you wish to add any local content to a view, you conform to this protocol in an object and return it from your
 *  `HUBContentProviderFactory` implementation.
 *
 *  You're free to implement your local content provider in whatever way you see fit, and it can load data both
 *  synchronously and asynchronously. It can also act as a last line of defense against remote content errors (such as
 *  network or server side failures).
 *
 *  The Hub Framework will automatically call your local content provider whenever new local content is needed,
 *  such as when a user enters a view for the first time, when a view needs to be reloaded, or if additional paginated
 *  content has been loaded. The local content phase is the last phase of loading content, so a local content provider
 *  can also be used to manipulate any remote content that was previously downloaded.
 *
 *  A local content provider has a 1:1 relationship with a view.
 */
@protocol HUBLocalContentProvider <NSObject>

/// The content provider's delegate. Don't assign this property yourself, it will be set by the Hub Framework.
@property (nonatomic, weak, nullable) id<HUBLocalContentProviderDelegate> delegate;

/**
 *  Load local content for a certain view
 *
 *  @param viewURI The view URI that this local content provider is being used for
 *
 *  The local content provider should immediately start to load content for the view, and notify its delegate when
 *  the operation was finished, or if an error was encountered. It's safe to cancel any previously unfinished local
 *  content operations at the time this method is called.
 */
- (void)loadContentForViewWithURI:(NSURL *)viewURI;

/**
 *  Load fallback content for a certain view, in case a remote content error was encountered
 *
 *  @param viewURI The view URI that this local content provider is being used for
 *  @param error The error that the remote content provider encountered
 *
 *  The Hub Framework will call this method as a last attempt to provide the user with any relevant content
 *  in case of an error. You can either choose to add the same content you normally would to the view, or add some
 *  specific content that makes sense in context of the error.
 *
 *  The local content provider should immediately start to load fallback content, and notify its delegate when the
 *  operation was finished, or if an error was encountered. It's safe to cancel any previously unfinished local content
 *  operations at the time this method is called.
 *
 *  In case no relevant fallback content can be provided, the local content provider should forward the error
 *  to its delegate, so that an error message can be displayed to the user.
 */
- (void)loadFallbackContentForViewWithURI:(NSURL *)viewURI forRemoteContentProviderError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
