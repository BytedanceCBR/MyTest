//
//  HouseDetailEntities.swift
//  Bubble
//
//  Created by linlin on 2018/6/28.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct CourtComentResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data: NewHouseComment?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct PermitList: Mappable {
    var permit : String?
    var permitDate : String?
    var bindBuilding : String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        permit <- map["permit"]
        permitDate <- map["permit_date"]
        bindBuilding <- map["bind_building"]
    }
}
struct CourtMoreDetail: Mappable {
    
    var developerName : String?
    var saleStatus : String?
    var pricingPerSqm : String?
    var openDate : String?
    var deliveryDate : String?
    var circuitDesc : String?
    var generalAddress : String?
    var saleAddress : String?
    var properyType : String?
    var featureDesc : String?
    var buildingType : String?
    var buildingCategory : String?
    var decoration : String?
    var propertyRight : String?
    var propertyName : String?
    var propertyPrice: String?
    var powerWaterGasDesc : String?
    var heating : String?
    var greenRatio : String?
    var parkingNum : String?
    var plotRatio : String?
    var buildingDesc : String?
    var permitList : [PermitList]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        developerName <- map["developer_name"]
        saleStatus <- map["sale_status"]
        pricingPerSqm <- map["pricing_per_sqm"]
        openDate <- map["open_date"]
        deliveryDate <- map["delivery_date"]
        circuitDesc <- map["circuit_desc"]
        generalAddress <- map["general_address"]
        saleAddress <- map["sale_address"]
        properyType <- map["propery_type"]
        featureDesc <- map["feature_desc"]
        buildingType <- map["building_type"]
        buildingCategory <- map["building_category"]
        decoration <- map["decoration"]
        propertyRight <- map["property_right"]
        propertyName <- map["property_name"]
        propertyPrice <- map["property_price"]
        powerWaterGasDesc <- map["power_water_gas_desc"]
        heating <- map["heating"]
        greenRatio <- map["green_ratio"]
        parkingNum <- map["parking_num"]
        plotRatio <- map["plot_ratio"]
        buildingDesc <- map["building_desc"]
        permitList <- map["permit_list"]
    }
}

struct CourtMoreDetailResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data: CourtMoreDetail?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}


struct CourtFloorPanResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data: FloorPan?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct CourtTimelineResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data: TimeLine?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct CourtPriceResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data: GlobalPrice?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct HouseDetailResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data: NewHouseData?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct NewHouseData: Mappable {
    
    var id: Int?
    var title: String?
    var uploadAt: Int = 0
    var imageGroup: [ImageGroup]?
    var coreInfo: NewHouseCoreInfo?
    var tags: [TagItem]?
    var contact: [String: String]?
    var timeLine: TimeLine?
    var floorPan: FloorPan?
    var comment: NewHouseComment?
    var globalPricing: GlobalPrice?
    var userStatus: UserStatus?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        uploadAt <- map["upload_at"]
        imageGroup <- map["image_group"]
        coreInfo <- map["core_info"]
        tags <- map["tags"]
        contact <- map["contact"]
        timeLine <- map["timeline"]
        floorPan <- map["floorpan_list"]
        comment <- map["comment"]
        globalPricing <- map["global_pricing"]
        userStatus <- map["user_status"]
    }
}

struct NewHouseCoreInfo: Mappable {
    var name: String?
    var aliasName: String?
    var constructionOpendate: String?
    var courtAddress: String?
    var pricingPerSqm: String?
    var geodeLng: String?
    var geodeLat: String?
    var geodeImageUrl: String?
    var saleStatus: TagItem?
    var propertyType: TagItem?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        aliasName <- map["alias_name"]
        constructionOpendate <- map["construction_opendate"]
        courtAddress <- map["court_address"]
        pricingPerSqm <- map["pricing_per_sqm"]
        geodeLng <- map["gaode_lng"]
        geodeLat <- map["gaode_lat"]
        geodeImageUrl <- map["geode_image_url"]
        saleStatus <- map["sale_status"]
        propertyType <- map["property_type"]
    }
}

struct TagItem: Mappable {
    var id: Int?
    var content: String?
    var backgroundColor: String?
    var textColor: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        content <- map["content"]
        backgroundColor <- map["background_color"]
        textColor <- map["text_color"]
    }
}

struct FloorPan: Mappable {
    var list: [Item]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        list <- map["list"]
    }
    
    struct Item: Mappable {
        
        var id: String?
        var saleStatus: TagItem?
        var title: String?
        var images: [ImageItem]?
        var pricingPerSqm: String?
        var squaremeter: String?
        var roomCount: Int = -1
        
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            id <- map["id"]
            saleStatus <- map["sale_status"]
            title <- map["title"]
            images <- map["images"]
            pricingPerSqm <- map["pricing_per_sqm"]
            squaremeter <- map["squaremeter"]
            roomCount <- map["room_count"]
        }
    }
}

struct ImageGroup: Mappable {
    
    var name: String?
    var type: Int?
    var images: [ImageItem]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        type <- map["type"]
        images <- map["images"]
    }
}

struct TimeLine: Mappable {
    var hasMore = false
    var list: [Item]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        hasMore <- map["has_more"]
        list <- map["list"]
    }
    
    struct Item: Mappable {
        var createTime: Int = 0
        var title: String?
        var desc: String?
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            createTime <- map["create_time"]
            title <- map["title"]
            desc <- map["desc"]
        }
    }
}

struct NewHouseComment: Mappable {
    var hasMore = false
    var list: [Item]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        hasMore <- map["has_more"]
        list <- map["list"]
    }
    
    struct Item: Mappable {
        var id: String?
        var createTime: Int?
        var userName: String?
        var content: String?
        var fromUrl: String?
        var source: String?
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            id <- map["id"]
            createTime <- map["create_time"]
            userName <- map["user_name"]
            content <- map["content"]
            fromUrl <- map["from_url"]
            source <- map["source"]
        }
    }
}

struct GlobalPrice: Mappable {
    var hasMore: Bool = false
    var list: [Item]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        hasMore <- map["has_more"]
        list <- map["list"]
    }
    
    struct Item: Mappable {
        var agencyName: String?
        var fromUrl: String?
        var pricingPerSqm: String?
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            agencyName <- map["agency_name"]
            fromUrl <- map["from_url"]
            pricingPerSqm <- map["pricing_per_sqm"]
        }
    }
    
}

struct FloorPlanInfoResponse: Mappable {
    var data: FloorPlanInfoData?
    var message: String?
    var status: Int = 0

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
    }
}

struct FloorPlanInfoData: Mappable {
    var id: String?
    var title: String?
    var saleStatus: Any?
    var pricing: String?
    var pricingPerSqm: String?
    var baseInfo: [ErshouHouseBaseInfo]?
    var images: [ImageItem] = []
    var recommend: [Recommend] = []
    var status: Int = 0

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        saleStatus <- map["sale_status"]
        pricing <- map["pricing"]
        pricingPerSqm <- map["pricing_per_sqm"]
        baseInfo <- map["base_info"]
        images <- map["images"]
        recommend <- map["recommend"]
        status <- map["status"]
    }

    struct Recommend: Mappable {
        var id: String?
        var saleStatus: Any?
        var title: String?
        var images: [ImageItem]?
        var pricingPerSqm: String?
        var squaremeter: String?
        var roomCount: Int?

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            id <- map["id"]
            title <- map["title"]
            saleStatus <- map["sale_status"]
            squaremeter <- map["squaremeter"]
            pricingPerSqm <- map["pricing_per_sqm"]
            roomCount <- map["roomCount"]
            images <- map["images"]
        }
    }
}
