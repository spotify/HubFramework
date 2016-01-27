#import "HUBComponentModel.h"

@class HUBComponentImageDataImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentModel` API
@interface HUBComponentModelImplementation : NSObject <HUBComponentModel>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param identifier The identifier of the model
 *  @param componentIdentifier The identifier of the component that the model should be rendered using
 *  @param contentIdentifier Any identifier for the model's content
 *  @param title Any title that the component should render
 *  @param subtitle Any subtitle that the component should render
 *  @param accessoryTitle Any accessory title that the component should render
 *  @param descriptionText Any description text that the component should render
 *  @param imageData Any image data that describes what type of image the component should render
 *  @param targetURL The URL that is the target of a user interaction with the component
 *  @param customData Any custom data that the component should use
 *  @param loggingData Any data that should be logged alongside interactions or impressions for the component
 *  @param date Any date that is associated with the item
 *
 *  For more information about these parameters and their corresponding properties, see their
 *  documentation in `HUBComponentModel`.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
               componentIdentifier:(nullable NSString *)componentIdentifier
                 contentIdentifier:(nullable NSString *)contentIdentifier
                             title:(nullable NSString *)title
                          subtitle:(nullable NSString *)subtitle
                    accessoryTitle:(nullable NSString *)accessoryTitle
                   descriptionText:(nullable NSString *)descriptionText
                         imageData:(nullable HUBComponentImageDataImplementation *)imageData
                         targetURL:(nullable NSURL *)targetURL
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
                       loggingData:(nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)loggingData
                              date:(nullable NSDate *)date NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
