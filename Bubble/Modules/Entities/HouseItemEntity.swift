//
// Created by linlin on 2018/6/19.
// Copyright (c) 2018 linlin. All rights reserved.
//

import ObjectMapper

enum HouseType: Int {
    case newHouse = 1
    case secondHandHouse = 2
    case neighborhood = 3

    func stringValue() -> String {
        switch self {
        case .newHouse:
            return "新房"
        case .secondHandHouse:
            return "二手房"
        case .neighborhood:
            return "小区"
        }
    }
}

struct HouseItemEntity: Mappable {

    //properties
    var id: String?
    var title: String?
    var uploadAt: Int?
    var displayTitle: String?
    var displaySubtitle: String?
    var displayDescription: String?
    var url: String?
    var coreInfo: [HouseItemAttribute]?
    var baseInfo: [HouseItemAttribute]?
    var baseInfoMap: HouseItemBaseInfo?
    var houseImage: [ImageItem]?
    var neighborhoodInfo: NeighborhoodInfo?

    init?(map: Map) {

    }

    // Mappable
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        uploadAt <- map["upload_at"]
        displayTitle <- map["display_title"]
        displaySubtitle <- map["display_subtitle"]
        displayDescription <- map["display_description"]
        url <- map["url"]
        coreInfo <- map["core_info"]
        baseInfo <- map["base_info"]
        baseInfoMap <- map["base_info_map"]
        houseImage <- map["house_image"]
        neighborhoodInfo <- map["neighborhood_info"]
    }

}

struct HouseItemAttribute: Mappable {
    var attr: String?
    var value: String?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        self.attr <- map["attr"]
        self.value <- map["value"]
    }
}

struct HouseItemBaseInfo: Mappable {
    var pricing: String?
    var pricingPerSqm: String?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        self.pricing <- map["pricing"]
        self.pricingPerSqm <- map["pricing_per_sqm"]
    }
}

struct ImageItem: Mappable {
    var uri: String?
    var url: String?
    var width: Int?
    var height: Int?
    var urlList: [String]?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        self.uri <- map["uri"]
        self.url <- map["url"]
        self.width <- map["width"]
        self.height <- map["height"]
        self.urlList <- map["url_list"]
    }
}

struct NeighborhoodInfo: Mappable {
    var id: String?
    var name: String?
    var address: String?
    var lng: Double?
    var lat: Double?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.address <- map["address"]
        self.lng <- map["lng"]
        self.lat <- map["lat"]
    }
}

struct HouseRecommendResponse: Mappable {

    var data: [HouseItemEntity]?
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

struct HouseRecommendSection: Mappable {

    var title: String?
    var link: String?
    var items: [HouseItemEntity]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        title <- map["title"]
        link <- map["link"]
        items <- map["items"]
    }
}

struct HouseRecommendData: Mappable {


    var court: HouseRecommendSection?
    var house: HouseRecommendSection?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        court <- map["court"]
        house <- map["house"]
    }

}

struct CourtItems: Mappable {
    var title: String?
    var link: String?
    var items: [Item]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        title <- map["title"]
        link <- map["link"]
        items <- map["items"]
    }

    struct Item: Mappable {

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
        }

    }
}

struct HouseItems {
    var title: String?
    var link: String?
    var items: [Item]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        title <- map["title"]
        link <- map["link"]
        items <- map["items"]
    }

    struct Item: Mappable {

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
        }

    }
}

struct HouseRecommendResponse1: Mappable {

    var data: HouseRecommendData?
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

