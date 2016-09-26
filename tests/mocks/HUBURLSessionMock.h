#import <Foundation/Foundation.h>

@class HUBURLSessionDataTaskMock;

NS_ASSUME_NONNULL_BEGIN

/// Mocked URL session, for use in unit tests only
@interface HUBURLSessionMock : NSURLSession

/// The data tasks that this session has created
@property (nonatomic, strong, readonly) NSArray<HUBURLSessionDataTaskMock *> *dataTasks;

@end

NS_ASSUME_NONNULL_END
