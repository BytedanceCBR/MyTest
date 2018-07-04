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

//struct TagItem: Mappable {
//    var id: Int?
//    var content: String?
//    var backgroundColor: String?
//    var textColor: String?
//
//    init?(map: Map) {
//
//    }
//
//    mutating func mapping(map: Map) {
//        id <- map["id"]
//        content <- map["content"]
//        backgroundColor <- map["background_color"]
//        textColor <- map["text_color"]
//    }
//}

struct ErshouHouseData: Mappable {
    
    var id: String?
    var title: String?
    var uploadAt: Int = 0
    var houseImage: [ImageItem]?
    var coreInfo: [ErshouHouseCoreInfo]?
    var baseInfo: [ErshouHouseBaseInfo]?
    var neighborhoodInfo: NeighborhoodInfo?
    var contact: [String: String]?
    var abtestVersions: String?
    var priceTrend: PriceTrend?
    var housePriceRange: [Int: Int]?
    var tags: [TagItem]?
    var userStatus: UserStatus?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        uploadAt <- map["upload_at"]
        coreInfo <- map["core_info"]
        houseImage <- map["house_image"]
        neighborhoodInfo <- map["neighborhood_info"]
        tags <- map["tags"]
        contact <- map["contact"]

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
    var houseSubStatus: Int?
    var pricingSubStauts: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        houseSubStatus <- map["house_sub_status"]
        pricingSubStauts <- map["pricing_sub_stauts"]
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

