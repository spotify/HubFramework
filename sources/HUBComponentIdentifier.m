#import "HUBComponentIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentIdentifier

- (instancetype)initWithNamespace:(NSString *)componentNamespace name:(NSString *)componentName
{
    if (!(self = [super init])) {
        return nil;
    }

    _componentNamespace = [componentNamespace copy];
    _componentName = [componentName copy];

    return self;
}

- (NSString *)identifierString
{
    if (self.componentNamespace) {
        return [NSString stringWithFormat:@"%@:%@", self.componentNamespace, self.componentName];
    }

    return self.componentName;
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    return [[HUBComponentIdentifier allocWithZone:zone] initWithNamespace:self.componentNamespace
                                                                     name:self.componentName];
}

#pragma mark - Equality and Hashing

- (BOOL)isEqualToComponentIdentifier:(HUBComponentIdentifier *)componentIdentifier
{
    if (componentIdentifier.componentNamespace != nil) {
        NSString * const componentNamespace = componentIdentifier.componentNamespace;
        
        if (![self.componentNamespace isEqualToString:componentNamespace]) {
            return NO;
        }
    } else if (self.componentNamespace != nil) {
        return NO;
    }
    
    return [self.componentName isEqualToString:componentIdentifier.componentName];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    
    if (![[other class] isEqual:[self class]]) {
        return NO;
    }

    return [self isEqualToComponentIdentifier:other];
}

- (NSUInteger)hash
{
    return [self.componentNamespace hash] ^ [self.componentName hash];
}

- (NSString *)description
{
    return self.identifierString;
}

@end

NS_ASSUME_NONNULL_END
