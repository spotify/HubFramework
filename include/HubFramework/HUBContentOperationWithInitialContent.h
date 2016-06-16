#import "HUBContentOperation.h"

/**
 *  Extended Hub content operation protocol that adds the ability to add initial content to a view
 *
 *  Use this protocol whenever your content operation is able to add pre-loaded content to a view,
 *  that is rendered before the main content loading chain is started.
 *
 *  See `HUBContentOperation` for more information.
 */
@protocol HUBContentOperationWithInitialContent <HUBContentOperation>

/**
 *  Add any initial content for a view with a certain view URI, using a view model builder
 *
 *  @param viewURI The URI of the view that initial content should be added for
 *  @param viewModelBuilder The builder that can be used to add initial content
 *
 *  Initial content is always loaded synchronously, and is displayed for the user before the "real" view model of
 *  a view is loaded. It can be used to display a "skeleton" version of the final User Interface, or to add placeholder
 *  content. The key for this method is speed - it shouldn't be used to perform expensive operations or to load any
 *  final content.
 *
 *  In case no relevant content can be added by the content operation, it can just implement this method as a no-op.
 */
- (void)addInitialContentForViewURI:(NSURL *)viewURI
                 toViewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder;

@end
