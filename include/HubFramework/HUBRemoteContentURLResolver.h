#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that resolve remote content HTTP URLs from view URIs for a feature
 *
 *  Conform to this protocol in a custom object in case you want to utilize the Hub Framework's default
 *  remote content provider (see `HUBDefaultRemoteContentProviderFactory`), instead of writing your own.
 */
@protocol HUBRemoteContentURLResolver <NSObject>

/**
 *  Resolve a remote content HTTP URL to call for a given view URI
 *
 *  @param viewURI The view URI to resolve a remote content URL for
 *
 *  The Hub Framework's default remote content provider will call this method to resolve from where to
 *  load remote content for the view in question. Return `nil` to indicate that no remote content should
 *  be loaded for the given view URI.
 */
- (nullable NSURL *)resolveRemoteContentURLForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
