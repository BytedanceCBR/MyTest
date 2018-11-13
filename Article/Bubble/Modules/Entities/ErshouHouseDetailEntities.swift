//
//  ErshouHouseDetailEntities.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct ShareInfo: Mappable {

    var shareUrl: String?
    var title: String = ""
    var isVideo: Int = 0
    var coverImage: String?
    var desc: String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        shareUrl <- map["share_url"]
        title <- map["title"]
        isVideo <- map["is_video"]
        coverImage <- map["cover_image"]
        desc <- map["description"]
    }
}

struct ErshouHouseDetailResponse: Mappable {
    var status: Int?
    var message: String?
    var data: ErshouHouseData?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct Disclaimer: Mappable {
    var text: String?
    var richText: [RichTextItem] = []

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        text <- map["text"]
        richText <- map["rich_text"]
    }

    struct RichTextItem: Mappable {
        var highlightRange: [Int]?
        var linkUrl: String?

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            highlightRange <- map["highlight_range"]
            linkUrl <- map["link_url"]
        }
    }
}

struct ErshouHouseData: Mappable {
    
    var id: String?
    var title: String?
    var uploadAt: Int = 0
    var houseImage: [ImageItem]?
    var coreInfo: [ErshouHouseCoreInfo]?
    var baseInfo: [ErshouHouseBaseInfo]?
    var outLineOverreview:ErshouOutlineOverreview?
    var neighborhoodInfo: NeighborhoodInfo?

    var priceTrend: [PriceTrend]?
    var housePriceRange: HousePriceRange?
    var housePriceRank: HousePriceRank?
    var tags: [TagItem] = []
    var userStatus: UserStatus?
    var disclaimer: Disclaimer?
    var logPB: [String: Any]?
    var shareInfo: ShareInfo?
    var pricingPerSqmValue: Int = 1
    
    var contact: FHHouseDetailContact?
    var status: Int? // 0 正常显示，1 二手房源正常下架（如已卖出等），-1 二手房非正常下架（如法律风险、假房源等）
 

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        uploadAt <- map["upload_at"]
        houseImage <- map["house_image"]
        coreInfo <- map["core_info"]
        baseInfo <- map["base_info"]
        neighborhoodInfo <- map["neighborhood_info"]
        contact <- map["contact"]
        priceTrend <- map["price_trend"]
        housePriceRange <- map["house_price_range"]
        housePriceRank <- map["house_pricing_rank"]
        tags <- map["tags"]
        userStatus <- map["user_status"]
        disclaimer <- map["disclaimer"]
        shareInfo <- map["share_info"]
        pricingPerSqmValue <- map["pricing_per_sqm_v"]
        logPB <- map["log_pb"]
        status <- map["status"]
        outLineOverreview <- map["house_overreview"]

    }
}

struct ErshouHouseBaseInfo: Mappable {
    var attr: String?
    var value: String?
    var isSingle: Bool?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        attr <- map["attr"]
        value <- map["value"]
        isSingle <- map["is_single"]
    }
}

struct ErshouOutlineInfo: Mappable {
    var title: String?
    var content: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        content <- map["content"]
    }
}

struct ErshouOutlineOverreview: Mappable {
    
    var list: [ErshouOutlineInfo]?
    var reportUrl: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        list <- map["list"]
        reportUrl <- map["report_url"]
    }
}

struct ErshouHouseCoreInfo: Mappable {
    var attr: String?
    var value: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        attr <- map["attr"]
        value <- map["value"]
    }
}

struct UserStatus: Mappable {
    var houseSubStatus: Int = 0
    var courtSubStatus: Int = 0
    var pricingSubStauts: Int = 0
    var courtOpenSubStatus: Int = 0
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        houseSubStatus <- map["house_sub_status"]
        pricingSubStauts <- map["pricing_sub_status"]
        courtOpenSubStatus <- map["court_open_sub_status"]
        courtSubStatus <- map["court_sub_status"]
    }
}

struct HousePriceRange: Mappable {
    var cur_price: Int?
    var price_min: Int?
    var price_max: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        cur_price <- map["cur_price"]
        price_min <- map["price_min"]
        price_max <- map["price_max"]

    }
}

struct HousePriceRank: Mappable {
    var position: Int? // 排名位置
    var total: Int? // 排名总数 类型 int
    var analyseDetail: String? // 排名分析，类型 string
    var buySuggestion: HousePriceRankSuggestion? // 购买建议，类型 dict

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        position <- map["position"]
        total <- map["total"]
        analyseDetail <- map["analyse_detail"]
        buySuggestion <- map["buy_suggestion"]

    }
}

struct HousePriceRankSuggestion: Mappable {
    var type: Int? // 类型 int(1 建议,2普通,3不建议)
    var content: String? // 建议内容，类型 string
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        type <- map["type"]
        content <- map["content"]
    }
}


struct PriceTrend: Mappable {
    var name: String?
    var values: [TrendItem] = []
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        values <- map["values"]
    }
}

struct TrendItem: Mappable {
    var price: String? // 单位是分钱，不是元
    var timeStr: String?
    var timestamp: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        price <- map["price"]
        timeStr <- map["time_str"]
        timestamp <- map["timestamp"]
    }
}

struct FHHouseDetailContact: Mappable {
    var phone: String?
    var style: Int? // 展现方式，类型 int 1：直接拨打 2：弹出信息登记表单
    var realtorName: String? // 经纪人姓名, 类型 string
    var avatarUrl: String? // 头像url, 类型 string
    var realtorId: String? // 经纪人id, 类型 string
    var agencyName: String? // 经纪人公司名称, 类型 string
    var showRealtorinfo: Int? // 是否显示经纪人信息(经纪人名称, 头像, 经纪人公司), 类型 int 1: 显示; int 0: 不显示

    var noticeDesc: String? // 新房详情电话描述

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        phone <- map["phone"]
        style <- map["style"]
        realtorName <- map["realtor_name"]
        avatarUrl <- map["avatar_url"]
        realtorId <- map["realtor_id"]
        agencyName <- map["agency_name"]
        showRealtorinfo <- map["show_realtorinfo"]

        noticeDesc <- map["notice_desc"]

    }
    
    init() {
        
    }
}


