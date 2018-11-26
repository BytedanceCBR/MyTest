//
//  RentHouseEntityAPI.swift
//  Article
//
//  Created by 谷春晖 on 2018/11/26.
//

import Foundation
import RxSwift
import ObjectMapper

func requestRentSearch(
    offset: Int = 0,
    query: String = "",
    searchId: String? = nil,
    suggestionParams: String = "",
    needEncode: Bool = true) -> Observable<SearchRentResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/search_rent?"
    if !query.isEmpty {
        url = "\(url)\(query)"
    }
    if needEncode, let theUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        url = theUrl
    }
    
    var sugParams = suggestionParams
    
    if suggestionParams.count > 0 {
        sugParams = suggestionParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["offset": offset,
                     "search_id": searchId ?? "",
                     "suggestion_params": sugParams],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> SearchRentResponse? in
            if let payload = payload {
                let response = SearchRentResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}


func pageRequestRentSearch(
    query: String = "",
    searchId: String? = nil,
    suggestionParams: String = "",
    needEncode: Bool = true) -> () -> Observable<SearchRentResponse?> {
    var offset: Int = 0
    var theSearchId = searchId
    return {
        return requestRentSearch(
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
