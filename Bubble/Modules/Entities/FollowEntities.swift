//
//  FollowEntities.swift
//  Bubble
//
//  Created by linlin on 2018/7/18.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct UserFollowResponse: Mappable {

    var status: Int?
    var message: String?
    var data:  FollowStatus?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }

}

struct FollowStatus: Mappable {
    var followStatus: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        followStatus <- map["follow_status"]
    }

}

struct UserFollowListResponse: Mappable {
    var status: Int?
    var message: String?
    var data: UserFollowData?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct UserFollowData: Mappable {

    var items: [Item] = []
    var hasMore: Bool?
    var totalCount: Int64 = -1

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        items <- map["follow_items"]
        hasMore <- map["has_more"]
        totalCount <- map["total_count"]
    }

    struct Item: Mappable {

        var followId: String?
        var title: String?
        var description: String?
        var saleInfo: String?
        var price: String?
        var pricePerSqm: String?
        var tags: [Tag]?
        var images: [ImageItem] = []
        var houseType: Int?

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            followId <- map["follow_id"]
            title <- map["title"]
            description <- map["description"]
            saleInfo <- map["sales_info"]
            price <- map["price"]
            pricePerSqm <- map["price_per_sqm"]
            tags <- map["tags"]
            images <- map["images"]
            houseType <- map["house_type"]
        }
    }

    struct Tag: Mappable {
        var id: Int = 0
        var content: String = ""
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
}
