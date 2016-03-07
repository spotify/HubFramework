#import "HUBJSONParsingOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONParsingOperation ()

@property (nonatomic, copy, readonly) NSArray<NSObject *> * _Nullable (^block)(NSObject *);

@end

@implementation HUBJSONParsingOperation

- (instancetype)initWithBlock:(NSArray<NSObject *> * _Nullable (^)(NSObject *))block
{
    NSParameterAssert(block != nil);
    
    self = [super init];
    
    if (self) {
        _block = [block copy];
    }
    
    return self;
}

- (nullable NSArray<NSObject *> *)parsedValuesForInput:(NSObject *)input
{
    NSParameterAssert(input != nil);
    return self.block(input);
}

@end

NS_ASSUME_NONNULL_END
