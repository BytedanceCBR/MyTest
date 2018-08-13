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

class TracerManager: NSObject {

    private var records: [TracerRecord]

    override init() {
        self.records = [ConsoleEventRecord()]
    }

    
    @objc
    func writeEvent(
        _ event: String,
        params: [String: Any]? = nil) {
        records.forEach { record in
            if let theParams = params {
                record.recordEvent(
                    key: event,
                    params: theParams)
            }
        }
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
            }else if let theParams = params {
                record.recordEvent(
                    key: event,
                    params: theParams)
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
