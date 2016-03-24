#import "HUBJSONSchemaRegistryImplementation.h"

#import "HUBJSONSchemaImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONSchemaRegistryImplementation ()

@property (nonatomic, copy, readonly) NSString *defaultComponentNamespace;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBJSONSchema>> *customSchemasByIdentifier;

@end

@implementation HUBJSONSchemaRegistryImplementation

- (instancetype)initWithDefaultComponentNamespace:(NSString *)defaultComponentNamespace
{
    self = [super init];
    
    if (self) {
        _defaultSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:defaultComponentNamespace];
        _defaultComponentNamespace = defaultComponentNamespace;
        _customSchemasByIdentifier = [NSMutableDictionary new];
    }
    
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
    return [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:self.defaultComponentNamespace];
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
