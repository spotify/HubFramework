#import <Foundation/Foundation.h>

/**
 *  Type for objects that describe a component category to use for fallbacks using `HUBComponentFallbackHandler`
 *
 *  An application using the Hub Framework can declare any number of categories to use when performing fallback logic
 *  for components, in case an unknown component namespace/name combo was encountered.
 *
 *  Ideally, a component category should be generic enough to apply to a range of components with similar visuals and
 *  behavior, but still contain enough information for a `HUBComponentFallbackHandler` to create appropriate fallback
 *  components based on them.
 */
typedef NSObject<NSCopying, NSCoding> HUBComponentCategory;

/// Category for components that have a row-like appearance, with a full screen width and a compact height
static HUBComponentCategory * const HUBComponentCategoryRow = @"row";

/// Category for components that have a card-like appearance, that are placable in a grid with compact width & height
static HUBComponentCategory * const HUBComponentCategoryCard = @"card";

/// Category for components that have a carousel-like apperance, with a swipeable horizontal set of child components
static HUBComponentCategory * const HUBComponentCategoryCarousel = @"carousel";

/// Category for components that have a banner-like appearance, imagery-heavy with a full screen width and compact height
static HUBComponentCategory * const HUBComponentCategoryBanner = @"banner";