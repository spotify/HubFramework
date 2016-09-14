#import "HUBActionContextImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBActionContextImplementation

@synthesize trigger = _trigger;
@synthesize customActionIdentifier = _customActionIdentifier;
@synthesize viewURI = _viewURI;
@synthesize viewModel = _viewModel;
@synthesize componentModel = _componentModel;
@synthesize viewController = _viewController;

- (instancetype)initWithTrigger:(HUBActionTrigger)trigger
         customActionIdentifier:(nullable HUBIdentifier *)customActionIdentifier
                        viewURI:(NSURL *)viewURI
                      viewModel:(id<HUBViewModel>)viewModel
                 componentModel:(id<HUBComponentModel>)componentModel
                 viewController:(UIViewController *)viewController
{
    NSParameterAssert(viewURI != nil);
    NSParameterAssert(viewModel != nil);
    NSParameterAssert(componentModel != nil);
    NSParameterAssert(viewController != nil);

    self = [super init];
    
    if (self) {
        _trigger = trigger;
        _customActionIdentifier = customActionIdentifier;
        _viewURI = viewURI;
        _viewModel = viewModel;
        _componentModel = componentModel;
        _viewController = viewController;
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
