#import "HUBDataLoader.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked data loader, for use in tests only
@interface HUBDataLoaderMock : NSObject <HUBDataLoader>

/// The feature identifier that the data loader is associated with
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/// The current URL that the data loader is acting like its loading data from
@property (nonatomic, copy, nullable, readonly) NSURL *currentDataURL;

/**
 *  Initialize an instance of this class with a feature identifier
 *
 *  @param featureIdentifier The identifier of the feature that the data loader should be associated with
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
