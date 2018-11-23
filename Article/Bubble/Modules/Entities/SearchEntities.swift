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
    var filterOrder: [SearchConfigFilterItem]?

    var courtFilter: [SearchConfigFilterItem]?
    var courtFilterOrder: [SearchConfigFilterItem]?

    var neighborhoodFilter: [SearchConfigFilterItem]?
    var neighborhoodFilterOrder: [SearchConfigFilterItem]?

    var saleHistoryFilter: [SearchConfigFilterItem]?

    var searchTabCourtFilter: [SearchConfigFilterItem]?
    var searchTabFilter: [SearchConfigFilterItem]?
    var searchTabNeighborHoodFilter: [SearchConfigFilterItem]?

    var abTestVersion: Any?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        filter <- map["filter"]
        filterOrder <- map["house_filter_order"]
        courtFilter <- map["court_filter"]
        courtFilterOrder <- map["court_filter_order"]
        neighborhoodFilter <- map["neighborhood_filter"]
        neighborhoodFilterOrder <- map["neighborhood_filter_order"]
        saleHistoryFilter <- map["sale_history_filter"]

        searchTabCourtFilter <- map["search_tab_court_filter"]
        searchTabFilter <- map["search_tab_filter"]
        searchTabNeighborHoodFilter <- map["search_tab_neighborhood_filter"]

        abTestVersion <- map["abtest"]
    }
}

struct SearchConfigFilterItem: Mappable {

    var text: String?
    var tabId: Int?
    var tabStyle: Int?
    var options: [SearchConfigOption]?
    var supportMulti: Bool = false
    var rate: Int = 1
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        text <- map["text"]
        tabId <- map["tab_id"]
        tabStyle <- map["tab_style"]
        options <- map["options"]
        rate <- map["rate"]
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
    var rankType: String?
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        supportMulti <- map["support_multi"]
        options <- map["options"]
        type <- map["type"]
        value <- map["value"]
        text <- map["text"]
        isEmpty <- map["is_empty"]
        rankType <- map["rank_type"]
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

struct SearchHistoryResponse: Mappable {
    var status: Int?
    var message: String?
    var data: Data?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }


    struct Data: Mappable {
        var data: [Item]?

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            data <- map["data"]
        }
    }

    struct Item: Mappable {
        var text: String?
        var listText: String?
        var userOriginEnter: String?
        var openUrl: String?
        var desc: String?
        var historyId: String?
        var extinfo: Any?

        init?(map: Map) {

        }

        init() {
            
        }

        mutating func mapping(map: Map) {
            text <- map["text"]
            listText <- map["list_text"]
            userOriginEnter <- map["user_origin_enter"]
            openUrl <- map["open_url"]
            desc <- map["description"]
            extinfo <- map["extinfo"]
            historyId <- map["history_id"]
        }
    }
}

// 猜你想搜
struct GuessYouWantResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data: GuessYouWantList?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct GuessYouWantList: Mappable {
    var data : [GuessYouWant]?
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        data <- map["data"]
    }
}

struct GuessYouWant: Mappable {
    var text : String?
    var extinfo:String?
    var guessSearchId : String?
    var houseType : Int = 0
    var guessSearchType : Int = 0
    var openUrl:String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        text <- map["text"]
        extinfo <- map["extinfo"]
        guessSearchId <- map["guess_search_id"]
        houseType <- map["house_type"]
        guessSearchType <- map["guess_search_type"]
        openUrl <- map["open_url"]
    }
}
