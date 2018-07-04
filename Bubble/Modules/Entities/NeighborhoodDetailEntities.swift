//
//  NeighborhoodDetailEntities.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import ObjectMapper

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
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.attr <- map["attr"]
        self.value <- map["value"]
        self.value <- map["is_single"]
    }
}

struct NeighborhoodDetailInfo: Mappable {
    var id: String?
    var name: String?
    var pricingPerSqm: String?
    var address: String?
    var monthUp: Float?
    var gaodeLng: String?
    var gaodeLat: String?
    var gaodeImageUrl: String?
    var images: [ImageItem]?
    var displayTitle: String?
    var displaySubtitle: String?
    var displayBuiltYear: String?
    var displayDescription: String?
    var houseType: Int?
    var displayPricePerSqm: String?
    var displayPrice: String?
    
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        address <- map["address"]
        monthUp <- map["month_up"]
        pricingPerSqm <- map["pricing_per_sqm"]
        gaodeLng <- map["gaode_lng"]
        gaodeLat <- map["gaode_lat"]
        gaodeImageUrl <- map["gaode_image_url"]
        images <- map["images"]
        displayTitle <- map["display_title"]
        displaySubtitle <- map["display_subtitle"]
        displayDescription <- map["display_description"]
        displayPrice <- map["display_price"]
        displayBuiltYear <- map["display_built_year"]
        houseType <- map["house_type"]
        displayPricePerSqm <- map["display_price_per_sqm"]
    }
}

struct TotalSalesItem: Mappable {
    var hasMore: Bool?
    var list: [TotalSalesInnerItem]?
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.hasMore <- map["has_more"]
        self.list <- map["list"]
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
    var neighborhoodInfo: NeighborhoodDetailInfo?
    var totalSalesCount: Int?
    var abtestVersions: String?
    var priceTrend: PriceTrend?
    var totalSales: TotalSalesItem?
    var tags: [TagItem]?
    var neighbordhoodStatus: NeighborhoodUsertatus?
    var images: [ImageItem]?

    
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

