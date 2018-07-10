//
//  SearchNeighborhoodEntityApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper

func requestNeighborhoodSearch(cityId: String = "133", offset: Int = 0, query: String = "") -> Observable<SearchNeighborhoodResponse?> {
    var url = "\(EnvContext.networkConfig.host)/api/search_neighborhood?"
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
        .map({ (payload) -> SearchNeighborhoodResponse? in
            if let payload = payload {
                let response = SearchNeighborhoodResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestNeighborhoodSearch(
    cityId: String = "133",
    query: String = "") -> () -> Observable<SearchNeighborhoodResponse?> {
    var offset: Int = 0
    return {
        return requestNeighborhoodSearch(
            cityId: cityId,
            offset: offset,
            query: query)
            .do(onNext: { (response) in
                if let count = response?.data?.items?.count {
                    offset = offset + count
                }
            })
    }
}
