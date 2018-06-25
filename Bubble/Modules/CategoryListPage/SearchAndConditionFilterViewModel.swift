//
// Created by linlin on 2018/6/21.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
infix operator <|>: SequencePrecedence

func <|>(l: ConditionAggregator, r: ConditionAggregator) -> ConditionAggregator {
    return ConditionAggregator { r.aggregator(l.aggregator($0)) }
}

class SearchAndConditionFilterViewModel {

    var conditions: [Int: ((String) -> String)] = [:]

    let queryCondition = BehaviorRelay<String>(value: "")

    var queryConditionAggregator = ConditionAggregator.monoid() {
        didSet {
            queryCondition.accept(getConditions())
        }
    }

    init() {
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
}

