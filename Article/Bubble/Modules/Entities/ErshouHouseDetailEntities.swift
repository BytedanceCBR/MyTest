//
//  ErshouHouseDetailEntities.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct ShareInfo: Mappable {

    var shareUrl: String?
    var title: String = ""
    var isVideo: Int = 0
    var coverImage: String?
    var desc: String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        shareUrl <- map["share_url"]
        title <- map["title"]
        isVideo <- map["is_video"]
        coverImage <- map["cover_image"]
        desc <- map["description"]
    }
}

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
    var priceTrend: [PriceTrend]?
    var housePriceRange: HousePriceRange?
    var tags: [TagItem] = []
    var userStatus: UserStatus?
    var disclaimer: Disclaimer?
    var logPB: [String: Any]?
    var shareInfo: ShareInfo?
    var pricingPerSqmValue: Int = 1
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
        shareInfo <- map["share_info"]
        pricingPerSqmValue <- map["pricing_per_sqm_v"]
        logPB <- map["log_pb"]
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

struct HousePriceRange: Mappable {
    var cur_price: Int?
    var price_min: Int?
    var price_max: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        cur_price <- map["cur_price"]
        price_min <- map["price_min"]
        price_max <- map["price_max"]

    }
}

struct PriceTrend: Mappable {
    var name: String?
    var values: [TrendItem] = []
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        values <- map["values"]
    }
}

struct TrendItem: Mappable {
    var price: String? // 单位是分钱，不是元
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

