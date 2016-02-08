#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol that can be used as an override point, to disqualify certain view URIs for a feature
 *
 *  By default, any view URI that has a feature's `rootViewURI` as a prefix is associated with that feature.
 *  By implementing this protocol in an object, and supplying it as part of a feature's `HUBFeatureConfiguration`
 *  object, you can override this behavior and return `NO` for certain view URIs.
 */
@protocol HUBViewURIQualifier <NSObject>

/**
 *  Qualify a certain view URI
 *
 *  @param viewURI The view URI to qualify
 *
 *  @return `YES` if the Hub Framework should go ahead and associate the view URI with the feature that is using
 *  this view URI qualifier, or `NO` to prevent that from happening.
 */
- (BOOL)qualifyViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
