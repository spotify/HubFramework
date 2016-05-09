#import "HUBHeaderMacros.h"

@protocol HUBContentOperationFactory;
@protocol HUBContentReloadPolicy;
@class HUBViewURIPredicate;

NS_ASSUME_NONNULL_BEGIN

/// Model object representing a feature registered with the Hub Framework
@interface HUBFeatureRegistration : NSObject

/// The identifier of the feature that this registration is for
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/// The localized title of the feature that this registration is for
@property (nonatomic, copy, readonly) NSString *featureTitle;

/// The view URI predicate that the feature will use
@property (nonatomic, strong, readonly) HUBViewURIPredicate *viewURIPredicate;

/// The content operation factories that the feature is using
@property (nonatomic, strong, readonly) NSArray<id<HUBContentOperationFactory>> *contentOperationFactories;

/// Any custom content reload policy that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBContentReloadPolicy> contentReloadPolicy;

/// The identifier of any custom JSON schema that the feature is using
@property (nonatomic, copy, nullable, readonly) NSString *customJSONSchemaIdentifier;

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param featureIdentifier The identifier of the feature
 *  @param featureTitle The localized title of the feature
 *  @param viewURIPredicate The view URI predicate that the feature will use
 *  @param contentOperationFactories The content operation factories that the feature will use
 *  @param contentReloadPolicy Any custom content reload policy that the feature will use
 *  @param customJSONSchemaIdentifier The identifier of any custom JSON schema the feature will use
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                                    title:(NSString *)featureTitle
                         viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                contentOperationFactories:(NSArray<id<HUBContentOperationFactory>> *)contentOperationFactories
                      contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
