#import "HUBContentProviderFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBContentProviderFactoryMock ()

@property (nonatomic, strong, readonly) NSArray<id<HUBContentProvider>> *contentProviders;

@end

@implementation HUBContentProviderFactoryMock

- (instancetype)initWithContentProviders:(NSArray<id<HUBContentProvider>> *)contentProviders
{
    self = [super init];
    
    if (self) {
        _contentProviders = contentProviders;
    }
    
    return self;
}

#pragma mark - HUBContentProviderFactory

- (NSArray<id<HUBContentProvider>> *)createContentProvidersForViewURI:(NSURL *)viewURI
{
    return self.contentProviders;
}

@end

NS_ASSUME_NONNULL_END
