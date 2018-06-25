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

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        text <- map["text"]
        text2 <- map["text2"]
        info <- map["info"]
        count <- map["count"]
    }
}
