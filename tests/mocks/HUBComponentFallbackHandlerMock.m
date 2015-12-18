#import "HUBComponentFallbackHandlerMock.h"

@implementation HUBComponentFallbackHandlerMock

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _fallbackComponentNamespace = @"fallback";
    _fallbackComponentIdentifier = @"component";
    
    return self;
}

- (NSString *)fallbackComponentIdentifierForModel:(id<HUBComponentModel>)model
{
    return [NSString stringWithFormat:@"%@:%@", self.fallbackComponentNamespace, self.fallbackComponentIdentifier];
}

@end
