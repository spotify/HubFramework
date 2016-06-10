#import "HUBViewModel.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModel` API
@interface HUBViewModelImplementation : NSObject <HUBViewModel>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param identifier The identifier of the view
 *  @param featureIdentifier The identifier of the feature that the view belongs to
 *  @param navigationBarTitle The title that the view should have in the navigation bar
 *  @param headerComponentModel The model for any component that make up the view's header
 *  @param bodyComponentModels The models for the components that make up the view's body
 *  @param overlayComponentModels The models for the components that will be rendered as overlays
 *  @param extensionURL Any HTTP URL from which data can be downloaded to extend this view model
 *  @param customData Any custom data that should be associated with the view
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                 featureIdentifier:(NSString *)featureIdentifier
                navigationBarTitle:(nullable NSString *)navigationBarTitle
              headerComponentModel:(nullable id<HUBComponentModel>)headerComponentModel
               bodyComponentModels:(NSArray<id<HUBComponentModel>> *)bodyComponentModels
            overlayComponentModels:(NSArray<id<HUBComponentModel>> *)overlayComponentModels
                      extensionURL:(nullable NSURL *)extensionURL
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
