//
// Created by linlin on 2018/6/21.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation

infix operator <|>: SequencePrecedence

func <|>(l: ConditionAggregator, r: ConditionAggregator) -> ConditionAggregator {
    return ConditionAggregator { r.aggregator(l.aggregator($0)) }
}

class SearchAndConditionFilterViewModel {

    var conditions: [Int: ((String) -> String)] = [:]

    init() {

    }

    func addCondition(index: Int, condition: @escaping (String) -> String) {
        conditions[index] = condition
    }

    func removeCondition(index: Int) {
        conditions[index] = nil
    }

    func getConditions() -> String {
        return conditions
            .reduce(ConditionAggregator.monoid()) { (result, e) -> ConditionAggregator in
                let (_, aggregator) = e
                return result <|> ConditionAggregator(aggregator: aggregator)
            }.aggregator("")
    }
}
