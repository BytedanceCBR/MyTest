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

func requestNeighborhoodSearch(cityId: String = "133", query: String = "") -> Observable<SearchNeighborhoodResponse?> {
    var url = "http://m.quduzixun.com/f100/api/search_neighborhood?city_id=\(cityId)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: nil,
            method: "GET",
            needCommonParams: false)
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
