//
//  RelatedSearchApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestRelatedHouseSearch(houseId: String = "", offset: String = "0", query: String = "",count : Int = 20) -> Observable<RelatedHouseResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/related_house?house_id=\(houseId)&offset=\(offset)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    
    var params = [String : Any]()
    if !url.contains("count") {
        params["count"] = count
    }
    
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: params,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> RelatedHouseResponse? in
            if let payload = payload {
                let response = RelatedHouseResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}


func requestRelatedCourtSearch(courtId: String = "", offset: String = "0", query: String = "") -> Observable<RelatedCourtResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/related_court?court_id=\(courtId)&offset=\(offset)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    if let theUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        url = theUrl
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: nil,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> RelatedCourtResponse? in
            if let payload = payload {
                let response = RelatedCourtResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func requestRelatedNeighborhoodSearch(
        neighborhoodId: String = "",
        searchId: String? = nil,
        offset: Int64  = 0,
        count: Int = 5,
        query: String = "") -> Observable<RelatedNeighborhoodResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/related_neighborhood?neighborhood_id=\(neighborhoodId)&offset=\(offset)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["count": count,
                     "search_id": searchId ?? ""],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> RelatedNeighborhoodResponse? in
            if let payload = payload {
                let response = RelatedNeighborhoodResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestRelatedNeighborhoodSearch(neighborhoodId: String = "",
                                          searchId: String? = nil,
                                          count: Int = 5,
                                          query: String = "") -> () -> Observable<RelatedNeighborhoodResponse?> {
    var offset: Int64 = 0
    var theSearchId = searchId
    return {
        return requestRelatedNeighborhoodSearch(
                neighborhoodId: neighborhoodId,
                searchId: theSearchId,
                offset: offset,
                count: count,
                query: query)
                .do(onNext: { (response) in
                    if let count = response?.data?.items?.count {
                        offset = offset + Int64(count)
                        theSearchId = response?.data?.searchId
                    }
                })
    }
}


func requestHouseInSameNeighborhoodSearch(
        neighborhoodId: String? = nil,
        houseId: String? = nil,
        searchId: String? = nil,
        count: Int = 5,
        offset: Int = 0) -> Observable<SameNeighborhoodHouseResponse?> {
    let url = "\(EnvContext.networkConfig.host)/f100/api/same_neighborhood_house"
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: url,
                    params: ["neighborhood_id": neighborhoodId ?? "",
                             "house_id": houseId ?? "",
                             "offset": offset,
                             "search_id": searchId ?? "",
                             "count": count],
                    method: "GET",
                    needCommonParams: true)
            .map({ (data) -> NSString? in
                NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            })
            .map({ (payload) -> SameNeighborhoodHouseResponse? in
                if let payload = payload {
                    let response = SameNeighborhoodHouseResponse(JSONString: payload as String)
                    return response
                } else {
                    return nil
                }
            })
}

func pageRequestHouseInSameNeighborhoodSearch(
        neighborhoodId: String? = nil,
        houseId: String? = nil,
        searchId: String? = nil,
        count: Int = 5) -> () -> Observable<SameNeighborhoodHouseResponse?> {
    var offset: Int = 0
    var theSearchId = searchId
    return {
        requestHouseInSameNeighborhoodSearch(
                neighborhoodId: neighborhoodId,
                houseId: houseId,
                searchId: theSearchId,
                count: count,
                offset: offset)
                .do(onNext: { (response) in
                    if let count = response?.data?.items.count {
                        offset = offset + Int(count)
                        theSearchId = response?.data?.searchId
                    }
                })
    }
}


func requestRentInSameNeighborhoodSearch(
    query:String? = nil ,
    neighborhoodId: String? = nil,
    houseId: String? = nil,
    searchId: String? = nil,
    condition: String? = nil ,
    count: Int = 5,
    offset: Int = 0) -> Observable<SearchRentResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/same_neighborhood_rent"
    var params = [String :Any]()
    if let theQuery = query {
        url = "\(url)?\(theQuery)"
        if let nid = neighborhoodId {
            params["neighborhood_id"] = nid
        }
        if let hid = houseId {
            params["exclude_id[]"] = hid
        }
    }else{
        params["neighborhood_id"] = neighborhoodId ?? ""
        params["exclude_id[]"] = houseId ?? ""
    }
    params["house_type"] = HouseType.rentHouse.rawValue
    params["offset"] = offset
    params["search_id"] =  searchId ?? ""
    params["count"] = count
    
    if let cd = condition {
        params["suggestion_params"] = cd
    }
    
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: params,
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

func pageRequestRentInSameNeighborhoodSearch(
    query:String? = nil ,
    neighborhoodId: String? = nil,
    houseId: String? = nil,
    searchId: String? = nil,
    condition: String? = nil ,
    count: Int = 20) -> () -> Observable<SearchRentResponse?> {
    var offset: Int = 0
    var theSearchId = searchId
    return {
        requestRentInSameNeighborhoodSearch(
            query:query,
            neighborhoodId: neighborhoodId,
            houseId: houseId ,
            searchId: theSearchId,
            condition: condition  ,
            count: count,
            offset: offset)
            .do(onNext: { (response) in
                if let count = response?.data?.items?.count {
                    offset = offset + Int(count)
                    theSearchId = response?.data?.searchId
                }
            })
    }
}


func pageRequestRelatedHouse(
    query:String? = nil ,
    houseId: String? = nil,
    searchId: String? = nil,
    condition: String? = nil ,
    count: Int = 20) -> () -> Observable<RelatedHouseResponse?> {
    var offset: Int = 0
    var theSearchId = searchId
    return {
        requestRelatedHouseSearch(houseId: houseId ?? "", offset: "\(offset)", query: query ?? "" , count: count)
            .do(onNext: { (response) in
                if let count = response?.data?.items?.count {
                    offset = offset + Int(count)
                    theSearchId = response?.data?.searchId
                }
            })
    }
}
