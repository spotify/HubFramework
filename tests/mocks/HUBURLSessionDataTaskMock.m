#import "HUBURLSessionDataTaskMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBURLSessionDataTaskMock ()

@property (nonatomic, copy, readonly) HUBURLSessionDataTaskMockCompletionHandler completionHandler;
@property (nonatomic, assign, readwrite) BOOL started;

@end

@implementation HUBURLSessionDataTaskMock

#pragma mark - Initializer

- (instancetype)initWithCompletionHandler:(HUBURLSessionDataTaskMockCompletionHandler)completionHandler
{
    NSParameterAssert(completionHandler != nil);
    
    self = [super init];
    
    if (self) {
        _completionHandler = [completionHandler copy];
    }
    
    return self;
}

#pragma mark - NSURLSessionDataTask

- (void)resume
{
    self.started = YES;
}

#pragma mark - API

- (void)finishWithData:(NSData *)data
{
    self.completionHandler(data, nil, nil);
}

- (void)failWithError:(NSError *)error
{
    self.completionHandler(nil, nil, error);
}

@end

NS_ASSUME_NONNULL_END
