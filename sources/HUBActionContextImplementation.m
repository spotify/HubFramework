#import "HUBActionContextImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBActionContextImplementation

@synthesize actionIdentifier = _actionIdentifier;
@synthesize viewURI = _viewURI;
@synthesize viewModel = _viewModel;
@synthesize componentModel = _componentModel;
@synthesize viewController = _viewController;

- (instancetype)initWithActionIdentifier:(HUBIdentifier *)actionIdentifier
                                 viewURI:(NSURL *)viewURI
                               viewModel:(id<HUBViewModel>)viewModel
                          componentModel:(id<HUBComponentModel>)componentModel
                          viewController:(UIViewController *)viewController
{
    NSParameterAssert(actionIdentifier != nil);
    NSParameterAssert(viewURI != nil);
    NSParameterAssert(viewModel != nil);
    NSParameterAssert(componentModel != nil);
    NSParameterAssert(viewController != nil);

    self = [super init];
    
    if (self) {
        _actionIdentifier = actionIdentifier;
        _viewURI = viewURI;
        _viewModel = viewModel;
        _componentModel = componentModel;
        _viewController = viewController;
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
