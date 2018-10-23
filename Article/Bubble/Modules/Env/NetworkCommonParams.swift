//
//  NetworkCommonParams.swift
//  Bubble
//
//  Created by linlin on 2018/7/10.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation

typealias NetworkParamsParser = () -> [AnyHashable: Any]

struct NetworkCommonParams {
    var params: NetworkParamsParser

    static func monoid() -> NetworkCommonParams {
        return NetworkCommonParams {
            [:]
        }
    }

    func join(_ params: @escaping NetworkParamsParser) -> NetworkCommonParams {
        return NetworkCommonParams {
            self.params().merging(params(), uniquingKeysWith: { (left, right) -> Any in
                right
            })
        }
    }
}

func <-(params: NetworkCommonParams, parser: @escaping NetworkParamsParser) -> NetworkCommonParams {
    return params.join(parser)
}
