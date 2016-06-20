#import "HUBComponentFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentFactoryMock ()

@property (nonatomic, strong, readonly) NSDictionary<NSString *, id<HUBComponent>> *components;

@end

@implementation HUBComponentFactoryMock

- (instancetype)initWithComponents:(NSDictionary<NSString *, id<HUBComponent>> *)components
{
    self = [super init];
    
    if (self) {
        _components = [components copy];
    }
    
    return self;
}

- (nullable id<HUBComponent>)createComponentForName:(NSString *)name
{
    return self.components[name];
}

#pragma mark - NSObject

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    if (protocol == @protocol(HUBComponentFactoryShowcaseNameProvider)) {
        return self.showcaseableComponentNames != nil;
    }
    
    return [super conformsToProtocol:protocol];
}

@end

NS_ASSUME_NONNULL_END
