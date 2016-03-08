#import "HUBInitialViewModelRegistry.h"

@interface HUBInitialViewModelRegistry ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, id<HUBViewModel>> *initialViewModels;

@end

@implementation HUBInitialViewModelRegistry

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _initialViewModels = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)registerInitialViewModel:(id<HUBViewModel>)initialViewModel forViewURI:(NSURL *)viewURI
{
    self.initialViewModels[viewURI] = initialViewModel;
}

- (id<HUBViewModel>)initialViewModelForViewURI:(NSURL *)viewURI
{
    return self.initialViewModels[viewURI];
}

@end
