#import "HUBCollectionViewMock.h"
#import "HUBComponentCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBCollectionViewMock

- (instancetype)init
{
    UICollectionViewLayout * const layout = [UICollectionViewFlowLayout new];
    
    if (!(self = [super initWithFrame:CGRectZero collectionViewLayout:layout])) {
        return nil;
    }
    
    _cells = [NSMutableDictionary new];
    
    return self;
}

- (nullable UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath];
}

@end

NS_ASSUME_NONNULL_END
