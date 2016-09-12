#import <Foundation/Foundation.h>

/// Enum describing various types of components used in the Hub Framework
typedef NS_ENUM(NSUInteger, HUBComponentType) {
    /// Type of components used in the header of a view
    HUBComponentTypeHeader,
    /// Type of components used in the body of a view
    HUBComponentTypeBody,
    /// Type of components rendered as overlays on top of a view
    HUBComponentTypeOverlay
};
