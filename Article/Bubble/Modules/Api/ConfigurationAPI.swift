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

func requestSearchConfig(
    gaodeCityName: String? = nil,
    geoCityId: String? = nil,
    cityId: Int? = nil) -> Observable<SearchConfigResponse?> {
    let commonParams = TTNetworkManager.shareInstance()?.commonParamsblock()
    var params = [String: Any]()
    if let commonParams = commonParams as? [String: Any] {
        params.merge(commonParams) { (left, right) -> Any in
            left
        }
    }

    if let cityId = cityId {
        params["city_id"] = cityId
    }

    if let gaodeCityName = gaodeCityName {
        params["city_name"] = gaodeCityName
    }

    if let geoCityId = geoCityId {
        params["gaode_city_id"] = geoCityId
    }

    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: "\(EnvContext.networkConfig.host)/f100/api/search_config",
                    params: params,
                    method: "GET",
                    needCommonParams: false)
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

    let commonParams = TTNetworkManager.shareInstance()?.commonParamsblock()
    if !needCommonParams {
        if let commonParams = commonParams as? [String: Any] {
            params.merge(commonParams) { (left, right) -> Any in
                left
            }
        }
    }


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

