//
//  NeighborhoodDetailEntitiesApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestNeighborhoodDetail(
    neighborhoodId: String = "",
    query: String = "",
    logPB: [String: Any]?) -> Observable<NeighborhoodDetailResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/neighborhood/info?neighborhood_id=\(neighborhoodId)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    var params = [String: Any]()
    if let logPB = logPB {
        params.merge(logPB, uniquingKeysWith: { $1 })
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: params,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> NeighborhoodDetailResponse? in
            if let payload = payload {
                let response = NeighborhoodDetailResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

//https://m.quduzixun.com/f100/api/neighborhood/sale?neighborhood_id=6569028179917291780&page=0&price=[10000,40000000]&count=10&room_num=[3,3]&squaremeter=[90,120]
func requestNeighborhoodTotalSales(neighborhoodId: String = "", query: String = "", offset: Int = 0, count: Int = 5) -> Observable<NeighborhoodTotalSalesResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/neighborhood/sale?neighborhood_id=\(neighborhoodId)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["page": offset,
                     "count": count],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> NeighborhoodTotalSalesResponse? in
            if let payload = payload {
                let response = NeighborhoodTotalSalesResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestNeighborhoodTotalSales(neighborhoodId: String = "", query: String = "", count: Int = 5) -> () -> Observable<NeighborhoodTotalSalesResponse?> {
    var offset: Int = 0
    return {
        return requestNeighborhoodTotalSales(
            neighborhoodId: neighborhoodId,
            query: query,
            offset: offset,
            count: count)
            .do(onNext: { (response) in
                if response?.data?.list?.count != nil {
                    offset = offset + 1
                }
            })
    }
}
