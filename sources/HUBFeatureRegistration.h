#import <Foundation/Foundation.h>

@protocol HUBRemoteContentProviderFactory;
@protocol HUBLocalContentProviderFactory;
@protocol HUBViewURIQualifier;

NS_ASSUME_NONNULL_BEGIN

/// Model object representing a feature registered with the Hub Framework
@interface HUBFeatureRegistration : NSObject

/// The identifier of the feature that this registration is for
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/// The root view URI of the feature
@property (nonatomic, copy, readonly) NSURL *rootViewURI;

/// Any remote content provider factory that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBRemoteContentProviderFactory> remoteContentProviderFactory;

/// Any local content provider factory that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBLocalContentProviderFactory> localContentProviderFactory;

/// The identifier of any custom JSON schema that the feature is using
@property (nonatomic, copy, nullable, readonly) NSString *customJSONSchemaIdentifier;

/// Any view URI qualifier that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBViewURIQualifier> viewURIQualifier;

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param featureIdentifier The identifier of the feature
 *  @param rootViewURI The root view URI of the feature
 *  @param remoteContentProviderFactory The remote content provider factory that the feature will use
 *  @param localContentProviderFactory The local content provider factory that the feature will use
 *  @param customJSONSchemaIdentifier The identifier of any custom JSON schema the feature will use
 *  @param viewURIQualifier Any view URI qualifier that the feature will use
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                              rootViewURI:(NSURL *)rootViewURI
             remoteContentProviderFactory:(nullable id<HUBRemoteContentProviderFactory>)remoteContentProviderFactory
              localContentProviderFactory:(nullable id<HUBLocalContentProviderFactory>)localContentProviderFactory
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                         viewURIQualifier:(nullable id<HUBViewURIQualifier>)viewURIQualifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
