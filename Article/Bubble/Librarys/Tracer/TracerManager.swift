//
// Created by leo on 2018/8/13.
//

import Foundation

typealias TracerPramasGetter = ([String: Any]) -> [String: Any]

typealias TracerPremeter = () -> [String: Any]

struct TracerParams {

    let paramsGetter: TracerPramasGetter

    static func momoid() -> TracerParams {
        return TracerParams { input in
            return input
        }
    }

}

infix operator <*>: SequencePrecedence

func <*>(params: TracerParams, parameter: @escaping TracerPremeter) -> TracerParams {
    return TracerParams {
        params.paramsGetter($0).merging(parameter(), uniquingKeysWith: { $1 })
    }
}

class TracerManager {

    private var records: [TracerRecord]

    init() {
        self.records = [ConsoleEventRecord()]
    }

    func writeEvent(
            _ event: String,
            traceParams: TracerParams? =  nil,
            kind: String? = nil,
            params: [String: Any]? = nil) {
        records.forEach { record in
            if let traceParams = traceParams {
                record.recordEvent(
                    key: event,
                    params: traceParams.paramsGetter([:]))
            }
        }
    }

}

protocol TracerRecord {

    func recordEvent(key: String, params: [String: Any])

}

func traceStayTime(key: String = "stay_time") -> () -> [String: Any] {
    let startTime = Date().timeIntervalSince1970
    return {
        let stayTime = Date().timeIntervalSince1970 - startTime
        return [key: stayTime]
    }
}
