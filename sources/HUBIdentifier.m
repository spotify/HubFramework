#import "HUBIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBIdentifier

#pragma mark - Initializers

- (instancetype)initWithNamespace:(NSString *)namespacePart name:(NSString *)namePart
{
    NSParameterAssert(namespacePart != nil);
    NSParameterAssert(namePart != nil);
    
    self = [super init];
    
    if (self) {
        _namespacePart = [namespacePart copy];
        _namePart = [namePart copy];
    }
    
    return self;
}

#pragma mark - Property overrides

- (NSString *)identifierString
{
    return [NSString stringWithFormat:@"%@:%@", self.namespacePart, self.namePart];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    return [[HUBIdentifier allocWithZone:zone] initWithNamespace:self.namespacePart
                                                            name:self.namePart];
}

#pragma mark - Equality and Hashing

- (BOOL)isEqualToIdentifier:(HUBIdentifier *)identifier
{
    if (![self.namespacePart isEqualToString:identifier.namespacePart]) {
        return NO;
    }
    
    return [self.namePart isEqualToString:identifier.namePart];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    
    if (![[other class] isEqual:[HUBIdentifier class]]) {
        return NO;
    }

    return [self isEqualToIdentifier:other];
}

- (NSUInteger)hash
{
    return self.namespacePart.hash ^ self.namePart.hash;
}

- (NSString *)description
{
    return self.identifierString;
}

@end

NS_ASSUME_NONNULL_END
