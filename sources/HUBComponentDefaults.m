#import "HUBComponentDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentDefaults

- (instancetype)initWithComponentNamespace:(NSString *)componentNamespace
                             componentName:(NSString *)componentName
                         componentCategory:(NSString *)componentCategory
{
    NSParameterAssert(componentNamespace != nil);
    NSParameterAssert(componentName != nil);
    NSParameterAssert(componentCategory != nil);
    
    self = [super init];
    
    if (self) {
        _componentNamespace = [componentNamespace copy];
        _componentName = [componentName copy];
        _componentCategory = [componentCategory copy];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
