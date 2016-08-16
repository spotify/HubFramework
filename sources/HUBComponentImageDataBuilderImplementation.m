#import "HUBComponentImageDataBuilderImplementation.h"

#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentImageDataJSONSchema.h"
#import "HUBIconImplementation.h"
#import "HUBUtilities.h"
#import "HUBImplementationMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentImageDataBuilderImplementation ()

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;

@end

@implementation HUBComponentImageDataBuilderImplementation

#pragma mark - Property synthesization

@synthesize style = _style;
@synthesize URL = _URL;
@synthesize placeholderIconIdentifier = _placeholderIconIdentifier;
@synthesize localImage = _localImage;
@synthesize modificationDelegate = _modificationDelegate;

#pragma mark - Modification tracking

HUB_TRACK_MODIFICATIONS(_URL, setURL:, nullable)
HUB_TRACK_MODIFICATIONS(_placeholderIconIdentifier, setPlaceholderIconIdentifier:, nullable)
HUB_TRACK_MODIFICATIONS(_localImage, setLocalImage:, nullable)

#pragma mark - Initializer

- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
        _iconImageResolver = iconImageResolver;
    }
    
    return self;
}

#pragma mark - HUBJSONCompatibleBuilder

- (nullable NSError *)addJSONData:(NSData *)JSONData
{
    return HUBAddJSONDataToBuilder(JSONData, self);
}

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    id<HUBComponentImageDataJSONSchema> const imageDataSchema = self.JSONSchema.componentImageDataSchema;
    
    self.style = HUBComponentImageStyleRectangular;
    self.URL = [imageDataSchema.URLPath URLFromJSONDictionary:dictionary];
    self.placeholderIconIdentifier = [imageDataSchema.placeholderIconIdentifierPath stringFromJSONDictionary:dictionary];
    
    NSString * const styleString = [imageDataSchema.styleStringPath stringFromJSONDictionary:dictionary];
    
    if (styleString != nil) {
        NSNumber * const styleNumber = imageDataSchema.styleStringMap[styleString];
        
        if (styleNumber != nil) {
            NSInteger const potentialImageStyle = styleNumber.integerValue;
            
            switch (potentialImageStyle) {
                case HUBComponentImageStyleNone:
                case HUBComponentImageStyleRectangular:
                case HUBComponentImageStyleCircular:
                    self.style = potentialImageStyle;
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    HUBComponentImageDataBuilderImplementation * const copy = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                                   iconImageResolver:self.iconImageResolver];
    
    copy.style = self.style;
    copy.URL = self.URL;
    copy.placeholderIconIdentifier = self.placeholderIconIdentifier;
    copy.localImage = self.localImage;
    
    return copy;
}

#pragma mark - API

- (nullable HUBComponentImageDataImplementation *)buildWithIdentifier:(nullable NSString *)identifier type:(HUBComponentImageType)type
{
    id<HUBIcon> const placeholderIcon = [self buildPlaceholderIcon];
    
    if (self.URL == nil && self.localImage == nil && placeholderIcon == nil) {
        return nil;
    }
    
    return [[HUBComponentImageDataImplementation alloc] initWithIdentifier:identifier
                                                                      type:type
                                                                     style:self.style
                                                                       URL:self.URL
                                                           placeholderIcon:placeholderIcon
                                                                localImage:self.localImage];
}

#pragma mark - Private utilities

- (nullable id<HUBIcon>)buildPlaceholderIcon
{
    id<HUBIconImageResolver> const iconImageResolver = self.iconImageResolver;
    
    if (iconImageResolver == nil) {
        return nil;
    }
    
    NSString * const placeholderIconIdentifier = self.placeholderIconIdentifier;
    
    if (placeholderIconIdentifier == nil) {
        return nil;
    }
    
    return [[HUBIconImplementation alloc] initWithIdentifier:placeholderIconIdentifier
                                               imageResolver:iconImageResolver
                                               isPlaceholder:YES];
}

NS_ASSUME_NONNULL_END

@end
