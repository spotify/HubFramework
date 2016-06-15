#import "HUBComponentSelectionHandlerMock.h"
#import "HUBComponentSelectionContext.h"

@interface HUBComponentSelectionHandlerMock ()

@property (nonatomic, strong, readonly) NSMutableArray<id<HUBComponentSelectionContext>> *mutableSelectionContexts;

@end

@implementation HUBComponentSelectionHandlerMock

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _mutableSelectionContexts = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Property overrides

- (NSArray<id<HUBComponentSelectionContext>> *)selectionContexts
{
    return [self.mutableSelectionContexts copy];
}

#pragma mark - HUBComponentSelectionHandler

- (BOOL)handleSelectionForComponentWithContext:(id<HUBComponentSelectionContext>)selectionContext
{
    if (!self.handlesSelection) {
        return NO;
    }
    
    [self.mutableSelectionContexts addObject:selectionContext];
    
    return YES;
}

@end
