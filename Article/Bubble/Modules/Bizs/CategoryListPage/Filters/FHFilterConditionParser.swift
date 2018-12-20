//
//  FHFilterConditionParser.swift
//  NewsLite
//
//  Created by leo on 2018/12/20.
//

import Foundation
@objc
class FHFilterConditionParser: NSObject {
    @objc
    static func getConfigByHouseType(houseType: HouseType) -> [FHFilterNodeModel] {
        let config = filterConfigByHouseType(houseType: houseType)
        if let config = config {
            let result = FHFilterConditionParser.convertConfigToFHFilterConditionModel(config: config)
            return result
        } else {
            return []
        }
    }

    static func convertConfigToFHFilterConditionModel(config: [SearchConfigFilterItem]) -> [FHFilterNodeModel] {
        let result = config.map { (item) -> FHFilterNodeModel in
            FHFilterConditionParser.convertFilterItemToModel(item)
        }
        return result
    }

    static func convertFilterItemToModel(_ item: SearchConfigFilterItem) -> FHFilterNodeModel {
        let model = FHFilterNodeModel()
        model.label = item.text ?? ""
        model.rate = item.rate
        model.isSupportMulti = item.supportMulti
        if let options = item.options {
            model.children = FHFilterConditionParser.convertConfigToFHFilterConditionModel(config: options)
        }
        return model
    }

    static func convertConfigToFHFilterConditionModel(config: [SearchConfigOption]) -> [FHFilterNodeModel] {
        let result = config.map { (option) -> FHFilterNodeModel in
            FHFilterConditionParser.convertFilterOptionToModel(option)
        }
        return result
    }

    static func convertFilterOptionToModel(_ item: SearchConfigOption) -> FHFilterNodeModel {
        let model = FHFilterNodeModel()
        model.label = item.text ?? ""
        model.rankType = item.rankType ?? ""
        model.isSupportMulti = item.supportMulti ?? false
        if let options = item.options {
            model.children = FHFilterConditionParser.convertConfigToFHFilterConditionModel(config: options)
        }
        return model
    }

    static func filterConfigByHouseType(houseType: HouseType) -> [SearchConfigFilterItem]? {
        let searchConfigs = EnvContext.shared.client.configCacheSubject.value
        switch houseType {
        case .secondHandHouse:
            return searchConfigs?.filter
        case .rentHouse:
            return searchConfigs?.rentFilter
        case .newHouse:
            return searchConfigs?.courtFilter
        case .neighborhood:
            return searchConfigs?.neighborhoodFilter
        default:
            return searchConfigs?.filter
        }
    }
}

