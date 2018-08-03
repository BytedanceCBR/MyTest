//
//  ErshouHouseDetailEntities.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct ErshouHouseDetailResponse: Mappable {
    var status: Int?
    var message: String?
    var data: ErshouHouseData?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct Disclaimer: Mappable {
    var text: String?
    var richText: [RichTextItem] = []

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        text <- map["text"]
        richText <- map["rich_text"]
    }

    struct RichTextItem: Mappable {
        var highlightRange: [Int]?
        var linkUrl: String?

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            highlightRange <- map["highlight_range"]
            linkUrl <- map["link_url"]
        }
    }
}

struct ErshouHouseData: Mappable {
    
    var id: String?
    var title: String?
    var uploadAt: Int = 0
    var houseImage: [ImageItem]?
    var coreInfo: [ErshouHouseCoreInfo]?
    var baseInfo: [ErshouHouseBaseInfo]?
    var neighborhoodInfo: NeighborhoodInfo?
    var contact: [String: Any] = [:]
    var priceTrend: PriceTrend?
    var housePriceRange: [Int: Int]?
    var tags: [TagItem] = []
    var userStatus: UserStatus?
    var disclaimer: Disclaimer?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        uploadAt <- map["upload_at"]
        houseImage <- map["house_image"]
        coreInfo <- map["core_info"]
        baseInfo <- map["base_info"]
        neighborhoodInfo <- map["neighborhood_info"]
        contact <- map["contact"]
        priceTrend <- map["price_trend"]
        housePriceRange <- map["house_price_range"]
        tags <- map["tags"]
        userStatus <- map["user_status"]
        disclaimer <- map["disclaimer"]
    }
}

struct ErshouHouseBaseInfo: Mappable {
    var attr: String?
    var value: String?
    var isSingle: Bool?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        attr <- map["attr"]
        value <- map["value"]
        isSingle <- map["is_single"]
    }
}

struct ErshouHouseCoreInfo: Mappable {
    var attr: String?
    var value: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        attr <- map["attr"]
        value <- map["value"]
    }
}

struct UserStatus: Mappable {
    var houseSubStatus: Int = 0
    var courtSubStatus: Int = 0
    var pricingSubStauts: Int = 0
    var courtOpenSubStatus: Int = 0
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        houseSubStatus <- map["house_sub_status"]
        pricingSubStauts <- map["pricing_sub_status"]
        courtOpenSubStatus <- map["court_open_sub_status"]
        courtSubStatus <- map["court_sub_status"]
    }
}

struct PriceTrend: Mappable {
    var name: String?
    var values: [TrendItem]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        values <- map["values"]
    }
}

struct TrendItem: Mappable {
    var price: String?
    var timeStr: String?
    var timestamp: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        price <- map["price"]
        timeStr <- map["time_str"]
        timestamp <- map["timestamp"]
    }
}

