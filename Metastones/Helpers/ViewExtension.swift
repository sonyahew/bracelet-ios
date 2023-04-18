//
//  ViewExtension.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import Kingfisher

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }else {
            return self.leftAnchor
        }
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }else {
            return self.rightAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    
    func applyCornerRadius(cornerRadius : CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat, withShadow: Bool? = nil) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.name = "99"
        if let withShadow = withShadow {
            if withShadow {
                backgroundColor = .clear
                mask.fillColor = UIColor.white.cgColor
                mask.shadowColor = UIColor.black.cgColor
                mask.shadowPath = mask.path
                mask.shadowOffset = .zero
                mask.shadowOpacity = 0.4
                mask.shadowRadius = 12
                layer.sublayers?.removeAll()
                layer.insertSublayer(mask, at: 0)
            }
        } else {
            layer.mask = mask
        }
    }
    
    func addDashedBorder() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.msBrown.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [5,5]
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0).cgPath
        self.layer.addSublayer(shapeLayer)
    }
    
    func addShadow(withRadius radius: CGFloat, opacity: Float, color: CGColor, offset: CGSize) {
        layer.masksToBounds = false
        layer.shadowColor = color
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        //layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
    
    func addSubviewAndPinEdges(_ child: UIView, padding: CGFloat = 0) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        child.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        child.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        child.widthAnchor.constraint(equalTo: widthAnchor, constant: padding).isActive = true
        child.heightAnchor.constraint(equalTo: heightAnchor, constant: padding).isActive = true
    }
    
    //add dash line
    private static let lineDashPattern: [NSNumber] = [5, 5]
    private static let lineDashWidth: CGFloat = 1.0

    func makeDashedLine() {
        let path = CGMutablePath()
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = UIView.lineDashWidth
        shapeLayer.strokeColor = UIColor(hex: 0xBCBCBC).cgColor
        shapeLayer.lineDashPattern = UIView.lineDashPattern
        path.addLines(between: [CGPoint(x: bounds.minX, y: bounds.height/2),
                                CGPoint(x: bounds.maxX, y: bounds.height/2)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    
    func addPulse() {
        layer.removeAnimation(forKey: "opacity")
        
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        layer.add(pulseAnimation, forKey: nil)
    }
    
    func hideShowBtnLive() {
        if AppData.shared.currentFbLive != nil {
            self.addPulse()
            self.addShadow(withRadius: 3, opacity: 0.2, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 3))
            self.isHidden = false
        } else {
            self.addShadow(withRadius: 0, opacity: 0, color: UIColor.clear.cgColor, offset: CGSize(width: 0, height: 0))
            self.isHidden = true
        }
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func loadWithCache(strUrl : String?, placeholder : UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        if let strUrl = strUrl {
            let url = URL.init(string: strUrl.urlPercentEncoding)
            kf.setImage(with: url, placeholder: placeholder ?? #imageLiteral(resourceName: "no-image"), options: []) { (result) in
                if let completion = completion {
                    switch result {
                    case .success(let value):
                        completion(value.image)
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
         tintColorDidChange()
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.width) + 1
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
