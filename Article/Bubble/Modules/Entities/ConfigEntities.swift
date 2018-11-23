//
//  Configs.swift
//  Bubble
//
//  Created by linlin on 2018/6/25.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper
struct GeneralConfigResponse: Mappable {

    var data: GeneralConfigData?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        data <- map["data"]
    }

}

struct GeneralConfigData: Mappable {
    var hotCityList: [HotCityItem] = []
    var cityList: [CityItem] = []
    var entryList: [EntryItem] = []
    var housetypelist: [Int] = []
    var currentCityId: Int64?
    var currentCityName: String?
    var opData: OpData?
    var opData2: Any?
    var banners: [Banner]?
    var reviewInfo: ConfigReviewInfo?
    var mapSearch : MapSearch?
    
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        hotCityList <- map["hot_city_list"]
        cityList <- map["city_list"]
        entryList <- map["entry_info"]
        currentCityId <- map["current_city_id"]
        currentCityName <- map["current_city_name"]
        opData <- map["op_data"]
        opData2 <- map["op_data_2"]
        banners <- map["banners"]
        housetypelist <- map["house_type_list"]
        reviewInfo <- map["review_info"]
        mapSearch <- map["map_search"]
    }
}

struct ConfigReviewInfo: Mappable {
    
    var isFLogin: Bool = false // 是否 fake login，类型 bool
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        isFLogin <- map["is_f_login"]
    }
    
}

struct HotCityItem: Mappable {

    var name: String?
    var cityId: Int = 0
    var iconUrl: String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        name <- map["name"]
        cityId <- map["city_id"]
        iconUrl <- map["icon_url"]
    }

}

struct CityItem: Mappable {
    var name: String?
    var fullPinyin: String = ""
    var simplePinyin: String = ""
    var cityId: Int = 0

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        name <- map["name"]
        fullPinyin <- map["full_pinyin"]
        simplePinyin <- map["simple_pinyin"]
        cityId <- map["city_id"]
    }
}

struct EntryItem: Mappable {
    var iconUrl: String?
    var name: String?
    var entryId: Int = 0

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        iconUrl <- map["icon_url"]
        name <- map["name"]
        entryId <- map["entry_id"]
    }

}

struct OpData: Mappable {
    var opStyle: Int = 1
    var items: [Item] = []

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        opStyle <- map["op_style"]
        items <- map["items"]
    }


    struct Item: Mappable {

        var hotCityList: String?
        var title: String?
        var description: String?
        var image: [ImageItem] = []
        var openUrl: String?
        var backgroundColor: String?
        var textColor: String?
        var logPb: [String: Any]?
        var id: String = ""

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            id <- map["id"]
            hotCityList <- map["hot_city_list"]
            title <- map["title"]
            description <- map["description"]
            image <- map["image"]
            openUrl <- map["open_url"]
            backgroundColor <- map["background_color"]
            textColor <- map["text_color"]
            logPb <- map["log_pb"]
        }
    }
}

struct Banner: Mappable {
    var id: String?
    var image: ImageItem?
    var url: String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        image <- map["image"]
        url <- map["url"]
    }
}

struct MapSearch : Mappable {
    
    var centerLatitude : String?
    var centerLongitude : String?
    var resizeLevel : Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        centerLatitude <- map["center_latitude"]
        centerLongitude <- map["center_longitude"]
        resizeLevel <- map["resize_level"]
    }
}


struct RentOpItem : Mappable {
    
    var id : String?
    var title : String?
    
    var image: [ImageItem] = []
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        id <- map["id"]
        
    }
    
    
}

struct RentOpData : Mappable {
    var opStyle : Int?
    var items : [RentOpItem]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        opStyle <- map["op_style"]
        items <- map["items"]
    }
}

