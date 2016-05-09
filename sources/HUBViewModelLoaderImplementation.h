#import "HUBViewModelLoader.h"
#import "HUBHeaderMacros.h"

@protocol HUBFeatureInfo;
@protocol HUBJSONSchema;
@protocol HUBContentOperation;
@protocol HUBConnectivityStateResolver;
@protocol HUBIconImageResolver;
@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModelLoader` API
@interface HUBViewModelLoaderImplementation : NSObject <HUBViewModelLoader>

/**
 *  Initialize an instance of this class with its required dependencies & values
 *
 *  @param viewURI The URI of the view that this loader will load view models for
 *  @param featureInfo An object containing information about the feature that the loader will be used for
 *  @param contentOperations The content operations that will create content for loaded view models
 *  @param JSONSchema The JSON schema that the loader should use for parsing
 *  @param componentDefaults The default values to use for component model builders created when loading view models
 *  @param connectivityStateResolver The connectivity state resolver used by the current `HUBManager`
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 *  @param initialViewModel Any pre-registered view model that the loader should include
 */
- (instancetype)initWithViewURI:(NSURL *)viewURI
                    featureInfo:(id<HUBFeatureInfo>)featureInfo
              contentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                     JSONSchema:(id<HUBJSONSchema>)JSONSchema
              componentDefaults:(HUBComponentDefaults *)componentDefaults
      connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
              iconImageResolver:(id<HUBIconImageResolver>)iconImageResolver
               initialViewModel:(nullable id<HUBViewModel>)initialViewModel HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
