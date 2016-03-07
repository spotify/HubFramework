#import "HUBImageLoaderMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBImageLoaderMock ()

@property (nonatomic, strong, readonly) NSMutableSet<NSURL *> *loadedImageURLs;

@end

@implementation HUBImageLoaderMock

@synthesize delegate = _delegate;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _loadedImageURLs = [NSMutableSet new];
    }
    
    return self;
}

- (void)loadImageForURL:(NSURL *)imageURL targetSize:(CGSize)targetSize
{
    [self.loadedImageURLs addObject:imageURL];
}

- (BOOL)hasLoadedImageForURL:(NSURL *)imageURL
{
    return [self.loadedImageURLs containsObject:imageURL];
}

@end

NS_ASSUME_NONNULL_END
