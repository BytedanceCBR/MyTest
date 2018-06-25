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
    var hotCityList: [HotCityItem]?
    var cityList: [CityItem]?
    var entryList: [EntryItem]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        hotCityList <- map["hot_city_list"]
        cityList <- map["city_list"]
        entryList <- map["entry_list"]
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
