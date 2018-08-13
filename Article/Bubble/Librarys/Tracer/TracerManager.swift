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

class TracerManager {

    @objc static let shared = TracerManager()

    init() {

    }



    func writeEvent(
            _ event: String,
            traceParams: TracerParams? =  nil,
            kind: String? = nil,
            params: [String: Any]? = nil) {

    }



}

protocol TracerRecord {

    func recordEvent(key: String, params: [String: Any])

}
