#import "HUBComponentFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentFactoryMock ()

@property (nonatomic, strong, readonly) NSDictionary<NSString *, id<HUBComponent>> *components;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSURL *> *mutableViewURIsForComponentNames;

@end

@implementation HUBComponentFactoryMock

- (instancetype)initWithComponents:(NSDictionary<NSString *, id<HUBComponent>> *)components
{
    self = [super init];
    
    if (self) {
        _components = [components copy];
        _mutableViewURIsForComponentNames = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (NSDictionary<NSString *,NSURL *> *)viewURIsForComponentNames
{
    return [self.mutableViewURIsForComponentNames copy];
}

#pragma mark - HUBComponentFactory

- (nullable id<HUBComponent>)createComponentForName:(NSString *)name viewURI:(NSURL *)viewURI
{
    self.mutableViewURIsForComponentNames[name] = viewURI;
    return self.components[name];
}

@end

NS_ASSUME_NONNULL_END
