#import "HUBComponentImageDataBuilderImplementation.h"

#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentImageDataJSONSchema.h"
#import "HUBIconImplementation.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentImageDataBuilderImplementation ()

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;

@end

@implementation HUBComponentImageDataBuilderImplementation

#pragma mark - Property synthesization

@synthesize URL = _URL;
@synthesize placeholderIconIdentifier = _placeholderIconIdentifier;
@synthesize localImage = _localImage;

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
    
    NSURL * const URL = [imageDataSchema.URLPath URLFromJSONDictionary:dictionary];
    
    if (URL != nil) {
        self.URL = URL;
    }
    
    NSString * const placeholderIconIdentifier = [imageDataSchema.placeholderIconIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (placeholderIconIdentifier != nil) {
        self.placeholderIconIdentifier = placeholderIconIdentifier;
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    HUBComponentImageDataBuilderImplementation * const copy = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                                   iconImageResolver:self.iconImageResolver];
    
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
