#import "HUBComponentFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentFactoryMock ()

@property (nonatomic, strong, readonly) NSDictionary<NSString *, id<HUBComponent>> *components;

@end

@implementation HUBComponentFactoryMock

- (instancetype)initWithComponents:(NSDictionary<NSString *, id<HUBComponent>> *)components
{
    if (!(self = [super init])) {
        return nil;
    }

    _components = [components copy];

    return self;
}

- (nullable id<HUBComponent>)createComponentForName:(NSString *)name
{
    return self.components[name];
}

@end

NS_ASSUME_NONNULL_END
