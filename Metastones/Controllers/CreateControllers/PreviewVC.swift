//
//  PreviewVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 14/01/2020.
//  Copyright © 2020 Metagroup. All rights reserved.
//

import UIKit

class PreviewVC: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lbTitle: UILabel!

    @IBOutlet weak var vwBracelet: UIView!
    @IBOutlet weak var lbCenter: UILabel!
    
    let degreesToRadians = CGFloat.pi / 180
    let ivBraceletOutline = UIImageView(image: #imageLiteral(resourceName: "img-bracelet-outline"))
    
    lazy var circleRadius = vwBracelet.frame.width / 3.3
    lazy var ballDiameter = view.frame.width / 8
    lazy var dragBallRadius: CGFloat = 0
    var circleBallCount = 1
    var containerMidPoint: CGPoint = CGPoint.zero
    var dropPoints: [CGPoint] = []
    var cartItem: CartItemModel?
    var orderItem: OrderItemModel?
    var arrCrystal: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cartItem = cartItem {
            for item in cartItem.bead ?? [] {
                circleBallCount += item.qty ?? 0
            }
            
            arrCrystal = Array(repeating: "", count: circleBallCount)
            arrCrystal[0] = "https://cdn.metastones.biz/medias/MS_DEV/GB1/IMAGE/metastones-logo.png"
            
            for item in cartItem.bead ?? [] {
                for seqNo in item.seqNo ?? [] {
                    arrCrystal[seqNo] = item.imgPath ?? ""
                }
            }
            
        } else if let orderItem = orderItem {
            for item in orderItem.bead {
                circleBallCount += item?.qty ?? 0
            }
            
            arrCrystal = Array(repeating: "", count: circleBallCount)
            arrCrystal[0] = "https://cdn.metastones.biz/medias/MS_DEV/GB1/IMAGE/metastones-logo.png"
            
            for item in orderItem.bead {
                for seqNo in item?.seqNo ?? [] {
                    arrCrystal[seqNo] = item?.imgPath ?? ""
                }
            }
        }
        
        setupView()
        startLoading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDragView()
        stopLoading()
    }
    
    func setupView() {
        lbTitle.text = kLb.personalized.localized
        lbCenter.text = ""
        //lbCenter.text = "\(kLb.wrist_size.localized): \(self.wristSizeText ?? "")\n\(kLb.bead_size.localized): \(self.beadSizeText ?? "")"
        
        ivBraceletOutline.contentMode = .scaleAspectFill
        vwBracelet.addSubview(ivBraceletOutline)
        ivBraceletOutline.translatesAutoresizingMaskIntoConstraints = false
        ivBraceletOutline.heightAnchor.constraint(equalToConstant: (circleRadius * 2)).isActive = true
        ivBraceletOutline.widthAnchor.constraint(equalToConstant: (circleRadius * 2)).isActive = true
        ivBraceletOutline.centerXAnchor.constraint(equalTo: vwBracelet.centerXAnchor).isActive = true
        ivBraceletOutline.centerYAnchor.constraint(equalTo: vwBracelet.centerYAnchor).isActive = true
    }
    
    func setupDragView() {
        containerMidPoint = CGPoint(x: vwBracelet.frame.width / 2, y: (vwBracelet.frame.height / 2))
        createDropPath()
    }
    
    @IBAction func backHandler(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PreviewVC {
    
//    private func createCircle(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
//        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
//        let circleLayer = CAShapeLayer()
//        circleLayer.path = circlePath.cgPath
//        circleLayer.fillColor = UIColor.clear.cgColor
//        circleLayer.strokeColor = UIColor.red.cgColor
//        circleLayer.lineWidth = 3.0
//        return circleLayer
//    }
    
    private func createDropPath() {
        var angle: CGFloat = 270 * degreesToRadians
        dropPoints = []
        dragBallRadius = (circleRadius * 3.3 * CGFloat.pi) / CGFloat(circleBallCount) / 3.3
        for _ in 0..<circleBallCount {
            let targetX = containerMidPoint.x + cos(angle) * circleRadius
            let targetY = containerMidPoint.y + sin(angle) * circleRadius
            dropPoints.append(CGPoint(x: targetX, y: targetY))
            //let circleLayer = createCircle(center: CGPoint(x: targetX, y: targetY), radius: dragBallRadius)
            //circleLayer.lineWidth = 1
            //circleLayer.lineDashPattern = [4, 4]
            //vwBracelet.layer.addSublayer(circleLayer)
            angle += CGFloat.pi * 2 / CGFloat(circleBallCount)
        }
        
        for (index, _) in dropPoints.enumerated() {
            var ball = UIView()
            ball = createBall(imageName: arrCrystal[index], diameter: dragBallRadius * 2)
            
            vwBracelet.addSubview(ball)
            ball.center.x = dropPoints[index].x
            ball.center.y = dropPoints[index].y
            
            if index != 0 {
                let containerPoint = ball.center
                let ballPath = getBallPath(point: containerPoint)
                ball.transform = CGAffineTransform(rotationAngle: CGFloat(ballPath.angle-1.57))
            }
        }
    }
    
    private func createBall(imageName: String, diameter: CGFloat? = nil) -> UIView {
        let diameter = diameter ?? ballDiameter
        let view = UIView(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        let imageView = UIImageView()
        imageView.loadWithCache(strUrl: imageName)
        imageView.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.isUserInteractionEnabled = false
        view.addSubview(imageView)
        return view
    }
    
    private func getBallPath(point: CGPoint) -> (path: CGPoint, angle: CGFloat) {
        let angleX = point.x - containerMidPoint.x
        let angleY = point.y - containerMidPoint.y
        let angle = atan2(angleY, angleX)
        let targetX = containerMidPoint.x + cos(angle) * circleRadius
        let targetY = containerMidPoint.y + sin(angle) * circleRadius
        return (CGPoint(x: targetX, y: targetY), angle)
    }
}
