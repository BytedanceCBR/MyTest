//
//  SearchAPI.swift
//  Bubble
//
//  Created by linlin on 2018/6/24.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

enum SearchSourceKey: String {
    case oldDetail = "old_detail"
    case neighborhoodDetail = "neighborhood_detail"
}

func requestSearch(
    offset: Int64 = 0,
    query: String = "",
    searchId: String? = nil,
    suggestionParams: String = "",
    needEncode: Bool = true) -> Observable<HouseRecommendResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/search?"
    if !query.isEmpty {
        url = "\(url)\(query)"
    }
    if needEncode, let theUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        url = theUrl
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["offset": offset,
                     "search_id": searchId ?? "",
                     "suggestion_params": suggestionParams],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> HouseRecommendResponse? in
            if let payload = payload {
                let response = HouseRecommendResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestErshouHouseSearch(
        query: String = "",
        searchId: String? = nil,
        suggestionParams: String = "",
        needEncode: Bool = true) -> () -> Observable<HouseRecommendResponse?> {
    var offset: Int64 = 0
    var theSearchId = searchId
    return {
        return requestSearch(
                offset: offset,
                query: query,
                searchId: theSearchId,
                suggestionParams: suggestionParams,
                needEncode: needEncode)
        .do(onNext: { (response) in
            if let count = response?.data?.items?.count {
                offset = offset + Int64(count)
                theSearchId = response?.data?.searchId
            }
        })
    }
}

func requestSearchHistory(houseType: String) -> Observable<SearchHistoryResponse?> {
    let url = "\(EnvContext.networkConfig.host)/f100/api/v2/get_history?"

    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["house_type":houseType],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> SearchHistoryResponse? in
            if let payload = payload {
                let response = SearchHistoryResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func requestDeleteSearchHistory(houseType: String) -> Observable<NSString?> {
    let url = "\(EnvContext.networkConfig.host)/f100/api/clear_history?"

    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["house_type":houseType],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
}

func requestGuessYouWant(cityId: Int, houseType:Int)-> Observable<GuessYouWantResponse?> {
    let params: [String : Any] = [
        "city_id": cityId,
        "house_type":houseType,
        "source": "app"]
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: "\(EnvContext.networkConfig.host)/f100/api/guess_you_want_search",
            params: params,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> GuessYouWantResponse? in
            if let payload = payload {
                let response = GuessYouWantResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}
