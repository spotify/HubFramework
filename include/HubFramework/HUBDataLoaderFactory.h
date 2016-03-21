#import <Foundation/Foundation.h>

@protocol HUBDataLoader;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol that objects that create data loaders for use with the Hub Framework conform to
 *
 *  You conform to this protocol in a custom object and pass that object when setting up `HUBManager`.
 *  The Hub Framework will then use the factory to create a data loader for each view model loader that
 *  does not have a custom `HUBRemoteContentProvider`.
 *
 *  See `HUBDataLoader` for more information.
 */
@protocol HUBDataLoaderFactory <NSObject>

/**
 *  Create a data loader for a feature with a given identifier
 *
 *  @param featureIdentifier The identifier of the feature that the data loader will be used for. This
 *         identifier can be used to measure network usage on a feature basis, or perform other types of
 *         logging or analytics.
 */
- (id<HUBDataLoader>)createDataLoaderForFeatureWithIdentifier:(NSString *)featureIdentifier;

@end

NS_ASSUME_NONNULL_END
