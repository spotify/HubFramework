#import <Foundation/Foundation.h>

@protocol HUBContentProviderFactory;
@protocol HUBViewURIQualifier;

NS_ASSUME_NONNULL_BEGIN

/// Model object representing a feature registered with the Hub Framework
@interface HUBFeatureRegistration : NSObject

/// The identifier of the feature that this registration is for
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/// The root view URI of the feature
@property (nonatomic, copy, readonly) NSURL *rootViewURI;

/// The content provider factories that the feature is using
@property (nonatomic, strong, readonly) NSArray<id<HUBContentProviderFactory>> *contentProviderFactories;

/// The identifier of any custom JSON schema that the feature is using
@property (nonatomic, copy, nullable, readonly) NSString *customJSONSchemaIdentifier;

/// Any view URI qualifier that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBViewURIQualifier> viewURIQualifier;

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param featureIdentifier The identifier of the feature
 *  @param rootViewURI The root view URI of the feature
 *  @param contentProviderFactories The content provider factories that the feature will use
 *  @param customJSONSchemaIdentifier The identifier of any custom JSON schema the feature will use
 *  @param viewURIQualifier Any view URI qualifier that the feature will use
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                              rootViewURI:(NSURL *)rootViewURI
                 contentProviderFactories:(NSArray<id<HUBContentProviderFactory>> *)contentProviderFactories
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                         viewURIQualifier:(nullable id<HUBViewURIQualifier>)viewURIQualifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
