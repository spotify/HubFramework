#import "HUBViewModelImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewModelImplementation

@synthesize identifier = _identifier;
@synthesize featureIdentifier = _featureIdentifier;
@synthesize entityIdentifier = _entityIdentifier;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize headerComponentModel = _headerComponentModel;
@synthesize bodyComponentModels = _bodyComponentModels;
@synthesize extensionURL = _extensionURL;
@synthesize customData = _customData;

- (instancetype)initWithIdentifier:(NSString *)identifier
                 featureIdentifier:(NSString *)featureIdentifier
                  entityIdentifier:(nullable NSString *)entityIdentifier
                navigationBarTitle:(nullable NSString *)navigationBarTitle
              headerComponentModel:(nullable id<HUBComponentModel>)headerComponentModel
               bodyComponentModels:(NSArray<id<HUBComponentModel>> *)bodyComponentModels
                      extensionURL:(nullable NSURL *)extensionURL
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _identifier = identifier;
    _featureIdentifier = featureIdentifier;
    _entityIdentifier = entityIdentifier;
    _navigationBarTitle = navigationBarTitle;
    _headerComponentModel = headerComponentModel;
    _bodyComponentModels = bodyComponentModels;
    _extensionURL = extensionURL;
    _customData = customData;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
