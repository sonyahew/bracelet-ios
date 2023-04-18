//
//  AppDataModel.swift
//  Metastones
//
//  Created by Sonya Hew on 08/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

struct AppDataModel: Codable {

    var pnToken: String? = ""
    var token: String? = ""
    var sessionId: String? = ""
    var langId: String? = "en"
    var cartItemCount: Int? = 0
    var quoteId: String? = ""
    var signUpSuccessImgStr: String? = ""
    var isRedeemedVoucher: Bool = false
}
