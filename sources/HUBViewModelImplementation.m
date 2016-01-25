#import "HUBViewModelImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewModelImplementation

@synthesize identifier = _identifier;
@synthesize featureIdentifier = _featureIdentifier;
@synthesize entityIdentifier = _entityIdentifier;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize headerComponentModels = _headerComponentModels;
@synthesize bodyComponentModels = _bodyComponentModels;
@synthesize extensionURL = _extensionURL;
@synthesize customData = _customData;

- (instancetype)initWithIdentifier:(NSString *)identifier featureIdentifier:(NSString *)featureIdentifier entityIdentifier:(nullable NSString *)entityIdentifier navigationBarTitle:(nullable NSString *)navigationBarTitle headerComponentModels:(NSArray<id<HUBComponentModel>> *)headerComponentModels bodyComponentModels:(NSArray<id<HUBComponentModel>> *)bodyComponentModels extensionURL:(nullable NSURL *)extensionURL customData:(NSDictionary<NSString *,NSObject *> *)customData
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _identifier = identifier;
    _featureIdentifier = featureIdentifier;
    _entityIdentifier = entityIdentifier;
    _navigationBarTitle = navigationBarTitle;
    _headerComponentModels = headerComponentModels;
    _bodyComponentModels = bodyComponentModels;
    _extensionURL = extensionURL;
    _customData = customData;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
