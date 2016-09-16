#import "HUBComponentFallbackHandlerMock.h"

#import "HUBComponentDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentFallbackHandlerMock ()

@property (nonatomic, strong, readonly) NSMutableDictionary<HUBComponentCategory, id<HUBComponent>> *fallbackComponents;

@end

@implementation HUBComponentFallbackHandlerMock

@synthesize defaultComponentNamespace = _defaultComponentNamespace;
@synthesize defaultComponentName = _defaultComponentName;
@synthesize defaultComponentCategory = _defaultComponentCategory;

- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults
{
    self = [super init];
    
    if (self) {
        _defaultComponentNamespace = componentDefaults.componentNamespace;
        _defaultComponentName = componentDefaults.componentName;
        _defaultComponentCategory = componentDefaults.componentCategory;
        _fallbackComponents = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (void)addFallbackComponent:(id<HUBComponent>)component forCategory:(HUBComponentCategory)category
{
    self.fallbackComponents[category] = component;
}

#pragma mark - HUBComponentFallbackHandler

- (id<HUBComponent>)createFallbackComponentForCategory:(HUBComponentCategory)componentCategory
{
    id<HUBComponent> const component = self.fallbackComponents[componentCategory];
    NSAssert(component != nil, @"No fallback component defined for category: %@", componentCategory);
    return component;
}

@end

NS_ASSUME_NONNULL_END
