#import "HUBComponentUIStateManager.h"

#import "HUBComponentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentUIStateManager ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id> *statesForComponentModelIdentifiers;

@end

@implementation HUBComponentUIStateManager

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _statesForComponentModelIdentifiers = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (void)saveUIState:(id)state forComponentModel:(id<HUBComponentModel>)componentModel
{
    self.statesForComponentModelIdentifiers[componentModel.identifier] = state;
}

- (nullable id)restoreUIStateForComponentModel:(id<HUBComponentModel>)componentModel
{
    return self.statesForComponentModelIdentifiers[componentModel.identifier];
}

- (void)removeSavedUIStateForComponentModel:(id<HUBComponentModel>)componentModel
{
    self.statesForComponentModelIdentifiers[componentModel.identifier] = nil;
}

@end

NS_ASSUME_NONNULL_END
