#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Type for objects that describe a layout trait to use in a `HUBComponentLayoutManager` to compute margins
 *
 *  Margins between various components and the content edge of a view is determined by inspecting the layout traits
 *  of a given component. Each component has the opportunity to declare its traits through the `layoutTraits` property
 *  of `HUBComponent`.
 *
 *  An application using the Hub Framework may declare additional traits using this type, as its up to the implementation
 *  of `HUBComponentLayoutManager` (conrolled by the application) to determine how to map traits to absolute margins.
 *
 *  Ideally, a layout trait should be generic enough to apply to a broad range of components, but still contain enough
 *  information for a `HUBComponentLayoutManager` to make correct decisions based on them.
 */
typedef NSObject HUBComponentLayoutTrait;

/// Layout trait for components which width does not fill the screen and is considered compact
static HUBComponentLayoutTrait * const HUBComponentLayoutTraitCompactWidth = @"compactWidth";

/// Layout trait for components which width fills the screen
static HUBComponentLayoutTrait * const HUBComponentLayoutTraitFullWidth = @"fullWidth";

/// Layout trait for components which are stackable on top of each other, without any margin in between
static HUBComponentLayoutTrait * const HUBComponentLayoutTraitStackable = @"stackable";


NS_ASSUME_NONNULL_END
