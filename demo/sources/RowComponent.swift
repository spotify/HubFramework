import Foundation
import HubFramework

class RowComponent: NSObject, HUBComponent {
    var layoutTraits: Set<HUBComponentLayoutTrait> { return [] }
    var view: UIView?
    
    func loadView() {
        self.view = UIView()
    }
    
    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        return CGSize(width: containerViewSize.width, height: 50)
    }
    
    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        
    }
    
    func prepareViewForReuse() {
        
    }
}
