#import "HUBComponentDefaults.h"

@implementation HUBComponentDefaults

- (instancetype)initWithComponentNamespace:(NSString *)componentNamespace componentName:(NSString *)componentName
{
    NSParameterAssert(componentNamespace != nil);
    NSParameterAssert(componentName != nil);
    
    self = [super init];
    
    if (self) {
        _componentNamespace = [componentNamespace copy];
        _componentName = [componentName copy];
    }
    
    return self;
}

@end
