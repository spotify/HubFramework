#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol that Hub Framework objects that may be serialized conform to
@protocol HUBSerializable <NSObject>

/**
 *  Serialize the object, creating a JSON dictionary representation of it
 *
 *  The object will be serialized according to its associated default JSON schema (see `HUBJSONSchema` for more information).
 *  Even if the feature that the model belongs to uses a custom JSON schema, the default Hub Framework JSON schema will be used
 *  when serializing the object.
 *
 *  This API can be used for caching, saving state, or to implement tests, etc.
 */
- (NSDictionary<NSString *, NSObject *> *)serialize;

@end

NS_ASSUME_NONNULL_END
