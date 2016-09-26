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

#import "HUBHeaderMacros.h"
#import "HUBComponentCategories.h"

NS_ASSUME_NONNULL_BEGIN

/// Class containing default values that are used as initial property values for component model builders
@interface HUBComponentDefaults : NSObject

/// The default component namespace that all component model builders will initially have
@property (nonatomic, copy, readonly) NSString *componentNamespace;

/// The default component name that all component model builders will initially have
@property (nonatomic, copy, readonly) NSString *componentName;

/// The default component category that all component model builders will initially have
@property (nonatomic, copy, readonly) HUBComponentCategory componentCategory;

/**
 *  Initialize an instance of this class with its required values
 *
 *  @param componentNamespace The default component namespace that all component model builders will initially have
 *  @param componentName The default component name that all component model builders will initially have
 *  @param componentCategory The default component category that all component model builders will initially have
 */
- (instancetype)initWithComponentNamespace:(NSString *)componentNamespace
                             componentName:(NSString *)componentName
                         componentCategory:(HUBComponentCategory)componentCategory HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
