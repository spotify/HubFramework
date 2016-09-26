import UIKit

extension UIImageView {
    /// Set the image of this image view, optionally animating the change
    func setImage(_ image: UIImage, animated shouldAnimate: Bool) {
        self.image = image
        
        if shouldAnimate {
            let animationKey = "hub_imageAnimation"
            self.layer.removeAnimation(forKey: animationKey)
            
            let animation = CATransition()
            animation.duration = 0.3
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.type = kCATransitionFade
            self.layer.add(animation, forKey: animationKey)
        }
    }
}
