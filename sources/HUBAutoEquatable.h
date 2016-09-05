#import <Foundation/Foundation.h>

/**
 *  Abstract base class for types that are automatically checked for equality
 *
 *  This class imlements `-isEqual:` using reflection and KVC, and determines whether
 *  two instances of the same class are equal by inspecting each individual key/value
 *  and checking them for equality. Two objects are only considered equal if all their
 *  key/value pairs are equal.
 *
 *  This class should be used as a superclass only for classes that rely on correctness
 *  and completeness for their equality checks, such as component models. Since the way
 *  the quality checks are performed is relatively expensive, it shouldn't be used for
 *  every class.
 */
@interface HUBAutoEquatable : NSObject

@end
