#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class used to define predicates that evaulates whether a view URI should be handled by the Hub Framework
 *
 *  A view URI predicate is passed when registering a feature with `HUBFeatureRegistry`, and is used by the
 *  Hub Framework to determine whether it should handle a certain view URI when a view controller or view model
 *  loader is requested.
 *
 *  You can construct simple predicates that only successfully evaluates a constant view URI, or enable a tree
 *  of view URIs using a root view URI, as well as using a block or `NSPredicate` to construct complex predicates
 *  that evaluate based on any condition.
 */
@interface HUBViewURIPredicate : NSObject

/**
 *  Create a predicate that only allows a single, constant view URI
 *
 *  @param viewURI The only view URI that the predicate should qualify. Any other view URI will be disqualified.
 */
+ (HUBViewURIPredicate *)predicateWithViewURI:(NSURL *)viewURI;

/**
 *  Create a predicate that allows view URIs that have a root view URI as a prefix
 *
 *  @param rootViewURI The root view URI that the predicate should be based on. The predicate will qualify this
 *                     view URI, as well as any URI that has this one as a prefix.
 */
+ (HUBViewURIPredicate *)predicateWithRootViewURI:(NSURL *)rootViewURI;

/**
 *  Create a predicate that allows view URIs that have a root view URI as a prefix, exluding a set of view URIs
 *
 *  @param rootViewURI The root view URI that the predicate should be based on
 *  @param exludedViewURIs A set of view URIs that should be excluded from qualification, even if they match the
 *         prefix requirement set by `rootViewURI`.
 */
+ (HUBViewURIPredicate *)predicateWithRootViewURI:(NSURL *)rootViewURI
                                 excludedViewURIs:(NSSet<NSURL *> *)exludedViewURIs;

/**
 *  Create a predicate with an `NSPredicate`
 *
 *  @param predicate The predicate that the view URI predicate should be based on. The predicate should be set up
 *                   to evaluate `NSURL` instances.
 *
 *  The returned predicate will return the outcome of sending any evaluated view URI to the underlying `NSPredicate`.
 */
+ (HUBViewURIPredicate *)predicateWithPredicate:(NSPredicate *)predicate;

/**
 *  Create a predicate with a block
 *
 *  @param block The block used to evaluate view URIs
 *
 *  The returned predicate will return the outcome of sending any evaluated view URI to its block.
 */
+ (HUBViewURIPredicate *)predicateWithBlock:(BOOL(^)(NSURL *))block;

/**
 *  Initialize an instance of this class with a block
 *
 *  @param block The block used to evaluate view URIs
 */
- (instancetype)initWithBlock:(BOOL(^)(NSURL *))block NS_DESIGNATED_INITIALIZER;

/**
 *  Evaluate a view URI
 *
 *  @param viewURI The view URI that should be evaluated, based on the underlying rules of the predicate.
 */
- (BOOL)evaluateViewURI:(NSURL *)viewURI;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
