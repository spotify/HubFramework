#import <Foundation/Foundation.h>

@protocol HUBContentOperation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol that objects that create Hub Framework content operations conform to
 *
 *  You conform to this protocol in a custom object and pass that object when configuring your feature with
 *  the Hub Framework. Multiple content operation factories can be used for a feature, and they can also be
 *  reused in between features.
 *
 *  For more information, see `HUBContentOperation`.
 */
@protocol HUBContentOperationFactory <NSObject>

/**
 *  Create an array of content operations to use for a view with a certain URI
 *
 *  @param viewURI The URI of the view to create content operations for
 *
 *  Content operations are always used in sequence, determined by the order the content operations appear in
 *  the returned array. The array must always contain at least one object.
 */
- (NSArray<id<HUBContentOperation>> *)createContentOperationsForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
