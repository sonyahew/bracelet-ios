//
//  ButtonExtension.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

typealias UIButtonTargetClosure = (UIButton) -> ()

class BrownButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .msBrown
        titleLabel?.font =  .boldSystemFont(ofSize: 14)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = self.bounds.size.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.msBrown.cgColor
    }
}

class ReversedBrownButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        titleLabel?.font = .boldSystemFont(ofSize: 14)
        setTitleColor(.msBrown, for: .normal)
        layer.cornerRadius = self.bounds.size.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.msBrown.cgColor
    }
}

class ReversedWhiteBackBrownButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .white
        titleLabel?.font = .boldSystemFont(ofSize: 14)
        setTitleColor(.msBrown, for: .normal)
        layer.cornerRadius = self.bounds.size.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.msBrown.cgColor
    }
}

extension UIButton{
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        self.addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
    func centerVertically(padding: CGFloat = 4.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
}

class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}
