#import "HUBComponentImageDataBuilderImplementation.h"

#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentImageDataJSONSchema.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageDataBuilderImplementation

@synthesize style = _style;
@synthesize URL = _URL;
@synthesize iconIdentifier = _iconIdentifier;

#pragma mark - HUBJSONCompatibleBuilder

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary usingSchema:(id<HUBJSONSchema>)schema
{
    id<HUBComponentImageDataJSONSchema> const imageDataSchema = schema.componentImageDataSchema;
    
    self.style = HUBComponentImageStyleRectangular;
    self.URL = [imageDataSchema.URLPath URLFromJSONDictionary:dictionary];
    self.iconIdentifier = [imageDataSchema.iconIdentifierPath stringFromJSONDictionary:dictionary];
    
    NSString * const styleString = [imageDataSchema.styleStringPath stringFromJSONDictionary:dictionary];
    
    if (styleString != nil) {
        NSNumber * const styleNumber = imageDataSchema.styleStringMap[styleString];
        
        if (styleNumber != nil) {
            NSUInteger const potentialImageStyle = styleNumber.unsignedIntegerValue;
            
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

- (nullable HUBComponentImageDataImplementation *)buildWithIdentifier:(nullable NSString *)identifier
{
    if (self.URL == nil && self.iconIdentifier == nil) {
        return nil;
    }
    
    return [[HUBComponentImageDataImplementation alloc] initWithIdentifier:identifier
                                                                     style:self.style
                                                                       URL:self.URL
                                                            iconIdentifier:self.iconIdentifier];
}

NS_ASSUME_NONNULL_END

@end
