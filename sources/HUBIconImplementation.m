#import "HUBIconImplementation.h"

#import "HUBIconImageResolver.h"

@interface HUBIconImplementation ()

@property (nonatomic, strong, readonly) id<HUBIconImageResolver> imageResolver;
@property (nonatomic, assign, readonly) BOOL isPlaceholder;

@end

@implementation HUBIconImplementation

@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier imageResolver:(id<HUBIconImageResolver>)imageResolver isPlaceholder:(BOOL)isPlaceholder
{
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _imageResolver = imageResolver;
        _isPlaceholder = isPlaceholder;
    }
    
    return self;
}

#pragma mark - HUBIcon

- (nullable UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color
{
    if (self.isPlaceholder) {
        return [self.imageResolver imageForPlaceholderIconWithIdentifier:self.identifier size:size color:color];
    } else {
        return [self.imageResolver imageForComponentIconWithIdentifier:self.identifier size:size color:color];
    }
}

@end
