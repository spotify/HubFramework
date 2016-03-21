#import "HUBRemoteContentURLResolverMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBRemoteContentURLResolverMock ()

@property (nonatomic, strong, readonly) NSMutableSet<NSURL *> *mutableViewURIs;

@end

@implementation HUBRemoteContentURLResolverMock

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _mutableViewURIs = [NSMutableSet new];
    }
    
    return self;
}

- (NSSet<NSURL *> *)viewURIs
{
    return [self.mutableViewURIs copy];
}

#pragma mark - HUBRemoteContentURLResolver

- (nullable NSURL *)resolveRemoteContentURLForViewURI:(NSURL *)viewURI
{
    [self.mutableViewURIs addObject:viewURI];
    return self.contentURL;
}

@end

NS_ASSUME_NONNULL_END
