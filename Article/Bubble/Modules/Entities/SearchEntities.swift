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
    var courtFilter: [SearchConfigFilterItem]?
    var neighborhoodFilter: [SearchConfigFilterItem]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        filter <- map["filter"]
        courtFilter <- map["court_filter"]
        neighborhoodFilter <- map["neighborhood_filter"]
    }
}

struct SearchConfigFilterItem: Mappable {

    var text: String?
    var tabId: Int?
    var tabStyle: Int?
    var options: [SearchConfigOption]?
    var supportMulti: Bool = false
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        text <- map["text"]
        tabId <- map["tab_id"]
        tabStyle <- map["tab_style"]
        options <- map["options"]
        supportMulti <- map["support_multi"]
    }
}

struct SearchConfigOption: Mappable {
    var supportMulti: Bool?
    var options: [SearchConfigOption]?
    var type: String?
    var text: String?
    var value: Any = 0
    var isEmpty: Int = 0
    var isNoLimit: Int = 0
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        supportMulti <- map["support_multi"]
        options <- map["options"]
        type <- map["type"]
        value <- map["value"]
        text <- map["text"]
        isEmpty <- map["is_empty"]
        isNoLimit <- map["is_no_limit"]
    }
}

struct SearchRelatedErshouHouseResponse: Mappable {
    var status: Int?
    var message: String?
    var data: [ErshouHouseData]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}
