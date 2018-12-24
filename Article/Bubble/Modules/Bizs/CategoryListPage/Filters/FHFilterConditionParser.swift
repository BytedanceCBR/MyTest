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
    static func getSortConfigByHouseType(houseType: HouseType) -> [FHFilterNodeModel] {
        let config = sortConfigByHouseType(houseType: houseType)
        if let config = config {
            let result = FHFilterConditionParser.convertConfigToFHFilterConditionModel(config: config)
            return result
        } else {
            return []
        }
    }

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
        model.rowId = "\(item.tabId ?? 0)"

        if let options = item.options {
            model.children = FHFilterConditionParser.convertConfigToFHFilterConditionModel(config: options, supportMulti: nil)
        } else {
            model.children = []
        }
        return model
    }

    static func convertConfigToFHFilterConditionModel(config: [SearchConfigOption], supportMulti: Bool?, parent: FHFilterNodeModel? = nil) -> [FHFilterNodeModel] {
        let result = config.map { (option) -> FHFilterNodeModel in
            let re = FHFilterConditionParser.convertFilterOptionToModel(option, supportMutli: supportMulti, parent: parent)
            if let supportMulti = supportMulti {
                re.isSupportMulti = supportMulti
            }
            return re
        }
        return result
    }

    static func convertFilterOptionToModel(_ item: SearchConfigOption, supportMutli: Bool?, parent: FHFilterNodeModel? = nil) -> FHFilterNodeModel {
        let model = FHFilterNodeModel()
        model.label = item.text ?? ""
        model.rankType = item.rankType ?? ""
        model.isEmpty = item.isEmpty
        model.isNoLimit = item.isNoLimit
        model.value = item.value as? String ?? ""
        model.key = item.type ?? ""
        model.parent = parent
        if let supportMutli = supportMutli {
            model.isSupportMulti = supportMutli
        } else {
            model.isSupportMulti = item.supportMulti ?? false
        }

        if let options = item.options {
            model.children = FHFilterConditionParser.convertConfigToFHFilterConditionModel(config: options, supportMulti: model.isSupportMulti, parent: model)
        } else {
            model.children = []
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

    static func sortConfigByHouseType(houseType: HouseType) -> [SearchConfigFilterItem]? {
        let searchConfigs = EnvContext.shared.client.configCacheSubject.value
        switch houseType {
        case .secondHandHouse:
            return searchConfigs?.filterOrder
        case .rentHouse:
            return searchConfigs?.rentFilterOrder
        case .newHouse:
            return searchConfigs?.courtFilterOrder
        case .neighborhood:
            return searchConfigs?.neighborhoodFilterOrder
        default:
            return searchConfigs?.filterOrder
        }
    }
}

