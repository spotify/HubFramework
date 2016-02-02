#import "HUBViewURIQualifier.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked view URI qualifier, for use in tests only
@interface HUBViewURIQualifierMock : NSObject <HUBViewURIQualifier>

/**
 *  Initialize an instance of this class
 *
 *  @param disqualifiedViewURIs An array of view URIs to disqualify
 */
- (instancetype)initWithDisqualifiedViewURIs:(NSArray<NSURL *> *)disqualifiedViewURIs NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
