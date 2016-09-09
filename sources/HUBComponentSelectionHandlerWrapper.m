#import "HUBComponentSelectionHandlerWrapper.h"

#import "HUBComponentSelectionContext.h"
#import "HUBComponentModel.h"
#import "HUBComponentTarget.h"
#import "HUBInitialViewModelRegistry.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentSelectionHandlerWrapper ()

@property (nonatomic, strong, nullable, readonly) id<HUBComponentSelectionHandler> selectionHandler;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;

@end

@implementation HUBComponentSelectionHandlerWrapper

#pragma mark - Initializer

- (instancetype)initWithSelectionHandler:(nullable id<HUBComponentSelectionHandler>)selectionHandler
                initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
{
    NSParameterAssert(initialViewModelRegistry != nil);
    
    self = [super init];
    
    if (self) {
        _selectionHandler = selectionHandler;
        _initialViewModelRegistry = initialViewModelRegistry;
    }
    
    return self;
}

#pragma mark - HUBComponentSelectionHandler

- (BOOL)handleSelectionForComponentWithContext:(id<HUBComponentSelectionContext>)selectionContext
{
    if ([self.selectionHandler handleSelectionForComponentWithContext:selectionContext]) {
        return YES;
    }
    
    id<HUBComponentTarget> const target = selectionContext.componentModel.target;
    NSURL * const targetURL = target.URI;
    id<HUBViewModel> const targetInitialViewModel = target.initialViewModel;
    
    if (targetURL == nil) {
        return NO;
    }
    
    if (targetInitialViewModel != nil) {
        [self.initialViewModelRegistry registerInitialViewModel:targetInitialViewModel forViewURI:targetURL];
    }
    
    [[UIApplication sharedApplication] openURL:targetURL];
    
    return YES;
}

@end

NS_ASSUME_NONNULL_END
