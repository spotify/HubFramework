#import "HUBActionContext.h"
#import "HUBHeaderMacros.h"

@protocol HUBViewModel, HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBActionContext` protocol.
@interface HUBActionContextImplementation : NSObject <HUBActionContext>

/** 
 *  Initializes an instance of the class with the provided values.
 *
 *  @param actionIdentifier The identifier of the action that this context is for
 *  @param viewURI The URI of the view that the action is for
 *  @param viewModel The model of the view that the action is for
 *  @param componentModel The model of the component that the action is for
 *  @param viewController The view controller presenting the view that the action is for
 */
- (instancetype)initWithActionIdentifier:(HUBIdentifier *)actionIdentifier
                                 viewURI:(NSURL *)viewURI
                               viewModel:(id<HUBViewModel>)viewModel
                          componentModel:(id<HUBComponentModel>)componentModel
                          viewController:(UIViewController *)viewController HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
