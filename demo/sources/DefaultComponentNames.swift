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

/// The component names that `DefaultComponentFactory` is compatible with
struct DefaultComponentNames {
    /// A row component - maps to `RowComponent`
    static var row: String { return "row" }
    /// A label component - maps to `LabelComponent`
    static var label: String { return "label" }
    /// An image component - maps to `ImageComponent`
    static var image: String { return "image" }
    /// A search bar component - maps to `SearchBarComponent`
    static var searchBar: String { return "searchBar" }
    /// An activity indicator component - maps to `ActivityIndicatorComponent`
    static var activityIndicator: String { return "activityIndicator" }
    /// A carousel component - maps to `CarouselComponent`
    static var carousel: String { return "carousel" }
    /// A sticky header component - maps to `HeaderComponent`
    static var header: String { return "header" }
}
