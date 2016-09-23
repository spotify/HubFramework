#import "HUBDefaultImageLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBDefaultImageLoader ()

@property (nonatomic, strong, readonly) NSURLSession *session;

@end

@implementation HUBDefaultImageLoader

@synthesize delegate = _delegate;

#pragma mark - Initializer

- (instancetype)initWithSession:(NSURLSession *)session
{
    NSParameterAssert(session != nil);
    
    self = [super init];
    
    if (self) {
        _session = session;
    }
    
    return self;
}

#pragma mark - HUBImageLoader

- (void)loadImageForURL:(NSURL *)imageURL targetSize:(CGSize)targetSize
{
    __weak __typeof(self) weakSelf = self;
    
    NSDate * const startDate = [NSDate date];
    
    NSURLSessionTask * const task = [self.session dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof(self) strongSelf = weakSelf;
        id<HUBImageLoaderDelegate> const delegate = strongSelf.delegate;
        
        if (data == nil || error != nil) {
            NSError * const nonNilError = error ?: [strongSelf createErrorWithIdentifier:@"unknown"];
            [delegate imageLoader:strongSelf didFailLoadingImageForURL:imageURL error:nonNilError];
            return;
        }
        
        NSData * const nonNilData = data;
        UIImage *image = [UIImage imageWithData:nonNilData scale:[UIScreen mainScreen].scale];
        
        if (image == nil) {
            NSError * const dataError = [self createErrorWithIdentifier:@"invalidData"];
            [delegate imageLoader:strongSelf didFailLoadingImageForURL:imageURL error:dataError];
            return;
        }
        
        if (!CGSizeEqualToSize(image.size, targetSize)) {
            BOOL const imageIsJPEG = [response.MIMEType isEqualToString:@"image/jpeg"];
            UIGraphicsBeginImageContextWithOptions(targetSize, imageIsJPEG, image.scale);
            [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        BOOL const loadedFromCache = [[NSDate date] timeIntervalSinceDate:startDate] > 0.07;
        [delegate imageLoader:strongSelf didLoadImage:image forURL:imageURL fromCache:loadedFromCache];
    }];

    [task resume];
}

- (NSError *)createErrorWithIdentifier:(NSString *)identifier
{
    NSString * const domain = [NSString stringWithFormat:@"com.spotify.hubFramework.imageLoader.%@", identifier];
    return [NSError errorWithDomain:domain code:-1 userInfo:nil];
}

@end

NS_ASSUME_NONNULL_END
