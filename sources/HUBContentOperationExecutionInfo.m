#import "HUBContentOperationExecutionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBContentOperationExecutionInfo

- (instancetype)initWithContentOperationIndex:(NSUInteger)contentOperationIndex
                                executionMode:(HUBContentOperationExecutionMode)executionMode
{
    self = [super init];
    
    if (self) {
        _contentOperationIndex = contentOperationIndex;
        _executionMode = executionMode;
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
