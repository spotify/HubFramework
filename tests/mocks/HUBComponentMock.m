#import "HUBComponentMock.h"
#import "HUBComponentImageData.h"

@interface HUBComponentMock ()

@property (nonatomic, strong, readwrite, nullable) id<HUBComponentImageData> mainImageData;
@property (nonatomic, readwrite) NSUInteger numberOfReuses;

@end

@implementation HUBComponentMock

@synthesize delegate = _delegate;
@synthesize view = _view;

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _canHandleImages = YES;
    
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
    return CGSizeZero;
}

- (void)configureViewWithModel:(id<HUBComponentModel>)model
{
    // No-op
}

#pragma mark - HUBComponentImageHandler

- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return CGSizeMake(100, 100);
}

- (void)updateViewForLoadedImage:(UIImage *)image fromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model
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
    if (protocol == @protocol(HUBComponentImageHandler)) {
        return self.canHandleImages;
    }
    
    return [super conformsToProtocol:protocol];
}

@end
