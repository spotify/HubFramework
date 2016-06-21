#import "HUBViewURIPredicate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewURIPredicate ()

@property (nonatomic, copy, readonly) BOOL(^block)(NSURL *);

@end

@implementation HUBViewURIPredicate

#pragma mark - Class construction methods

+ (HUBViewURIPredicate *)predicateWithViewURI:(NSURL *)viewURI
{
    return [self predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return [evaluatedViewURI isEqual:viewURI];
    }];
}

+ (HUBViewURIPredicate *)predicateWithRootViewURI:(NSURL *)rootViewURI
{
    return [self predicateWithRootViewURI:rootViewURI excludedViewURIs:[NSSet set]];
}

+ (HUBViewURIPredicate *)predicateWithRootViewURI:(NSURL *)rootViewURI excludedViewURIs:(NSSet<NSURL *> *)exludedViewURIs
{
    return [self predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        if ([exludedViewURIs containsObject:evaluatedViewURI]) {
            return NO;
        }
        
        NSString * const rootViewURIAbsoluteString = rootViewURI.absoluteString;
        return [evaluatedViewURI.absoluteString hasPrefix:rootViewURIAbsoluteString];
    }];
}

+ (HUBViewURIPredicate *)predicateWithPredicate:(NSPredicate *)predicate
{
    return [self predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return [predicate evaluateWithObject:evaluatedViewURI];
    }];
}

+ (HUBViewURIPredicate *)predicateWithBlock:(BOOL (^)(NSURL * _Nonnull))block
{
    return [[HUBViewURIPredicate alloc] initWithBlock:block];
}

#pragma mark - Initializer

- (instancetype)initWithBlock:(BOOL(^)(NSURL *))block
{
    NSParameterAssert(block != nil);
    
    self = [super init];
    
    if (self) {
        _block = [block copy];
    }
    
    return self;
}

#pragma mark - API

- (BOOL)evaluateViewURI:(NSURL *)viewURI
{
    return self.block(viewURI);
}

@end

NS_ASSUME_NONNULL_END
