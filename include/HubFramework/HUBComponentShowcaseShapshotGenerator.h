#import <UIKIt/UIKit.h>

/**
 *  Protocol defining the public API of an object that can generate showcase snapshots
 *
 *  Use this API to generate snapshot images of components, that can be used in showcases
 *  or tooling associated with the Hub Framework. Normally, you don't interact with it
 *  in production code.
 *
 *  You don't conform to this protocol yourself, instead request an instance conforming
 *  to it from the application's `HUBComponentShowcaseManager`.
 */
@protocol HUBComponentShowcaseSnapshotGenerator <NSObject>

/**
 *  Generate a snapshot of the component that this object represents
 *
 *  @param containerViewSize The size of the container view that the component should
 *         be simulated to be added in. This will be taken into account when calculating
 *         the size of the component's view and thus the snapshot.
 */
- (UIImage *)generateShowcaseSnapshotForContainerViewSize:(CGSize)containerViewSize;

@end
