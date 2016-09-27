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

import Foundation
import HubFramework

/// Extension adding APIs for registering custom JSON schemas with the Hub Framework
extension HUBJSONSchemaRegistry {
    /// The JSON schema identifier used by the GitHub search feature
    var gitHubSearchSchemaIdentifier: String { return "gitHub" }
    
    /// Register the JSON schema for the GitHub search feature
    func registerGitHubSearchSchema() {
        let schema = self.createNewSchema()
        schema.viewModelSchema.bodyComponentModelDictionariesPath = schema.createNewPath().go(to: "items").forEach().dictionaryPath()
        
        schema.componentModelSchema.targetDictionaryPath = schema.createNewPath().dictionaryPath()
        schema.componentModelSchema.titlePath = schema.createNewPath().go(to: "name").stringPath()
        schema.componentModelSchema.subtitlePath = schema.createNewPath().go(to: "owner").go(to: "login").run({ input in
            guard let authorName = input as? String else {
                return nil
            }
            
            return "Author: " + authorName
        }).stringPath()
        
        schema.componentTargetSchema.uriPath = schema.createNewPath().go(to: "html_url").urlPath()
        
        self.registerCustomSchema(schema, forIdentifier: self.gitHubSearchSchemaIdentifier)
    }
}
