//
//  HouseDetailEntities.swift
//  Bubble
//
//  Created by linlin on 2018/6/28.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

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
        backgroundColor <- map["backgroundColor"]
        textColor <- map["textColor"]
    }
}

struct FloorPan: Mappable {
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
        var saleStatus: TagItem?
        var title: String?
        var images: [ImageItem]?
        var pricingPerSqm: String?
        var squaremeter: String?


        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            id <- map["id"]
            saleStatus <- map["sale_status"]
            title <- map["title"]
            images <- map["images"]
            pricingPerSqm <- map["pricing_per_sqm"]
            squaremeter <- map["squaremeter"]
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
