#import "HUBComponentModelImplementation.h"

#import "HUBComponentIdentifier.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONKeys.h"
#import "HUBViewModel.h"
#import "HUBUtilities.h"
#import "HUBIcon.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentModelImplementation

@synthesize identifier = _identifier;
@synthesize index = _index;
@synthesize componentIdentifier = _componentIdentifier;
@synthesize componentCategory = _componentCategory;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize accessoryTitle = _accessoryTitle;
@synthesize descriptionText = _descriptionText;
@synthesize mainImageData = _mainImageData;
@synthesize backgroundImageData = _backgroundImageData;
@synthesize customImageData = _customImageData;
@synthesize icon = _icon;
@synthesize targetURL = _targetURL;
@synthesize targetInitialViewModel = _targetInitialViewModel;
@synthesize metadata = _metadata;
@synthesize loggingData = _loggingData;
@synthesize customData = _customData;
@synthesize childComponentModels = _childComponentModels;

- (instancetype)initWithIdentifier:(NSString *)identifier
                             index:(NSUInteger)index
               componentIdentifier:(HUBComponentIdentifier *)componentIdentifier
                 componentCategory:(HUBComponentCategory *)componentCategory
                             title:(nullable NSString *)title
                          subtitle:(nullable NSString *)subtitle
                    accessoryTitle:(nullable NSString *)accessoryTitle
                   descriptionText:(nullable NSString *)descriptionText
                     mainImageData:(nullable id<HUBComponentImageData>)mainImageData
               backgroundImageData:(nullable id<HUBComponentImageData>)backgroundImageData
                   customImageData:(NSDictionary<NSString *, id<HUBComponentImageData>> *)customImageData
                              icon:(nullable id<HUBIcon>)icon
                         targetURL:(nullable NSURL *)targetURL
            targetInitialViewModel:(nullable id<HUBViewModel>)targetInitialViewModel
                          metadata:(nullable NSDictionary<NSString *, NSObject *> *)metadata
                       loggingData:(nullable NSDictionary<NSString *, NSObject *> *)loggingData
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
              childComponentModels:(nullable NSArray<id<HUBComponentModel>> *)childComponentModels
{
    NSParameterAssert(identifier != nil);
    NSParameterAssert(componentIdentifier != nil);
    NSParameterAssert(componentCategory != nil);
    NSParameterAssert(customImageData != nil);
    
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _componentIdentifier = [componentIdentifier copy];
        _componentCategory = [componentCategory copy];
        _index = index;
        _title = [title copy];
        _subtitle = [subtitle copy];
        _accessoryTitle = [accessoryTitle copy];
        _descriptionText = [descriptionText copy];
        _mainImageData = mainImageData;
        _backgroundImageData = backgroundImageData;
        _customImageData = customImageData;
        _icon = icon;
        _targetURL = [targetURL copy];
        _targetInitialViewModel = targetInitialViewModel;
        _metadata = metadata;
        _loggingData = loggingData;
        _customData = customData;
        _childComponentModels = childComponentModels;
    }
    
    return self;
}

#pragma mark - NSObject

- (nullable id)valueForKey:(NSString *)key
{
    // For some reason KVC won't work with this property name, so this workaround is required
    if ([key isEqualToString:@"componentCategory"]) {
        return self.componentCategory;
    }
    
    return [super valueForKey:key];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBComponentModel with contents: %@", HUBSerializeToString(self)];
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> const * serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyIdentifier] = self.identifier;
    serialization[HUBJSONKeyComponent] = [self serializedComponentData];
    serialization[HUBJSONKeyText] = [self serializedTextData];
    serialization[HUBJSONKeyImages] = [self serializedImageData];
    serialization[HUBJSONKeyTarget] = [self serializedTargetData];
    serialization[HUBJSONKeyMetadata] = self.metadata;
    serialization[HUBJSONKeyLogging] = self.loggingData;
    serialization[HUBJSONKeyCustom] = self.customData;
    serialization[HUBJSONKeyChildren] = [self serializedChildComponentModels];
    
    return [serialization copy];
}

#pragma mark - HUBComponentModel

- (nullable id<HUBComponentModel>)childComponentModelAtIndex:(NSUInteger)childIndex
{
    if (childIndex >= self.childComponentModels.count) {
        return nil;
    }
    
    return self.childComponentModels[childIndex];
}

#pragma mark - Private utilities

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedComponentData
{
    return @{
        HUBJSONKeyIdentifier: self.componentIdentifier.identifierString,
        HUBJSONKeyCategory: self.componentCategory
    };
}

- (nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedTextData
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyTitle] = self.title;
    serialization[HUBJSONKeySubtitle] = self.subtitle;
    serialization[HUBJSONKeyAccessory] = self.accessoryTitle;
    serialization[HUBJSONKeyDescription] = self.descriptionText;
    
    if (serialization.count == 0) {
        return nil;
    }
    
    return [serialization copy];
}

- (nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedImageData
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyMain] = [self.mainImageData serialize];
    serialization[HUBJSONKeyBackground] = [self.backgroundImageData serialize];
    serialization[HUBJSONKeyIcon] = self.icon.identifier;
    
    NSMutableDictionary * const customImageDataDictionary = [NSMutableDictionary new];
    
    for (NSString * const imageIdentifier in self.customImageData) {
        customImageDataDictionary[imageIdentifier] = [self.customImageData[imageIdentifier] serialize];
    }
    
    if (customImageDataDictionary.count > 0) {
        serialization[HUBJSONKeyCustom] = [customImageDataDictionary copy];
    }
    
    if (serialization.count == 0) {
        return nil;
    }
    
    return [serialization copy];
}

- (nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedTargetData
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyURI] = self.targetURL.absoluteString;
    serialization[HUBJSONKeyView] = [self.targetInitialViewModel serialize];
    
    if (serialization.count == 0) {
        return nil;
    }
                  
    return [serialization copy];
}

- (nullable NSArray<NSDictionary<NSString *, NSObject<NSCoding> *> *> *)serializedChildComponentModels
{
    NSArray<id<HUBComponentModel>> * const childComponentModels = self.childComponentModels;
    
    if (childComponentModels.count == 0) {
        return nil;
    }
    
    NSMutableArray<NSDictionary<NSString *, NSObject<NSCoding> *> *> * const serializedModels = [NSMutableArray new];
    
    for (id<HUBComponentModel> const model in childComponentModels) {
        [serializedModels addObject:[model serialize]];
    }
    
    return [serializedModels copy];
}

@end

NS_ASSUME_NONNULL_END
