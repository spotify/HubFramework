#import "HUBViewModelLoader.h"
#import "HUBHeaderMacros.h"

@protocol HUBJSONSchema;
@protocol HUBContentProvider;
@protocol HUBConnectivityStateResolver;
@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModelLoader` API
@interface HUBViewModelLoaderImplementation : NSObject <HUBViewModelLoader>

/**
 *  Initialize an instance of this class with its required dependencies & values
 *
 *  @param viewURI The URI of the view that this loader will load view models for
 *  @param featureIdentifier The identifier of the feature that this loader will belong to
 *  @param contentProviders The content providers that will provide content for loaded view models
 *  @param JSONSchema The JSON schema that the loader should use for parsing
 *  @param componentDefaults The default values to use for component model builders created when loading view models
 *  @param connectivityStateResolver The connectivity state resolver used by the current `HUBManager`
 *  @param initialViewModel Any pre-registered view model that the loader should include
 */
- (instancetype)initWithViewURI:(NSURL *)viewURI
              featureIdentifier:(NSString *)featureIdentifier
               contentProviders:(NSArray<id<HUBContentProvider>> *)contentProviders
                     JSONSchema:(id<HUBJSONSchema>)JSONSchema
              componentDefaults:(HUBComponentDefaults *)componentDefaults
      connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
               initialViewModel:(nullable id<HUBViewModel>)initialViewModel HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
