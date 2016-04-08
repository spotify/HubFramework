#import "HUBJSONSchema.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBJSONSchema` API
@interface HUBJSONSchemaImplementation : NSObject <HUBJSONSchema>

/**
 *  Initialize an instance of this class with the default component namespace
 *
 *  @param defaultComponentNamespace The default component namespace of this Hub Framework instance
 */
- (instancetype)initWithDefaultComponentNamespace:(NSString *)defaultComponentNamespace;

/**
 *  Initialize an instance of this class with all required sub-schemas
 *
 *  @param viewModelSchema The schema to use for view models
 *  @param componentModelSchema The schema to use for component models
 *  @param componentImageDataSchema The schema to use for component image data
 *  @param defaultComponentNamespace The default component namespace of this Hub Framework instance
 *
 *  In order to create default implementations of all sub-schemas, use the convenience initializer.
 */
- (instancetype)initWithViewModelSchema:(id<HUBViewModelJSONSchema>)viewModelSchema
                   componentModelSchema:(id<HUBComponentModelJSONSchema>)componentModelSchema
               componentImageDataSchema:(id<HUBComponentImageDataJSONSchema>)componentImageDataSchema
              defaultComponentNamespace:(NSString *)defaultComponentNamespace HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
