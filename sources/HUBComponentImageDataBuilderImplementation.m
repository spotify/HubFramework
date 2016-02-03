#import "HUBComponentImageDataBuilderImplementation.h"

#import "HUBComponentImageDataImplementation.h"
#import "HUBComponentImageDataJSONSchema.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageDataBuilderImplementation

@synthesize style = _style;
@synthesize URL = _URL;
@synthesize iconIdentifier = _iconIdentifier;

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary usingSchema:(id<HUBComponentImageDataJSONSchema>)schema
{
    self.style = HUBComponentImageStyleRectangular;
    self.URL = [schema.URLPath URLFromJSONDictionary:dictionary];
    self.iconIdentifier = [schema.iconIdentifierPath stringFromJSONDictionary:dictionary];
    
    NSString * const styleString = [schema.styleStringPath stringFromJSONDictionary:dictionary];
    
    if (styleString != nil) {
        NSNumber * const styleNumber = [schema.styleStringMap objectForKey:styleString];
        
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

- (nullable HUBComponentImageDataImplementation *)build
{
    if (self.URL == nil && self.iconIdentifier == nil) {
        return nil;
    }
    
    return [[HUBComponentImageDataImplementation alloc] initWithStyle:self.style
                                                                  URL:self.URL
                                                       iconIdentifier:self.iconIdentifier];
}

NS_ASSUME_NONNULL_END

@end
