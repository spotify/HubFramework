#import "HUBComponentModelJSONSchemaImplementation.h"

#import "HUBMutableJSONPathImplementation.h"
#import "HUBJSONKeys.h"

@implementation HUBComponentModelJSONSchemaImplementation

@synthesize identifierPath = _identifierPath;
@synthesize componentIdentifierPath = _componentIdentifierPath;
@synthesize componentCategoryPath = _componentCategoryPath;
@synthesize contentIdentifierPath = _contentIdentifierPath;
@synthesize titlePath = _titlePath;
@synthesize subtitlePath = _subtitlePath;
@synthesize accessoryTitlePath = _accessoryTitlePath;
@synthesize descriptionTextPath = _descriptionTextPath;
@synthesize mainImageDataDictionaryPath = _mainImageDataDictionaryPath;
@synthesize backgroundImageDataDictionaryPath = _backgroundImageDataDictionaryPath;
@synthesize customImageDataDictionaryPath = _customImageDataDictionaryPath;
@synthesize targetURLPath = _targetURLPath;
@synthesize targetInitialViewModelDictionaryPath = _targetInitialViewModelDictionaryPath;
@synthesize customDataPath = _customDataPath;
@synthesize loggingDataPath = _loggingDataPath;
@synthesize datePath = _datePath;
@synthesize childComponentModelDictionariesPath = _childComponentModelDictionariesPath;

- (instancetype)init
{
    id<HUBMutableJSONPath> const componentDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyComponent];
    id<HUBMutableJSONPath> const imagesDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyImages];
    id<HUBMutableJSONPath> const targetDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyTarget];
    
    return [self initWithIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyIdentifier] stringPath]
                componentIdentifierPath:[[componentDictionaryPath goTo:HUBJSONKeyIdentifier] stringPath]
                  componentCategoryPath:[[componentDictionaryPath goTo:HUBJSONKeyCategory] stringPath]
                  contentIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyContentIdentifier] stringPath]
                              titlePath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyTitle] stringPath]
                           subtitlePath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeySubtitle] stringPath]
                     accessoryTitlePath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyAccessoryTitle] stringPath]
                    descriptionTextPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyDescription] stringPath]
            mainImageDataDictionaryPath:[[imagesDictionaryPath goTo:HUBJSONKeyMain] dictionaryPath]
      backgroundImageDataDictionaryPath:[[imagesDictionaryPath goTo:HUBJSONKeyBackground] dictionaryPath]
          customImageDataDictionaryPath:[[imagesDictionaryPath goTo:HUBJSONKeyCustom] dictionaryPath]
                          targetURLPath:[[targetDictionaryPath goTo:HUBJSONKeyURL] URLPath]
   targetInitialViewModelDictionaryPath:[[targetDictionaryPath goTo:HUBJSONKeyView] dictionaryPath]
                         customDataPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyCustom] dictionaryPath]
                        loggingDataPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyLogging] dictionaryPath]
                               datePath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyDate] datePath]
    childComponentModelDictionariesPath:[[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyChildren] forEach] dictionaryPath]];
}

- (instancetype)initWithIdentifierPath:(id<HUBJSONStringPath>)identifierPath
               componentIdentifierPath:(id<HUBJSONStringPath>)componentIdentiferPath
                 componentCategoryPath:(id<HUBJSONStringPath>)componentCategoryPath
                 contentIdentifierPath:(id<HUBJSONStringPath>)contentIdentifierPath
                             titlePath:(id<HUBJSONStringPath>)titlePath
                          subtitlePath:(id<HUBJSONStringPath>)subtitlePath
                    accessoryTitlePath:(id<HUBJSONStringPath>)accessoryTitlePath
                   descriptionTextPath:(id<HUBJSONStringPath>)descriptionTextPath
           mainImageDataDictionaryPath:(id<HUBJSONDictionaryPath>)mainImageDataDictionaryPath
     backgroundImageDataDictionaryPath:(id<HUBJSONDictionaryPath>)backgroundImageDataDictionaryPath
         customImageDataDictionaryPath:(id<HUBJSONDictionaryPath>)customImageDataDictionaryPath
                         targetURLPath:(id<HUBJSONURLPath>)targetURLPath
  targetInitialViewModelDictionaryPath:(id<HUBJSONDictionaryPath>)targetInitialViewModelDictionaryPath
                        customDataPath:(id<HUBJSONDictionaryPath>)customDataPath
                       loggingDataPath:(id<HUBJSONDictionaryPath>)loggingDataPath
                              datePath:(id<HUBJSONDatePath>)datePath
   childComponentModelDictionariesPath:(id<HUBJSONDictionaryPath>)childComponentModelDictionariesPath
{
    self = [super init];
    
    if (self) {
        _identifierPath = identifierPath;
        _componentIdentifierPath = componentIdentiferPath;
        _componentCategoryPath = componentCategoryPath;
        _contentIdentifierPath = contentIdentifierPath;
        _titlePath = titlePath;
        _subtitlePath = subtitlePath;
        _accessoryTitlePath = accessoryTitlePath;
        _descriptionTextPath = descriptionTextPath;
        _mainImageDataDictionaryPath = mainImageDataDictionaryPath;
        _backgroundImageDataDictionaryPath = backgroundImageDataDictionaryPath;
        _customImageDataDictionaryPath = customImageDataDictionaryPath;
        _targetURLPath = targetURLPath;
        _targetInitialViewModelDictionaryPath = targetInitialViewModelDictionaryPath;
        _customDataPath = customDataPath;
        _loggingDataPath = loggingDataPath;
        _datePath = datePath;
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
                                                               contentIdentifierPath:self.contentIdentifierPath
                                                                           titlePath:self.titlePath
                                                                        subtitlePath:self.subtitlePath
                                                                  accessoryTitlePath:self.accessoryTitlePath
                                                                 descriptionTextPath:self.descriptionTextPath
                                                         mainImageDataDictionaryPath:self.mainImageDataDictionaryPath
                                                   backgroundImageDataDictionaryPath:self.backgroundImageDataDictionaryPath
                                                       customImageDataDictionaryPath:self.customImageDataDictionaryPath
                                                                       targetURLPath:self.targetURLPath
                                                targetInitialViewModelDictionaryPath:self.targetInitialViewModelDictionaryPath
                                                                      customDataPath:self.customDataPath
                                                                     loggingDataPath:self.loggingDataPath
                                                                            datePath:self.datePath
                                                 childComponentModelDictionariesPath:self.childComponentModelDictionariesPath];
}

@end
