//
//  NeighborhoodDetailEntities.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

struct NeighborhoodTotalSalesResponse: Mappable {
    var status: Int?
    var message: String?
    var data: TotalSalesItem?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct NeighborhoodDetailResponse: Mappable {
    var status: Int?
    var message: String?
    var data: NeighborhoodDetailData?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        data <- map["data"]
    }
}

struct NeighborhoodItemAttribute: Mappable {
    var attr: String?
    var value: String?
    var isSingle: Bool? = false
    var openUrl: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.attr <- map["attr"]
        self.value <- map["value"]
        self.isSingle <- map["is_single"]
        self.openUrl <- map["open_url"]
    }
}

struct NeighborhoodDetailInfo: Mappable {
    var id: String?
    var name: String?
    var pricingPerSqm: String?
    var monthUp: Float?
    var address: String?
    var gaodeLng: String?
    var gaodeLat: String?
    var gaodeImageUrl: String?
    var districtName: String?
    var areaName: String?
    var locationFullName: String?
    var status: Int?
    
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        pricingPerSqm <- map["pricing_per_sqm"]
        monthUp <- map["month_up"]
        address <- map["address"]
        gaodeLng <- map["gaode_lng"]
        gaodeLat <- map["gaode_lat"]
        gaodeImageUrl <- map["gaode_image_url"]
        districtName <- map["district_name"]
        areaName <- map["area_name"]
        locationFullName <- map["location_full_name"]
        status <- map["status"]
    }
}

struct TotalSalesItem: Mappable {
    var hasMore: Bool?
    var list: [TotalSalesInnerItem]?
    var total: Int = 0
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.hasMore <- map["has_more"]
        self.list <- map["list"]
        total <- map["total"]
    }
}

struct TotalSalesInnerItem: Mappable {
    var floorplan: String?
    var squaremeter: String?
    var dealDate: String?
    var dataSource: String?
    var agencyName: String?
    var pricing: String?
    var pricingPerSqm: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.floorplan <- map["floorplan"]
        self.squaremeter <- map["squaremeter"]
        self.dealDate <- map["deal_date"]
        self.dataSource <- map["data_source"]
        self.agencyName <- map["agency_name"]
        self.pricing <- map["pricing"]
        self.pricingPerSqm <- map["pricing_per_sqm"]
    }
}

struct NeighborhoodDetailData: Mappable {
    
    var id: String?
    var name: String?
    var neighborhoodImage: [ImageItem]?
    var coreInfo: [NeighborhoodItemAttribute]?
    var statsInfo: [NeighborhoodItemAttribute]?
    var baseInfo: [NeighborhoodItemAttribute]?
    var neighborhoodBaseInfoFold: Bool = true
    var neighborhoodInfo: NeighborhoodDetailInfo?
    var totalSalesCount: Int?
    var abtestVersions: String?
    var priceTrend: [PriceTrend]?
    var totalSales: TotalSalesItem?
    var tags: [TagItem]?
    var neighbordhoodStatus: NeighborhoodUsertatus?
    var shareInfo: ShareInfo?
    var logPB: Any?
    var evaluationInfo: NeighborhoodEvaluationinfo?

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        priceTrend <- map["price_trend"]
        baseInfo <- map["base_info"]
        statsInfo <- map["stats_info"]
        neighborhoodInfo <- map["neighborhood_info"]
        neighborhoodImage <- map["neighborhood_image"]
        totalSalesCount <- map["total_sales_count"]
        name <- map["name"]
        totalSales <- map["total_sales"]
        coreInfo <- map["core_info"]
        abtestVersions <- map["abtest_versions"]
        neighbordhoodStatus <- map["neighbordhood_status"]
        shareInfo <- map["share_info"]
        logPB <- map["log_pb"]
        evaluationInfo <- map["evaluation_info"]
    }
}

struct NeighborhoodEvaluationinfo: Mappable  {
    init?(map: Map) {
        
    }
    
    var totalScore: String?
    var detailUrl: String?
    var content: String?
    var subScores: [EvaluationIteminfo]?
    
    mutating func mapping(map: Map) {
        totalScore <- map["total_score"]
        detailUrl <- map["detail_url"]
        content <- map["content"]
        subScores <- map["sub_scores"]

    }
}

struct EvaluationIteminfo: Mappable  {
    init?(map: Map) {
        
    }
    
    var scoreName: String?
    var scoreValue: Int?
    var scoreLevel: Int?
    var content: String?
    var fhSearchId: String?

    mutating func mapping(map: Map) {
        scoreName <- map["score_name"]
        scoreValue <- map["score_value"]
        scoreLevel <- map["score_level"]
        content <- map["content"]
    }
}

struct NeighborhoodUsertatus: Mappable {
    var neighborhoodSubStatus: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        neighborhoodSubStatus <- map["neighborhood_sub_status"]
    }
}

