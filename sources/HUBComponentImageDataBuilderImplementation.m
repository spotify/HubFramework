#import "HUBComponentImageDataBuilderImplementation.h"

#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentImageDataJSONSchema.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentImageDataBuilderImplementation ()

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;

@end

@implementation HUBComponentImageDataBuilderImplementation

@synthesize style = _style;
@synthesize URL = _URL;
@synthesize placeholderIdentifier = _placeholderIdentifier;
@synthesize localImage = _localImage;

#pragma mark - Initializer

- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
{
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
    }
    
    return self;
}

#pragma mark - HUBJSONCompatibleBuilder

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    id<HUBComponentImageDataJSONSchema> const imageDataSchema = self.JSONSchema.componentImageDataSchema;
    
    self.style = HUBComponentImageStyleRectangular;
    self.URL = [imageDataSchema.URLPath URLFromJSONDictionary:dictionary];
    self.placeholderIdentifier = [imageDataSchema.placeholderIdentifierPath stringFromJSONDictionary:dictionary];
    
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

#pragma mark - API

- (nullable HUBComponentImageDataImplementation *)buildWithIdentifier:(nullable NSString *)identifier type:(HUBComponentImageType)type
{
    if (self.URL == nil && self.placeholderIdentifier == nil && self.localImage == nil) {
        return nil;
    }
    
    return [[HUBComponentImageDataImplementation alloc] initWithIdentifier:identifier
                                                                      type:type
                                                                     style:self.style
                                                                       URL:self.URL
                                                     placeholderIdentifier:self.placeholderIdentifier
                                                                localImage:self.localImage];
}

NS_ASSUME_NONNULL_END

@end
