#import "HUBConnectivityStateResolverMock.h"

@interface HUBConnectivityStateResolverMock ()

@property (nonatomic, strong, readonly) NSHashTable<id<HUBConnectivityStateResolverObserver>> *observers;

@end

@implementation HUBConnectivityStateResolverMock

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    
    return self;
}

#pragma mark - API

- (void)callObservers
{
    for (id<HUBConnectivityStateResolverObserver> const observer in self.observers) {
        [observer connectivityStateResolverStateDidChange:self];
    }
}

#pragma mark - HUBConnectivityStateResolver

- (HUBConnectivityState)resolveConnectivityState
{
    return self.state;
}

- (void)addObserver:(id<HUBConnectivityStateResolverObserver>)observer
{
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<HUBConnectivityStateResolverObserver>)observer
{
    [self.observers removeObject:observer];
}

@end
