//
// Created by linlin on 2018/6/19.
// Copyright (c) 2018 linlin. All rights reserved.
//

import ObjectMapper

@objc enum HouseType: Int {
    case newHouse = 1
    case secondHandHouse = 2
    case rentHouse = 3
    case neighborhood = 4    

    func traceTypeValue() -> String {
        switch self {
        case .newHouse:
            return "new"
        case .secondHandHouse:
            return "old"
        case .rentHouse:
            return "rent"
        case .neighborhood:
            return "neighborhood"
        }
    }
    
    func stringValue() -> String {
        switch self {
        case .newHouse:
            return "新房"
        case .secondHandHouse:
            return "二手房"
        case .rentHouse:
            return "租房"
        case .neighborhood:
            return "小区"
        }
    }
    
}

struct HouseItemEntity: Mappable {
    var items: [HouseItemInnerEntity]?
    var total: Int = 0
    var refreshTip: String?
    var searchId: String?
    var hasMore: Bool? = false
    
    init?(map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        items <- map["items"]
        total <- map["total"]
        refreshTip <- map["refresh_tip"]
        searchId <- map["search_id"]
        hasMore <- map["has_more"]
    }
}

struct HouseItemInnerEntity: Mappable {
    
    //properties
    var id: String?
    var impr_id:String?
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
    var tags: [TagItem]?
    var displayBuiltYear: String?
    var displayPricePerSqm: String?
    var displayPrice: String?
    var status: Int?
    var cellstyle: Int?
    var logPB: [String: Any]?
    var images: [ImageItem]?
    var houseImageTag: HouseImageTag?
    var recommendReasons: [ResommendReason]?
    var fhSearchId: String?

    init?(map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {

        var info: [String: Any] = [:]
        info <- map["base_info"]

        id <- map["id"]
        impr_id <- map["impr_id"]
        title <- map["title"]
        uploadAt <- map["upload_at"]
        displayTitle <- map["display_title"]
        displaySubtitle <- map["display_subtitle"]
        displayDescription <- map["display_description"]
        neighborhoodInfo <- map["neighborhood_info"]
        url <- map["url"]
        coreInfo <- map["core_info"]
        baseInfo <- map["base_info"]
        baseInfoMap <- map["base_info_map"]
        houseImage <- map["house_image"]
        neighborhoodInfo <- map["neighborhood_info"]
        displayBuiltYear <- map["display_built_year"]
        displayPrice <- map["display_price"]
        displayPricePerSqm <- map["display_price_per_sqm"]
        status <- map["status"]
        cellstyle <- map["cell_style"]
        images <- map["images"]
        tags <- map["tags"]
        houseImageTag <- map["house_image_tag"]
        recommendReasons <- map["recommend_reasons"]
        logPB <- map["log_pb"]
    }

    struct HouseImageTag: Mappable {

        var id: String?
        var text: String?
        var backgroundColor: String?
        var textColor: String?

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            id <- map["id"]
            text <- map["text"]
            backgroundColor <- map["background_color"]
            textColor <- map["text_color"]
        }
    }

    struct ResommendReason: Mappable {

        var id: String?
        var text: String?
        var textColor: String?
        var textAlpha: Int?
        var backgroundColor: String?
        var backgroundAlpha: Int?
        var iconText: String?
        var iconTextColor: String?
        var iconTextAlpha: String?
        var iconBackgroundColor: String?
        var iconBackgroundAlpha: String?
        
        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            id <- map["id"]
            text <- map["text"]
            textColor <- map["text_color"]
            textAlpha <- map["text_alpha"]
            backgroundColor <- map["background_color"]
            backgroundAlpha <- map["background_alpha"]
            iconText <- map["icon_text"]
            iconTextColor <- map["icon_text_color"]
            iconTextAlpha <- map["icon_text_alpha"]
            iconBackgroundColor <- map["icon_background_color"]
            iconBackgroundAlpha <- map["icon_background_alpha"]
        }
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
    var pricingPerSqm: String?
    var address: String?
    var monthUp: Float?
    var gaodeLng: String?
    var gaodeLat: String?
    var gaodeImageUrl: String?
    var images: [ImageItem]?
    var displayTitle: String?
    var displaySubtitle: String?
    var displayBuiltYear: String?
    var displayDescription: String?
    var houseType: Int?
    var pricingPerSqmValue: Int = 1
    var displayPricePerSqm: String?
    var displayPrice: String?


    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        address <- map["address"]
        monthUp <- map["month_up"]
        pricingPerSqm <- map["pricing_per_sqm"]
        gaodeLng <- map["gaode_lng"]
        gaodeLat <- map["gaode_lat"]
        gaodeImageUrl <- map["gaode_image_url"]
        images <- map["images"]
        displayTitle <- map["display_title"]
        displaySubtitle <- map["display_subtitle"]
        displayDescription <- map["display_description"]
        displayPrice <- map["display_price"]
        displayBuiltYear <- map["display_built_year"]
        houseType <- map["house_type"]
        pricingPerSqmValue <- map["pricing_per_sqm_v"]
        displayPricePerSqm <- map["display_price_per_sqm"]
    }
}


struct HouseRecommendResponse: Mappable {
    
    var data: HouseItemEntity?
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

struct RelatedHouseResponse: Mappable {
    
    var data: HouseItemEntity?
    var message: String?
    var status: Int?
    var searchId: String?

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
        searchId <- map["search_id"]

    }
    
}

struct RelatedCourtResponse: Mappable {
    
    var data: CourtItemEntity?
    var message: String?
    var status: Int?
    var searchId: String?

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
        searchId <- map["search_id"]

    }
    
}


struct RelatedNeighborhoodResponse: Mappable {
    
    var data: NeighborhoodItemEntity?
    var message: String?
    var status: Int?
    var searchId: String?

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
        searchId <- map["search_id"]

    }
    
}

struct HouseRecommendSection: Mappable {
    
    var title: String?
    var link: String?
    var items: [HouseItemInnerEntity]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        link <- map["link"]
        items <- map["items"]
    }
}

struct CourtRecommendSection: Mappable {
    
    var title: String?
    var link: String?
    var items: [CourtItemInnerEntity]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        link <- map["link"]
        items <- map["items"]
    }
}


struct HouseRecommendData: Mappable {

    var items: [HouseItemInnerEntity]?
    var hasMore: Bool = false
    var searchId: String?
    var refreshTip: String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        hasMore <- map["has_more"]
        items <- map["items"]
        refreshTip <- map["refresh_tip"]
        searchId <- map["search_id"]

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

