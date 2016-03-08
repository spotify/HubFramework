#import "HUBComponent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extended Hub component protocol that adds the ability to observe content offset changes
 *
 *  Use this protocol if your component needs to react to content offset changes in the view that it
 *  is being displayed in. See `HUBComponent` for more info.
 */
@protocol HUBComponentContentOffsetObserver <HUBComponent>

/**
 *  Update the component’s view in reaction to that the content offset of the container view changed
 *
 *  @param contentOffset The new content offset of the container view
 *
 *  The Hub Framework will send this message every time that the content offset changed in the main
 *  container view. This is equivalent to `UIScrollView scrollViewDidScroll:`.
 */
- (void)updateViewForChangedContentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
