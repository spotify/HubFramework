#import <Foundation/Foundation.h>

@protocol HUBDataLoader;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBDataLoader`
 *
 *  You don't conform to this protocol yourself. Instead, the Hub Framework will assign an internal object
 *  that conforms to this protocol as the delegate of any data loader. You use the methods defined in this
 *  protocol to communicate a data loader's outcomes back to the framework.
 */
@protocol HUBDataLoaderDelegate <NSObject>

/**
 *  Notify the Hub Framework that a data loader finished loading
 *
 *  @param dataLoader The data loader that finished loading
 *  @param data The binary data that was downloaded
 *  @param dataURL The URL that the data was downloaded from
 */
- (void)dataLoader:(id<HUBDataLoader>)dataLoader didLoadData:(NSData *)data forURL:(NSURL *)dataURL;

/**
 *  Notify the Hub Framework that a data loader failed to load because of an error
 *
 *  @param dataLoader The data loader that failed loading
 *  @param dataURL The URL of the data that failed to load
 *  @param error The errot that was encountered
 */
- (void)dataLoader:(id<HUBDataLoader>)dataLoader didFailLoadingDataForURL:(NSURL *)dataURL error:(NSError *)error;

@end

/**
 *  Protcol that objects that load data on behalf of the Hub Framework conform to
 *
 *  The Hub Framework uses data loaders for features that don't implement their own `HUBRemoteContentProvider`,
 *  and instead opt to use the `HUBRemoteContentURLResolver` API. Data loaders are used to download binary data,
 *  which is then used to parse remote content.
 *
 *  The framework itself does not employ any caching, authentication or related data loading mechanisms, so it's
 *  up to each implementation of this protocol to handle that. Any network loading framework may be used to
 *  implement this protocol; such as `NSURLSession`, `SPTDataLoader`, or others.
 *
 *  See also `HUBDataLoaderFactory` which is used to create instances conforming to this protocol.
 */
@protocol HUBDataLoader <NSObject>

/// The data loader's delegate. Don't assign this property yourself, it will be set by the Hub Framework.
@property (nonatomic, weak, nullable) id<HUBDataLoaderDelegate> delegate;

/**
 *  Load data from a certain URL
 *
 *  @param dataURL The URL of the data to load
 *
 *  The data loader can either chose to start a download operation, or use cached data. It should notify its
 *  delegate of the success/error outcome of the operation through its delegate.
 */
- (void)loadDataForURL:(NSURL *)dataURL;

/**
 *  Cancel loading data from a certain URL
 *
 *  @param dataURL The URL of the operation to cancel
 *
 *  The Hub Framework will call this method whenever the contents of the given URL are no longer considered
 *  relevant, so the data loader is free to cancel the operation to free up resources.
 */
- (void)cancelLoadingDataForURL:(NSURL *)dataURL;

@end

NS_ASSUME_NONNULL_END
