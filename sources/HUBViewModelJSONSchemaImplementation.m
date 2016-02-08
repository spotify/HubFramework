#import "HUBViewModelJSONSchemaImplementation.h"

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
    return [self initWithIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:@"id"] stringPath]
                  featureIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:@"feature"] stringPath]
                   entityIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:@"entity"] stringPath]
                 navigationBarTitlePath:[[[HUBMutableJSONPathImplementation path] goTo:@"title"] stringPath]
     headerComponentModelDictionaryPath:[[[HUBMutableJSONPathImplementation path] goTo:@"header"] dictionaryPath]
     bodyComponentModelDictionariesPath:[[[[HUBMutableJSONPathImplementation path] goTo:@"body"] forEach] dictionaryPath]
                       extensionURLPath:[[[HUBMutableJSONPathImplementation path] goTo:@"extension"] URLPath]
                         customDataPath:[[[HUBMutableJSONPathImplementation path] goTo:@"custom"] dictionaryPath]];
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
    if (!(self = [super init])) {
        return nil;
    }
    
    _identifierPath = identifierPath;
    _featureIdentifierPath = featureIdentifierPath;
    _entityIdentifierPath = entityIdentifierPath;
    _navigationBarTitlePath = navigationBarTitlePath;
    _headerComponentModelDictionaryPath = headerComponentModelDictionaryPath;
    _bodyComponentModelDictionariesPath = bodyComponentModelDictionariesPath;
    _extensionURLPath = extensionURLPath;
    _customDataPath = customDataPath;
    
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
