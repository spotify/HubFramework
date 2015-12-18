#import "HUBComponentModel.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked component model, for use in tests only
@interface HUBComponentModelMock : NSObject <HUBComponentModel>

/**
 *  Initialize an instance of this class with a component identifier
 *
 *  @param componentIdentifier The component identifier that the mock should have
 */
- (instancetype)initWithComponentIdentifier:(NSString *)componentIdentifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
