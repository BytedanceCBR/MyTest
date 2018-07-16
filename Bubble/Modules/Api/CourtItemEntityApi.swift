//
//  CourtItemEntityApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestCourtSearch(
        cityId: String = "133",
        offset: Int64 = 0,
        query: String = "") -> Observable<CourtSearchResponse?> {

    var url = "\(EnvContext.networkConfig.host)/api/search_court?city_id=\(cityId)"
    if !query.isEmpty {
        url = "\(url)\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["offset": offset],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> CourtSearchResponse? in
            if let payload = payload {
                let response = CourtSearchResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}


func pageRequestCourtSearch(cityId: String = "133", query: String = "") -> () -> Observable<CourtSearchResponse?> {
    var offset: Int64 = 0
    return {
        return requestCourtSearch(
            cityId: cityId,
            offset: offset,
            query: query)
            .do(onNext: { (response) in
                if let count = response?.data?.items?.count {
                    offset = offset + Int64(count)
                }
            })
    }
}


func requestCourtInfo(courtId: String, type: Int) -> Observable<Void> {
    return .empty()
}
