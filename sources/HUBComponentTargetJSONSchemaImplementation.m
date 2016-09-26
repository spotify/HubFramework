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
