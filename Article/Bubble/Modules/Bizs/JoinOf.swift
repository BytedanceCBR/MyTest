//
//  JoinOf.swift
//  News
//
//  Created by leo on 2018/8/13.
//

import Foundation

infix operator <|>: SequencePrecedence

// MARK - ConditionAggregator

func <|>(l: ConditionAggregator, r: ConditionAggregator) -> ConditionAggregator {
    return ConditionAggregator { r.aggregator(l.aggregator($0)) }
}

// MARK - TracerParams

func <|>(params: TracerParams, parameter: @escaping TracerPremeter) -> TracerParams {
    return TracerParams {
        params.paramsGetter($0).merging(parameter(), uniquingKeysWith: { $1 })
    }
}

func <|>(l: TracerParams, r: TracerParams) -> TracerParams {
    return TracerParams {
        r.paramsGetter(l.paramsGetter($0))
    }
}
