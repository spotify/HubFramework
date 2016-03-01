#import <UIKit/UIKit.h>

@class HUBComponentWrapper;

NS_ASSUME_NONNULL_BEGIN

/// Collection view cell that performs the rendering of a `HUBComponent` and its view
@interface HUBComponentCollectionViewCell : UICollectionViewCell

/**
 *  The wrapper of the current component that the cell is for
 *
 *  Setting this property removes any previous component’s view from this cell. The new component’s
 *  view will then be loaded (if needed) and added to the cell's content view.
 */
@property (nonatomic, strong, nullable) HUBComponentWrapper *componentWrapper;

@end

NS_ASSUME_NONNULL_END
