#import "HUBSerializable.h"

@protocol HUBViewModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of an object that describes a target of a user interaction
 *  with a Hub Framework component.
 *
 *  You create targets using `HUBComponentTargetBuilder`, available on `HUBComponentModelBuilder`.
 */
@protocol HUBComponentTarget <HUBSerializable>

/**
 *  Any URI that should be opened when the user interacts with the component this target is for
 *
 *  By default, this URI is opened using `[UIApplication openURL:]` when a user interacts with
 *  this target's associated component. This behavior can be overriden by implementing a custom
 *  selection handler (`HUBComponentSelectionHandler`) and sending it when registering a feature
 *  using `HUBFeatureRegistry`.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *URI;

/**
 *  Any initial view model that should be used for the target view
 *
 *  This property can be used to setup several views up-front, either partially or completely.
 *  In case this property is not `nil`, and the target view is a Hub Framework-powered view as
 *  well, the framework will automatically setup that view using this view model. Using this
 *  property might lead to a better user experience, since the user will be able to see a skeleton
 *  version of new views before the their content is loaded, rather than just seing a blank screen.
 */
@property (nonatomic, strong, readonly, nullable) id<HUBViewModel> initialViewModel;

/**
 *  Any custom data associated with this target
 *
 *  You can use custom data to set key/value combinations to be used in a custom selection handler
 *  or component to make decisions.
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, NSObject *> *customData;

@end

NS_ASSUME_NONNULL_END
