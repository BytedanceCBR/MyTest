//
//  HomePageRollScreenEntitys.swift
//  Article
//
//  Created by 张元科 on 2018/11/20.
//

import Foundation
import ObjectMapper

struct HomePageRollScreenResponse: Mappable {
    
    var status: Int?
    var message: String?
    var data: HomePageRollScreenList?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct HomePageRollScreenList: Mappable {
    var data : [HomePageRollScreen]?
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        data <- map["data"]
    }
}

struct HomePageRollScreen: Mappable {
    var text : String?
    var guessSearchId : String?
    var houseType : Int = 0
    var openUrl:String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        text <- map["text"]
        guessSearchId <- map["guess_search_id"]
        houseType <- map["house_type"]
        openUrl <- map["open_url"]
    }
}
