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
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _featureIdentifier = [featureIdentifier copy];
        _entityIdentifier = [entityIdentifier copy];
        _navigationBarTitle = [navigationBarTitle copy];
        _headerComponentModel = headerComponentModel;
        _bodyComponentModels = bodyComponentModels;
        _extensionURL = [extensionURL copy];
        _customData = customData;
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
