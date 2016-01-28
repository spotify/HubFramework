#import "HUBJSONPathImplementation.h"

#import "HUBMutableJSONPathImplementation.h"
#import "HUBJSONParsingOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONPathImplementation ()

@property (nonatomic, strong, readonly) NSArray<HUBJSONParsingOperation *> *parsingOperations;

@end

@implementation HUBJSONPathImplementation

- (instancetype)initWithParsingOperations:(NSArray<HUBJSONParsingOperation *> *)parsingOperations
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _parsingOperations = parsingOperations;
    
    return self;
}

#pragma mark - HUBDictionaryPath

- (nullable NSArray<NSObject *> *)valuesFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    NSArray<NSObject *> *currentValues = @[dictionary];
    
    for (HUBJSONParsingOperation * const operation in self.parsingOperations) {
        currentValues = [self valuesByPerformingParsingOperation:operation withInputValues:currentValues];
        
        if (currentValues == nil) {
            return nil;
        }
    }
    
    return currentValues;
}

- (id<HUBMutableJSONPath>)mutableCopy
{
    return [[HUBMutableJSONPathImplementation alloc] initWithParsingOperations:self.parsingOperations];
}

#pragma mark - HUBJSONBoolPath

- (BOOL)boolFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    // Type-checking is performed by a parsing operation appended by `HUBMutableJSONPathImplementation`
    return [(NSNumber *)[[self valuesFromJSONDictionary:dictionary] firstObject] boolValue];
}

#pragma mark - HUBJSONIntegerPath

- (NSInteger)integerFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    // Type-checking is performed by a parsing operation appended by `HUBMutableJSONPathImplementation`
    return [(NSNumber *)[[self valuesFromJSONDictionary:dictionary] firstObject] integerValue];
}

#pragma mark - HUBJSONStringPath

- (nullable NSString *)stringFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    // Type-checking is performed by a parsing operation appended by `HUBMutableJSONPathImplementation`
    return (NSString *)[[self valuesFromJSONDictionary:dictionary] firstObject];
}

#pragma mark - HUBJSONURLPath

- (nullable NSURL *)URLFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    // Type-checking is performed by a parsing operation appended by `HUBMutableJSONPathImplementation`
    return (NSURL *)[[self valuesFromJSONDictionary:dictionary] firstObject];
}

#pragma mark - HUBJSONDatePath

- (nullable NSDate *)dateFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    // Type-checking is performed by a parsing operation appended by `HUBMutableJSONPathImplementation`
    return (NSDate *)[[self valuesFromJSONDictionary:dictionary] firstObject];
}

#pragma mark - HUBJSONDictionaryPath

- (nullable NSDictionary<NSString *, NSObject *> *)dictionaryFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    // Type-checking is performed by a parsing operation appended by `HUBMutableJSONPathImplementation`
    return (NSDictionary<NSString *, NSObject *> *)[[self valuesFromJSONDictionary:dictionary] firstObject];
}

#pragma mark - Private utilities

- (nullable NSArray<NSObject *> *)valuesByPerformingParsingOperation:(HUBJSONParsingOperation *)operation withInputValues:(NSArray<NSObject *> *)inputValues
{
    NSMutableArray * const outputValues = [NSMutableArray new];
    
    for (NSObject * const value in inputValues) {
        NSArray * const operationOutput = [operation parsedValuesForInput:value];
        
        if (operationOutput == nil) {
            return nil;
        }
        
        [outputValues addObjectsFromArray:operationOutput];
    }
    
    return [outputValues copy];
}

@end

NS_ASSUME_NONNULL_END
