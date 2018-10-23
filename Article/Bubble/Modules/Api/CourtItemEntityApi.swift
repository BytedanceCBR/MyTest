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
        offset: Int64 = 0,
        query: String = "",
        searchId: String? = nil,
        suggestionParams: String = "",
        needEncode: Bool = true) -> Observable<CourtSearchResponse?> {

    var url = "\(EnvContext.networkConfig.host)/f100/api/search_court?"
    if needEncode, !query.isEmpty, let theQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        url = "\(url)\(theQuery)"
    } else {
        url = "\(url)\(query)"
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
        .map({ (payload) -> CourtSearchResponse? in
            if let payload = payload {
                let response = CourtSearchResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}


func pageRequestCourtSearch(
    query: String = "",
    suggestionParams: String = "",
    needEncode: Bool = true) -> () -> Observable<CourtSearchResponse?> {
    var offset: Int64 = 0
    var searchId: String?
    return {
        return requestCourtSearch(
                offset: offset,
                query: query,
                searchId: searchId,
                suggestionParams: suggestionParams,
                needEncode: needEncode)
                .do(onNext: { (response) in
                    if let count = response?.data?.items?.count {
                        offset = offset + Int64(count)
                        searchId = response?.data?.searchId
                    }
                })
    }
}


func requestCourtInfo(courtId: String, type: Int) -> Observable<Void> {
    return .empty()
}
