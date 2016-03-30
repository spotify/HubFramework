#import "HUBViewModelLoader.h"

@protocol HUBJSONSchema;
@protocol HUBContentProvider;
@protocol HUBConnectivityStateResolver;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModelLoader` API
@interface HUBViewModelLoaderImplementation : NSObject <HUBViewModelLoader>

/**
 *  Initialize an instance of this class with its required dependencies & values
 *
 *  @param viewURI The URI of the view that this loader will load view models for
 *  @param featureIdentifier The identifier of the feature that this loader will belong to
 *  @param defaultComponentNamespace The default namespace that components in loaded view models should have
 *  @param contentProviders The content providers that will provide content for loaded view models
 *  @param JSONSchema The JSON schema that the loader should use for parsing
 *  @param connectivityStateResolver The connectivity state resolver used by the current `HUBManager`
 *  @param initialViewModel Any pre-registered view model that the loader should include
 */
- (instancetype)initWithViewURI:(NSURL *)viewURI
              featureIdentifier:(NSString *)featureIdentifier
      defaultComponentNamespace:(NSString *)defaultComponentNamespace
               contentProviders:(NSArray<id<HUBContentProvider>> *)contentProviders
                     JSONSchema:(id<HUBJSONSchema>)JSONSchema
      connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
               initialViewModel:(nullable id<HUBViewModel>)initialViewModel NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
