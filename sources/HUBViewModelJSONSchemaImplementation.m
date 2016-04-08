#import "HUBViewModelJSONSchemaImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBMutableJSONPathImplementation.h"

@implementation HUBViewModelJSONSchemaImplementation

@synthesize identifierPath = _identifierPath;
@synthesize featureIdentifierPath = _featureIdentifierPath;
@synthesize entityIdentifierPath = _entityIdentifierPath;
@synthesize navigationBarTitlePath = _navigationBarTitlePath;
@synthesize headerComponentModelDictionaryPath = _headerComponentModelDictionaryPath;
@synthesize bodyComponentModelDictionariesPath = _bodyComponentModelDictionariesPath;
@synthesize extensionURLPath = _extensionURLPath;
@synthesize customDataPath = _customDataPath;

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyIdentifier] stringPath]
                  featureIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyFeature] stringPath]
                   entityIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyEntity] stringPath]
                 navigationBarTitlePath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyTitle] stringPath]
     headerComponentModelDictionaryPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyHeader] dictionaryPath]
     bodyComponentModelDictionariesPath:[[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyBody] forEach] dictionaryPath]
                       extensionURLPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyExtension] URLPath]
                         customDataPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyCustom] dictionaryPath]];
}

- (instancetype)initWithIdentifierPath:(id<HUBJSONStringPath>)identifierPath
                 featureIdentifierPath:(id<HUBJSONStringPath>)featureIdentifierPath
                  entityIdentifierPath:(id<HUBJSONStringPath>)entityIdentifierPath
                navigationBarTitlePath:(id<HUBJSONStringPath>)navigationBarTitlePath
    headerComponentModelDictionaryPath:(id<HUBJSONDictionaryPath>)headerComponentModelDictionaryPath
    bodyComponentModelDictionariesPath:(id<HUBJSONDictionaryPath>)bodyComponentModelDictionariesPath
                      extensionURLPath:(id<HUBJSONURLPath>)extensionURLPath
                        customDataPath:(id<HUBJSONDictionaryPath>)customDataPath
{
    self = [super init];
    
    if (self) {
        _identifierPath = identifierPath;
        _featureIdentifierPath = featureIdentifierPath;
        _entityIdentifierPath = entityIdentifierPath;
        _navigationBarTitlePath = navigationBarTitlePath;
        _headerComponentModelDictionaryPath = headerComponentModelDictionaryPath;
        _bodyComponentModelDictionariesPath = bodyComponentModelDictionariesPath;
        _extensionURLPath = extensionURLPath;
        _customDataPath = customDataPath;
    }
    
    return self;
}

#pragma mark - HUBViewModelJSONSchema

- (id)copy
{
    return [[HUBViewModelJSONSchemaImplementation alloc] initWithIdentifierPath:self.identifierPath
                                                          featureIdentifierPath:self.featureIdentifierPath
                                                           entityIdentifierPath:self.entityIdentifierPath
                                                         navigationBarTitlePath:self.navigationBarTitlePath
                                             headerComponentModelDictionaryPath:self.headerComponentModelDictionaryPath
                                             bodyComponentModelDictionariesPath:self.bodyComponentModelDictionariesPath
                                                               extensionURLPath:self.extensionURLPath
                                                                 customDataPath:self.customDataPath];
}

@end
