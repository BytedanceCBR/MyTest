//
//  NeighborhoodDetailEntitiesApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper

func requestNeighborhoodDetail(neighborhoodId: String = "", query: String = "") -> Observable<NeighborhoodDetailResponse?> {
    var url = "http://m.quduzixun.com/f100/api/neighborhood/info?neighborhood_id=\(neighborhoodId)"
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
        .map({ (payload) -> NeighborhoodDetailResponse? in
            if let payload = payload {
                let response = NeighborhoodDetailResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}
