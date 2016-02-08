#import "HUBJSONParsingOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONParsingOperation ()

@property (nonatomic, copy, readonly) id (^block)(id);

@end

@implementation HUBJSONParsingOperation

- (instancetype)initWithBlock:(NSArray<NSObject *> *(^)(NSObject *))block
{
    NSParameterAssert(block != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _block = block;
    
    return self;
}

- (nullable NSArray<NSObject *> *)parsedValuesForInput:(NSObject *)input
{
    NSParameterAssert(input != nil);
    return self.block(input);
}

@end

NS_ASSUME_NONNULL_END
