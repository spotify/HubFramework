#import "HUBComponentImageDataJSONSchemaImplementation.h"

#import "HUBComponentImageDataImplementation.h"
#import "HUBMutableJSONPathImplementation.h"
#import "HUBJSONKeys.h"

@implementation HUBComponentImageDataJSONSchemaImplementation

@synthesize URLPath = _URLPath;
@synthesize placeholderIconIdentifierPath = _placeholderIconIdentifierPath;

- (instancetype)init
{
    return [self initWithURLPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyURI] URLPath]
   placeholderIconIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyPlaceholder] stringPath]];
}

- (instancetype)initWithURLPath:(id<HUBJSONURLPath>)URLPath
  placeholderIconIdentifierPath:(id<HUBJSONStringPath>)placeholderIconIdentifierPath
{
    self = [super init];
    
    if (self) {
        _URLPath = URLPath;
        _placeholderIconIdentifierPath = placeholderIconIdentifierPath;
    }
    
    return self;
}

#pragma mark - HUBComponentImageDataJSONSchema

- (id)copy
{
    return [[HUBComponentImageDataJSONSchemaImplementation alloc] initWithURLPath:self.URLPath
                                                    placeholderIconIdentifierPath:self.placeholderIconIdentifierPath];
}

@end
