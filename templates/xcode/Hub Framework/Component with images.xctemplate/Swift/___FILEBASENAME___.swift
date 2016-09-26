import Foundation
import HubFramework

class ___FILEBASENAMEASIDENTIFIER___: NSObject, HUBComponentWithImageHandling {
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

    func preferredSizeForImage(from imageData: HUBComponentImageData, model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        // Return the size you'd prefer an image to be, or CGSizeZero for non-supported types.
        switch imageData.type {
        case .main, .background, .custom:
            return CGSize();
        }
    }

    func updateView(forLoadedImage image: UIImage, from imageData: HUBComponentImageData, model: HUBComponentModel, animated: Bool) {
        // Update your view after an image was downloaded by the Hub Framework
    }
}
