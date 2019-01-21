//
//  SearchNeighborhoodEntity.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct SearchNeighborhoodResponse: Mappable {
    
    var data: NeighborhoodItemEntity?
    var message: String?
    var status: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
    }
    
}

struct NeighborhoodItemEntity: Mappable {
    var items: [NeighborhoodInnerItemEntity]?
    var hasMore: Bool = false
    var total: Int = 0
    var refreshTip: String?
    var searchId: String?
    var logPB: [String: Any]?
    var houseListOpenUrl: String?

    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.items <- map["items"]
        hasMore <- map["has_more"]
        total <- map["total"]
        refreshTip <- map["refresh_tip"]
        searchId <- map["search_id"]
        logPB <- map["log_pb"]
        houseListOpenUrl <- map["house_list_open_url"]
    }
}

struct BaseInfoMapItem: Mappable {
    var builtYear: String?
    var pricingPerSqm: String?

    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.builtYear <- map["built_year"]
        self.pricingPerSqm <- map["pricing_per_sqm"]

    }
}

struct NeighborhoodInnerItemEntity: Mappable {
    
    //properties
    var id: String?
    var name: String?
    var uploadAt: Int?
    var address: String?
    var displayTitle: String?
    var displaySubtitle: String?
    var displayPricePerSqm: String?
    var displayPrice: String?
    var displayBuiltYear: String?
    var displayDescription: String?
    var houseType: Int?
    var gaodeLng: String?
    var gaodeLat: String?
    var baseInfoMap: BaseInfoMapItem?
    var images: [ImageItem]?
    var displayStatusInfo: String?
    var logPB: [String: Any]?
    var fhSearchId: String?
    var imprId: String?
    var searchId: String?

    init?(map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        images <- map["images"]
        address <- map["address"]
        displayTitle <- map["display_title"]
        displaySubtitle <- map["display_subtitle"]
        displayPrice <- map["display_price"]
        displayBuiltYear <- map["display_built_year"]
        houseType <- map["house_type"]
        displayPricePerSqm <- map["display_price_per_sqm"]
        displayDescription <- map["display_description"]
        baseInfoMap <- map["base_info_map"]
        gaodeLng <- map["gaode_lng"]
        gaodeLat <- map["gaode_lat"]
        displayStatusInfo <- map["display_stats_info"]
        logPB <- map["log_pb"]
        fhSearchId <- map["fhSearchId"]
        imprId <- map["impr_id"]
        searchId <- map["search_id"]

    }
    
}


struct SameNeighborhoodHouseResponse: Mappable {
    var message: String?
    var status: Int = 0
    var data: Data?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        message <- map["message"]
        data <- map["data"]
        status <- map["status"]
    }

    struct Data: Mappable {
        var items: [HouseItemInnerEntity] = []
        var hasMore: Bool = false
        var total: Int = 0
        var refreshTip: String?
        var searchId: String?
        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            items <- map["items"]
            hasMore <- map["has_more"]
            total <- map["total"]
            refreshTip <- map["refresh_tip"]
            searchId <- map["search_id"]
        }
    }

}
