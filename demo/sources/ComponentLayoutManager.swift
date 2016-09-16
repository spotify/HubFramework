import Foundation
import HubFramework

class ComponentLayoutManager: NSObject, HUBComponentLayoutManager {
    func marginBetweenComponent(withLayoutTraits layoutTraits: Set<HUBComponentLayoutTrait>, andContentEdge contentEdge: HUBComponentLayoutContentEdge) -> CGFloat {
        return 0
    }
    
    func verticalMarginBetweenComponent(withLayoutTraits layoutTraits: Set<HUBComponentLayoutTrait>, andHeaderComponentWithLayoutTraits headerLayoutTraits: Set<HUBComponentLayoutTrait>) -> CGFloat {
        return 0
    }
    
    func verticalMarginForComponent(withLayoutTraits layoutTraits: Set<HUBComponentLayoutTrait>, precedingComponentLayoutTraits: Set<HUBComponentLayoutTrait>) -> CGFloat {
        return 0
    }
    
    func horizontalMarginForComponent(withLayoutTraits layoutTraits: Set<HUBComponentLayoutTrait>, precedingComponentLayoutTraits: Set<HUBComponentLayoutTrait>) -> CGFloat {
        return 0
    }
    
    func horizontalOffsetForComponents(withLayoutTraits componentsTraits: [Set<HUBComponentLayoutTrait>], firstComponentLeadingHorizontalOffset firstComponentLeadingOffsetX: CGFloat, lastComponentTrailingHorizontalOffset lastComponentTrailingOffsetX: CGFloat) -> CGFloat {
        return 0
    }
}
