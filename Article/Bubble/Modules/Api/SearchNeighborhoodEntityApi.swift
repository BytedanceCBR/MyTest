//
//  SearchNeighborhoodEntityApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestNeighborhoodSearch(
        offset: Int = 0,
        query: String = "",
        searchId: String? = nil,
        suggestionParams: String = "",
        needEncode: Bool = true) -> Observable<SearchNeighborhoodResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/search_neighborhood?"
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
    query: String = "",
        searchId: String? = nil,
    suggestionParams: String = "",
    needEncode: Bool = true) -> () -> Observable<SearchNeighborhoodResponse?> {
    var offset: Int = 0
    var theSearchId = searchId
    return {
        return requestNeighborhoodSearch(
            offset: offset,
            query: query,
            searchId: theSearchId,
            suggestionParams: suggestionParams,
            needEncode: needEncode)
            .do(onNext: { (response) in
                if let count = response?.data?.items?.count {
                    offset = offset + count
                    theSearchId = response?.data?.searchId
                }
            })
    }
}
