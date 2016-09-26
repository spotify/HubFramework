/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

#import "HUBComponentModelJSONSchemaImplementation.h"

#import "HUBMutableJSONPathImplementation.h"
#import "HUBJSONKeys.h"

@implementation HUBComponentModelJSONSchemaImplementation

@synthesize identifierPath = _identifierPath;
@synthesize groupIdentifierPath = _groupIdentifierPath;
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
@synthesize targetDictionaryPath = _targetDictionaryPath;
@synthesize metadataPath = _metadataPath;
@synthesize loggingDataPath = _loggingDataPath;
@synthesize customDataPath = _customDataPath;
@synthesize childDictionariesPath = _childDictionariesPath;

- (instancetype)init
{
    id<HUBMutableJSONPath> const basePath = [HUBMutableJSONPathImplementation path];
    id<HUBMutableJSONPath> const componentDictionaryPath = [basePath goTo:HUBJSONKeyComponent];
    id<HUBMutableJSONPath> const textDictionaryPath = [basePath goTo:HUBJSONKeyText];
    id<HUBMutableJSONPath> const imagesDictionaryPath = [basePath goTo:HUBJSONKeyImages];
    
    return [self initWithIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyIdentifier] stringPath]
                    groupIdentifierPath:[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyGroup] stringPath]
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
                   targetDictionaryPath:[[basePath goTo:HUBJSONKeyTarget] dictionaryPath]
                           metadataPath:[[basePath goTo:HUBJSONKeyMetadata] dictionaryPath]
                        loggingDataPath:[[basePath goTo:HUBJSONKeyLogging] dictionaryPath]
                         customDataPath:[[basePath goTo:HUBJSONKeyCustom] dictionaryPath]
                  childDictionariesPath:[[[[HUBMutableJSONPathImplementation path] goTo:HUBJSONKeyChildren] forEach] dictionaryPath]];
}

- (instancetype)initWithIdentifierPath:(id<HUBJSONStringPath>)identifierPath
                   groupIdentifierPath:(id<HUBJSONStringPath>)groupIdentifierPath
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
                  targetDictionaryPath:(id<HUBJSONDictionaryPath>)targetDictionaryPath
                          metadataPath:(id<HUBJSONDictionaryPath>)metadataPath
                       loggingDataPath:(id<HUBJSONDictionaryPath>)loggingDataPath
                        customDataPath:(id<HUBJSONDictionaryPath>)customDataPath
                 childDictionariesPath:(id<HUBJSONDictionaryPath>)childDictionariesPath
{
    self = [super init];
    
    if (self) {
        _identifierPath = identifierPath;
        _groupIdentifierPath = groupIdentifierPath;
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
        _targetDictionaryPath = targetDictionaryPath;
        _metadataPath = metadataPath;
        _loggingDataPath = loggingDataPath;
        _customDataPath = customDataPath;
        _childDictionariesPath = childDictionariesPath;
    }
    
    return self;
}

#pragma mark - HUBComponentModelJSONSchema

- (id)copy
{
    return [[HUBComponentModelJSONSchemaImplementation alloc] initWithIdentifierPath:self.identifierPath
                                                                 groupIdentifierPath:self.groupIdentifierPath
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
                                                                targetDictionaryPath:self.targetDictionaryPath
                                                                        metadataPath:self.metadataPath
                                                                     loggingDataPath:self.loggingDataPath
                                                                      customDataPath:self.customDataPath
                                                               childDictionariesPath:self.childDictionariesPath];
}

@end
