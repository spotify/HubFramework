#import "HUBViewModelLoader.h"

@protocol HUBRemoteContentProvider;
@protocol HUBLocalContentProvider;
@protocol HUBJSONSchema;
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
 *  @param remoteContentProvider Any remote content provider that the loader should use
 *  @param localContentProvider Any local content provider that the loader should use
 *  @param JSONSchema The JSON schema that the loader should use for parsing
 *  @param connectivityStateResolver The connectivity state resolver used by the current `HUBManager`
 */
- (instancetype)initWithViewURI:(NSURL *)viewURI
              featureIdentifier:(NSString *)featureIdentifier
      defaultComponentNamespace:(NSString *)defaultComponentNamespace
          remoteContentProvider:(nullable id<HUBRemoteContentProvider>)remoteContentProvider
           localContentProvider:(nullable id<HUBLocalContentProvider>)localContentProvider
                     JSONSchema:(id<HUBJSONSchema>)JSONSchema
      connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
