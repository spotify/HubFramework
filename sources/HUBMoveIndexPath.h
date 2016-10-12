#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The @c HUBMoveIndexPath represents a movement between two separate index paths.
@interface HUBMoveIndexPath : NSObject

/**
 * Initializes a move between the two provided index paths.
 * @param fromIndexPath The index path that the item previously resided at.
 * @param toIndexPath The index path that the item is now residing at.
 */
- (instancetype)initWithFrom:(NSIndexPath *)fromIndexPath
                          to:(NSIndexPath *)toIndexPath;

/// The index path that the item previously resided at.
@property (nonatomic, strong, readonly) NSIndexPath *fromIndexPath;

/// The index path that the item is now residing at.
@property (nonatomic, strong, readonly) NSIndexPath *toIndexPath;

@end

NS_ASSUME_NONNULL_END
