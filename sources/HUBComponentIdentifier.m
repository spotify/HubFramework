#import "HUBComponentIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentIdentifier

+ (instancetype)identifierWithNamespace:(nullable NSString *)componentNamespace name:(NSString *)componentName
{
    return [[self alloc] initWithNamespace:componentNamespace name:componentName];
}

- (instancetype)initWithNamespace:(nullable NSString *)componentNamespace name:(NSString *)componentName
{
    if (!(self = [super init])) {
        return nil;
    }

    _componentNamespace = [componentNamespace copy];
    _componentName = [componentName copy];

    return self;
}

- (nullable instancetype)initWithString:(NSString *)identifierString
{
    NSArray<NSString *> * const splitModelIdentifier = [identifierString componentsSeparatedByString:@":"];

    if ([splitModelIdentifier firstObject].length == 0) {
        return nil;
    }
    
    if (splitModelIdentifier.count < 2) {
        return [self initWithNamespace:nil name:splitModelIdentifier[0]];
    }

    return [self initWithNamespace:splitModelIdentifier[0] name:splitModelIdentifier[1]];
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
