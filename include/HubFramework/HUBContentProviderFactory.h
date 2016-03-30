#import <Foundation/Foundation.h>

@protocol HUBContentProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol that objects that create Hub Framework content providers conform to
 *
 *  You conform to this protocol in a custom object and pass that object when configuring your feature with
 *  the Hub Framework. Multiple content provider factories can be used for a feature, and they can also be
 *  reused in between features.
 *
 *  For more information, see `HUBContentProvider`.
 */
@protocol HUBContentProviderFactory <NSObject>

/**
 *  Create an array of content providers to use for a view with a certain URI
 *
 *  @param viewURI The URI of the view to create content providers for
 *
 *  Content providers are always used in sequence, determined by the order the content providers appear in
 *  the returned array. The array must always contain at least one object.
 */
- (NSArray<id<HUBContentProvider>> *)createContentProvidersForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
