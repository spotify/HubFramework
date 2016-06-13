#import "HUBComponentSelectionHandlerMock.h"

@interface HUBComponentSelectionHandlerMock ()

@property (nonatomic, strong, readonly) NSMutableArray<id<HUBComponentModel>> *mutableSelectedComponentModels;

@end

@implementation HUBComponentSelectionHandlerMock

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _mutableSelectedComponentModels = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Property overrides

- (NSArray<id<HUBComponentModel>> *)selectedComponentModels
{
    return [self.mutableSelectedComponentModels copy];
}

#pragma mark - HUBComponentSelectionHandler

- (BOOL)handleSelectionForComponentWithModel:(id<HUBComponentModel>)componentModel
                              viewController:(UIViewController *)viewController
                                     viewURI:(NSURL *)viewURI
{
    if (!self.handlesSelection) {
        return NO;
    }
    
    [self.mutableSelectedComponentModels addObject:componentModel];
    
    return YES;
}

@end
