#import "HUBComponentIdentifier.h"


@interface HUBComponentIdentifier ()
@property (nonatomic, copy, readwrite) NSString *componentNamespace;
@property (nonatomic, copy, readwrite) NSString *componentName;
@end


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

- (instancetype)initWithString:(NSString *)identifierString
{
    NSArray<NSString *> * const splitModelIdentifier = [identifierString componentsSeparatedByString:@":"];

    if (splitModelIdentifier.count != 2) {
        return nil;
    }

    return [self initWithNamespace:splitModelIdentifier[0] name:splitModelIdentifier[1]];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[HUBComponentIdentifier allocWithZone:zone] initWithNamespace:self.componentNamespace
                                                                     name:self.componentName];
}


#pragma mark - Equality and Hashing

- (BOOL)isEqualToComponentIdentifier:(HUBComponentIdentifier *)componentIdentifier
{
    return [self.componentNamespace isEqualToString:componentIdentifier.componentNamespace] &&
            [self.componentName isEqualToString:componentIdentifier.componentName];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    return [self isEqualToComponentIdentifier:other];
}

- (NSUInteger)hash
{
    return [self.componentNamespace hash] ^ [self.componentName hash];
}

@end
