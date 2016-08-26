#import "HUBComponentReusePool.h"

#import "HUBComponentWrapper.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModel.h"
#import "HUBComponentRegistryImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentReusePool ()

@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, strong, readonly) NSMutableDictionary<HUBComponentIdentifier *, NSMutableArray<HUBComponentWrapper *> *> *componentWrappers;

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
    NSMutableArray * const existingWrappers = self.componentWrappers[componentIdentifier];
    
    if (existingWrappers != nil) {
        [existingWrappers addObject:componentWrapper];
    } else {
        self.componentWrappers[componentIdentifier] = [NSMutableArray arrayWithObject:componentWrapper];
    }
}

- (HUBComponentWrapper *)componentWrapperForModel:(id<HUBComponentModel>)model
                                                       delegate:(id<HUBComponentWrapperDelegate>)delegate
                                         parentComponentWrapper:(nullable HUBComponentWrapper *)parentComponentWrapper
{
    NSMutableArray * const existingWrappers = self.componentWrappers[model.componentIdentifier];
    
    if (existingWrappers.count > 0) {
        HUBComponentWrapper * const wrapper = existingWrappers[0];
        wrapper.delegate = delegate;
        [existingWrappers removeObjectAtIndex:0];
        return wrapper;
    }
    
    id<HUBComponent> const component = [self.componentRegistry createComponentForModel:model];
    
    return [[HUBComponentWrapper alloc] initWithComponent:component
                                                                  model:model
                                                         UIStateManager:self.UIStateManager
                                                               delegate:delegate
                                                 parentComponentWrapper:parentComponentWrapper];
}

@end

NS_ASSUME_NONNULL_END
