#import "HUBViewModelBuilder.h"
#import "HUBJSONCompatibleBuilder.h"

@class HUBComponentIdentifier;
@class HUBViewModelImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModelBuilder` API
@interface HUBViewModelBuilderImplementation : NSObject <HUBViewModelBuilder, HUBJSONCompatibleBuilder>

/**
 *  Initialize an instance of this class with a feature identifier
 *
 *  @param featureIdentifier The identifier of the feature that this builder is for
 *  @param defaultComponentNamespace The default component namespace that all component builders created
 *         by this builder will have.
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                defaultComponentNamespace:(NSString *)defaultComponentNamespace NS_DESIGNATED_INITIALIZER;

/**
 *  Add data from a JSON array to this builder
 *
 *  @param array The JSON array to extract data from
 *  @param schema The JSON schema to use to extract the data from the dictionary
 *
 *  Each element in the array will be type-checked to be a dictionary, and then parsed as a body
 *  component model dictionary.
 */
- (void)addDataFromJSONArray:(NSArray<NSObject *> *)array
                 usingSchema:(id<HUBJSONSchema>)schema;

/**
 *  Build an instance of `HUBViewModelImplementation` from the data contained in this builder
 */
- (HUBViewModelImplementation *)build;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
