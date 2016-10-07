#import "HUBBlockContentOperationFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBBlockContentOperationFactory ()

@property (nonatomic, copy) NSArray<id<HUBContentOperation>> *(^block)(NSURL *);

@end

@implementation HUBBlockContentOperationFactory

#pragma mark - Initializer

- (instancetype)initWithBlock:(NSArray<id<HUBContentOperation>> *(^)(NSURL *))block
{
    NSParameterAssert(block != nil);
    
    self = [super init];
    
    if (self != nil) {
        _block = [block copy];
    }
    
    return self;
}

#pragma mark - HUBContentOperationFactory

- (NSArray<id<HUBContentOperation>> *)createContentOperationsForViewURI:(NSURL *)viewURI
{
    return self.block(viewURI);
}

@end

NS_ASSUME_NONNULL_END
