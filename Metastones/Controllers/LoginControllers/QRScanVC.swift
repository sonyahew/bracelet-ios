//
//  QRScanVC.swift
//  Metastones
//
//  Created by Sonya Hew on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import ZXingObjC

protocol QRScanVCDelegate: class {
    func returnQRValue(value: String)
}

class QRScanVC: UIViewController {
    
    let scanView = UIView()
    let scanMessage = UILabel()
    let btnCancel  = UIButton()
    
    weak var delegate : QRScanVCDelegate?
    
    let popup = PopupManager()
        
    fileprivate var capture: ZXCapture?
    
    fileprivate var isScanning: Bool?
    fileprivate var isFirstApplyOrientation: Bool?
    fileprivate var captureSizeTransform: CGAffineTransform?
    
    var hideNavBar: Bool = false
    var topupAmt : String = ""
    let qrView : UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        setupQRScanner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopQRScanner()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstApplyOrientation == true { return }
        isFirstApplyOrientation = true
        applyOrientation()
    }
    
    func setupView() {
        view.addSubview(scanView)
        scanView.translatesAutoresizingMaskIntoConstraints = false
        scanView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scanView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        scanView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        scanView.heightAnchor.constraint(equalTo: scanView.widthAnchor).isActive = true
        
        view.addSubview(scanMessage)
        scanMessage.text = kLb.align_qr_code_with_the_frame_to_scan.localized
        scanMessage.textColor = .white
        scanMessage.font = .systemFont(ofSize: 14)
        scanMessage.translatesAutoresizingMaskIntoConstraints = false
        scanMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scanMessage.topAnchor.constraint(equalTo: scanView.bottomAnchor, constant: 18).isActive = true
        
        view.addSubview(btnCancel)
        btnCancel.setTitle(kLb.cancel.localized, for: .normal)
        btnCancel.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btnCancel.setTitleColor(.white, for: .normal)
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        btnCancel.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 96).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        btnCancel.addTarget(self, action: #selector(cancelHandler), for: .touchUpInside)
    }
    
    @objc func cancelHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupQRScanner() {
        isScanning = false
        isFirstApplyOrientation = false
        
        capture = ZXCapture()
        guard let _capture = capture else { return }
        _capture.camera = _capture.back()
        _capture.focusMode =  .continuousAutoFocus
        _capture.delegate = self
        self.view.layer.addSublayer(_capture.layer)
        
        let scanFrame = UIImageView(image: #imageLiteral(resourceName: "img-qr-frame.png"))
        scanView.addSubview(scanFrame)
        scanFrame.translatesAutoresizingMaskIntoConstraints = false
        scanFrame.centerYAnchor.constraint(equalTo: scanView.centerYAnchor).isActive = true
        scanFrame.centerXAnchor.constraint(equalTo: scanView.centerXAnchor).isActive = true
        view.bringSubviewToFront(scanView)
        view.bringSubviewToFront(scanMessage)
        view.bringSubviewToFront(btnCancel)
        capture?.start()
    }
    
    func stopQRScanner() {
        capture?.stop()
        isScanning = false
        capture?.layer.removeFromSuperlayer()
    }
    
//    func createFrame() -> CAShapeLayer {
//        let height: CGFloat = scanView.frame.size.height
//        let width: CGFloat = scanView.frame.size.height
//        let path = UIBezierPath()
//        let length: CGFloat = 28
//        path.move(to: CGPoint(x: 5, y: length))
//        path.addLine(to: CGPoint(x: 5, y: 5))
//        path.addLine(to: CGPoint(x: length, y: 5))
//        path.move(to: CGPoint(x: height - length, y: 5))
//        path.addLine(to: CGPoint(x: height - 5, y: 5))
//        path.addLine(to: CGPoint(x: height - 5, y: length))
//        path.move(to: CGPoint(x: 5, y: width - length))
//        path.addLine(to: CGPoint(x: 5, y: width - 5))
//        path.addLine(to: CGPoint(x: length, y: width - 5))
//        path.move(to: CGPoint(x: width - length, y: height - 5))
//        path.addLine(to: CGPoint(x: width - 5, y: height - 5))
//        path.addLine(to: CGPoint(x: width - 5, y: height - length))
//        let shape = CAShapeLayer()
//        shape.path = path.cgPath
//        shape.strokeColor = UIColor.white.cgColor
//        shape.lineWidth = 5
//        shape.fillColor = UIColor.clear.cgColor
//        return shape
//    }
    
    func applyOrientation() {
        let orientation = UIApplication.shared.statusBarOrientation
        var captureRotation: Double
        var scanRectRotation: Double
        
        switch orientation {
        case .portrait:
            captureRotation = 0
            scanRectRotation = 90
            break
            
        case .landscapeLeft:
            captureRotation = 90
            scanRectRotation = 180
            break
            
        case .landscapeRight:
            captureRotation = 270
            scanRectRotation = 0
            break
            
        case .portraitUpsideDown:
            captureRotation = 180
            scanRectRotation = 270
            break
            
        default:
            captureRotation = 0
            scanRectRotation = 90
            break
        }
        
        applyRectOfInterest(orientation: orientation)
        
        let angleRadius = captureRotation / 180.0 * Double.pi
        let captureTranform = CGAffineTransform(rotationAngle: CGFloat(angleRadius))
        
        capture?.transform = captureTranform
        capture?.rotation = CGFloat(scanRectRotation)
        capture?.layer.frame = view.frame
    }
    
    func applyRectOfInterest(orientation: UIInterfaceOrientation) {
        var transformedVideoRect = view.frame
        let cameraSessionPreset = capture?.sessionPreset

        var scaleVideoX, scaleVideoY: CGFloat
        var videoHeight, videoWidth: CGFloat

        // Currently support only for 1920x1080 || 1280x720
        if cameraSessionPreset == AVCaptureSession.Preset.hd1920x1080.rawValue {
            videoHeight = 1080.0
            videoWidth = 1920.0
        } else {
            videoHeight = 720.0
            videoWidth = 1280.0
        }

        if orientation == UIInterfaceOrientation.portrait {
            scaleVideoX = self.view.frame.width / videoHeight
            scaleVideoY = self.view.frame.height / videoWidth

            // Convert CGPoint under portrait mode to map with orientation of image
            // because the image will be cropped before rotate
            // reference: https://github.com/TheLevelUp/ZXingObjC/issues/222
            let realX = transformedVideoRect.origin.y;
            let realY = self.view.frame.size.width - transformedVideoRect.size.width - transformedVideoRect.origin.x;
            let realWidth = transformedVideoRect.size.height;
            let realHeight = transformedVideoRect.size.width;
            transformedVideoRect = CGRect(x: realX, y: realY, width: realWidth, height: realHeight);

        } else {
            scaleVideoX = self.view.frame.width / videoWidth
            scaleVideoY = self.view.frame.height / videoHeight
        }

        captureSizeTransform = CGAffineTransform(scaleX: 1.0/scaleVideoX, y: 1.0/scaleVideoY)
        guard let _captureSizeTransform = captureSizeTransform else { return }
        let transformRect = transformedVideoRect.applying(_captureSizeTransform)
        capture?.scanRect = transformRect
    }

    func barcodeFormatToString(format: ZXBarcodeFormat) -> String {
        switch (format) {
        case kBarcodeFormatAztec:
            return "Aztec"

        case kBarcodeFormatCodabar:
            return "CODABAR"

        case kBarcodeFormatCode39:
            return "Code 39"

        case kBarcodeFormatCode93:
            return "Code 93"

        case kBarcodeFormatCode128:
            return "Code 128"

        case kBarcodeFormatDataMatrix:
            return "Data Matrix"

        case kBarcodeFormatEan8:
            return "EAN-8"

        case kBarcodeFormatEan13:
            return "EAN-13"

        case kBarcodeFormatITF:
            return "ITF"

        case kBarcodeFormatPDF417:
            return "PDF417"

        case kBarcodeFormatQRCode:
            return "QR Code"

        case kBarcodeFormatRSS14:
            return "RSS 14"

        case kBarcodeFormatRSSExpanded:
            return "RSS Expanded"

        case kBarcodeFormatUPCA:
            return "UPCA"

        case kBarcodeFormatUPCE:
            return "UPCE"

        case kBarcodeFormatUPCEANExtension:
            return "UPC/EAN extension"

        default:
            return "Unknown"
        }
    }
    
    @objc
    func dismissController() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: ZXCaptureDelegate
extension QRScanVC: ZXCaptureDelegate {
    func captureCameraIsReady(_ capture: ZXCapture!) {
        isScanning = true
    }
    
    func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
        guard let _result = result, isScanning == true else { return }
        
        let qrData = _result.text ?? ""
        if _result.barcodeFormat == kBarcodeFormatQRCode {
            capture?.stop()
            isScanning = false
            
            if !qrData.isEmpty, qrData != "", let yourTargetUrl = URL(string:qrData){
                var dict = [String:String]()
                let components = URLComponents(url: yourTargetUrl, resolvingAgainstBaseURL: false)!
                if let queryItems = components.queryItems {
                    for item in queryItems {
                        dict[item.name] = item.value ?? ""
                    }
                }

                if let referralCode = dict["r"], referralCode != "" {
                    delegate?.returnQRValue(value: referralCode)
                    navigationController?.popViewController(animated: true)
                } else {
                    popup.showAlert(destVC: popup.getErrorPopup(desc: kLb.please_scan_a_valid_qr_code.localized)) { (_) in
                        self.resumeCapture()
                    }
                }
                
            } else {
                popup.showAlert(destVC: popup.getErrorPopup(desc: kLb.please_scan_a_valid_qr_code.localized)) { (_) in
                    self.resumeCapture()
                }
            }
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        } else {
            popup.showAlert(destVC: popup.getErrorPopup(desc: kLb.please_scan_a_valid_qr_code.localized)) { (_) in
                self.resumeCapture()
            }
        }
    }
    
    func resumeCapture() {
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.isScanning = true
            weakSelf.capture?.start()
        }
    }
}

