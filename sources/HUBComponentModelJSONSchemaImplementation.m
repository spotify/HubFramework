#import "HUBComponentModelJSONSchemaImplementation.h"

#import "HUBMutableJSONPathImplementation.h"
#import "HUBJSONKeys.h"

@implementation HUBComponentModelJSONSchemaImplementation

@synthesize identifierPath = _identifierPath;
@synthesize componentIdentifierPath = _componentIdentifierPath;
@synthesize componentCategoryPath = _componentCategoryPath;
@synthesize titlePath = _titlePath;
@synthesize subtitlePath = _subtitlePath;
@synthesize accessoryTitlePath = _accessoryTitlePath;
@synthesize descriptionTextPath = _descriptionTextPath;
@synthesize mainImageDataDictionaryPath = _mainImageDataDictionaryPath;
@synthesize backgroundImageDataDictionaryPath = _backgroundImageDataDictionaryPath;
@synthesize customImageDataDictionaryPath = _customImageDataDictionaryPath;
@synthesize iconIdentifierPath = _iconIdentifierPath;
@synthesize targetURLPath = _targetURLPath;
@synthesize targetInitialViewModelDictionaryPath = _targetInitialViewModelDictionaryPath;
@synthesize customDataPath = _customDataPath;
@synthesize loggingDataPath = _loggingDataPath;
@synthesize childComponentModelDictionariesPath = _childComponentModelDictionariesPath;

- (instancetype)init
{
    id<HUBMutableJSONPath> const componentDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyComponent];
    id<HUBMutableJSONPath> const textDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyText];
    id<HUBMutableJSONPath> const imagesDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyImages];
    id<HUBMutableJSONPath> const targetDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyTarget];
    id<HUBMutableJSONPath> const metadataDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyMetadata];
    
    return [self initWithIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyIdentifier] stringPath]
                componentIdentifierPath:[[componentDictionaryPath goTo:HUBJSONKeyIdentifier] stringPath]
                  componentCategoryPath:[[componentDictionaryPath goTo:HUBJSONKeyCategory] stringPath]
                              titlePath:[[textDictionaryPath goTo:HUBJSONKeyTitle] stringPath]
                           subtitlePath:[[textDictionaryPath goTo:HUBJSONKeySubtitle] stringPath]
                     accessoryTitlePath:[[textDictionaryPath goTo:HUBJSONKeyAccessory] stringPath]
                    descriptionTextPath:[[textDictionaryPath goTo:HUBJSONKeyDescription] stringPath]
            mainImageDataDictionaryPath:[[imagesDictionaryPath goTo:HUBJSONKeyMain] dictionaryPath]
      backgroundImageDataDictionaryPath:[[imagesDictionaryPath goTo:HUBJSONKeyBackground] dictionaryPath]
          customImageDataDictionaryPath:[[imagesDictionaryPath goTo:HUBJSONKeyCustom] dictionaryPath]
                     iconIdentifierPath:[[imagesDictionaryPath goTo:HUBJSONKeyIcon] stringPath]
                          targetURLPath:[[targetDictionaryPath goTo:HUBJSONKeyURI] URLPath]
   targetInitialViewModelDictionaryPath:[[targetDictionaryPath goTo:HUBJSONKeyView] dictionaryPath]
                         customDataPath:[[metadataDictionaryPath goTo:HUBJSONKeyCustom] dictionaryPath]
                        loggingDataPath:[[metadataDictionaryPath goTo:HUBJSONKeyLogging] dictionaryPath]
    childComponentModelDictionariesPath:[[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyChildren] forEach] dictionaryPath]];
}

- (instancetype)initWithIdentifierPath:(id<HUBJSONStringPath>)identifierPath
               componentIdentifierPath:(id<HUBJSONStringPath>)componentIdentiferPath
                 componentCategoryPath:(id<HUBJSONStringPath>)componentCategoryPath
                             titlePath:(id<HUBJSONStringPath>)titlePath
                          subtitlePath:(id<HUBJSONStringPath>)subtitlePath
                    accessoryTitlePath:(id<HUBJSONStringPath>)accessoryTitlePath
                   descriptionTextPath:(id<HUBJSONStringPath>)descriptionTextPath
           mainImageDataDictionaryPath:(id<HUBJSONDictionaryPath>)mainImageDataDictionaryPath
     backgroundImageDataDictionaryPath:(id<HUBJSONDictionaryPath>)backgroundImageDataDictionaryPath
         customImageDataDictionaryPath:(id<HUBJSONDictionaryPath>)customImageDataDictionaryPath
                    iconIdentifierPath:(id<HUBJSONStringPath>)iconIdentifierPath
                         targetURLPath:(id<HUBJSONURLPath>)targetURLPath
  targetInitialViewModelDictionaryPath:(id<HUBJSONDictionaryPath>)targetInitialViewModelDictionaryPath
                        customDataPath:(id<HUBJSONDictionaryPath>)customDataPath
                       loggingDataPath:(id<HUBJSONDictionaryPath>)loggingDataPath
   childComponentModelDictionariesPath:(id<HUBJSONDictionaryPath>)childComponentModelDictionariesPath
{
    self = [super init];
    
    if (self) {
        _identifierPath = identifierPath;
        _componentIdentifierPath = componentIdentiferPath;
        _componentCategoryPath = componentCategoryPath;
        _titlePath = titlePath;
        _subtitlePath = subtitlePath;
        _accessoryTitlePath = accessoryTitlePath;
        _descriptionTextPath = descriptionTextPath;
        _mainImageDataDictionaryPath = mainImageDataDictionaryPath;
        _backgroundImageDataDictionaryPath = backgroundImageDataDictionaryPath;
        _customImageDataDictionaryPath = customImageDataDictionaryPath;
        _iconIdentifierPath = iconIdentifierPath;
        _targetURLPath = targetURLPath;
        _targetInitialViewModelDictionaryPath = targetInitialViewModelDictionaryPath;
        _customDataPath = customDataPath;
        _loggingDataPath = loggingDataPath;
        _childComponentModelDictionariesPath = childComponentModelDictionariesPath;
    }
    
    return self;
}

#pragma mark - HUBComponentModelJSONSchema

- (id)copy
{
    return [[HUBComponentModelJSONSchemaImplementation alloc] initWithIdentifierPath:self.identifierPath
                                                             componentIdentifierPath:self.componentIdentifierPath
                                                               componentCategoryPath:self.componentCategoryPath
                                                                           titlePath:self.titlePath
                                                                        subtitlePath:self.subtitlePath
                                                                  accessoryTitlePath:self.accessoryTitlePath
                                                                 descriptionTextPath:self.descriptionTextPath
                                                         mainImageDataDictionaryPath:self.mainImageDataDictionaryPath
                                                   backgroundImageDataDictionaryPath:self.backgroundImageDataDictionaryPath
                                                       customImageDataDictionaryPath:self.customImageDataDictionaryPath
                                                                  iconIdentifierPath:self.iconIdentifierPath
                                                                       targetURLPath:self.targetURLPath
                                                targetInitialViewModelDictionaryPath:self.targetInitialViewModelDictionaryPath
                                                                      customDataPath:self.customDataPath
                                                                     loggingDataPath:self.loggingDataPath
                                                 childComponentModelDictionariesPath:self.childComponentModelDictionariesPath];
}

@end
