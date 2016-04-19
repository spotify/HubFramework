#import "HUBComponentImageDataJSONSchemaImplementation.h"

#import "HUBComponentImageDataImplementation.h"
#import "HUBMutableJSONPathImplementation.h"
#import "HUBJSONKeys.h"

@implementation HUBComponentImageDataJSONSchemaImplementation

@synthesize styleStringPath = _styleStringPath;
@synthesize styleStringMap = _styleStringMap;
@synthesize URLPath = _URLPath;
@synthesize placeholderIdentifierPath = _placeholderIdentifierPath;

- (instancetype)init
{
    NSDictionary * const styleStringMap = @{
        HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleNone) : @(HUBComponentImageStyleNone),
        HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleRectangular) : @(HUBComponentImageStyleRectangular),
        HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleCircular) : @(HUBComponentImageStyleCircular)
    };
    
    return [self initWithStyleStringPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyStyle] stringPath]
                          styleStringMap:styleStringMap
                                 URLPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyURI] URLPath]
               placeholderIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyPlaceholder] stringPath]];
}

- (instancetype)initWithStyleStringPath:(id<HUBJSONStringPath>)styleStringPath
                         styleStringMap:( NSDictionary<NSString *, NSNumber *> *)styleStringMap
                                URLPath:(id<HUBJSONURLPath>)URLPath
              placeholderIdentifierPath:(id<HUBJSONStringPath>)placeholderIdentifierPath
{
    self = [super init];
    
    if (self) {
        _styleStringPath = styleStringPath;
        _styleStringMap = styleStringMap;
        _URLPath = URLPath;
        _placeholderIdentifierPath = placeholderIdentifierPath;
    }
    
    return self;
}

#pragma mark - HUBComponentImageDataJSONSchema

- (id)copy
{
    return [[HUBComponentImageDataJSONSchemaImplementation alloc] initWithStyleStringPath:self.styleStringPath
                                                                           styleStringMap:self.styleStringMap
                                                                                  URLPath:self.URLPath
                                                                placeholderIdentifierPath:self.placeholderIdentifierPath];
}

@end
