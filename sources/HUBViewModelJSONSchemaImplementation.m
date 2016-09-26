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
