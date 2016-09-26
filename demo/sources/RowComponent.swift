import Foundation
import HubFramework

/**
 *  A component that renders as Row using a UITableViewCell
 *
 *  This component is compatible with the following model data:
 *
 *  - title
 *  - subtitle
 *  - mainImageData
 */
class RowComponent: NSObject, HUBComponentWithImageHandling {
    var layoutTraits: Set<HUBComponentLayoutTrait> { return [] }
    var view: UIView?
    
    private lazy var cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
    private var cellHeight: CGFloat { return 50 }
    private var imageSize: CGSize {
        return CGSize(width: self.cellHeight, height: self.cellHeight)
    }
    
    func loadView() {
        self.view = self.cell
    }
    
    func preferredViewSize(forDisplaying model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        return CGSize(width: containerViewSize.width, height: self.cellHeight)
    }
    
    func configureView(with model: HUBComponentModel, containerViewSize: CGSize) {
        self.cell.textLabel?.text = model.title
        self.cell.detailTextLabel?.text = model.subtitle
        
        if model.mainImageData != nil {
            UIGraphicsBeginImageContext(self.imageSize)
            UIColor.lightGray.setFill()
            UIRectFill(CGRect(origin: CGPoint(), size: self.imageSize))
            self.cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    func prepareViewForReuse() {
        self.cell.prepareForReuse()
        self.cell.imageView?.image = nil
    }
    
    // MARK: - HUBComponentWithImageHandling
    
    func preferredSizeForImage(from imageData: HUBComponentImageData, model: HUBComponentModel, containerViewSize: CGSize) -> CGSize {
        if imageData.type != .main {
            return CGSize()
        }
        
        return self.imageSize
    }
    
    func updateView(forLoadedImage image: UIImage, from imageData: HUBComponentImageData, model: HUBComponentModel, animated: Bool) {
        self.cell.imageView?.setImage(image, animated: animated)
        self.cell.setNeedsLayout()
    }
}
