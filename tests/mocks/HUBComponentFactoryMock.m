#import "HUBComponentFactoryMock.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModel.h"


@interface HUBComponentFactoryMock ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, HUBComponentIdentifier *> *aliases;
@end

@implementation HUBComponentFactoryMock

- (instancetype)initWithComponents:(NSDictionary *)components
{
    if (!(self = [super init])) {
        return nil;
    }

    _aliases = [NSMutableDictionary new];
    _components = [components copy];

    return self;
}

- (NSArray *)allComponentNames
{
    return [self.components.allKeys copy];
}

- (id<HUBComponent>)componentForName:(NSString *)name
{
    id<HUBComponent> component = self.components[name];
    return component;
}

- (HUBComponentIdentifier *)fallbackComponentIdentifierForModel:(id<HUBComponentModel>)model
{
    HUBComponentIdentifier * const identifier = model.componentIdentifier;

    if (!identifier || !self.aliases[identifier.componentName]) {
        return self.defaultComponentIdentifier;
    }

    HUBComponentIdentifier * const alias = self.aliases[identifier.componentName];
    return alias;
}

- (void)addAlias:(HUBComponentIdentifier *)alias forName:(NSString *)name
{
    self.aliases[name] = alias;
}

@end
