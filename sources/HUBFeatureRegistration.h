#import <Foundation/Foundation.h>

@protocol HUBContentProviderFactory;
@protocol HUBContentReloadPolicy;
@class HUBViewURIPredicate;

NS_ASSUME_NONNULL_BEGIN

/// Model object representing a feature registered with the Hub Framework
@interface HUBFeatureRegistration : NSObject

/// The identifier of the feature that this registration is for
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/// The view URI predicate that the feature will use
@property (nonatomic, strong, readonly) HUBViewURIPredicate *viewURIPredicate;

/// The content provider factories that the feature is using
@property (nonatomic, strong, readonly) NSArray<id<HUBContentProviderFactory>> *contentProviderFactories;

/// Any custom content reload policy that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBContentReloadPolicy> contentReloadPolicy;

/// The identifier of any custom JSON schema that the feature is using
@property (nonatomic, copy, nullable, readonly) NSString *customJSONSchemaIdentifier;

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param featureIdentifier The identifier of the feature
 *  @param viewURIPredicate The view URI predicate that the feature will use
 *  @param contentProviderFactories The content provider factories that the feature will use
 *  @param contentReloadPolicy Any custom content reload policy that the feature will use
 *  @param customJSONSchemaIdentifier The identifier of any custom JSON schema the feature will use
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                         viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                 contentProviderFactories:(NSArray<id<HUBContentProviderFactory>> *)contentProviderFactories
                      contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
