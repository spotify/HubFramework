#import <Foundation/Foundation.h>

@protocol HUBViewModel;

/**
 *  Protocol used to define objects that represent a policy for when the content for a view should be reloaded
 *
 *  To define a reload policy, conform to this protocol in a custom object and pass it when registering your
 *  feature with `HUBFeatureRegistry`. A reload policy can be used to implement custom rules around when to
 *  reload a given view.
 *
 *  Each application using the Hub Framework also has a default content reload policy used for features that
 *  do not declare their own. This reload policy is passed when setting up `HUBManager`.
 */
@protocol HUBContentReloadPolicy <NSObject>

/**
 *  Return whether the content for a view should be reloaded
 *
 *  @param currentViewModel The current view model of the view
 *
 *  The Hub Framework will call this method every time a view that has already loaded a view model is about
 *  to appear on the screen. The passed `currentViewModel` can be used to inspect the current content of the
 *  view, as well as the view model's `buildDate` to determine whether a view should be reloaded or not.
 */
- (BOOL)shouldReloadContentForViewWithCurrentViewModel:(id<HUBViewModel>)currentViewModel;

@end
