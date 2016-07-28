#import <UIKit/UIKit.h>

@protocol HUBComponentModel;

/**
 *  Protocol defining the public API for a component that has been wrapped by the Hub Framework
 *
 *  The Hub Framework wraps all components that are supplied into it by various `HUBComponentFactory` implementations,
 *  giving you access to the current model that the component is using, and a tailored set of APIs suitable for managing
 *  component instances outside of the framework.
 *
 *  You don't conform to this protocol yourself, instead components created through a component's `childDelegate` will
 *  automatically be wrapped according to this protocol.
 */
@protocol HUBComponentWrapper <NSObject>

/// The identifier of this component instance. Can be used to track it accross various operations.
@property (nonatomic, strong, readonly) NSUUID *identifier;

/// The view that the component is using. The wrapper guarantees that the view is always loaded when accessed.
@property (nonatomic, strong, readonly) UIView *view;

/// The current model that the component is using. Changed whenever the component is reused.
@property (nonatomic, strong, readonly) id<HUBComponentModel> model;

/**
 *  Return the component's preferred view size when displayed in a container with a given size
 *
 *  @param containerViewSize The size of the container, typically the component view's superview
 *
 *  You can use this API to adjust the component view's frame according to a value that both fits the container and the
 *  preference of the component. No components should make an assumption that the value returned from this method is final,
 *  so you are free to tweak it to satisfy other layout rules.
 */
- (CGSize)preferredViewSizeForContainerViewSize:(CGSize)containerViewSize;

/**
 *  Preprare the component for reuse, resigning control over it and returning it to the framework reuse pool
 *
 *  Call this method whenever you are done with a component instance, and wish to return it to the Hub Framework for reuse.
 *  Once called, the framework assumes that you will no longer perform any operations on this instance, until it is requested
 *  again, so make sure to reset any references made to it.
 *
 *  If you are using a `UICollectionView`-based UI to manage components, you can use `HUBComponentCollectionViewCell` to
 *  automatically have your components be reused whenever collection view cells are reused.
 */
- (void)prepareForReuse;

@end
