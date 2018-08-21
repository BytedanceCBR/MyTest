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
            .debug("conditionTracer")
            .bind { [weak self] (condition) in
                EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                    toTracerParams(condition, key: "filter")
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
        return (conditions
            .reduce(ConditionAggregator.monoid()) { (result, e) -> ConditionAggregator in
                let (_, aggregator) = e
                return result <|> ConditionAggregator(aggregator: aggregator)
            } <|> queryConditionAggregator).aggregator("")
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
        values.append(node.filterCondition)
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
