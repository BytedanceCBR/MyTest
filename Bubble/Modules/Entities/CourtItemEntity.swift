//
//  CourtItemEntity.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper


struct CourtSearchResponse: Mappable {
    
    var data: CourtItemEntity?
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

struct SaleStatusItem: Mappable {
    var id: Int?
    var content: String?
    var backgroundColor: String?
    var textColor: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.backgroundColor <- map["background_color"]
        self.content <- map["content"]
        self.textColor <- map["text_color"]

    }
}
struct ProperyTypeItem: Mappable {
    var id: Int?
    var content: String?
    var backgroundColor: String?
    var textColor: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.backgroundColor <- map["background_color"]
        self.content <- map["content"]
        self.textColor <- map["text_color"]
        
    }
}

struct CourtCoreItem: Mappable {
    var name: String?
    var aliasName: String?
    var constructionOpendate: String?
    var courtAddress: String?
    var saleStatus: SaleStatusItem?
    var properyType: ProperyTypeItem?
    var pricingPerSqm: String?
    var gaodeLng: String?
    var gaodeLat: String?
    var gaodeImageUrl: String?

    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.name <- map["name"]
        self.aliasName <- map["alias_name"]
        self.constructionOpendate <- map["construction_opendate"]
        self.courtAddress <- map["court_address"]
        self.saleStatus <- map["sale_status"]
        self.properyType <- map["propery_type"]
        self.pricingPerSqm <- map["pricing_per_sqm"]
        self.gaodeLng <- map["gaode_lng"]
        self.gaodeLat <- map["gaode_lat"]
        self.gaodeImageUrl <- map["gaode_image_url"]
  
    }
}

struct TimeLineListItem: Mappable {
    var created_time: Int?
    var desc: String?
    var title: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.created_time <- map["created_time"]
        self.desc <- map["desc"]
        self.title <- map["title"]
    }
}

struct CourtTimeLineItem: Mappable {
    var hasMore: Bool?
    var list: [TimeLineListItem]?
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.hasMore <- map["has_more"]
        self.list <- map["list"]
    }
}

struct CommentListItem: Mappable {
    var id: String?
    var created_time: Int?
    var userName: String?
    var content: String?
    var fromUrl: String?
    var source: String?

    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.userName <- map["user_name"]
        self.content <- map["content"]
        self.fromUrl <- map["from_url"]
        self.source <- map["source"]
    }
}

struct CourtCommentItem: Mappable {
    var hasMore: Bool?
    var list: [CommentListItem]?
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.hasMore <- map["has_more"]
        self.list <- map["list"]
    }
}

struct GlobalPriceListInnerItem: Mappable {
    
    var agencyName: String?
    var pricingPerSqm: String?
    var fromUrl: String?
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.agencyName <- map["agency_name"]
        self.pricingPerSqm <- map["pricing_per_sqm"]
        self.fromUrl <- map["from_url"]
    }
}

struct CourtGlobalPriceItem: Mappable {
    var hasMore: Bool?
    var list: [GlobalPriceListInnerItem]?
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.hasMore <- map["has_more"]
        self.list <- map["list"]
    }
}

struct FloorpanListInnerItem: Mappable {
    
    var id: String?
    var saleStatus: SaleStatusItem?
    var pricingPerSqm: String?
    var title: String?
    var images: [ImageItem]?
    var squaremeter: String?


    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.saleStatus <- map["sale_status"]
        self.title <- map["title"]
        self.images <- map["images"]
        self.pricingPerSqm <- map["pricing_per_sqm"]
        self.squaremeter <- map["squaremeter"]

    }
}


struct FloorpanListItem: Mappable {
    var hasMore: Bool?
    var list: [FloorpanListInnerItem]?
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.hasMore <- map["has_more"]
        self.list <- map["list"]
    }
}

struct CourtUserSatusItem: Mappable {
    var CourtOpenSubscribeStatus: Int?
    var courtSubStatus: Int?
    var pricingSubStauts: Int?
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        
        self.courtSubStatus <- map["court_sub_status"]
        self.pricingSubStauts <- map["pricing_sub_stauts"]
        self.CourtOpenSubscribeStatus <- map["CourtOpenSubscribeStatus"]
    }
}
struct CourtItemEntity: Mappable {
    var items: [CourtItemInnerEntity]?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.items <- map["items"]
    }
}

struct CourtItemInnerEntity: Mappable {
    
    //properties
    var id: String?
    var title: String?
    var uploadAt: Int?
    var displayTitle: String?
    var displayPricePerSqm: String?
    var displayDescription: String?
    var url: String?
    var coreInfo: [CourtCoreItem]?
    var timeLine: CourtTimeLineItem?
    var comment: CourtCommentItem?
    var courtImage: [ImageItem]?
    var globalPrice: CourtGlobalPriceItem?
    var tags: [TagItem]?
    var floorpanList: FloorpanListItem?
    var contact: [String: String]?
    var userStatus: CourtUserSatusItem?
    
    init?(map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        uploadAt <- map["upload_at"]
        displayTitle <- map["display_title"]
        displayPricePerSqm <- map["display_price_per_sqm"]
        displayDescription <- map["display_description"]
        coreInfo <- map["core_info"]
        tags <- map["tags"]
        courtImage <- map["images"]
        timeLine <- map["timeline"]
        comment <- map["comment"]
        globalPrice <- map["global_pricing"]
        floorpanList <- map["floorpan_list"]
        contact <- map["contact"]
        userStatus <- map["user_status"]
    }
    
}

