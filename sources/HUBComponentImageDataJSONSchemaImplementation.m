#import "HUBComponentImageDataJSONSchemaImplementation.h"

#import "HUBComponentImageData.h"
#import "HUBMutableJSONPathImplementation.h"

@implementation HUBComponentImageDataJSONSchemaImplementation

@synthesize styleStringPath = _styleStringPath;
@synthesize styleStringMap = _styleStringMap;
@synthesize URLPath = _URLPath;
@synthesize iconIdentifierPath = _iconIdentifierPath;

- (instancetype)init
{
    NSDictionary * const styleStringMap = @{
        @"none" : @(HUBComponentImageStyleNone),
        @"rectangular" : @(HUBComponentImageStyleRectangular),
        @"circular" : @(HUBComponentImageStyleCircular)
    };
    
    return [self initWithStyleStringPath:[[[HUBMutableJSONPathImplementation path] goTo:@"style"] stringPath]
                          styleStringMap:styleStringMap
                                 URLPath:[[[HUBMutableJSONPathImplementation path] goTo:@"url"] URLPath]
                      iconIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:@"icon"] stringPath]];
}

- (instancetype)initWithStyleStringPath:(id<HUBJSONStringPath>)styleStringPath
                         styleStringMap:( NSDictionary<NSString *, NSNumber *> *)styleStringMap
                                URLPath:(id<HUBJSONURLPath>)URLPath
                     iconIdentifierPath:(id<HUBJSONStringPath>)iconIdentifierPath
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _styleStringPath = styleStringPath;
    _styleStringMap = styleStringMap;
    _URLPath = URLPath;
    _iconIdentifierPath = iconIdentifierPath;
    
    return self;
}

#pragma mark - HUBComponentImageDataJSONSchema

- (id)copy
{
    return [[HUBComponentImageDataJSONSchemaImplementation alloc] initWithStyleStringPath:self.styleStringPath
                                                                           styleStringMap:self.styleStringMap
                                                                                  URLPath:self.URLPath
                                                                       iconIdentifierPath:self.iconIdentifierPath];
}

@end
