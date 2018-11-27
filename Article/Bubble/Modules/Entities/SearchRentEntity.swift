//
//  SearchRentEntity.swift
//  Article
//
//  Created by 谷春晖 on 2018/11/26.
//

import Foundation
import ObjectMapper


struct SearchRentResponse: Mappable {
    
    var data: RentItemEntity?
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

struct RentItemEntity: Mappable {
    var items: [RentInnerItemEntity]?
    var hasMore: Bool = false
    var total: Int = 0
    var refreshTip: String?
    var searchId: String?
    var houseListOpenUrl: String?
    var mapFindHouseOpenUrl : String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.items <- map["items"]
        hasMore <- map["has_more"]
        total <- map["total"]
        refreshTip <- map["refresh_tip"]
        searchId <- map["search_id"]
        houseListOpenUrl <- map["house_list_open_url"]
        mapFindHouseOpenUrl <- map["map_find_house_open_url"]
    }
}

struct RentTagEntity : Mappable {
    
    var text : String = ""
    var backgroundColor : String?
    var id : String?
    var textColor : String?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        text <- map["text"]
        backgroundColor <- map["background_color"]
        id <- map["id"]
        textColor <- map["text_color"]
    }
    
}

struct RentInnerItemEntity: Mappable {
    
    //properties
    var id: String?
    var houseType: Int?
    var status : String?
    var subtitle : String?
    var title : String?
    var url : String?
    var houseImage : [ImageItem]?
    var tags : [RentTagEntity]?
    var imprId : String?
    var pricing : String?
    var houseImageTag : RentTagEntity?
    var logPB: [String: Any]?    
    var fhSearchId : String?
    
    init?(map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        id <- map["id"]
        houseType <- map["house_type"]
        status <- map["status"]
        subtitle <- map["subtitle"]
        title <- map["title"]
        url <- map["url"]
        houseImage <- map["house_image"]
        tags <- map["tags"]
        imprId <- map["impr_id"]
        pricing <- map["pricing"]
        houseImageTag <- map["house_image_tag"]
        logPB <- map["log_pb"]
        fhSearchId <- map["fhSearchId"]
    }
    
}


struct SameRentHouseResponse: Mappable {
    var message: String?
    var status: Int = 0
    var data: RentItemEntity?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        message <- map["message"]
        data <- map["data"]
        status <- map["status"]
    }
    
//    struct Data: Mappable {
//        var items: [HouseItemInnerEntity] = []
//        var hasMore: Bool = false
//        var total: Int = 0
//        var refreshTip: String?
//        var searchId: String?
//        init?(map: Map) {
//
//        }
//
//        mutating func mapping(map: Map) {
//            items <- map["items"]
//            hasMore <- map["has_more"]
//            total <- map["total"]
//            refreshTip <- map["refresh_tip"]
//            searchId <- map["search_id"]
//        }
//    }
    
}
