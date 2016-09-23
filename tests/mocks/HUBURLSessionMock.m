#import "HUBURLSessionMock.h"
#import "HUBURLSessionDataTaskMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBURLSessionMock ()

@property (nonatomic, strong, readonly) NSMutableArray<HUBURLSessionDataTaskMock *> *mutableDataTasks;

@end

@implementation HUBURLSessionMock

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _mutableDataTasks = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Property overrides

- (NSArray<HUBURLSessionDataTaskMock *> *)dataTasks
{
    return [self.mutableDataTasks copy];
}

#pragma mark - NSURLSession

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler
{
    HUBURLSessionDataTaskMock * const task = [[HUBURLSessionDataTaskMock alloc] initWithCompletionHandler:completionHandler];
    [self.mutableDataTasks addObject:task];
    return task;
}

@end

NS_ASSUME_NONNULL_END
