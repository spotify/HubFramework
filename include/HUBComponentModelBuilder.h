#import <Foundation/Foundation.h>

#import "HUBComponentImageDataBuilder.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API for a builder that builds component model objects
 *
 *  This builder acts like a mutable model counterpart for `HUBComponentModel`, with the key
 *  difference that they are not related by inheritance.
 *
 *  All properties are briefly documented as part of this protocol, but for more extensive
 *  documentation and use case examples, see the full documentation in the `HUBComponentModel`
 *  protocol definition.
 */
@protocol HUBComponentModelBuilder <NSObject>

/// The identifier of the model that this builder is for
@property (nonatomic, copy, readonly) NSString *modelIdentifier;

/// The (fully namespaced) identifier of the component that this model should be rendered using
@property (nonatomic, copy) NSString *componentIdentifier;

/// Any identifier for the model's content, that can be used for content tracking
@property (nonatomic, copy, nullable) NSString *contentIdentifier;

/// The index that the component would prefer to be placed at. Can be used to move components locally.
@property (nonatomic, copy, nullable) NSNumber *preferredIndex;

/// Any title that the component should render
@property (nonatomic, copy, nullable) NSString *title;

/// Any subtitle that the component should render
@property (nonatomic, copy, nullable) NSString *subtitle;

/// Any accessory title that the component should render
@property (nonatomic, copy, nullable) NSString *accessoryTitle;

/// Any longer describing text that the component should render
@property (nonatomic, copy, nullable) NSString *descriptionText;

/// A builder that can be used to construct data that describes what type of image the component should render
@property (nonatomic, strong, readonly) id<HUBComponentImageDataBuilder> imageData;

/// Any URL that is the target of a user interaction with the component
@property (nonatomic, copy, nullable) NSURL *targetURL;

/// Any custom data that the component should use
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSObject *> *customData;

/// Any data that should be logged alongside interactions or impressions for the component
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSObject<NSCoding> *> *loggingData;

/// Any date that is associated with the component
@property (nonatomic, strong, nullable) NSDate *date;

@end

NS_ASSUME_NONNULL_END
