//
//  HouseDetailEntities.swift
//  Bubble
//
//  Created by linlin on 2018/6/28.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct HouseDetailEntry: Mappable {

    var status: Int?
    var message: String?
    var data: [String: Any]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}
