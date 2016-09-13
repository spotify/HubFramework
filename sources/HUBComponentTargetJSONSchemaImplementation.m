#import "HUBComponentTargetJSONSchemaImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBMutableJSONPathImplementation.h"

@implementation HUBComponentTargetJSONSchemaImplementation

@synthesize URIPath = _URIPath;
@synthesize initialViewModelDictionaryPath = _initialViewModelDictionaryPath;
@synthesize actionIdentifiersPath = _actionIdentifiersPath;
@synthesize customDataPath = _customDataPath;

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithURIPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyURI] URLPath]
  initialViewModelDictionaryPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyView] dictionaryPath]
           actionIdentifiersPath:[[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyActions] forEach] stringPath]
                  customDataPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyCustom] dictionaryPath]];
}

- (instancetype)initWithURIPath:(id<HUBJSONURLPath>)URIPath
 initialViewModelDictionaryPath:(id<HUBJSONDictionaryPath>)initialViewModelDictionaryPath
          actionIdentifiersPath:(id<HUBJSONStringPath>)actionIdentifiersPath
                 customDataPath:(id<HUBJSONDictionaryPath>)customDataPath
{
    self = [super init];
    
    if (self) {
        _URIPath = URIPath;
        _initialViewModelDictionaryPath = initialViewModelDictionaryPath;
        _actionIdentifiersPath = actionIdentifiersPath;
        _customDataPath = customDataPath;
    }
    
    return self;
}

#pragma mark - HUBComponentTargetJSONSchema

- (id)copy
{
    return [[HUBComponentTargetJSONSchemaImplementation alloc] initWithURIPath:self.URIPath
                                                initialViewModelDictionaryPath:self.initialViewModelDictionaryPath
                                                         actionIdentifiersPath:self.actionIdentifiersPath
                                                                customDataPath:self.customDataPath];
}

@end
