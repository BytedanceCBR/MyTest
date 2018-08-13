//
//  CommonEntities.swift
//  Article
//
//  Created by leo on 2018/8/13.
//

import Foundation
import ObjectMapper

struct LogPB: Mappable {

    var status: Int?


    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        status <- map["status"]

    }


}
