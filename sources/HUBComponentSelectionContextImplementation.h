#import "HUBComponentSelectionContext.h"
#import "HUBHeaderMacros.h"

@protocol HUBViewModel, HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the @c HUBComponentSelectionContext protocol.
@interface HUBComponentSelectionContextImplementation : NSObject <HUBComponentSelectionContext>

/** 
 * Initializes an instance of the class with the provided values.
 *
 * @param viewURI The URI of the view which the selection event occured in.
 * @param viewModel The model of the view which the selection occurred.
 * @param componentModel The model of the component which was selected.
 * @param viewController The view controller presenting the view in which the selection occurred.
 */
- (instancetype)initWithViewURI:(NSURL *)viewURI
                      viewModel:(id<HUBViewModel>)viewModel
                 componentModel:(id<HUBComponentModel>)componentModel
                 viewController:(UIViewController *)viewController HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
