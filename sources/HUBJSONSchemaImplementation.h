#import "HUBJSONSchema.h"
#import "HUBHeaderMacros.h"

@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBJSONSchema` API
@interface HUBJSONSchemaImplementation : NSObject <HUBJSONSchema>

/**
 *  Initialize an instance of this class with a set of component default values
 *
 *  @param componentDefaults The default component values to use when parsing JSON
 */
- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults;

/**
 *  Initialize an instance of this class with all required sub-schemas
 *
 *  @param viewModelSchema The schema to use for view models
 *  @param componentModelSchema The schema to use for component models
 *  @param componentImageDataSchema The schema to use for component image data
 *  @param componentDefaults The default component values to use when parsing JSON
 *
 *  In order to create default implementations of all sub-schemas, use the convenience initializer.
 */
- (instancetype)initWithViewModelSchema:(id<HUBViewModelJSONSchema>)viewModelSchema
                   componentModelSchema:(id<HUBComponentModelJSONSchema>)componentModelSchema
               componentImageDataSchema:(id<HUBComponentImageDataJSONSchema>)componentImageDataSchema
                      componentDefaults:(HUBComponentDefaults *)componentDefaults HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
