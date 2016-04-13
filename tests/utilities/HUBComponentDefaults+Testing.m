#import "HUBComponentDefaults+Testing.h"

@implementation HUBComponentDefaults (Testing)

+ (HUBComponentDefaults *)defaultsForTesting
{
    return [[HUBComponentDefaults alloc] initWithComponentNamespace:@"namespace"
                                                      componentName:@"name"
                                                  componentCategory:@"category"];
}

@end
