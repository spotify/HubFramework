#import "HUBAction.h"

/**
 *  An action that gets performed whenever a component is selected
 *
 *  This action opens any `URI` associated with the target of the component that was selected,
 *  using the default `[UIApplication openURL:]` API, and returns the outcome.
 */
@interface HUBSelectionAction : NSObject <HUBAction>

@end
