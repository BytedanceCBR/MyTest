//
// Created by leo on 2018/8/2.
//

import Foundation
import ObjectMapper
class SuggestionHistoryDataSource {

    private let KEY_SUGGESTION_HISTORY_CACHE = "cache_suggestion_history"

    lazy private var suggestionHistoryCache: YYCache? = {
        YYCache(name: KEY_SUGGESTION_HISTORY_CACHE)
    }()

    init() {

    }

    func getHistoryByType(houseType: HouseType) -> [SuggestionItem] {
        guard let payload = suggestionHistoryCache?.object(forKey: keyByHouseType(houseType)) as? String else {
            return []
        }
        let result = SuggestionData(JSONString: payload)
        return result?.items ?? []
    }

    func addHistoryItem(item: SuggestionItem, houseType: HouseType) {
        if let payload = suggestionHistoryCache?.object(forKey: keyByHouseType(houseType)) as? String,
            let cache = SuggestionData(JSONString: payload) {
            var result = SuggestionData()
            result.items = ([item] + cache.items.filter { $0.text != item.text }).take(10)
            if let content = result.toJSONString() {
                suggestionHistoryCache?.setObject(content as NSCoding, forKey: keyByHouseType(houseType))
            }
        } else {
            var result = SuggestionData()
            result.items = [item]
            if let content = result.toJSONString() {
                suggestionHistoryCache?.setObject(content as NSCoding, forKey: keyByHouseType(houseType))
            }
        }
    }

    func cleanHistoryItems(houseType: HouseType) {
        let result = SuggestionData()
        if let content = result.toJSONString() {
            suggestionHistoryCache?.setObject(content as NSCoding, forKey: keyByHouseType(houseType))
        }
    }
    
    func keyByHouseType(_ houseType: HouseType) -> String {
        return "history-houseType-\(houseType.rawValue)"
    }

}

struct SuggestionData: Mappable {

    var items: [SuggestionItem] = []

    init?(map: Map) {

    }
    
    init() {
        
    }

    mutating func mapping(map: Map) {
        items <- map["items"]
    }
}


