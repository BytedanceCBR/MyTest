//
// Created by leo on 2018/8/13.
//

import Foundation

typealias TracerPramasGetter = ([String: Any]) -> [String: Any]

public typealias TracerPremeter = () -> [String: Any]

extension TracerParams {
    static func momoid() -> TracerParams {
        return TracerParams { input in
            return input
        }
    }
}

func mapTracerParams(_ value: [String: Any]) -> TracerPremeter {
    return {
        return value
    }
}

func toTracerParams(_ value: Any, key: String) -> TracerPremeter {
    return {
        [key: value]
    }
}

func toTracerParams(_ value: Int, key: String) -> TracerPremeter {
    return {
        [key: value]
    }
}

func toTracerParams(_ value: String, key: String) -> TracerPremeter {
    return {
        [key: value]
    }
}

func toTraceParams<T>(_ value: T, apply: @escaping (T) -> [String: Any]) -> TracerPremeter {
    return{
        apply(value)
    }
}

func paramsOfMap(_ data: [String: Any]) -> TracerParams {
    return TracerParams.momoid() <|> mapTracerParams(data)
}

class TracerManager {

    private var records: [TracerRecord]

    var defaultParams: [String: Any]?

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
                    params: traceParams.paramsGetter(defaultParams ?? [:]))
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
        return [key: Int64(stayTime * 1000)]
    }
}
