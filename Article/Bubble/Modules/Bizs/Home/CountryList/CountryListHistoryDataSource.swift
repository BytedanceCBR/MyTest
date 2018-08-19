//
// Created by leo on 2018/8/3.
//

import Foundation
import ObjectMapper

class CountryListHistoryDataSource {

    private let KEY_COUNTRY_LIST_HISTORY_CACHE = "cache_country_list_history"

    private let KEY_LIST = "key_history_list"

    lazy private var historyCache: YYCache? = {
        YYCache(name: KEY_COUNTRY_LIST_HISTORY_CACHE)
    }()

    init() {

    }

    func getHistory() -> [CountryListNode] {
        guard let payload = historyCache?.object(forKey: KEY_LIST) as? String else {
            return []
        }

        let result = CountryHistoryCacheData(JSONString: payload)
        return result?.datas ?? []
    }

    func addHistory(item: CountryListNode, maxSaveCount: Int) {
        if let payload = historyCache?.object(forKey: KEY_LIST) as? String,
           let cache = CountryHistoryCacheData(JSONString: payload) {
            var result = CountryHistoryCacheData()
            result.datas = ([item] + cache.datas.filter { $0.label != item.label }).take(maxSaveCount)
            if let content = result.toJSONString() {
                historyCache?.setObject(content as NSCoding, forKey: KEY_LIST)
            }
        } else {
            var result = CountryHistoryCacheData()
            result.datas = [item]
            if let content = result.toJSONString() {
                historyCache?.setObject(content as NSCoding, forKey: KEY_LIST)
            }
        }
    }

    func addHistory(item: CityItem, maxSaveCount: Int) {
        let cityNode = CountryListNode(
                label: item.name ?? "",
                type: .bubble,
                query: .history,
                cityId: item.cityId,
                pinyin: item.fullPinyin,
                simplePinyin: item.simplePinyin,
                children: nil)
        addHistory(item: cityNode, maxSaveCount: maxSaveCount)

    }

    func cleanHistory() {
        let result = CountryHistoryCacheData()
        if let content = result.toJSONString() {
            historyCache?.setObject(content as NSCoding, forKey: KEY_LIST)
        }
    }
}

enum CountryListCellType: String {
    case bubble = "bubble"
    case item = "item"
}

enum CountryQueryType: String {
    case hot = "hot"
    case history = "history"
    case list = "list"
    case location = "location"
}

struct CountryListNode : Mappable {
    var label: String = ""
    var type: CountryListCellType = .item
    var query: CountryQueryType = .list
    var cityId: Int?
    var pinyin: String?
    var simplePinyin: String?
    var children: [CountryListNode]?

    init?(map: Map) {
    }
    
    init(
        label: String,
        type: CountryListCellType,
        query: CountryQueryType,
        cityId: Int?,
        pinyin: String?,
        simplePinyin: String?,
        children: [CountryListNode]?) {
        self.label = label
        self.type = type
        self.query = query
        self.cityId = cityId
        self.pinyin = pinyin
        self.simplePinyin = simplePinyin
        self.children = children
    }

    mutating func mapping(map: Map) {
        label <- map["label"]
        type <- map["type"]
        query <- map["query"]
        cityId <- map["cityId"]
        pinyin <- map["pinyin"]
        simplePinyin <- map["simplePinyin"]
        children <- map["children"]
    }
}

struct CountryHistoryCacheData: Mappable {
    var datas: [CountryListNode] = []

    init?(map: Map) {

    }

    init() {

    }

    mutating func mapping(map: Map) {
        datas <- map["datas"]
    }
}
