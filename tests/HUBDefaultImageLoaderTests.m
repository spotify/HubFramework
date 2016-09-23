#import <XCTest/XCTest.h>

#import <UIKit/UIKit.h>

#import "HUBDefaultImageLoader.h"
#import "HUBURLSessionMock.h"
#import "HUBURLSessionDataTaskMock.h"

@interface HUBDefaultImageLoaderTests : XCTestCase <HUBImageLoaderDelegate>

@property (nonatomic, strong) HUBURLSessionMock *session;
@property (nonatomic, strong) HUBDefaultImageLoader *imageLoader;
@property (nonatomic, strong) UIImage *loadedImage;
@property (nonatomic, strong) NSURL *loadedImageURL;
@property (nonatomic, strong) NSError *loadingError;

@end

@implementation HUBDefaultImageLoaderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.session = [HUBURLSessionMock new];
    self.imageLoader = [[HUBDefaultImageLoader alloc] initWithSession:self.session];
    self.imageLoader.delegate = self;
}

#pragma mark - Tests

- (void)testLoadingImage
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.spotify.com/123"];
    CGSize const targetSize = CGSizeMake(200, 200);
    [self.imageLoader loadImageForURL:imageURL targetSize:targetSize];
    
    HUBURLSessionDataTaskMock * const dataTask = self.session.dataTasks.firstObject;
    XCTAssertTrue(dataTask.started);

    UIGraphicsBeginImageContext(targetSize);
    [[UIColor redColor] setFill];
    UIRectFill(CGRectMake(0, 0, targetSize.width, targetSize.height));
    UIImage * const image = UIGraphicsGetImageFromCurrentImageContext();

    NSData * const data = UIImagePNGRepresentation(image);
    [dataTask finishWithData:data];
    
    XCTAssertNotNil(self.loadedImage);
    XCTAssertTrue(CGSizeEqualToSize(self.loadedImage.size, image.size));
    XCTAssertEqualObjects(self.loadedImageURL, imageURL);
    XCTAssertNil(self.loadingError);
}

- (void)testImageResizing
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.spotify.com/123"];
    CGSize const targetSize = CGSizeMake(200, 200);
    [self.imageLoader loadImageForURL:imageURL targetSize:targetSize];
    
    HUBURLSessionDataTaskMock * const dataTask = self.session.dataTasks.firstObject;
    XCTAssertTrue(dataTask.started);
    
    UIGraphicsBeginImageContext(targetSize);
    [[UIColor redColor] setFill];
    UIRectFill(CGRectMake(0, 0, 100, 100));
    UIImage * const image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData * const data = UIImagePNGRepresentation(image);
    [dataTask finishWithData:data];
    
    XCTAssertNotNil(self.loadedImage);
    XCTAssertTrue(CGSizeEqualToSize(self.loadedImage.size, targetSize));
    XCTAssertEqualObjects(self.loadedImageURL, imageURL);
    XCTAssertNil(self.loadingError);
}

- (void)testNetworkErrorHandling
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.spotify.com/123"];
    CGSize const targetSize = CGSizeMake(200, 200);
    [self.imageLoader loadImageForURL:imageURL targetSize:targetSize];
    
    HUBURLSessionDataTaskMock * const dataTask = self.session.dataTasks.firstObject;
    XCTAssertTrue(dataTask.started);
    
    NSError * const error = [NSError errorWithDomain:@"com.spotify.hubFramework" code:-1 userInfo:nil];
    [dataTask failWithError:error];
    
    XCTAssertNil(self.loadedImage);
    XCTAssertEqualObjects(self.loadingError, error);
}

- (void)testInvalidImageDataProducingError
{
    NSURL * const imageURL = [NSURL URLWithString:@"https://image.spotify.com/123"];
    CGSize const targetSize = CGSizeMake(200, 200);
    [self.imageLoader loadImageForURL:imageURL targetSize:targetSize];
    
    HUBURLSessionDataTaskMock * const dataTask = self.session.dataTasks.firstObject;
    XCTAssertTrue(dataTask.started);
    
    NSData * const data = [@"Clearly not an image" dataUsingEncoding:NSUTF8StringEncoding];
    [dataTask finishWithData:data];
    
    XCTAssertNil(self.loadedImage);
    XCTAssertNotNil(self.loadingError);
}

#pragma mark - HUBImageLoaderDelegate

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didLoadImage:(UIImage *)image forURL:(NSURL *)imageURL fromCache:(BOOL)loadedFromCache
{
    XCTAssertEqual(self.imageLoader, imageLoader);
    
    self.loadedImage = image;
    self.loadedImageURL = imageURL;
}

- (void)imageLoader:(id<HUBImageLoader>)imageLoader didFailLoadingImageForURL:(NSURL *)imageURL error:(NSError *)error
{
    XCTAssertEqual(self.imageLoader, imageLoader);
    
    self.loadingError = error;
}

@end
