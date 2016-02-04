#import "HUBComponentModelJSONSchemaImplementation.h"

#import "HUBMutableJSONPathImplementation.h"

@implementation HUBComponentModelJSONSchemaImplementation

@synthesize identifierPath = _identifierPath;
@synthesize componentIdentifierPath = _componentIdentifierPath;
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

- (instancetype)init
{
    HUBMutableJSONPathImplementation * const imagesDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:@"images"];
    HUBMutableJSONPathImplementation * const targetDictionaryPath = [[HUBMutableJSONPathImplementation path] goTo:@"target"];
    
    return [self initWithIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:@"id"] stringPath]
                componentIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:@"component"] stringPath]
                  contentIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:@"contentId"] stringPath]
                              titlePath:[[[HUBMutableJSONPathImplementation path] goTo:@"title"] stringPath]
                           subtitlePath:[[[HUBMutableJSONPathImplementation path] goTo:@"subtitle"] stringPath]
                     accessoryTitlePath:[[[HUBMutableJSONPathImplementation path] goTo:@"accessoryTitle"] stringPath]
                    descriptionTextPath:[[[HUBMutableJSONPathImplementation path] goTo:@"description"] stringPath]
            mainImageDataDictionaryPath:[[imagesDictionaryPath goTo:@"main"] dictionaryPath]
      backgroundImageDataDictionaryPath:[[imagesDictionaryPath goTo:@"background"] dictionaryPath]
          customImageDataDictionaryPath:[[imagesDictionaryPath goTo:@"custom"] dictionaryPath]
                          targetURLPath:[[targetDictionaryPath goTo:@"url"] URLPath]
   targetInitialViewModelDictionaryPath:[[targetDictionaryPath goTo:@"view"] dictionaryPath]
                         customDataPath:[[[HUBMutableJSONPathImplementation path] goTo:@"custom"] dictionaryPath]
                        loggingDataPath:[[[HUBMutableJSONPathImplementation path] goTo:@"logging"] dictionaryPath]
                               datePath:[[[HUBMutableJSONPathImplementation path] goTo:@"date"] datePath]];
}

- (instancetype)initWithIdentifierPath:(id<HUBJSONStringPath>)identifierPath
               componentIdentifierPath:(id<HUBJSONStringPath>)componentIdentiferPath
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
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _identifierPath = identifierPath;
    _componentIdentifierPath = componentIdentiferPath;
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
    
    return self;
}

@end
