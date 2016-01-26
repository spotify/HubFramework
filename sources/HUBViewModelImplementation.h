#import "HUBViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModel` API
@interface HUBViewModelImplementation : NSObject <HUBViewModel>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param identifier The identifier of the view
 *  @param featureIdentifier The identifier of the feature that the view belongs to
 *  @param entityIdentifier The identifier of any entity that the view represents
 *  @param navigationBarTitle The title that the view should have in the navigation bar
 *  @param headerComponentModels The models for the components that make up the view's header
 *  @param bodyComponentModels The models for the components that make up the view's body
 *  @param extensionURL Any HTTP URL from which data can be downloaded to extend this view model
 *  @param customData Any custom data that should be associated with the view
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                 featureIdentifier:(NSString *)featureIdentifier
                  entityIdentifier:(nullable NSString *)entityIdentifier
                navigationBarTitle:(nullable NSString *)navigationBarTitle
             headerComponentModels:(NSArray<id<HUBComponentModel>> *)headerComponentModels
               bodyComponentModels:(NSArray<id<HUBComponentModel>> *)bodyComponentModels
                      extensionURL:(nullable NSURL *)extensionURL
                        customData:(NSDictionary<NSString *, NSObject *> *)customData NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
