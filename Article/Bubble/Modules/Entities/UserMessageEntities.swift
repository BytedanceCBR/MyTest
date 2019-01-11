//
//  UserMessageEntities.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct CategroyRefreshTipResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data:  categroyBadgeData?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct UserUnreadMessageResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data:  UserUnreadMsg?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct categroyBadgeData: Mappable {
    
    var count: Int?
    var tip: String?
    var showtype: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        count <- map["count"]
        tip <- map["tip"]
        showtype <- map["show_type"]
    }
}

struct UserUnreadMsg: Mappable {
    
    var unread: [UserUnreadInnerMsg]?

    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        unread <- map["unread"]

    }
}

struct UserUnreadInnerMsg: Mappable {
    
    var timestamp: Int?
    var content: String?
    var id: String?
    var dateStr: String?
    var unread: Int?
    var icon: String?
    var title: String?
    var openUrl: String?
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        timestamp <- map["timestamp"]
        content <- map["content"]
        id <- map["id"]
        dateStr <- map["date_str"]
        unread <- map["unread"]
        icon <- map["icon"]
        title <- map["title"]
        openUrl <- map["open_url"]
    }
}

struct UserListMessageResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data:  UserListMsgObj?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct UserListMsgObj: Mappable {
    
    var hasMore: Bool?
    var items:  [UserListMsgItem]?
    var minCursor: String?
    var searchId: String?

    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        items <- map["items"]
        hasMore <- map["has_more"]
        minCursor <- map["min_cursor"]
        searchId <- map["search_id"]
    }
}


struct UserListMsgItem: Mappable {
    
    var title: String?
    var id: String?
    var timestamp: String?

    var dateStr: String?
    var items:[UserListMsgInnerItem]?
    var moreLabel: String?
    var moreDetal: String?

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        dateStr <- map["date_str"]
        items <- map["items"]
        id <- map["id"]
        moreLabel <- map["more_label"]
        moreDetal <- map["more_detail"]
        timestamp <- map["timestamp"]

    }
}


struct UserListMsgInnerItem: Mappable {
    var id: String?
    var title: String?
    var description: String?
    var salesInfo: String?
    var price: String?
    var pricePerSqm: String?
    var openUrl: String?
    var tags: [TagItem]?
    var images: [ImageItem]?
    var houseType: Int?
    var logPb: Any?
    var status: Int = 0
    var houseImageTag: HouseImageTag?
    var searchId: String?
    var imprId: String?


    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
        salesInfo <- map["sales_info"]
        price <- map["price"]
        pricePerSqm <- map["price_per_sqm"]
        tags <- map["tags"]
        openUrl <- map["open_url"]
        images <- map["images"]
        houseType <- map["house_type"]
        status <- map["status"]
        logPb <- map["log_pb"]
        searchId <- map["search_id"]
        imprId <- map["impr_id"]

        houseImageTag <- map["house_image_tag"]
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
}

struct SystemNotificationResponse: Mappable {

    var data: Data?
    var message: String?
    var status: Int?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        data <- map["data"]
        message <- map["message"]
        status <- map["status"]
    }

    struct Data: Mappable {
        var items: [Item]?
        var hasMore: Bool?
        var minCoursor: String?
        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            items <- map["items"]
            hasMore <- map["has_more"]
            minCoursor <- map["min_cursor"]
        }
    }

    struct Item: Mappable {
        var id: String?
        var title: String?
        var images: ImageItem?
        var openUrl: String?
        var content: String?
        var timestamp: Int64?
        var dateStr: String?
        var bottonName: String?

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            id <- map["id"]
            title <- map["title"]
            images <- map["images"]
            openUrl <- map["open_url"]
            content <- map["content"]
            timestamp <- map["timestamp"]
            dateStr <- map["date_str"]
            bottonName <- map["button_name"]
        }
    }

}
