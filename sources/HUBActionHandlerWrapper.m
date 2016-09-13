#import "HUBActionHandlerWrapper.h"

#import "HUBActionRegistryImplementation.h"
#import "HUBActionContext.h"
#import "HUBAction.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentModel.h"
#import "HUBComponentTarget.h"
#import "HUBViewModelLoaderImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBActionHandlerWrapper ()

@property (nonatomic, strong, readonly, nullable) id<HUBActionHandler> actionHandler;
@property (nonatomic, strong, readonly) HUBActionRegistryImplementation *actionRegistry;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) HUBViewModelLoaderImplementation *viewModelLoader;

@end

@implementation HUBActionHandlerWrapper

#pragma mark - Initializer

- (instancetype)initWithActionHandler:(nullable id<HUBActionHandler>)actionHandler
                       actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
             initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                      viewModelLoader:(HUBViewModelLoaderImplementation *)viewModelLoader
{
    NSParameterAssert(actionRegistry != nil);
    NSParameterAssert(initialViewModelRegistry != nil);
    NSParameterAssert(viewModelLoader != nil);
    
    self = [super init];
    
    if (self) {
        _actionHandler = actionHandler;
        _actionRegistry = actionRegistry;
        _initialViewModelRegistry = initialViewModelRegistry;
        _viewModelLoader = viewModelLoader;
    }
    
    return self;
}

#pragma mark - HUBActionHandler

- (BOOL)handleActionWithContext:(id<HUBActionContext>)context
{
    if ([self.actionHandler handleActionWithContext:context]) {
        return YES;
    }
    
    id<HUBComponentTarget> const target = context.componentModel.target;
    id<HUBAction> action = nil;
    
    if (context.customActionIdentifier == nil) {
        action = self.actionRegistry.selectionAction;
        
        NSURL * const URI = target.URI;
        id<HUBViewModel> const initialViewModel = target.initialViewModel;
        
        if (URI != nil && initialViewModel != nil) {
            [self.initialViewModelRegistry registerInitialViewModel:initialViewModel forViewURI:URI];
        }
    } else {
        HUBIdentifier * const actionIdentifier = context.customActionIdentifier;
        action = [self.actionRegistry createCustomActionForIdentifier:actionIdentifier];
    }
    
    if (action == nil) {
        return NO;
    }
    
    BOOL const actionPerformed = [action performWithContext:context];
    
    if (context.customActionIdentifier == nil && target.URI != nil) {
        NSURL * const targetURI = target.URI;
        [self.initialViewModelRegistry removeInitialViewModelForViewURI:targetURI];
    }
    
    return actionPerformed;
}

@end

NS_ASSUME_NONNULL_END
