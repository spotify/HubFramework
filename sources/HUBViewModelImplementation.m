#import "HUBViewModelImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBComponentModel.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewModelImplementation

@synthesize identifier = _identifier;
@synthesize featureIdentifier = _featureIdentifier;
@synthesize viewURI = _viewURI;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize headerComponentModel = _headerComponentModel;
@synthesize bodyComponentModels = _bodyComponentModels;
@synthesize overlayComponentModels = _overlayComponentModels;
@synthesize extensionURL = _extensionURL;
@synthesize customData = _customData;
@synthesize buildDate = _buildDate;

- (instancetype)initWithIdentifier:(NSString *)identifier
                 featureIdentifier:(NSString *)featureIdentifier
                           viewURI:(NSURL *)viewURI
                navigationBarTitle:(nullable NSString *)navigationBarTitle
              headerComponentModel:(nullable id<HUBComponentModel>)headerComponentModel
               bodyComponentModels:(NSArray<id<HUBComponentModel>> *)bodyComponentModels
            overlayComponentModels:(NSArray<id<HUBComponentModel>> *)overlayComponentModels
                      extensionURL:(nullable NSURL *)extensionURL
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
{
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _featureIdentifier = [featureIdentifier copy];
        _viewURI = [viewURI copy];
        _navigationBarTitle = [navigationBarTitle copy];
        _headerComponentModel = headerComponentModel;
        _bodyComponentModels = bodyComponentModels;
        _overlayComponentModels = overlayComponentModels;
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
    serialization[HUBJSONKeyTitle] = self.navigationBarTitle;
    serialization[HUBJSONKeyHeader] = [self.headerComponentModel serialize];
    serialization[HUBJSONKeyBody] = [self serializeComponentModels:self.bodyComponentModels];
    serialization[HUBJSONKeyOverlays] = [self serializeComponentModels:self.overlayComponentModels];
    serialization[HUBJSONKeyExtension] = self.extensionURL.absoluteString;
    serialization[HUBJSONKeyCustom] = self.customData;
    
    return [serialization copy];
}

- (nullable NSArray<NSDictionary<NSString *, NSObject *> *> *)serializeComponentModels:(NSArray<id<HUBComponentModel>> *)componentModels
{
    if (componentModels.count == 0) {
        return nil;
    }
    
    NSMutableArray<NSDictionary<NSString *, NSObject *> *> * const serializedModels = [NSMutableArray new];
    
    for (id<HUBComponentModel> const model in componentModels) {
        [serializedModels addObject:[model serialize]];
    }
    
    return [serializedModels copy];
}

@end

NS_ASSUME_NONNULL_END
