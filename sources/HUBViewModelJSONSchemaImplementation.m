#import "HUBViewModelJSONSchemaImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBMutableJSONPathImplementation.h"

@implementation HUBViewModelJSONSchemaImplementation

@synthesize identifierPath = _identifierPath;
@synthesize navigationBarTitlePath = _navigationBarTitlePath;
@synthesize headerComponentModelDictionaryPath = _headerComponentModelDictionaryPath;
@synthesize bodyComponentModelDictionariesPath = _bodyComponentModelDictionariesPath;
@synthesize overlayComponentModelDictionariesPath = _overlayComponentModelDictionariesPath;
@synthesize extensionURLPath = _extensionURLPath;
@synthesize customDataPath = _customDataPath;

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyIdentifier] stringPath]
                 navigationBarTitlePath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyTitle] stringPath]
     headerComponentModelDictionaryPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyHeader] dictionaryPath]
     bodyComponentModelDictionariesPath:[[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyBody] forEach] dictionaryPath]
  overlayComponentModelDictionariesPath:[[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyOverlays] forEach] dictionaryPath]
                       extensionURLPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyExtension] URLPath]
                         customDataPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyCustom] dictionaryPath]];
}

- (instancetype)initWithIdentifierPath:(id<HUBJSONStringPath>)identifierPath
                navigationBarTitlePath:(id<HUBJSONStringPath>)navigationBarTitlePath
    headerComponentModelDictionaryPath:(id<HUBJSONDictionaryPath>)headerComponentModelDictionaryPath
    bodyComponentModelDictionariesPath:(id<HUBJSONDictionaryPath>)bodyComponentModelDictionariesPath
 overlayComponentModelDictionariesPath:(id<HUBJSONDictionaryPath>)overlayComponentModelDictionariesPath
                      extensionURLPath:(id<HUBJSONURLPath>)extensionURLPath
                        customDataPath:(id<HUBJSONDictionaryPath>)customDataPath
{
    self = [super init];
    
    if (self) {
        _identifierPath = identifierPath;
        _navigationBarTitlePath = navigationBarTitlePath;
        _headerComponentModelDictionaryPath = headerComponentModelDictionaryPath;
        _bodyComponentModelDictionariesPath = bodyComponentModelDictionariesPath;
        _overlayComponentModelDictionariesPath = overlayComponentModelDictionariesPath;
        _extensionURLPath = extensionURLPath;
        _customDataPath = customDataPath;
    }
    
    return self;
}

#pragma mark - HUBViewModelJSONSchema

- (id)copy
{
    return [[HUBViewModelJSONSchemaImplementation alloc] initWithIdentifierPath:self.identifierPath
                                                         navigationBarTitlePath:self.navigationBarTitlePath
                                             headerComponentModelDictionaryPath:self.headerComponentModelDictionaryPath
                                             bodyComponentModelDictionariesPath:self.bodyComponentModelDictionariesPath
                                          overlayComponentModelDictionariesPath:self.overlayComponentModelDictionariesPath
                                                               extensionURLPath:self.extensionURLPath
                                                                 customDataPath:self.customDataPath];
}

@end
