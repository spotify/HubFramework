#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Factory used to create collection views for use in a `HUBViewController`
@interface HUBCollectionViewFactory : NSObject

/// Create a view controller. It will be setup with an appropritate layout.
- (UICollectionView *)createCollectionView;

@end

NS_ASSUME_NONNULL_END
