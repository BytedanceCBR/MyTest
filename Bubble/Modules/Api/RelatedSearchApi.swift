//
//  RelatedSearchApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestRelatedHouseSearch(houseId: String = "", offset: String = "0", query: String = "") -> Observable<RelatedHouseResponse?> {
    var url = "\(EnvContext.networkConfig.host)/api/related_house?house_id=\(houseId)&offset=\(offset)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: nil,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> RelatedHouseResponse? in
            if let payload = payload {
                let response = RelatedHouseResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}


func requestRelatedCourtSearch(courtId: String = "", offset: String = "0", query: String = "") -> Observable<RelatedCourtResponse?> {
    var url = "\(EnvContext.networkConfig.host)/api/related_court?court_id=\(courtId)&offset=\(offset)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: nil,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> RelatedCourtResponse? in
            if let payload = payload {
                let response = RelatedCourtResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func requestRelatedNeighborhoodSearch(
        neighborhoodId: String = "",
        offset: Int64  = 0,
        query: String = "") -> Observable<RelatedNeighborhoodResponse?> {
    var url = "\(EnvContext.networkConfig.host)/api/related_neighborhood?neighborhood_id=\(neighborhoodId)&offset=\(offset)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: nil,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> RelatedNeighborhoodResponse? in
            if let payload = payload {
                let response = RelatedNeighborhoodResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestRelatedNeighborhoodSearch(neighborhoodId: String = "",
                                          query: String = "") -> () -> Observable<RelatedNeighborhoodResponse?> {
    var offset: Int64 = 0
    return {
        return requestRelatedNeighborhoodSearch(
            neighborhoodId: neighborhoodId,
            offset: offset,
            query: query)
            .do(onNext: { (response) in
                if let count = response?.data?.items?.count {
                    offset = offset + Int64(count)
                }
            })
    }
}
