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

func requestSearchConfig(gaodeCityName: String? = nil) -> Observable<SearchConfigResponse?> {
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: "\(EnvContext.networkConfig.host)/f100/api/search_config",
                    params: nil,
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

func requestGeneralConfig(
    cityName: String? = nil,
    cityId: String? = nil,
    gaodeCityId: String? = nil,
    lat: Double? = nil,
    lng: Double? = nil,
    needCommonParams: Bool = true,
    params: [String: Any] = [:]) -> Observable<GeneralConfigResponse?> {
    var params: [String: Any] = params
    if let theCityName = cityName {
        params["city_name"] = theCityName
    }else
    {
        params["city_name"] = nil
    }
    if let cityId = cityId {
        params["city_id"] = cityId
    }else
    {
        params["city_id"] = nil
    }

    if let lat = lat, let lng = lng {
        params["gaode_lng"] = lng
        params["gaode_lat"] = lat
    }

    if let gaodeCityId = gaodeCityId {
        params["gaode_city_id"] = gaodeCityId
    }
    return requestGeneralConfig(params: params, needCommonParams: needCommonParams)
}

func requestGeneralConfig(params: [String: Any], needCommonParams: Bool = true) -> Observable<GeneralConfigResponse?> {

    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: "\(EnvContext.networkConfig.host)/f100/api/config",
                    params: params,
                    method: "GET",
                    needCommonParams: needCommonParams)
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

