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
class ReallyLongListContentOperation: NSObject, HUBContentOperation {
    weak var delegate: HUBContentOperationDelegate?
    private var initialRenderingPassPerformed = false

    func perform(forViewURI viewURI: URL, featureInfo: HUBFeatureInfo, connectivityState: HUBConnectivityState, viewModelBuilder: HUBViewModelBuilder, previousError: Error?) {
        // To enable the navigation bar title to be displayed synchronously,
        // we finish directly if this operation is being executed for the first
        // rendering pass, then reschedule it right after that, so that the
        // operation gets run again (adding all the rows)
        if !initialRenderingPassPerformed {
            initialRenderingPassPerformed = true
            delegate?.contentOperationDidFinish(self)
            delegate?.contentOperationRequiresRescheduling(self)
            return
        }
        
        // Run this code on a background queue as to not block the main thread
        DispatchQueue(label: String(describing: self)).async {
            // Add 10,000 rows with unique IDs
            for index in 0..<10000 {
                let rowBuilder = viewModelBuilder.builderForBodyComponentModel(withIdentifier: "row-\(index)")
                rowBuilder.title = "Row number \(index + 1)"
            }
            
            // We don't need to manually go back to the main queue, Hubs takes care of this for us
            self.delegate?.contentOperationDidFinish(self)
        }
    }
}
