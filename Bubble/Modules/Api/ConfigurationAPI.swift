//
//  ConfigurationAPI.swift
//  Bubble
//
//  Created by linlin on 2018/6/22.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestSearchConfig(cityId: String = "133") -> Observable<SearchConfigResponse?> {
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: "\(EnvContext.networkConfig.host)/api/search_config",
                    params: ["city_id": cityId],
                    method: "GET",
                    needCommonParams: true)
            .map({ (data) -> NSString? in
                NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            })
            .map({ (payload) -> SearchConfigResponse? in
                if let payload = payload {
                    let response = SearchConfigResponse(JSONString: payload as String)
                    return response
                } else {
                    return nil
                }
            })
}

func requestGeneralConfig(cityId: String? = nil, gaodeCityId: String? = nil, lat: Double? = nil, lng: Double? = nil) -> Observable<GeneralConfigResponse?> {
    var params: [String: Any] = [:]
    if let cityId = cityId {
        params["city_id"] = cityId
    }

    if let lat = lat, let lng = lng {
        params["gaode_lng"] = lng
        params["gaode_lat"] = lat
    }

    if let gaodeCityId = gaodeCityId {
        params["gaode_city_id"] = gaodeCityId
    }
    return requestGeneralConfig(params: params)
}

func requestGeneralConfig(params: [String: Any]) -> Observable<GeneralConfigResponse?> {
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: "\(EnvContext.networkConfig.host)/api/config",
                    params: params,
                    method: "GET",
                    needCommonParams: true)
            .map({ (data) -> NSString? in
                NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            })
            .map({ (payload) -> GeneralConfigResponse? in
                if let payload = payload {
                    let response = GeneralConfigResponse(JSONString: payload as String)
                    return response
                } else {
                    return nil
                }
            })
}

