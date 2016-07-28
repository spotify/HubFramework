#import "HUBComponentResizeObservingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentResizeObservingView ()

@property (nonatomic, assign) CGSize previousSize;
@property (nonatomic, weak, nullable) UIView *previousSuperview;

@end

@implementation HUBComponentResizeObservingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.previousSize = frame.size;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.userInteractionEnabled = NO;
        self.hidden = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(self.previousSize, self.frame.size)) {
        return;
    }
    
    self.previousSize = self.frame.size;
    [self.delegate resizeObservingViewDidResize:self];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    // This prevents accidental removal of the view by an API user
    if (self.superview == nil) {
        [self.previousSuperview addSubview:self];
    } else {
        self.previousSuperview = self.superview;
    }
}

@end

NS_ASSUME_NONNULL_END
