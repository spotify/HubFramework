#import "HUBComponentReusePool.h"

#import "HUBComponentWrapper.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModel.h"
#import "HUBComponentRegistryImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentReusePool ()

@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, strong, readonly) NSMutableDictionary<HUBComponentIdentifier *, NSMutableSet<HUBComponentWrapper *> *> *componentWrappers;

@end

@implementation HUBComponentReusePool

- (instancetype)initWithComponentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                           UIStateManager:(HUBComponentUIStateManager *)UIStateManager
{
    NSParameterAssert(componentRegistry != nil);
    NSParameterAssert(UIStateManager != nil);
    
    self = [super init];
    
    if (self) {
        _componentRegistry = componentRegistry;
        _UIStateManager = UIStateManager;
        _componentWrappers = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)addComponentWrappper:(HUBComponentWrapper *)componentWrapper
{
    HUBComponentIdentifier * const componentIdentifier = componentWrapper.model.componentIdentifier;
    NSMutableSet * const existingWrappers = self.componentWrappers[componentIdentifier];
    
    if (existingWrappers != nil) {
        [existingWrappers addObject:componentWrapper];
    } else {
        self.componentWrappers[componentIdentifier] = [NSMutableSet setWithObject:componentWrapper];
    }
}

- (HUBComponentWrapper *)componentWrapperForModel:(id<HUBComponentModel>)model
                                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                                           parent:(nullable HUBComponentWrapper *)parent
{
    NSMutableSet * const existingWrappers = self.componentWrappers[model.componentIdentifier];
    
    if (existingWrappers.count > 0) {
        HUBComponentWrapper * const wrapper = [existingWrappers anyObject];
        wrapper.delegate = delegate;
        [existingWrappers removeObject:wrapper];
        return wrapper;
    }
    
    id<HUBComponent> const component = [self.componentRegistry createComponentForModel:model];
    
    return [[HUBComponentWrapper alloc] initWithComponent:component
                                                    model:model
                                           UIStateManager:self.UIStateManager
                                                 delegate:delegate
                                                   parent:parent];
}

@end

NS_ASSUME_NONNULL_END
