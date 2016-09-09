#import "HUBActionMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBActionMock

#pragma mark - Initializer

- (instancetype)initWithBlock:(BOOL(^_Nullable)(id<HUBActionContext>))block
{
    self = [super init];
    
    if (self) {
        _block = [block copy];
    }
    
    return self;
}

#pragma mark - HUBAction

- (BOOL)performWithContext:(id<HUBActionContext>)context
{
    return self.block != nil ? self.block(context) : NO;
}

@end

NS_ASSUME_NONNULL_END
