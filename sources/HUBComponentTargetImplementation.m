#import "HUBComponentTargetImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentTargetImplementation

@synthesize URI = _URI;
@synthesize initialViewModel = _initialViewModel;
@synthesize customData = _customData;

#pragma mark - Initializer

- (instancetype)initWithURI:(nullable NSURL *)URI
           initialViewModel:(nullable id<HUBViewModel>)initialViewModel
                 customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
{
    self = [super init];
    
    if (self) {
        _URI = [URI copy];
        _initialViewModel = initialViewModel;
        _customData = [customData copy];
    }
    
    return self;
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    
    serialization[HUBJSONKeyURI] = self.URI.absoluteString;
    serialization[HUBJSONKeyView] = [self.initialViewModel serialize];
    serialization[HUBJSONKeyCustom] = self.customData;
    
    return [serialization copy];
}

@end

NS_ASSUME_NONNULL_END
