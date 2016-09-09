#import "HUBAutoEquatable.h"
#import "HUBComponentModel.h"
#import "HUBHeaderMacros.h"

@class HUBIdentifier;
@protocol HUBIcon;
@protocol HUBComponentTarget;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentModel` API
@interface HUBComponentModelImplementation : HUBAutoEquatable <HUBComponentModel>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param identifier The identifier of the model
 *  @param index The index of the model, either within its parent or within the root list
 *  @param componentIdentifier The identifier of the component that the model should be rendered using
 *  @param componentCategory The category of the component that the model should be rendered using
 *  @param title Any title that the component should render
 *  @param subtitle Any subtitle that the component should render
 *  @param accessoryTitle Any accessory title that the component should render
 *  @param descriptionText Any description text that the component should render
 *  @param mainImageData Any image data for the component's "main" image
 *  @param backgroundImageData Any image data for the component's background image
 *  @param customImageData Any image data objects describing layout properties for custom images for the component
 *  @param icon Any icon that the component should render
 *  @param target Any target of user interactions with the component
 *  @param metadata Any metadata that should be associated with the component
 *  @param loggingData Any data that should be logged alongside interactions or impressions for the component
 *  @param customData Any custom data that the component should use
 *  @param childComponentModels Any component models that are children of this model
 *
 *  For more information about these parameters and their corresponding properties, see their
 *  documentation in `HUBComponentModel`.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                             index:(NSUInteger)index
               componentIdentifier:(HUBIdentifier *)componentIdentifier
                 componentCategory:(HUBComponentCategory *)componentCategory
                             title:(nullable NSString *)title
                          subtitle:(nullable NSString *)subtitle
                    accessoryTitle:(nullable NSString *)accessoryTitle
                   descriptionText:(nullable NSString *)descriptionText
                     mainImageData:(nullable id<HUBComponentImageData>)mainImageData
               backgroundImageData:(nullable id<HUBComponentImageData>)backgroundImageData
                   customImageData:(NSDictionary<NSString *, id<HUBComponentImageData>> *)customImageData
                              icon:(nullable id<HUBIcon>)icon
                            target:(nullable id<HUBComponentTarget>)target
                          metadata:(nullable NSDictionary<NSString *, NSObject *> *)metadata
                       loggingData:(nullable NSDictionary<NSString *, NSObject *> *)loggingData
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
              childComponentModels:(nullable NSArray<id<HUBComponentModel>> *)childComponentModels HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
