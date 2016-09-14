#import "HUBActionRegistryImplementation.h"

#import "HUBActionFactory.h"
#import "HUBActionContext.h"
#import "HUBIdentifier.h"
#import "HUBSelectionAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBActionRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBActionFactory>> *actionFactories;

@end

@implementation HUBActionRegistryImplementation

#pragma mark - Initializers

+ (instancetype)registryWithDefaultSelectionAction
{
    return [[self alloc] initWithSelectionAction:[HUBSelectionAction new]];
}

- (instancetype)initWithSelectionAction:(id<HUBAction>)selectionAction
{
    NSParameterAssert(selectionAction != nil);
    
    self = [super init];
    
    if (self) {
        _selectionAction = selectionAction;
        _actionFactories = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (nullable id<HUBAction>)createCustomActionForIdentifier:(HUBIdentifier *)identifier
{
    id<HUBActionFactory> const factory = self.actionFactories[identifier.namespacePart];
    return [factory createActionForName:identifier.namePart];
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
