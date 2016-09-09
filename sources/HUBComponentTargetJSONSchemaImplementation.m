#import "HUBComponentTargetJSONSchemaImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBMutableJSONPathImplementation.h"

@implementation HUBComponentTargetJSONSchemaImplementation

@synthesize URIPath = _URIPath;
@synthesize initialViewModelDictionaryPath = _initialViewModelDictionaryPath;
@synthesize customDataPath = _customDataPath;

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithURIPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyURI] URLPath]
  initialViewModelDictionaryPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyView] dictionaryPath]
                  customDataPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyCustom] dictionaryPath]];
}

- (instancetype)initWithURIPath:(id<HUBJSONURLPath>)URIPath
 initialViewModelDictionaryPath:(id<HUBJSONDictionaryPath>)initialViewModelDictionaryPath
                 customDataPath:(id<HUBJSONDictionaryPath>)customDataPath
{
    self = [super init];
    
    if (self) {
        _URIPath = URIPath;
        _initialViewModelDictionaryPath = initialViewModelDictionaryPath;
        _customDataPath = customDataPath;
    }
    
    return self;
}

#pragma mark - HUBComponentTargetJSONSchema

- (id)copy
{
    return [[HUBComponentTargetJSONSchemaImplementation alloc] initWithURIPath:self.URIPath
                                                initialViewModelDictionaryPath:self.initialViewModelDictionaryPath
                                                                customDataPath:self.customDataPath];
}

@end
