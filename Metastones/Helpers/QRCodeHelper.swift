//
//  QRCodeHelper.swift
//  Metastones
//
//  Created by Ivan Tuang on 25/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class QRCodeHelper: NSObject {
    func generateQrCode(content : String) -> UIImage? {
        
        let data = content.data(using: String.Encoding.utf8)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        guard let qrImage = qrFilter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 15, y: 15)
        let scaledQrImage = qrImage.transformed(by: transform)
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        //guard let logo = CIImage(image: #imageLiteral(resourceName: "icon-earn-p")) else { return nil }
        //guard let qrCodeWithLogo = ciImage.combined(with: logo) else { return nil }
        
        return UIImage(ciImage: ciImage)
    }
}
