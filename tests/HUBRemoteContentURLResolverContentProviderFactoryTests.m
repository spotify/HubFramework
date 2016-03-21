#import <XCTest/XCTest.h>

#import "HUBRemoteContentURLResolverContentProviderFactory.h"
#import "HUBRemoteContentURLResolverMock.h"
#import "HUBDataLoaderFactoryMock.h"
#import "HUBDataLoaderMock.h"

@interface HUBRemoteContentURLResolverContentProviderFactoryTests : XCTestCase

@property (nonatomic, strong) HUBRemoteContentURLResolverMock *URLResolver;
@property (nonatomic, copy) NSString *featureIdentifier;
@property (nonatomic, strong) HUBDataLoaderFactoryMock *dataLoaderFactory;
@property (nonatomic, strong) HUBRemoteContentURLResolverContentProviderFactory *contentProviderFactory;

@end

@implementation HUBRemoteContentURLResolverContentProviderFactoryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.URLResolver = [HUBRemoteContentURLResolverMock new];
    self.featureIdentifier = @"feature";
    self.dataLoaderFactory = [HUBDataLoaderFactoryMock new];
    self.contentProviderFactory = [[HUBRemoteContentURLResolverContentProviderFactory alloc] initWithURLResolver:self.URLResolver
                                                                                               featureIdentifier:self.featureIdentifier
                                                                                               dataLoaderFactory:self.dataLoaderFactory];
}

#pragma mark - Tests

- (void)testDataLoaderWithCorrectFeatureIdentifierUsed
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    [self.contentProviderFactory createRemoteContentProviderForViewURI:viewURI];
    XCTAssertEqual(self.dataLoaderFactory.lastCreatedDataLoader.featureIdentifier, self.featureIdentifier);
}

@end
