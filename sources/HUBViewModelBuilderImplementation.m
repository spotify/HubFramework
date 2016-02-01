#import "HUBViewModelBuilderImplementation.h"

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelBuilderImplementation ()

@property (nonatomic, strong, readonly) HUBComponentModelBuilderImplementation *headerComponentModelBuilderImplementation;
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
    _headerComponentModelBuilderImplementation = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"header"];
    _bodyComponentModelBuilders = [NSMutableDictionary new];
    
    return self;
}

#pragma mark - HUBViewModelBuilder

- (id<HUBComponentModelBuilder>)headerComponentModelBuilder
{
    return self.headerComponentModelBuilderImplementation;
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
    HUBComponentModelImplementation *headerComponentModel;
    
    if (self.headerComponentModelBuilder.componentIdentifier != nil) {
        headerComponentModel = [self.headerComponentModelBuilderImplementation build];
    } else {
        headerComponentModel = nil;
    }
    
    NSMutableArray * const bodyComponentModels = [NSMutableArray new];
    
    for (HUBComponentModelBuilderImplementation * const builder in self.bodyComponentModelBuilders) {
        [bodyComponentModels addObject:[builder build]];
    }
    
    return [[HUBViewModelImplementation alloc] initWithIdentifier:self.viewIdentifier
                                                featureIdentifier:self.featureIdentifier
                                                 entityIdentifier:self.entityIdentifier
                                               navigationBarTitle:self.navigationBarTitle
                                             headerComponentModel:headerComponentModel
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
