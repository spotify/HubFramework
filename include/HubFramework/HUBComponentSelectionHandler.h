#import <UIKit/UIKit.h>

@protocol HUBComponentModel;

/**
 *  Protocol used to define custom selection handlers for components
 *
 *  Each feature can supply a component selection handler when it's being registered with the
 *  Hub Framework (through `HUBFeatureRegistry`). This enables execution of custom code whenever
 *  a component was selected by the user.
 */
@protocol HUBComponentSelectionHandler <NSObject>

/**
 *  Perform custom selection handling for a component
 *
 *  @param componentModel The model of the component that was selected
 *  @param viewController The view controller that the selection event occured in
 *  @param viewURI The URI of the view that the selection event occured in
 *
 *  @return Whether custom selection handling was performed, which will prevent the default selection
 *  handling (opening any `targetURL` associated with the component model) from being performed.
 *
 *  The Hub Framework will call this method on any selection handler associated with the current feature
 *  whenever a component was selected by the user.
 */
- (BOOL)handleSelectionForComponentWithModel:(id<HUBComponentModel>)componentModel
                              viewController:(UIViewController *)viewController
                                     viewURI:(NSURL *)viewURI;

@end
