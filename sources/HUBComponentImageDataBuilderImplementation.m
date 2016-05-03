#import "HUBComponentImageDataBuilderImplementation.h"

#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentImageDataJSONSchema.h"
#import "HUBIconImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentImageDataBuilderImplementation ()

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) id<HUBIconImageResolver> iconImageResolver;

@end

@implementation HUBComponentImageDataBuilderImplementation

@synthesize style = _style;
@synthesize URL = _URL;
@synthesize placeholderIconIdentifier = _placeholderIconIdentifier;
@synthesize localImage = _localImage;

#pragma mark - Initializer

- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema iconImageResolver:(id<HUBIconImageResolver>)iconImageResolver
{
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
        _iconImageResolver = iconImageResolver;
    }
    
    return self;
}

#pragma mark - HUBJSONCompatibleBuilder

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
    if (self.URL == nil && self.placeholderIconIdentifier == nil && self.localImage == nil) {
        return nil;
    }
    
    id<HUBIcon> const placeholderIcon = [self buildPlaceholderIcon];
    
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
    NSString * const placeholderIconIdentifier = self.placeholderIconIdentifier;
    
    if (placeholderIconIdentifier == nil) {
        return nil;
    }
    
    return [[HUBIconImplementation alloc] initWithIdentifier:placeholderIconIdentifier
                                               imageResolver:self.iconImageResolver
                                               isPlaceholder:YES];
}

NS_ASSUME_NONNULL_END

@end
