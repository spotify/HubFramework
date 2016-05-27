#import "HUBMutableJSONPathImplementation.h"

#import "HUBJSONParsingOperation.h"
#import "HUBJSONPathImplementation.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBMutableJSONPathImplementation ()

@property (nonatomic, strong, readonly) NSArray<HUBJSONParsingOperation *> *parsingOperations;

@end

@implementation HUBMutableJSONPathImplementation

#pragma mark - Initializers

+ (instancetype)path
{
    return [[self alloc] initWithParsingOperations:@[]];
}

- (instancetype)initWithParsingOperations:(NSArray<HUBJSONParsingOperation *> *)parsingOperations
{
    NSParameterAssert(parsingOperations != nil);
    
    self = [super init];
    
    if (self) {
        _parsingOperations = parsingOperations;
    }
    
    return self;
}

#pragma mark - HUBMutableJSONPath

- (id<HUBMutableJSONPath>)goTo:(NSString *)key
{
    HUBJSONParsingOperation * const operation = [[HUBJSONParsingOperation alloc] initWithBlock:^NSArray<NSObject *> * _Nullable (NSObject *input) {
        if (![input isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        NSObject * const output = ((NSDictionary *)input)[key];
        
        if (output == nil) {
            return nil;
        }
        
        return @[output];
    }];
    
    return [self pathByAppendingParsingOperation:operation];
}

- (id<HUBMutableJSONPath>)forEach
{
    HUBJSONParsingOperation * const operation = [[HUBJSONParsingOperation alloc] initWithBlock:^NSArray<NSObject *> * _Nullable (NSObject *input) {
        if (![input isKindOfClass:[NSArray class]]) {
            return nil;
        }
        
        return (NSArray *)input;
    }];
    
    return [self pathByAppendingParsingOperation:operation];
}

- (id<HUBMutableJSONPath>)runBlock:(HUBMutableJSONPathBlock)block
{
    HUBJSONParsingOperation * const operation = [[HUBJSONParsingOperation alloc] initWithBlock:^NSArray<NSObject *> * _Nullable (NSObject *input) {
        NSObject * const output = block(input);
        
        if (output == nil) {
            return nil;
        }
        
        return @[output];
    }];
    
    return [self pathByAppendingParsingOperation:operation];
}

- (id<HUBMutableJSONPath>)combineWithPath:(id<HUBMutableJSONPath>)path
{
    HUBJSONParsingOperation * const operation = [[HUBJSONParsingOperation alloc] initWithBlock:^NSArray<NSObject *> * _Nullable (NSObject *input) {
        if (![input isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        NSDictionary * const dictionary = (NSDictionary *)input;
        NSMutableArray<NSObject *> * const output = [NSMutableArray new];
        
        NSArray<NSObject *> * const originalOutput = [[self copy] valuesFromJSONDictionary:dictionary];
        
        if (originalOutput != nil) {
            [output addObjectsFromArray:originalOutput];
        }
        
        NSArray<NSObject *> * const addedOutput = [[path copy] valuesFromJSONDictionary:dictionary];
        
        if (addedOutput != nil) {
            [output addObjectsFromArray:addedOutput];
        }
        
        return [output copy];
    }];
    
    return [[HUBMutableJSONPathImplementation alloc] initWithParsingOperations:@[operation]];
}

- (id<HUBJSONBoolPath>)boolPath
{
    return [self destinationPathWithExpectedType:[NSNumber class]];
}

- (id<HUBJSONIntegerPath>)integerPath
{
    return [self destinationPathWithExpectedType:[NSNumber class]];
}

- (id<HUBJSONStringPath>)stringPath
{
    return [self destinationPathWithExpectedType:[NSString class]];
}

- (id<HUBJSONURLPath>)URLPath
{
    HUBJSONParsingOperation * const formattingOperation = [[HUBJSONParsingOperation alloc] initWithBlock:^NSArray<NSObject *> * _Nullable (NSObject *input) {
        if (![input isKindOfClass:[NSString class]]) {
            return nil;
        }
        
        NSURL * const URL = [NSURL URLWithString:(NSString *)input];
        
        if (URL == nil) {
            return nil;
        }
        
        return @[URL];
    }];
    
    return [self destinationPathWithFinalParsingOperation:formattingOperation];
}

- (id<HUBJSONDictionaryPath>)dictionaryPath
{
    return [self destinationPathWithExpectedType:[NSDictionary class]];
}

#pragma mark - NSObject

- (id)copy
{
    return [[HUBJSONPathImplementation alloc] initWithParsingOperations:self.parsingOperations];
}

#pragma mark - Private utilities

- (id<HUBMutableJSONPath>)pathByAppendingParsingOperation:(HUBJSONParsingOperation *)operation
{
    NSArray * const operations = [self.parsingOperations arrayByAddingObject:operation];
    return [[HUBMutableJSONPathImplementation alloc] initWithParsingOperations:operations];
}

- (HUBJSONPathImplementation *)destinationPathWithExpectedType:(Class)expectedType
{
    HUBJSONParsingOperation * const typeCheckingOperation = [[HUBJSONParsingOperation alloc] initWithBlock:^NSArray<NSObject *> * _Nullable (NSObject *input) {
        if (![input isKindOfClass:expectedType]) {
            return nil;
        }
        
        return @[input];
    }];
    
    return [self destinationPathWithFinalParsingOperation:typeCheckingOperation];
}

- (HUBJSONPathImplementation *)destinationPathWithFinalParsingOperation:(HUBJSONParsingOperation *)operation
{
    NSArray * const operations = [self.parsingOperations arrayByAddingObject:operation];
    return [[HUBJSONPathImplementation alloc] initWithParsingOperations:operations];
}

@end

NS_ASSUME_NONNULL_END
