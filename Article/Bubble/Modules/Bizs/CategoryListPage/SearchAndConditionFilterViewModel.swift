//
// Created by linlin on 2018/6/21.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


public struct TracerParams {

    let paramsGetter: TracerPramasGetter

}

class SearchAndConditionFilterViewModel {

    var conditions: [Int: ((String) -> String)] = [:]

    let queryCondition = BehaviorRelay<String>(value: "")

    let conditionTracer = BehaviorRelay<[Int: [Node]]>(value: [:])

    let disposeBag = DisposeBag()

    var pageType: String?

    var searchSortCondition: Node? {
        didSet {
            queryCondition.accept(getConditions())
        }
    }

    var queryConditionAggregator = ConditionAggregator.monoid() {
        didSet {
            queryCondition.accept(getConditions())
        }
    }

    init() {
        conditionTracer
            .map { $0.values }
            .map { $0.reduce([:], mapCondition) }
            .map(jsonStringMapper)
//            .debug("conditionTracer")
            .skip(1)
            .bind { [weak self] (condition) in

                let params = EnvContext.shared.homePageParams <|>
                    toTracerParams(self?.pageType ?? "be_null", key: "page_type")
                recordEvent(key: "house_filter", params: params)
            }.disposed(by: disposeBag)


    }

    func addCondition(index: Int, condition: @escaping (String) -> String) {
        conditions[index] = condition
        queryCondition.accept(getConditions())
    }

    func removeCondition(index: Int) {
        conditions[index] = nil
        queryCondition.accept(getConditions())
    }

    func getConditions() -> String {
        var initQuery = ""
        if let searchSortCondition = searchSortCondition {
            initQuery = "&\(searchSortCondition.externalConfig)"
        }
        return (conditions
            .reduce(ConditionAggregator.monoid()) { (result, e) -> ConditionAggregator in
                let (_, aggregator) = e
                return result <|> ConditionAggregator(aggregator: aggregator)
            } <|> queryConditionAggregator).aggregator(initQuery)
    }

    func sendSearchRequest() {
        queryCondition.accept(getConditions())
    }

    func cleanCondition() {
        conditions = [:]
        queryCondition.accept("")
    }
}

fileprivate func mapCondition(result: [String: [Any]], nodes: [Node]) -> [String: [Any]] {
    var result = result
    nodes.forEach { node in
        var values = valueWithDefault(map: result, key: node.key, defaultValue: [Node]())
        if let filterCondition = node.filterCondition {
            values.append(filterCondition)
        }
        result[node.key] = values
    }
    return result
}

fileprivate func jsonStringMapper(value:  [String: [Any]]) -> String {
    if let data = try? JSONSerialization.data(withJSONObject: value, options: []) as Data,
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
        return json as String
    }
    return ""
}
