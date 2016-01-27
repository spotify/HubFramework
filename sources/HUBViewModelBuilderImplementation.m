#import "HUBViewModelBuilderImplementation.h"

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilderImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelBuilderImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *headerComponentModelBuilders;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *bodyComponentModelBuilders;

@end

@implementation HUBViewModelBuilderImplementation

@synthesize viewIdentifier = _viewIdentifier;
@synthesize featureIdentifier = _featureIdentifier;
@synthesize entityIdentifier = _entityIdentifier;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize extensionURL = _extensionURL;
@synthesize customData = _customData;

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
{
    NSParameterAssert(featureIdentifier != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _viewIdentifier = [NSUUID UUID].UUIDString;
    _featureIdentifier = featureIdentifier;
    _headerComponentModelBuilders = [NSMutableDictionary new];
    _bodyComponentModelBuilders = [NSMutableDictionary new];
    
    return self;
}

#pragma mark - HUBViewModelBuilder

- (BOOL)builderExistsForHeaderComponentModelWithIdentifier:(NSString *)identifier
{
    return [self.headerComponentModelBuilders objectForKey:identifier] != nil;
}

- (id<HUBComponentModelBuilder>)builderForHeaderComponentModelWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForComponentModelWithIdentifier:identifier fromDictionary:self.headerComponentModelBuilders];
}

- (BOOL)builderExistsForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    return [self.bodyComponentModelBuilders objectForKey:identifier] != nil;
}

- (id<HUBComponentModelBuilder>)builderForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForComponentModelWithIdentifier:identifier fromDictionary:self.bodyComponentModelBuilders];
}

#pragma mark - API

- (HUBViewModelImplementation *)build
{
    NSMutableArray * const headerComponentModels = [NSMutableArray new];
    NSMutableArray * const bodyComponentModels = [NSMutableArray new];
    
    for (HUBComponentModelBuilderImplementation * const builder in self.headerComponentModelBuilders) {
        [headerComponentModels addObject:[builder build]];
    }
    
    for (HUBComponentModelBuilderImplementation * const builder in self.bodyComponentModelBuilders) {
        [bodyComponentModels addObject:[builder build]];
    }
    
    return [[HUBViewModelImplementation alloc] initWithIdentifier:self.viewIdentifier
                                                featureIdentifier:self.featureIdentifier
                                                 entityIdentifier:self.entityIdentifier
                                               navigationBarTitle:self.navigationBarTitle
                                            headerComponentModels:[headerComponentModels copy]
                                              bodyComponentModels:[bodyComponentModels copy]
                                                     extensionURL:self.extensionURL
                                                       customData:[self.customData copy]];
}

#pragma mark - Private utilities

- (id<HUBComponentModelBuilder>)getOrCreateBuilderForComponentModelWithIdentifier:(NSString *)identifier
                                                                   fromDictionary:(NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *)dictionary
{
    id<HUBComponentModelBuilder> const existingBuilder = [dictionary objectForKey:identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    id<HUBComponentModelBuilder> const newBuilder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:identifier];
    [dictionary setObject:newBuilder forKey:identifier];
    return newBuilder;
}

@end

NS_ASSUME_NONNULL_END
