#import "HUBActionRegistryImplementation.h"

#import "HUBActionFactory.h"
#import "HUBActionContext.h"
#import "HUBIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBActionRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBActionFactory>> *actionFactories;

@end

@implementation HUBActionRegistryImplementation

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _actionFactories = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (nullable id<HUBAction>)actionForContext:(id<HUBActionContext>)context
{
    HUBIdentifier * const actionIdentifier = context.actionIdentifier;
    id<HUBActionFactory> const factory = self.actionFactories[actionIdentifier.namespacePart];
    return [factory createActionForName:actionIdentifier.namePart];
}

#pragma mark - HUBActionRegistry

- (void)registerActionFactory:(id<HUBActionFactory>)actionFactory forNamespace:(NSString *)actionNamespace
{
    if (self.actionFactories[actionNamespace] != nil) {
        NSAssert(NO,
                 @"Attempted to register an action factory for a namespace that has already been registered: %@",
                 actionNamespace);
    }
    
    self.actionFactories[actionNamespace] = actionFactory;
}

- (void)unregisterActionFactoryForNamespace:(NSString *)actionNamespace
{
    self.actionFactories[actionNamespace] = nil;
}

@end

NS_ASSUME_NONNULL_END
