//
//  PersonalizedVC.swift
//  Metastones
//
//  Created by Ivan Tuang on 23/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

enum BaziAttr: String {
    case metal = "metal"
    case water = "water"
    case wood = "wood"
    case fire = "fire"
    case earth = "earth"
}

class PersonalizedVC: UIViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnChangeDOB: UIButton!
    
    @IBOutlet weak var vwTotal: UIView!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var lbTotalValue: UILabel!
    @IBOutlet weak var btnTotalValue: UIButton!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnAddToCart: UIButton!
    
    @IBOutlet weak var vwBracelet: UIView!
    @IBOutlet weak var lbMetal: UILabel!
    @IBOutlet weak var lbWater: UILabel!
    @IBOutlet weak var lbWood: UILabel!
    @IBOutlet weak var lbFire: UILabel!
    @IBOutlet weak var lbEarth: UILabel!
    @IBOutlet weak var lbMetalValue: UILabel!
    @IBOutlet weak var lbWaterValue: UILabel!
    @IBOutlet weak var lbWoodValue: UILabel!
    @IBOutlet weak var lbFireValue: UILabel!
    @IBOutlet weak var lbEarthValue: UILabel!
    @IBOutlet var vwValues: [UIView]!
    @IBOutlet weak var lbCenter: UILabel!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var vwSteps: UIView!
    @IBOutlet weak var svSteps: UIStackView!
    @IBOutlet weak var ivStep1: UIImageView!
    @IBOutlet weak var lbStep1: UILabel!
    @IBOutlet weak var ivStep2: UIImageView!
    @IBOutlet weak var lbStep2: UILabel!
    @IBOutlet weak var ivStep3: UIImageView!
    @IBOutlet weak var lbStep3: UILabel!
    
    @IBOutlet weak var vwSelection: UIView!
    
    @IBOutlet weak var cvSelection: UICollectionView!
    
    @IBOutlet weak var constraintHeightVwTotal: NSLayoutConstraint!
    @IBOutlet var constraintAspectVwBracelet: NSLayoutConstraint!
    
    let personalizeViewModel = PersonalizeViewModel()
    let appData = AppData.shared
    let popupManager = PopupManager.shared
    let degreesToRadians = CGFloat.pi / 180
    let ivBraceletOutline = UIImageView(image: #imageLiteral(resourceName: "img-bracelet-outline"))
    
    lazy var circleRadius = vwBracelet.frame.width / 3.3
    lazy var ballDiameter = view.frame.width / 8
    lazy var dragBallRadius: CGFloat = 0
    var circleBallCount = 16
    var containerMidPoint: CGPoint = CGPoint.zero
    var isDragging = false
    var dragIndexPath: IndexPath?
    var dragItemList: [UIView?] = []
    var dragItemObjList: [BraceletBeadModel?] = [] {
        didSet {
            var totalAmt = 0.0
            for itemObj in dragItemObjList {
                if let itemObj = itemObj, let unitPrice = itemObj.unitPrice {
                    totalAmt += Double(unitPrice) ?? 0.0
                }
            }
            self.totalAmt = "\(selectedBaziMetaData.first??.currencyCode ?? "MYR")\("\(totalAmt)".toDisplayCurrency())"
            calculateBaziAttrPieces()
        }
    }
    var dragItem: UIView?
    var dragItemObj: BraceletBeadModel?
    var dropPoints: [CGPoint] = []
    var wristSize: String? = ""
    var wristSizeText: String? = ""
    var beadSize: String? = ""
    var beadSizeText: String? = ""
    var numberBead: String? = ""
    var isFirstEnter: Bool = true
    var isDisplayedGuide: Bool = false
    var selectedBracelet: BraceletBeadModel? = nil {
        didSet {
            if dragItemObjList.indices.contains(0) {
                dragItemObjList[0] = selectedBracelet
            }
        }
    }
    var baziBalance: String? = ""
    var selectedBaziMeta: String? = ""
    var totalAmt: String? = "" {
        didSet {
            lbTotalValue.text = totalAmt
        }
    }
    var validDragItemObjList: [PostCustomBraceletModel] = []
    var customBraceletDetails: BraceletDetailsModel? {
        didSet {
            metalCount = customBraceletDetails?.data?.numberBaziBead?.metal
            waterCount = customBraceletDetails?.data?.numberBaziBead?.water
            woodCount = customBraceletDetails?.data?.numberBaziBead?.wood
            fireCount = customBraceletDetails?.data?.numberBaziBead?.fire
            earthCount = customBraceletDetails?.data?.numberBaziBead?.earth
            
            metalTotalCount = customBraceletDetails?.data?.numberBaziBead?.metal
            waterTotalCount = customBraceletDetails?.data?.numberBaziBead?.water
            woodTotalCount = customBraceletDetails?.data?.numberBaziBead?.wood
            fireTotalCount = customBraceletDetails?.data?.numberBaziBead?.fire
            earthTotalCount = customBraceletDetails?.data?.numberBaziBead?.earth
            
            var arrAttr : [String] = []
            if customBraceletDetails?.data?.numberBaziBead?.metal ?? 0 > 0 {
                arrAttr.append(kLb.gold.localized)
            }
            if customBraceletDetails?.data?.numberBaziBead?.water ?? 0 > 0 {
                arrAttr.append(kLb.water.localized)
            }
            if customBraceletDetails?.data?.numberBaziBead?.wood ?? 0 > 0 {
                arrAttr.append(kLb.wood.localized)
            }
            if customBraceletDetails?.data?.numberBaziBead?.fire ?? 0 > 0 {
                arrAttr.append(kLb.fire.localized)
            }
            if customBraceletDetails?.data?.numberBaziBead?.earth ?? 0 > 0 {
                arrAttr.append(kLb.earth.localized)
            }
            
            segmentTitles.removeLast()
            segmentTitles.append(arrAttr)
        }
    }
    var selectedBaziMetaData: [BraceletBeadModel?] = []
    var userNameDOB: String?
    var segmentControl = ScrollableSegmentedControl()
    
    var metalTotalCount: Int? = 0
    var waterTotalCount: Int? = 0
    var woodTotalCount: Int? = 0
    var fireTotalCount: Int? = 0
    var earthTotalCount: Int? = 0
    
    var metalCount: Int? = 0 {
        didSet {
            lbMetalValue.text = "\(metalCount ?? 0)"
        }
    }
    var waterCount: Int? = 0 {
        didSet {
            lbWaterValue.text = "\(waterCount ?? 0)"
        }
    }
    var woodCount: Int? = 0 {
        didSet {
            lbWoodValue.text = "\(woodCount ?? 0)"
        }
    }
    var fireCount: Int? = 0 {
        didSet {
            lbFireValue.text = "\(fireCount ?? 0)"
        }
    }
    var earthCount: Int? = 0 {
        didSet {
            lbEarthValue.text = "\(earthCount ?? 0)"
        }
    }
    var enableBtnCart: Bool = true {
        didSet {
            btnAddToCart.isUserInteractionEnabled = enableBtnCart
            btnAddToCart.alpha = enableBtnCart ? 1 : 0.5
        }
    }
    
    private var segmentTitles = [[kLb.wrist_bead_size.localized],
                                 [kLb.bracelet_design.localized],
                                 [kLb.gold.localized, kLb.water.localized, kLb.wood.localized, kLb.fire.localized, kLb.earth.localized]]
    private var currentStep = 0 {
        didSet {
            setupBtnCondition()
            lbStep1.textColor = .msBrown
            
            ivStep2.image = currentStep == 0 ? #imageLiteral(resourceName: "step2-braceletdesign") : #imageLiteral(resourceName: "step2-braceletdesign-on")
            lbStep2.textColor = currentStep == 0 ? .gray : .msBrown
            
            ivStep3.image = currentStep == 0 || currentStep == 1 ? #imageLiteral(resourceName: "step3-beaddesign") : #imageLiteral(resourceName: "step3-beaddesign-on")
            lbStep3.textColor = currentStep == 0 || currentStep == 1 ? .gray : .msBrown
            
            segmentControl.removeFromSuperview()
            segmentControl = ScrollableSegmentedControl()
            setupSegmentView()
        }
    }
    
    private var braceletSetupData: BraceletSetupModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //vwTotal.isHidden = true
        //constraintHeightVwTotal.constant = 0
        
        vwBracelet.isHidden = true
        constraintAspectVwBracelet.isActive = false
    }
    
    func setupView() {
        lbTitle.text = kLb.personalized.localized
        
        lbMetal.text = kLb.gold.localized
        lbWater.text = kLb.water.localized
        lbWood.text = kLb.wood.localized
        lbFire.text = kLb.fire.localized
        lbEarth.text = kLb.earth.localized
        
        lbMetalValue.text = "0"
        lbWaterValue.text = "0"
        lbWoodValue.text = "0"
        lbFireValue.text = "0"
        lbEarthValue.text = "0"
        
        for view in vwValues {
            view.applyCornerRadius(cornerRadius: 5)
        }
        
        lbCenter.text = kLb.choose_your_wrist_bead_size.localized
        lbTotal.text = kLb.total.localized + ": "
        
        currentStep = 0
        lbStep1.text = kLb.wrist_bead_size_step.localized
        lbStep2.text = kLb.bracelet_design_step.localized
        lbStep3.text = kLb.bead_design_step.localized
        
        btnAddToCart.applyCornerRadius(cornerRadius: btnAddToCart.frame.size.height/2)
        btnAddToCart.setTitle(kLb.add_to_cart.localized, for: .normal)
        enableBtnCart = false
        
        btnChangeDOB.setTitle(kLb.change_dob.localized, for: .normal)
        
        btnPrevious.tintColor = .white
        btnPrevious.applyCornerRadius(cornerRadius: btnPrevious.frame.size.height/2)
        btnPrevious.setTitle(kLb.previous.localized, for: .normal)
        
        btnNext.tintColor = .white
        btnNext.applyCornerRadius(cornerRadius: btnNext.frame.size.height/2)
        btnNext.setTitle(kLb.next.localized, for: .normal)
        
        cvSelection.delegate = self
        cvSelection.dataSource = self
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragHandler(pan:)))
        dragGesture.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(dragGesture)
        
        //ivBraceletOutline.contentMode = .scaleAspectFill
        //vwBracelet.addSubview(ivBraceletOutline)
        //ivBraceletOutline.translatesAutoresizingMaskIntoConstraints = false
        //ivBraceletOutline.heightAnchor.constraint(equalToConstant: (circleRadius * 2)).isActive = true
        //ivBraceletOutline.widthAnchor.constraint(equalToConstant: (circleRadius * 2)+10).isActive = true
        //ivBraceletOutline.centerXAnchor.constraint(equalTo: vwBracelet.centerXAnchor).isActive = true
        //ivBraceletOutline.centerYAnchor.constraint(equalTo: vwBracelet.centerYAnchor, constant: 20).isActive = true
    }
    
    func setupData() {
        personalizeViewModel.customBraceletSetup { (proceed, data) in
            if proceed {
                self.braceletSetupData = data
                self.cvSelection.reloadData()
            }
        }
    }
    
    func calculateBaziAttrPieces() -> Bool {
        var mergedDragItemObjList: [BraceletBeadModel?] = []
        validDragItemObjList = []
        var validItemCount = 0
        for (dragItemIndex, item) in dragItemObjList.enumerated() {
            if mergedDragItemObjList.filter({ $0?.type == item?.type }).count > 0, let index = mergedDragItemObjList.firstIndex(where: { $0?.type == item?.type }) {
                mergedDragItemObjList[index]?.quantity += 1
            } else {
                mergedDragItemObjList.append(item)
            }
            
            if item != nil {
                validItemCount += 1
                if validDragItemObjList.filter({ $0.prd_master_id == item?.id }).count > 0, let index = validDragItemObjList.firstIndex(where: { $0.prd_master_id == item?.id }) {
                    validDragItemObjList[index].qty += 1
                    validDragItemObjList[index].seq_no = (validDragItemObjList[index].seq_no ?? []) + [dragItemIndex]
                    
                } else {
                    var objItem = PostCustomBraceletModel.init()
                    objItem.prd_master_id = item?.id ?? ""
                    objItem.prd_qty_id = item?.qtyId ?? ""
                    objItem.qty = 1
                    if dragItemIndex > 0 {
                        objItem.seq_no = (objItem.seq_no ?? []) + [dragItemIndex]
                    }
                    objItem.currency_code = item?.currencyCode ?? ""
                    validDragItemObjList.append(objItem)
                }
            }
        }
        
        self.enableBtnCart = appData.appSetting?.customBraceletCheckout ?? 0 == 1 ? validItemCount-1 == Int(numberBead ?? "0") ?? 0 : false
        
        var metalQuantity = 0
        var waterQuantity = 0
        var woodQuantity = 0
        var fireQuantity = 0
        var earthQuantity = 0
        
        for item in mergedDragItemObjList {
            switch item?.type {
                case BaziAttr.metal.rawValue:
                    metalQuantity = (item?.quantity ?? 0)
                
                case BaziAttr.water.rawValue:
                    waterQuantity = (item?.quantity ?? 0)
                
                case BaziAttr.wood.rawValue:
                    woodQuantity = (item?.quantity ?? 0)
                
                case BaziAttr.fire.rawValue:
                    fireQuantity = (item?.quantity ?? 0)
                
                case BaziAttr.earth.rawValue:
                    earthQuantity = (item?.quantity ?? 0)
                
                default:
                    continue
            }
        }
        
        metalCount = (metalTotalCount ?? 0) - metalQuantity
        waterCount = (waterTotalCount ?? 0) - waterQuantity
        woodCount = (woodTotalCount ?? 0) - woodQuantity
        fireCount = (fireTotalCount ?? 0) - fireQuantity
        earthCount = (earthTotalCount ?? 0) - earthQuantity
        
        return metalCount ?? 0 < 0 || waterCount ?? 0 < 0 || woodCount ?? 0 < 0 || fireCount ?? 0 < 0 || earthCount ?? 0 < 0
    }
    
    func setupBtnCondition() {
        if currentStep != 0 {
            btnPrevious.backgroundColor = .msBrown
            btnPrevious.isUserInteractionEnabled = true
            
            if currentStep == 2 {
                btnNext.setTitle(kLb.reset.localized, for: .normal)
                btnNext.backgroundColor = .msBrown
                btnNext.isUserInteractionEnabled = true
                
            } else {
                btnNext.setTitle(kLb.next.localized, for: .normal)
                btnNext.backgroundColor = currentStep != segmentTitles.count-1 && (selectedBracelet?.id != nil && selectedBracelet?.id != "") ? .msBrown : .lightGray
                btnNext.isUserInteractionEnabled = currentStep != segmentTitles.count-1 && (selectedBracelet?.id != nil && selectedBracelet?.id != "")
            }

        } else {
            btnPrevious.backgroundColor = .lightGray
            btnPrevious.isUserInteractionEnabled = false
            
            btnNext.backgroundColor = wristSize == "" || beadSize == "" ? .lightGray : .msBrown
            btnNext.isUserInteractionEnabled = wristSize != "" && beadSize != ""
        }
    }
    
    func setupDragView() {
        dragItemList = Array.init(repeating: nil, count: circleBallCount)
        dragItemObjList = Array.init(repeating: nil, count: circleBallCount)
        containerMidPoint = CGPoint(x: vwBracelet.frame.width / 2, y: (vwBracelet.frame.height / 2)+20)
        
        if self.customBraceletDetails?.data?.bracelet.count == 1 {
            self.selectedBracelet = self.customBraceletDetails?.data?.bracelet.first ?? nil
        }
        
        createDropPath()
    }
    
    func setupSegmentView() {
        //add segments here
        for (index, item) in segmentTitles[currentStep].enumerated() {
            segmentControl.insertSegment(withTitle: item, image: UIImage(), at: index)
        }
        segmentControl.segmentStyle = currentStep == 2 ? .textOnly : .imageOnLeft
        segmentControl.segmentContentColor = .white
        segmentControl.selectedSegmentContentColor = .msBrown
        segmentControl.tintColor = .msBrown
        segmentControl.underlineSelected = currentStep == 2
        segmentControl.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
        vwSelection.backgroundColor = .black
        vwSelection.addSubviewAndPinEdges(segmentControl)
        segmentControl.topAnchor.constraint(equalTo: vwSelection.topAnchor, constant: 2).isActive = true
        segmentControl.bottomAnchor.constraint(equalTo: vwSelection.bottomAnchor, constant: 2).isActive = true
        
        segmentControl.selectedSegmentIndex = 0
        cvSelection.reloadData()
    }
    
    @objc func segmentSelected(sender: ScrollableSegmentedControl) {
        selectedBaziMeta = segmentTitles.last?[sender.selectedSegmentIndex]
        
        switch selectedBaziMeta{
            case kLb.gold.localized:
                selectedBaziMetaData = customBraceletDetails?.data?.bead?.metal ?? []
            
            case kLb.water.localized:
                selectedBaziMetaData = customBraceletDetails?.data?.bead?.water ?? []
            
            case kLb.wood.localized:
                selectedBaziMetaData = customBraceletDetails?.data?.bead?.wood ?? []
            
            case kLb.fire.localized:
                selectedBaziMetaData = customBraceletDetails?.data?.bead?.fire ?? []
            
            case kLb.earth.localized:
                selectedBaziMetaData = customBraceletDetails?.data?.bead?.earth ?? []
            
            default:
                selectedBaziMetaData = []
        }
        
        cvSelection.reloadData()
    }
    
    @IBAction func backHandler(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeDOBHandler(_ sender: Any) {
        if let viewControllers = self.navigationController?.viewControllers {
            
            if viewControllers.contains(where: { return $0 is FavouriteListVC }) {
                self.navigationController?.popToViewController(getViewControllerFromStackFor(viewController: FavouriteListVC(), currVC: self), animated: true)
                
            } else if viewControllers.contains(where: { return $0 is MenuVC }) {
                self.navigationController?.popToViewController(getViewControllerFromStackFor(viewController: MenuVC(), currVC: self), animated: true)
            }
        }
    }
    
    @IBAction func totalValueHandler(_ sender: Any) {
        let completedItem = dragItemObjList.filter({ $0 != nil })
        if completedItem.count > 0 {
            
            let cartVC = getVC(sb: "Sheet", vc: "PersonalizedCartVC") as! PersonalizedCartVC
            cartVC.totalQty = "\(completedItem.count)"
            cartVC.totalAmt = totalAmt
            cartVC.dragItemObjList = completedItem
            cartVC.enableBtnCart = enableBtnCart
            getSheetedController(controller: cartVC, sizes: [.fullScreen], currentVC: self) { (sc) in
                let personalizedCartVC = sc as! PersonalizedCartVC
                if personalizedCartVC.cartAction == .addToCart {
                    self.addToCart()
                }
            }
        }
    }
    
    @IBAction func infoHandler(_ sender: Any) {
        popupManager.showAlert(destVC: popupManager.getMsgOnlyPopup(desc: kLb.personalized_disclaimer.localized))
    }
    
    @IBAction func addToCartHandler(_ sender: Any) {
        addToCart()
    }
    
    func addToCart() {
        //popupManager.showAlert(destVC: popupManager.getComingSoonPopup(desc: kLb.coming_soon))
        
        popupManager.showAlert(destVC: popupManager.getGeneralPopup(desc: kLb.are_you_confirm_to_purchase_this_custom_bracelet.localized, strLeftText: kLb.cancel.localized, strRightText: kLb.ok.localized, style: .warning)) { (btnTitle) in
            if btnTitle == kLb.ok.localized {
                var testPostData = ToPostCustomBraceletModel.init()
                testPostData.data = self.validDragItemObjList
                self.personalizeViewModel.postCustomBracelet(data: testPostData.toJSONString()) { (proceed, data) in
                    if proceed {
                        let completedItem = self.dragItemObjList.filter({ $0 != nil })
                        if completedItem.count > 0 {
                            
                            self.navigationController?.setViewControllers([getVC(sb: "Landing", vc: "MenuVC"), getVC(sb: "Landing", vc: "MyCartVC")], animated: true)
                            
                            //let cartVC = getVC(sb: "Sheet", vc: "PersonalizedCartVC") as! PersonalizedCartVC
                            //cartVC.totalQty = "\(completedItem.count)"
                            //cartVC.totalAmt = self.totalAmt
                            //cartVC.dragItemObjList = completedItem
                            //cartVC.enableBtnCart = self.enableBtnCart
                            //cartVC.isAddedCart = true
                            //getSheetedController(controller: cartVC, sizes: [.fullScreen], currentVC: self) { (sc) in
                            //    let personalizedCartVC = sc as! PersonalizedCartVC
                            //    if personalizedCartVC.cartAction == .viewCart {
                            //        self.navigationController?.setViewControllers([getVC(sb: "Landing", vc: "MenuVC"), getVC(sb: "Landing", vc: "MyCartVC")], animated: true)
                            //    }
                            //}
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func previousHandler(_ sender: Any?) {
        if currentStep > 0 {
            var stepToMinus = 1
            if currentStep == 2, self.customBraceletDetails?.data?.bracelet.count == 1 {
                stepToMinus += 1
            }
            
            currentStep -= stepToMinus
        }
    }
    
    @IBAction func nextHandler(_ sender: Any?) {
        if currentStep < segmentTitles.count {
            if currentStep == 2 {
                for (index, item) in self.dragItemList.enumerated() {
                    if index != 0 {
                        self.dragItemList[index] = nil
                        item?.removeFromSuperview()
                    }
                }
                
                for (index, item) in self.dragItemObjList.enumerated() {
                    if index != 0 {
                        self.dragItemObjList[index] = nil
                    }
                }

            } else {
                var stepToAdd = 1
                if currentStep == 0, self.customBraceletDetails?.data?.bracelet.count == 1 {
                    stepToAdd += 1
                }
                
                currentStep += stepToAdd
                
                if currentStep == 2, !isDisplayedGuide {
                    isDisplayedGuide = !isDisplayedGuide
                    popupManager.showAlert(destVC: popupManager.getMsgOnlyPopup(desc: kLb.personalized_guidelines.localized))
                }
            }
        }
    }
}

extension PersonalizedVC {
    private func getBallPath(point: CGPoint) -> (path: CGPoint, angle: CGFloat) {
        let angleX = point.x - containerMidPoint.x
        let angleY = point.y - containerMidPoint.y
        let angle = atan2(angleY, angleX)
        let targetX = containerMidPoint.x + cos(angle) * circleRadius
        let targetY = containerMidPoint.y + sin(angle) * circleRadius
        return (CGPoint(x: targetX, y: targetY), angle)
    }
    
    private func createCircle(center: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.red.cgColor
        circleLayer.lineWidth = 3.0
        return circleLayer
    }
    
    private func createDropPath() {
        var angle: CGFloat = 270 * degreesToRadians
        dropPoints = []
        dragBallRadius = (circleRadius * 3.3 * CGFloat.pi) / CGFloat(circleBallCount) / 3.3
        for _ in 0..<circleBallCount {
            let targetX = containerMidPoint.x + cos(angle) * circleRadius
            let targetY = containerMidPoint.y + sin(angle) * circleRadius
            dropPoints.append(CGPoint(x: targetX, y: targetY))
            let circleLayer = createCircle(center: CGPoint(x: targetX, y: targetY), radius: dragBallRadius)
            circleLayer.lineWidth = 1
            circleLayer.lineDashPattern = [4, 4]
            vwBracelet.layer.addSublayer(circleLayer)
            angle += CGFloat.pi * 2 / CGFloat(circleBallCount)
        }
        
        let logoItem = createBall(imageName: "https://cdn.metastones.biz/medias/MS_DEV/GB1/IMAGE/metastones-logo.png", diameter: dragBallRadius * 2)
        dragItemList[0] = logoItem
        vwBracelet.addSubview(logoItem)
        logoItem.center.x = dropPoints[0].x
        logoItem.center.y = dropPoints[0].y
    }
    
    private func getBezierPath(point: CGPoint, radius: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: point, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
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
    
    @objc func dragHandler(pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            if let touchItem = (dragItemList.filter { $0?.hitTest(pan.location(in: $0), with: nil) != nil }).first {
                if touchItem != dragItemList.first {
                    guard let touchItem = touchItem else { return }
                    guard let touchedItemIndex = dragItemList.firstIndex(of: touchItem) else { return }
                    self.dragItem = touchItem
                    self.dragItemObj = dragItemObjList[touchedItemIndex]
                    touchItem.superview?.bringSubviewToFront(touchItem)
                    isDragging = true
                }
            } else {
                dragItem = UIView()
                if let dragItem = dragItem, dragIndexPath == nil {
                    let touch = pan.location(in: self.cvSelection)
                    if let indexPath = self.cvSelection.indexPathForItem(at: touch), currentStep == 2 {
                        let ball = createBall(imageName: selectedBaziMetaData[indexPath.item]?.path ?? "", diameter: dragBallRadius * 2)
                        dragIndexPath = indexPath
                        self.dragItemObj = selectedBaziMetaData[indexPath.item]
                        dragItem.addSubview(ball)
                        view.addSubview(dragItem)
                        dragItem.center = pan.location(in: self.view)
                        dragItem.frame.size = ball.frame.size
                        ball.center = CGPoint(x: dragItem.bounds.width / 2, y: dragItem.bounds.height / 2)
                        isDragging = true
                    }
                }
            }
        } else if pan.state == .ended {
            if isDragging {
                isDragging = false
                dragIndexPath = nil
                if let dragItem = dragItem {
                    if calculateBaziAttrPieces() {
                        dragItemList.removeLast()
                        dragItemObjList.removeLast()
                        dragItem.removeFromSuperview()
                        popupManager.showAlert(destVC: popupManager.getAlertPopup(title: "", desc: kLb.we_dont_recommend.localized))
                        
                    } else {
                        var snap = false
                        for i in 0..<dropPoints.count {
                            if i != 0 {
                                let dragItemPoint = view.convert(CGPoint(x: dragItem.center.x, y: dragItem.center.y), to: vwBracelet)
                                let distance = getDistance(p1: dropPoints[i], p2: dragItemPoint)
                                if distance < dragBallRadius {
                                    // check existing location
                                    if let foundItem = dragItemList[i] {
                                        foundItem.removeFromSuperview()
                                        dragItemList[i] = nil
                                        dragItemObjList[i] = nil
                                    }
                                    // check ball's previous location
                                    if let previousIdex = dragItemList.firstIndex(of: dragItem) {
                                        dragItemList[previousIdex] = nil
                                        dragItemObjList[previousIdex] = nil
                                    }
                                    dragItemList[i] = dragItem
                                    dragItemObjList[i] = dragItemObj
                                    let convertPoint = vwBracelet.convert(dropPoints[i], to: self.view)
                                    dragItem.center.x = convertPoint.x
                                    dragItem.center.y = convertPoint.y
                                    snap = true
                                    break
                                }
                            } else {
                                if let previousIdex = dragItemList.firstIndex(of: dragItem) {
                                    dragItemList[previousIdex] = nil
                                    dragItemObjList[previousIdex] = nil
                                }
                            }
                        }
                        if !snap {
                            dragItem.removeFromSuperview()
                            self.dragItem = nil
                        }
                    }
                }
            }
        } else if isDragging {
            let dragPoint = pan.location(in: self.view)
            let distance = getDistance(p1: vwBracelet.center, p2: dragPoint)
            if let dragItem = dragItem, abs(circleRadius - distance) < dragBallRadius * 2 {
                let containerPoint = pan.location(in: self.vwBracelet)
                let ballPath = getBallPath(point: containerPoint)
                dragItem.center = vwBracelet.convert(ballPath.path, to: self.view)
                dragItem.transform = CGAffineTransform(rotationAngle: CGFloat(ballPath.angle-1.57))
                if !dragItemList.contains(dragItem) {
                    dragItemList.append(dragItem)
                    dragItemObjList.append(dragItemObj)
                }
            } else {
                dragItem?.center = dragPoint
                if let index = dragItemList.firstIndex(of: dragItem) {
                    dragItemList[index] = nil
                    dragItemObjList[index] = nil
                }
            }
        }
    }
    
    private func getDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let d1 = abs(p1.x - p2.x)
        let d2 = abs(p1.y - p2.y)
        return sqrt(d1 * d1 + d2 * d2)
    }
}

extension PersonalizedVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentStep {
            case 0:
                return 1
            
            case 1:
                return customBraceletDetails?.data?.bracelet.count ?? 0
            
            case 2:
                return selectedBaziMetaData.count
            
            default:
                return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch currentStep {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectionCell", for: indexPath) as! SelectionCell
                cell.braceletSetupData = braceletSetupData
                cell.delegate = self
                return cell
            
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dragCell", for: indexPath) as! DragCell
                let data = customBraceletDetails?.data?.bracelet[indexPath.item]
                cell.ivContent.loadWithCache(strUrl: data?.path)
                cell.lbTitle.text = data?.name
                cell.lbPrice.text = "\(data?.currencyCode ?? "")\(data?.unitPrice ?? "")"
                cell.isSelected = selectedBracelet?.id == data?.id
                return cell
            
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dragCell", for: indexPath) as! DragCell
                let data = selectedBaziMetaData[indexPath.item]
                cell.ivContent.loadWithCache(strUrl: data?.path)
                cell.lbTitle.text = data?.name
                cell.lbPrice.text = "\(data?.currencyCode ?? "")\(data?.unitPrice ?? "")"
                return cell
            
            default:
                return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch currentStep {
            case 0:
                return CGSize(width: self.view.frame.width-16, height: 110)
            
            default:
                return CGSize(width: 115, height: 115)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentStep == 1 {
            selectedBracelet = customBraceletDetails?.data?.bracelet[indexPath.item]
            collectionView.reloadData()
            setupBtnCondition()
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
}

extension PersonalizedVC: SelectionCellDelegate {
    
    func updateValue(text: String?, value: String?, type: SelectionCellType, isNext: Bool?) {
        switch type {
            case .wrist:
                self.wristSizeText = text
                self.wristSize = value
            
            case .bead:
                self.beadSizeText = text
                self.beadSize = value
            
            case .numberBead:
                self.numberBead = value
        }
        
        lbCenter.text = "\(userNameDOB ?? "")\(kLb.wrist_size.localized): \(self.wristSizeText ?? "")\n\(kLb.bead_size.localized): \(self.beadSizeText ?? "")"
        setupBtnCondition()
        for item in self.vwBracelet.layer.sublayers ?? [] {
            if item.isKind(of: CAShapeLayer.self), let index = vwBracelet.layer.sublayers?.firstIndex(of: item) {
                vwBracelet.layer.sublayers?.remove(at: index)
            }
        }
        customBraceletDetails = nil
        for item in self.dragItemList {
            item?.removeFromSuperview()
        }
        
        if self.wristSize != "" && self.beadSize != "" && self.numberBead != "" {
            personalizeViewModel.customBraceletDetails(braceletSize: self.wristSize, beadSize: self.beadSize, totalBead: self.numberBead, baziBalance: self.baziBalance) { (proceed, data) in
                if proceed {
                    if self.isFirstEnter {
                        self.isFirstEnter = !self.isFirstEnter
                        
                        //self.vwTotal.isHidden = false
                        //self.constraintHeightVwTotal.constant = 50
                        
                        self.vwBracelet.isHidden = false
                        self.constraintAspectVwBracelet.isActive = true
                        
                        self.view.layoutIfNeeded()
                    }
                    
                    self.selectedBracelet = nil
                    self.customBraceletDetails = data
                    self.circleBallCount = (Int(self.numberBead ?? "0") ?? 0) + 1
                    self.setupDragView()
                    
                    if isNext ?? false {
                        self.nextHandler(nil)
                    }
                }
            }
        }
    }
}

class DragCell: UICollectionViewCell {
    
    @IBOutlet weak var ivContent: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    override var isSelected: Bool {
        didSet {
            layer.borderColor = isSelected ? UIColor.msBrown.cgColor : UIColor.clear.cgColor
            layer.borderWidth = isSelected ? 2 : 0
        }
    }
}

enum SelectionCellType {
    case wrist
    case bead
    case numberBead
}
protocol SelectionCellDelegate: class {
    func updateValue(text: String?, value: String?, type: SelectionCellType, isNext: Bool?)
}
class SelectionCell: UICollectionViewCell, UITextFieldDelegate {
    @IBOutlet weak var tfFirst: UITextField!
    @IBOutlet weak var tfSecond: UITextField!
    
    var arrSelectionBracelet: [String] = []
    var arrSelectionBead: [String] = []
    var arrSelectionNumberBead: [String] = []
    var braceletSetupData: BraceletSetupModel? {
        didSet {
            if braceletSetupData?.data.count ?? 0 > 0 {
                arrSelectionBracelet = braceletSetupData?.data.filter({ $0?.braceletDesc != nil && $0?.braceletDesc != "" }).map({ $0?.braceletDesc ?? "" }) ?? []
            }
        }
    }
    
    weak var delegate: SelectionCellDelegate?
    
    override func awakeFromNib() {
        tfFirst.delegate = self
        tfSecond.delegate = self
        tfFirst.setupTextField(placeholder: kLb.choose_wrist_size.localized, titleLeft: kLb.wrist_size.localized)
        tfSecond.setupTextField(placeholder: kLb.choose_bead_size.localized, titleLeft: kLb.bead_size.localized)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
            case tfFirst:
                if arrSelectionBracelet.count > 0 {
                    showActionSheet(title: "", message: kLb.choose_wrist_size.localized, totalButton: arrSelectionBracelet, fromVC: UIApplication.topViewController(), sourceView: textField) { (alertController, btnIndex, btnTitle) in
                        textField.text = btnTitle
                        self.tfSecond.text = ""
                        self.arrSelectionBead = self.braceletSetupData?.data[btnIndex]?.beadSize.filter({ $0 != nil }).map({ "\($0 ?? 0)mm" }) ?? []
                        self.arrSelectionNumberBead = self.braceletSetupData?.data[btnIndex]?.numberBead.filter({ $0 != nil }).map({ "\($0 ?? 0)" }) ?? []
                        self.delegate?.updateValue(text: "", value: "" , type: .bead, isNext: false)
                        self.delegate?.updateValue(text: "", value: "" , type: .numberBead, isNext: false)
                        self.delegate?.updateValue(text: textField.text, value: "\(self.braceletSetupData?.data[btnIndex]?.braceletSize ?? 0)" , type: .wrist, isNext: true)
                    }
                }
                return false
            
            case tfSecond:
                if arrSelectionBead.count > 0 {
                    showActionSheet(title: "", message: kLb.choose_wrist_size.localized, totalButton: arrSelectionBead, fromVC: UIApplication.topViewController(), sourceView: textField) { (alertController, btnIndex, btnTitle) in
                        textField.text = btnTitle
                        self.delegate?.updateValue(text: textField.text, value: "\(btnTitle.dropLast(2))", type: .bead, isNext: false)
                        self.delegate?.updateValue(text: "", value: "\(self.arrSelectionNumberBead[btnIndex])", type: .numberBead, isNext: true)
                    }
                }
                return false
            
            default:
                return true
        }
    }
}
