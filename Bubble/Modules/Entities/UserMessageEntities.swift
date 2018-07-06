//
//  UserMessageEntities.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

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

    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        timestamp <- map["timestamp"]
        content <- map["content"]
        id <- map["id"]
        dateStr <- map["date_str"]
        unread <- map["unread"]

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

    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        items <- map["items"]
        hasMore <- map["has_more"]
        minCursor <- map["min_cursor"]
    }
}


struct UserListMsgItem: Mappable {
    
    var title: String?
    var id: String?
    var timestamp: String?

    var dateStr: String?
    var items:[UserListMsgInnerItem]?

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        dateStr <- map["date_str"]
        items <- map["items"]
        id <- map["id"]
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
    }
}
