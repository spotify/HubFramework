#import "HUBComponentMock.h"
#import "HUBComponentImageData.h"

@interface HUBComponentMock ()

@property (nonatomic, strong, readwrite, nullable) id<HUBComponentImageData> mainImageData;
@property (nonatomic, readwrite) NSUInteger numberOfReuses;

@end

@implementation HUBComponentMock

@synthesize view = _view;
@synthesize childEventHandler = _childEventHandler;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _layoutTraits = [NSMutableSet new];
        _canHandleImages = YES;
    }
    
    return self;
}

#pragma mark - HUBComponent

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)prepareViewForReuse
{
    self.numberOfReuses++;
}

- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return self.preferredViewSize;
}

- (void)configureViewWithModel:(id<HUBComponentModel>)model
{
    // No-op
}

#pragma mark - HUBComponentWithImageHandling

- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return CGSizeMake(100, 100);
}

- (void)updateViewForLoadedImage:(UIImage *)image fromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model animated:(BOOL)animated
{
    switch (imageData.type) {
        case HUBComponentImageTypeMain:
            self.mainImageData = imageData;
            break;
        case HUBComponentImageTypeBackground:
        case HUBComponentImageTypeCustom:
            break;
    }
}

#pragma mark - Mocking tools

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    if (protocol == @protocol(HUBComponentWithImageHandling)) {
        return self.canHandleImages;
    }
    
    return [super conformsToProtocol:protocol];
}

@end
