//
//  UserMessageEntities.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct UserInfoResponse: Mappable {

    var status: Int?
    var message: String?
    var data: UserInfo?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}


struct UserInfo: Mappable {
    var area: String?
    var avatar_url: String?
    var bg_img_url: String?
    var birthday: String?
    var can_be_found_by_phone: Int?
    var connects: [UserConnections]?
    var description: String?
    var followers_count: Int?
    var followings_count: Int?
    var gender: Int?
    var industry: String?
    var is_blocked: Int?
    var is_blocking: Int?
    var is_recommend_allowed: Int?
    var is_toutiao: Int?
    var media_id: Int?
    var mobile: String?
    var name: String?
    var recommend_hint_message: String?
    var screen_name: String?
    var session_key: String?
    var share_to_repost: Int?
    var user_auth_info: String?
    var user_decoration: String?
    var user_id: Int?
    var user_privacy_extend: Int?
    var user_verified: Int?
    var verified_agency: String?
    var verified_content: String?
    var visit_count_recent: Int?

    init?(map: Map) {

    }
    
    init() {
        
    }

    mutating func mapping(map: Map) {
        area <- map["area"]
        avatar_url <- map["avatar_url"]
        bg_img_url <- map["bg_img_url"]
        birthday <- map["birthday"]
        can_be_found_by_phone <- map["can_be_found_by_phone"]
        connects <- map["connects"]
        description <- map["description"]
        followers_count <- map["followers_count"]
        followings_count <- map["followings_count"]
        gender <- map["gender"]
        industry <- map["industry"]
        is_blocked <- map["is_blocked"]
        is_blocking <- map["is_blocking"]
        is_recommend_allowed <- map["is_recommend_allowed"]
        is_toutiao <- map["is_toutiao"]
        media_id <- map["media_id"]
        mobile <- map["mobile"]
        name <- map["name"]
        recommend_hint_message <- map["recommend_hint_message"]
        screen_name <- map["screen_name"]
        session_key <- map["session_key"]
        share_to_repost <- map["share_to_repost"]
        user_auth_info <- map["user_auth_info"]
        user_decoration <- map["user_decoration"]
        user_id <- map["user_id"]
        user_privacy_extend <- map["user_privacy_extend"]
        user_verified <- map["user_verified"]
        verified_agency <- map["verified_agency"]
        verified_content <- map["verified_content"]
        visit_count_recent <- map["visit_count_recent"]
    }
}

struct UserConnections: Mappable {
    var platform: String?
    var profile_image_url: String?
    var expired_time: Int?
    var expires_in: Int?
    var platform_screen_name: String?
    var user_id: Int?
    var platform_uid: String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        expired_time <- map["expired_time"]
        expires_in <- map["expires_in"]
        platform <- map["platform"]
        platform_screen_name <- map["platform_screen_name"]
        platform_uid <- map["platform_uid"]
        profile_image_url <- map["profile_image_url"]
        user_id <- map["user_id"]
    }
}
