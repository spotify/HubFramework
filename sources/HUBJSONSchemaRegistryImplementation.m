#import "HUBJSONSchemaRegistryImplementation.h"

#import "HUBJSONSchemaImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONSchemaRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBJSONSchema>> *customSchemasByIdentifier;

@end

@implementation HUBJSONSchemaRegistryImplementation

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _defaultSchema = [HUBJSONSchemaImplementation new];
    _customSchemasByIdentifier = [NSMutableDictionary new];
    
    return self;
}

#pragma mark - API

- (nullable id<HUBJSONSchema>)customSchemaForIdentifier:(NSString *)identifier
{
    return self.customSchemasByIdentifier[identifier];
}

#pragma mark - HUBJSONSchemaRegistry

- (id<HUBJSONSchema>)createNewSchema
{
    return [HUBJSONSchemaImplementation new];
}

- (void)registerCustomSchema:(id<HUBJSONSchema>)schema forIdentifier:(NSString *)identifier
{
    NSAssert(self.customSchemasByIdentifier[identifier] == nil,
             @"Attempted to register a JSON schema for an identifier that is already registered: %@",
             identifier);
    
    [self.customSchemasByIdentifier setObject:schema forKey:identifier];
}

@end

NS_ASSUME_NONNULL_END
