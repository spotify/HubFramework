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

/// Struct containing keys used for custom data in the GitHub search feature
struct GitHubSearchCustomDataKeys {
    /// Key used to encode a search string into a view model builder's custom data
    static var searchString: String { return "searchString" }
    /// Key used to encode a Boolean indicating whether a search is currently in
    /// progess into a view model builder's custom data
    static var searchInProgress: String { return "searchInProgress" }
}
