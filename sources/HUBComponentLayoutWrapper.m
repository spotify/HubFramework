#import "HUBComponentLayoutWrapper.h"

#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentLayoutWrapper ()

@property (nonatomic, strong, readonly) id<HUBComponent> component;

@end

@implementation HUBComponentLayoutWrapper

@synthesize identifier = _identifier;
@synthesize model = _model;

- (instancetype)initWithComponent:(id<HUBComponent>)component model:(id<HUBComponentModel>)model
{
    self = [super init];
    
    if (self) {
        _identifier = [NSUUID UUID];
        _component = component;
        _model = model;
    }
    
    return self;
}

#pragma mark - HUBComponentWrapper

- (UIView *)view
{
    return HUBComponentLoadViewIfNeeded(self.component);
}

- (CGSize)preferredViewSizeForContainerViewSize:(CGSize)containerViewSize
{
    return [self.component preferredViewSizeForDisplayingModel:self.model containerViewSize:containerViewSize];
}

- (void)prepareForReuse
{
    // No-op
}

@end

NS_ASSUME_NONNULL_END
