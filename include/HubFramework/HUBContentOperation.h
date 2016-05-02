#import "HUBConnectivityState.h"

@protocol HUBContentOperation;
@protocol HUBViewModelBuilder;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HUBContentOperationMode

/**
 *  Enum describing various modes that a content operation can use
 *
 *  A content operation's current mode gives the Hub Framework a hint on whether it should wait for the content
 *  operation to finish asynchronously, or whether it can continue the content loading process once the content
 *  operation has been called.
 */
typedef NS_ENUM(NSInteger, HUBContentOperationMode) {
    /// The content operation is currently not in any mode (not active)
    HUBContentOperationModeNone,
    /// The content operation is currently loading synchronously
    HUBContentOperationModeSynchronous,
    /// The content operation is currently loading asynchronously
    HUBContentOperationModeAsynchronous
};

#pragma mark - HUBContentOperationDelegate

/**
 *  Delegate protocol for objects conforming to `HUBContentOperation`
 *
 *  You don't conform to this protocol yourself. Instead, you synthesize your content operation's `delegate`
 *  property, which the Hub Framework will assign. You may then use the methods defined in this protocol to
 *  communicate content operation events back to the framework.
 */
@protocol HUBContentOperationDelegate <NSObject>

/**
 *  Notify the Hub Framework that a content operation finished
 *
 *  @param operation The operation that finished
 *
 *  If a content operation loads content asynchronously (`HUBContentOperationModeAsynchronous`), it should call
 *  this method once it successfully loaded its content, and added it to the current `HUBViewModelBuilder`.
 *
 *  This method can also be used in case a content operation updated its content after it was initially loaded,
 *  and wants to trigger a rendering update.
 */
- (void)contentOperationDidFinish:(id<HUBContentOperation>)operation;

/**
 *  Notify the Hub Framework that a content operation failed because of an error
 *
 *  @param operation The operation that encountered an error
 *  @param error The error that was encountered
 *
 *  Use this method to propagate an error from a content operation to the framework. If this method is called, an
 *  attempt will be made to recover by sending the error when calling any next content operation in the sequence as
 *  `previousContentOperationError`. If the next content operation manages to recover, the error is silenced. If no
 *  additional content operations were able to recover, the error will block the creation of a view model and a
 *  visual representation of it will be rendered instead of content.
 */
- (void)contentOperation:(id<HUBContentOperation>)operation didFailWithError:(NSError *)error;

@end

#pragma mark - HUBContentOperation

/**
 *  Protocol used to define objects that load content that will make up a Hub Framework view model
 *
 *  To define a content operation, conform to this protocol in a custom object - and return it from a matching
 *  `HUBContentOperationFactory` that is passed when configuring your feature with the Hub Framework. A content
 *  operation is free to do its work in whatever way it desires, online or offline - manipulating a view's content
 *  either in code or through JSON (or another data format) - synchronously or asynchronously.
 *
 *  When a new view is about to be displayed by the Hub Framework, the framework will call the content operations
 *  associated with that view. The content that these content operations add to the used `HUBViewModelBuilder` will
 *  then be used to create a view model for the view.
 */
@protocol HUBContentOperation <NSObject>

/// The content operation's delegate. Don't assign this property yourself, it will be set by the Hub Framework.
@property (nonatomic, weak, nullable) id<HUBContentOperationDelegate> delegate;

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

/**
 *  Load the content to be provided by this content operation
 *
 *  @param viewURI The URI of the view to load content for
 *  @param connectivityState The current connectivity state of the app. You can use the value of this parameter to
 *         determine whether your content operation should be used or not, in case it requires a certain state.
 *  @param viewModelBuilder The builder that should be used to add content to the view. In case the content operation
 *         does its work asynchronously, it may retain this object for future use.
 *  @param previousContentOperationError Any error encountered by a previous content operation in the list of the view's
 *         content operations. If this is non-`nil`, you can attempt to recover the error in this content operation, to
 *         provide any relevant to avoid displaying an error screen for the user. In case this conent operation can't
 *         recover the error, it should either return `HUBContentOperationModeNone` or propagate the error using the
 *         error delegate callback method.
 *
 *  @return An enum value describing what mode the content operation is currently in. If the content operation is finished
 *          at this point, it should return `HUBContentOperationModeSynchronous`. In case it needs more time to load, it
 *          should return `HUBContentOperationModeAsynchronous` and use its delegate to notify the Hub Framework when it
 *          finished loading. `HUBContentOperationModeNone` can also be returned to indicate that the content operation won't
 *          do any work at this time.
 *
 *  The Hub Framework will call this method on all content operations associated with a certain view when the view is about
 *  to appear on the screen. Content operations are always called in sequence, so the passed builder may contain conent
 *  already loaded by a previous content operation. Subsequent content operations are therefor able to modify content added
 *  by previous ones.
 */
- (HUBContentOperationMode)loadContentForViewURI:(NSURL *)viewURI
                              connectivityState:(HUBConnectivityState)connectivityState
                               viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
                   previousContentOperationError:(nullable NSError *)previousContentOperationError;

/**
 *  Extend the current view model by loading content from a certain URL
 *
 *  @param extensionURL The HTTP URL that should be used to load extension data
 *  @param viewURI The URI of the view to load extension content for
 *  @param viewModelBuilder The builder to use to add the extension content. It will contain the content already present
 *         in the view in question.
 *
 *  @return An enum value describing what mode the content operation is currently in. If the content operation is finished
 *          at this point, it should return `HUBContentOperationModeSynchronous`. In case it needs more time to load, it
 *          should return `HUBContentOperationModeAsynchronous` and use its delegate to notify the Hub Framework when it
 *          finished loading. `HUBContentOperationModeNone` can also be returned to indicate that the content operation won't
 *          do any work at this time.
 *
 *  The Hub Framework will call this method on all content operations associated with a certain view when the view was
 *  scrolled to the bottom, and if the current view model contains an `extensionURL`. This can be used to implement paginated
 *  content. If possible, the content operation should use the URL provided as `extensionURL` to load content.
 *
 *  This method will only be called if the current connectivity state is `HUBConnectivityStateOnline`.
 *
 *  Any errors encountered during this process are not taken into account, as this is considered an optional operation.
 */
- (HUBContentOperationMode)loadContentFromExtensionURL:(NSURL *)extensionURL
                                           forViewURI:(NSURL *)viewURI
                                     viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder;

@end

NS_ASSUME_NONNULL_END
