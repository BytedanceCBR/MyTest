//
//  SearchEntities.swift
//  Bubble
//
//  Created by linlin on 2018/6/22.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct SearchConfigResponse: Mappable {

    var status: Int?
    var data: SearchConfigResponseData?
    var message: String?

    init?(map: Map) {
        
    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
        message <- map["message"]
    }

}

struct SearchConfigResponseData: Mappable {

    var filter: [SearchConfigFilterItem]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        filter <- map["filter"]
    }


}

struct SearchConfigFilterItem: Mappable {

    var text: String?
    var tabId: Int?
    var options: [SearchConfigOption]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        text <- map["text"]
        tabId <- map["tab_id"]
        options <- map["options"]
    }
}

struct SearchConfigOption: Mappable {
    var name: String?
    var supportMulti: Bool?
    var options: [SearchConfigOption]?
    var type: String?
    var text: String?
    var value: Any?
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        name <- map["name"]
        supportMulti <- map["support_multi"]
        options <- map["options"]
        type <- map["type"]
        value <- map["value"]
        text <- map["text"]
    }
}

