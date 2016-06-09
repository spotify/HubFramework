#import "HUBSerializable.h"

@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a model that is used for a View in the Hub Framework
 *
 *  You don't conform to this protocol yourself, instead the Hub Framework will create implementations of it
 *  for you based on the data supplied to a `HUBViewModelBuilder` or through JSON data.
 *
 *  See also `HUBViewController` that acts as the controller for a view that renders the data from a `HUBViewModel`.
 */
@protocol HUBViewModel <HUBSerializable>

#pragma mark - Identifiers

/**
 *  The identifier of the view
 *
 *  The value of this property doesn't have any specific format or constraints, and is up to the API user to define
 *  according to the context of the application. Doesn't explicitly need to be unique, but for logging and identification
 *  purposes, it's definitely recommended.
 *
 *  In case the value of this property hasn't been explicitly set by the API user, it defaults to the `UUIDString` of a
 *  new `NSUUID`.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 *  The identifier of the feature that the view belongs to
 *
 *  This property can be used to group views together, to be able to reason about them as a feature. Unless overriden in
 *  the content loading process, the default value is the identifier of the Hub Framework feature that this view belongs.
 */
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/**
 *  The URI of the view
 *
 *  The value of this property is assigned automatically by the Hub Framework based on the URI that was used to open
 *  the view that this view model is being used in.
 */
@property (nonatomic, copy, readonly) NSURL *viewURI;

#pragma mark - Navigation bar title

/**
 *  The title that the view should have in the navigation bar
 *
 *  In case the view has a component-based header, the value of this property is ignored by the framework.
 */
@property (nonatomic, copy, readonly, nullable) NSString *navigationBarTitle;

#pragma mark - Component models

/**
 *  The model for any component that make up the view's header
 *
 *  If the view should not use a component-based header, and instead just display a normal UINavigationBar,
 *  this property will be `nil`.
 *
 *  See `HUBComponentModel` for more information on how component models work.
 */
@property (nonatomic, strong, readonly, nullable) id<HUBComponentModel> headerComponentModel;

/**
 *  The models for the components that make up the view's body
 *
 *  See `HUBComponentModel` for more information on how component models work.
 */
@property (nonatomic, strong, readonly) NSArray<id<HUBComponentModel>> *bodyComponentModels;

/**
 *  The models for the components that will be rendered as overlays for the view
 *
 *  See `HUBComponentModel` for more information on how component models work.
 */
@property (nonatomic, strong, readonly) NSArray<id<HUBComponentModel>> *overlayComponentModels;

#pragma mark - Metadata

/**
 *  Any HTTP URL from which data can be downloaded to extend this view model
 *
 *  When a view has content that should be paginated, the URL of this property points to a JSON endpoint that describes
 *  the "next page". Once downloaded, the content of this URL will be appended to this view model.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *extensionURL;

/**
 *  Any custom data that is associated with the view
 *
 *  This dictionary contains any custom data passed from the server side, or added in the local content loading process.
 */
@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, NSObject *> *customData;

/**
 *  The date when this view model was built by the Hub Framework
 *
 *  You can use this property to determine the age of the view model, to make decisions on whether to reload a view's
 *  content or not. It will be set when the view model is built by a `HUBViewModelBuilder` according to the current date
 *  of the device.
 */
@property (nonatomic, strong, readonly) NSDate *buildDate;

@end

NS_ASSUME_NONNULL_END
