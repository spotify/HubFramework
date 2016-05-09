#import "HUBFeatureInfoImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureInfoImplementation

@synthesize identifier = _identifier;
@synthesize title = _title;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title
{
    NSParameterAssert(identifier != nil);
    NSParameterAssert(title != nil);
    
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _title = [title copy];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
