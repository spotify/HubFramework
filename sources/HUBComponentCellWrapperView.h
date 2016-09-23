#import <UIKit/UIKit.h>

/**
 *  View that is used to wrap component views that are implemented as cells
 *
 *  When a component choses to implement its `view` as either a `UICollectionViewCell` or
 *  `UITableViewCell`, this view is used to wrap that view before its added as part of the
 *  container view. The reason for this is to work around a UIKit behavior where it will
 *  try to perform selection on the component cell, instead of the cell that is managed by
 *  the Hub Framework - resulting in an untappable view.
 *
 *  The work around is achieved by returning NO from `pointInside:withEvent:` from this view
 *  and then forwarding all touch handling events to the component from the container view
 *  collection view cell.
 */
@interface HUBComponentCellWrapperView : UIView

/// The component view to wrap. Setting this property will add the view as a subview.
@property (nonatomic, strong, nullable) UIView *componentView;

@end
