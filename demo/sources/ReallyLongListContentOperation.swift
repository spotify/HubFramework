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

/// Content operation that adds 10,000 rows as part of the "Really Long List" feature
class ReallyLongListContentOperation: HUBContentOperationWithPaginatedContent {
    weak var delegate: HUBContentOperationDelegate?


    func perform(in context: HUBContentOperationContext) {
        addRows(toViewModelBuilder: context.viewModelBuilder, pageIndex: 0)
    }

    func appendContent(atPageIndex pageIndex: UInt, in context: HUBContentOperationContext) {
        addRows(toViewModelBuilder: context.viewModelBuilder, pageIndex: pageIndex)
    }
    
    private func addRows(toViewModelBuilder viewModelBuilder: HUBViewModelBuilder, pageIndex: UInt) {
        let pageSize = 50
        let startIndex = Int(pageIndex) * pageSize
        let endIndex = startIndex + pageSize - 1
        
        (startIndex...endIndex).forEach { index in
            let rowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "row-\(index)")
            rowBuilder.title = "Row number \(index + 1)"
        }
        
        delegate?.contentOperationDidFinish(self)
    }
}
