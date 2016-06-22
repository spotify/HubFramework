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

#pragma mark - HUBComponentFactory

- (nullable id<HUBComponent>)createComponentForName:(NSString *)name
{
    return self.components[name];
}

#pragma mark - HUBComponentFactoryShowcaseNameProvider

- (nullable NSString *)showcaseNameForComponentName:(NSString *)componentName
{
    return self.showcaseNamesForComponentNames[componentName];
}

#pragma mark - NSObject

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    if (protocol == @protocol(HUBComponentFactoryShowcaseNameProvider)) {
        return (self.showcaseableComponentNames != nil || self.showcaseNamesForComponentNames != nil);
    }
    
    return [super conformsToProtocol:protocol];
}

@end

NS_ASSUME_NONNULL_END
