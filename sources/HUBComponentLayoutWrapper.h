#import "HUBComponentWrapper.h"
#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Special component wrapper used during the layout calculation phase of a Hub Framework view's lifecycle
 *
 *  This component wrapper is only used by `HUBCollectionViewLayout` to provide a consistent interface to
 *  components even during the layout phase.
 */
@interface HUBComponentLayoutWrapper : NSObject <HUBComponentWrapper>

/**
 *  Initialize an instance of this class with a component and a component model
 *
 *  @param component The component to wrap
 *  @param model The model that the component will use
 */
- (instancetype)initWithComponent:(id<HUBComponent>)component
                            model:(id<HUBComponentModel>)model HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
