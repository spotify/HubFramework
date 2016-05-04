#import "HUBContentOperationFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBContentOperationFactoryMock

- (instancetype)initWithContentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
{
    self = [super init];
    
    if (self) {
        _contentOperations = contentOperations;
    }
    
    return self;
}

#pragma mark - HUBContentOperationFactory

- (NSArray<id<HUBContentOperation>> *)createContentOperationsForViewURI:(NSURL *)viewURI
{
    return self.contentOperations;
}

@end

NS_ASSUME_NONNULL_END
