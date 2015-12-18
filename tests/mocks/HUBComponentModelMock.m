#import "HUBComponentModelMock.h"

@implementation HUBComponentModelMock

@synthesize componentIdentifier = _componentIdentifier;

- (instancetype)initWithComponentIdentifier:(NSString *)componentIdentifier
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _componentIdentifier = componentIdentifier;
    
    return self;
}

@end
