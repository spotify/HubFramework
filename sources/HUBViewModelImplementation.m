#import "HUBViewModelImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBComponentModel.h"

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
@synthesize buildDate = _buildDate;

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
        _buildDate = [NSDate date];
    }
    
    return self;
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyIdentifier] = self.identifier;
    serialization[HUBJSONKeyFeature] = self.featureIdentifier;
    serialization[HUBJSONKeyEntity] = self.entityIdentifier;
    serialization[HUBJSONKeyTitle] = self.navigationBarTitle;
    serialization[HUBJSONKeyHeader] = [self.headerComponentModel serialize];
    serialization[HUBJSONKeyBody] = [self serializedBodyComponentModels];
    serialization[HUBJSONKeyExtension] = self.extensionURL.absoluteString;
    serialization[HUBJSONKeyCustom] = self.customData;
    
    return [serialization copy];
}

- (nullable NSArray<NSDictionary<NSString *, NSObject *> *> *)serializedBodyComponentModels
{
    NSArray<id<HUBComponentModel>> * const bodyComponentModels = self.bodyComponentModels;
    
    if (bodyComponentModels.count == 0) {
        return nil;
    }
    
    NSMutableArray<NSDictionary<NSString *, NSObject *> *> * const serializedModels = [NSMutableArray new];
    
    for (id<HUBComponentModel> const model in bodyComponentModels) {
        [serializedModels addObject:[model serialize]];
    }
    
    return [serializedModels copy];
}

@end

NS_ASSUME_NONNULL_END
