#import "HUBComponentFactory.h"

NS_ASSUME_NONNULL_BEGIN

/// Component factory mock
@interface HUBComponentFactoryMock : NSObject <HUBComponentFactory>
@property (nonatomic, copy) NSDictionary *components;
@property (nonatomic, strong) HUBComponentIdentifier *defaultComponentIdentifier;

- (instancetype)initWithComponents:(NSDictionary *)components;
- (void)addAlias:(HUBComponentIdentifier *)alias forName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
