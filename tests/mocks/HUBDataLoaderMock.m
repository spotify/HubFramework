#import "HUBDataLoaderMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBDataLoaderMock ()

@property (nonatomic, copy, nullable, readwrite) NSURL *currentDataURL;

@end

@implementation HUBDataLoaderMock

@synthesize delegate = _delegate;

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
{
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
    }
    
    return self;
}

#pragma mark - HUBDataLoader

- (void)loadDataForURL:(NSURL *)dataURL
{
    self.currentDataURL = dataURL;
}

- (void)cancelLoadingDataForURL:(NSURL *)dataURL
{
    NSParameterAssert([self.currentDataURL isEqual:dataURL]);
    self.currentDataURL = nil;
}

@end

NS_ASSUME_NONNULL_END
