import Foundation
import HubFramework

class ___FILEBASENAMEASIDENTIFIER___: NSObject, HUBComponentViewObserver {
    var view: UIView?

    var layoutTraits: Set<HUBComponentLayoutTrait> {
        // Return a set of layout traits that describe your component's UI style
        return []
    }

    func loadView() {
        // Create your view. You can give it a zero rectangle for its frame.
        self.view = UIView(frame: CGRect())
    }

    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        // Return the size you'd prefer that the layout system resizes your view to
        return CGSize()
    }

    func prepareViewForReuse() {
        // Prepare your view for reuse, reset state, remove highlights, etc.
    }

    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        // Do your model->view data binding here
    }

    func viewDidResize() {
        // Update the component after it was resized by the layout system
    }

    func viewWillAppear() {
        // Called when the component is about to appear on the screen
    }
}
