//
//  SuggestionEntity.swift
//  Bubble
//
//  Created by linlin on 2018/6/25.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct SuggestionResponse: Mappable {

    var data: [SuggestionItem] = []

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        data <- map["data"]
    }

}

struct SuggestionItem: Mappable {

    var id: String?
    var text: String?
    var text2: String?
    var info: Any?
    var count: Int = 0
    var logPb: [String: Any]?
    var score: String?
    var houseType: Int = 0
    var tips: String?
    var tips2: String?
    var logPB: Any?
    var openUrl: String?
    var placeHolder: String?
    var userOriginEnter: String?

    init?(map: Map) {

    }

    init() {
        
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        text <- map["text"]
        text2 <- map["text2"]
        info <- map["info"]
        count <- map["count"]
        logPb <- map["log_pb"]
        score <- map["score"]
        houseType <- map["house_type"]
        tips2 <- map["tips2"]
        tips <- map["tips"]
        logPB <- map["log_pb"]
        openUrl <- map["open_url"]
        placeHolder <- map["place_holder"]
    }

    func idFromInfo() -> String? {
        if let info = self.info as? [String: Any],
            let theId = info["wordid"] as? String {
            return theId
        } else {
            return nil
        }
    }
}
