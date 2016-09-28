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

/// Component layout manager used when setting up HUBManager
class ComponentLayoutManager: NSObject, HUBComponentLayoutManager {
    /// The margin used whenever a component's layout traits indicate that it should have margin applied
    static var margin: CGFloat { return 15 }
    
    func marginBetweenComponent(withLayoutTraits layoutTraits: Set<HUBComponentLayoutTrait>, andContentEdge contentEdge: HUBComponentLayoutContentEdge) -> CGFloat {
        switch contentEdge {
        case .top, .bottom:
            return layoutTraits.contains(.stackable) ? 0 : ComponentLayoutManager.margin
        case .left, .right:
            return layoutTraits.contains(.fullWidth) ? 0 : ComponentLayoutManager.margin
        }
    }
    
    func verticalMarginBetweenComponent(withLayoutTraits layoutTraits: Set<HUBComponentLayoutTrait>, andHeaderComponentWithLayoutTraits headerLayoutTraits: Set<HUBComponentLayoutTrait>) -> CGFloat {
        return 0
    }
    
    func verticalMarginForComponent(withLayoutTraits layoutTraits: Set<HUBComponentLayoutTrait>, precedingComponentLayoutTraits: Set<HUBComponentLayoutTrait>) -> CGFloat {
        if layoutTraits.contains(.stackable) && precedingComponentLayoutTraits.contains(.stackable) {
            return 0
        }
        
        if layoutTraits.contains(.alwaysStackUpwards) {
            return 0
        }
        
        return ComponentLayoutManager.margin
    }
    
    func horizontalMarginForComponent(withLayoutTraits layoutTraits: Set<HUBComponentLayoutTrait>, precedingComponentLayoutTraits: Set<HUBComponentLayoutTrait>) -> CGFloat {
        if layoutTraits.contains(.fullWidth) {
            return 0
        }
        
        return ComponentLayoutManager.margin
    }
    
    func horizontalOffsetForComponents(withLayoutTraits componentsTraits: [Set<HUBComponentLayoutTrait>], firstComponentLeadingHorizontalOffset firstComponentLeadingOffsetX: CGFloat, lastComponentTrailingHorizontalOffset lastComponentTrailingOffsetX: CGFloat) -> CGFloat {
        return 0
    }
}
