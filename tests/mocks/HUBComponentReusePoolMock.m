#import "HUBComponentReusePoolMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentReusePoolMock ()

@property (nonatomic, strong, readonly) NSHashTable *mutableComponentsInUse;

@end

@implementation HUBComponentReusePoolMock

#pragma mark - Initializer

- (instancetype)initWithComponentRegistry:(id<HUBComponentRegistry>)componentRegistry
{
    self = [super initWithComponentRegistry:componentRegistry];
    
    if (self) {
        _mutableComponentsInUse = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}

#pragma mark - HUBComponentReusePool

- (HUBComponentWrapper *)componentWrapperForModel:(id<HUBComponentModel>)model
                                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                                           parent:(nullable HUBComponentWrapper *)parent
{
    HUBComponentWrapper * const componentWrapper = [super componentWrapperForModel:model
                                                                          delegate:delegate
                                                                            parent:parent];
    
    [self.mutableComponentsInUse addObject:componentWrapper];
    return componentWrapper;
}

#pragma mark - Property overrides

- (NSArray<HUBComponentWrapper *> *)componentsInUse
{
    return self.mutableComponentsInUse.allObjects;
}

@end

NS_ASSUME_NONNULL_END
