#import "HUBAutoEquatable.h"

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^HUBAutoEquatableComparisonBlock)(NSObject *, NSObject *);
typedef NSDictionary<NSString *, HUBAutoEquatableComparisonBlock> HUBAutoEquatableComparisonMap;
typedef NSMutableDictionary<NSString *, HUBAutoEquatableComparisonBlock> HUBAutoEquatableMutableComparisonMap;

@implementation HUBAutoEquatable

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    HUBAutoEquatableComparisonMap * const comparisonMap = [self getOrCreateComparisonMap];
    
    for (NSString * const propertyName in comparisonMap) {
        if (!comparisonMap[propertyName](self, object)) {
            return NO;
        }
    }
    
    return YES;
}

- (HUBAutoEquatableComparisonMap *)getOrCreateComparisonMap
{
    static NSMutableDictionary<NSString *, HUBAutoEquatableComparisonMap *> *comparisonMapsForClassNames = nil;
    
    if (comparisonMapsForClassNames == nil) {
        comparisonMapsForClassNames = [NSMutableDictionary new];
    }
    
    NSString * const className = NSStringFromClass([self class]);
    
    HUBAutoEquatableComparisonMap *comparisonMap = comparisonMapsForClassNames[className];
    
    if (comparisonMap == nil) {
        HUBAutoEquatableMutableComparisonMap * const mutableComparisonMap = [HUBAutoEquatableMutableComparisonMap new];
        
        unsigned int propertyCount;
        const objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; i++) {
            const objc_property_t property = propertyList[i];
            const char * propertyNameCString = property_getName(property);
            NSString * const propertyName = [NSString stringWithUTF8String:propertyNameCString];
            
            if (protocol_getProperty(@protocol(NSObject), propertyNameCString, YES, YES) != NULL) {
                continue;
            }
            
            mutableComparisonMap[propertyName] = ^(NSObject * const objectA, NSObject * const objectB) {
                NSObject * const valueA = [objectA valueForKey:propertyName];
                NSObject * const valueB = [objectB valueForKey:propertyName];
                
                if (valueA == nil && valueB == nil) {
                    return YES;
                }
                
                return [valueA isEqual:valueB];
            };
        }
        
        comparisonMap = mutableComparisonMap;
        comparisonMapsForClassNames[className] = comparisonMap;
    }
    
    return comparisonMap;
}

@end

NS_ASSUME_NONNULL_END
