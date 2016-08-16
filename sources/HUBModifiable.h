#import <Foundation/Foundation.h>

@protocol HUBModifiable;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol for `HUBModifiable` types, used to track modification statuses of objects
@protocol HUBModificationDelegate <NSObject>

/**
 *  Notify the delegate that an object was modified
 *
 *  @param modifiable The object that was modified
 *
 *  Every object conforming to `HUBModifiable` should send this message to its `modificationDelegate`
 *  whenever a property that alters its modification status was modified.
 */
- (void)modifiableWasModified:(id<HUBModifiable>)modifiable;

@end

/// Protocol adopted by types that can have their modification status tracked by a delegate
@protocol HUBModifiable <NSObject>

/// The delegate that will track the object's modification status. See `HUBModificationDelegate`.
@property (nonatomic, weak, nullable) id<HUBModificationDelegate> modificationDelegate;

@end

NS_ASSUME_NONNULL_END
