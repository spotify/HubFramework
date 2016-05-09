#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of an object that contains information about a Hub Framework feature
 *
 *  You don't conform to this protocol yourself, instead the Hub Framework will create instances conforming
 *  to this protocol based on the information a feature provided when it was registered with the framework.
 */
@protocol HUBFeatureInfo <NSObject>

/// The identifier of the feature
@property (nonatomic, copy, readonly) NSString *identifier;

/// The localized title of the feature
@property (nonatomic, copy, readonly) NSString *title;

@end

NS_ASSUME_NONNULL_END
