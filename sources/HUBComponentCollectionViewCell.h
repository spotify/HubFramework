#import <UIKit/UIKit.h>

@protocol HUBComponent;

NS_ASSUME_NONNULL_BEGIN

/// Collection view cell that wraps a `HUBComponent` and its view
@interface HUBComponentCollectionViewCell : UICollectionViewCell

/**
 *  The component that the collection view cell is currently wrapping
 *
 *  Setting this property removes any previously wrapped component’s view from this cell. The new component’s
 *  view will then be loaded (if needed) and added to the cell's content view.
 */
@property (nonatomic, strong, nullable) id<HUBComponent> component;

@end

NS_ASSUME_NONNULL_END
