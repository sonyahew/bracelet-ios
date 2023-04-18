//
//  OrderStatusModel.swift
//  Metastones
//
//  Created by Ivan Tuang on 02/12/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit
import HandyJSON

struct OrderStatusModel: HandyJSON, Codable {
    var err: Int?
    var msg: String?
    var data: OrderStatusDataModel? = OrderStatusDataModel.init()
}

struct OrderStatusDataModel: HandyJSON, Codable  {
    var status: String?
    var order: [OrderHistorySubdataModel?] = []
}
