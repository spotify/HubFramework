#import "HUBViewModelImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBComponentModel.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewModelImplementation

@synthesize identifier = _identifier;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize headerComponentModel = _headerComponentModel;
@synthesize bodyComponentModels = _bodyComponentModels;
@synthesize overlayComponentModels = _overlayComponentModels;
@synthesize extensionURL = _extensionURL;
@synthesize customData = _customData;
@synthesize buildDate = _buildDate;

#pragma mark - HUBAutoEquatable

+ (nullable NSSet<NSString *> *)ignoredAutoEquatablePropertyNames
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(buildDate))];
}

#pragma mark - Initializer

- (instancetype)initWithIdentifier:(nullable NSString *)identifier
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

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBViewModel with contents: %@", HUBSerializeToString(self)];
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyIdentifier] = self.identifier;
    serialization[HUBJSONKeyTitle] = self.navigationBarTitle;
    serialization[HUBJSONKeyHeader] = [self.headerComponentModel serialize];
    serialization[HUBJSONKeyBody] = [self serializeComponentModels:self.bodyComponentModels];
    serialization[HUBJSONKeyOverlays] = [self serializeComponentModels:self.overlayComponentModels];
    serialization[HUBJSONKeyExtension] = self.extensionURL.absoluteString;
    serialization[HUBJSONKeyCustom] = self.customData;
    
    return [serialization copy];
}

#pragma mark - Private utilities

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
