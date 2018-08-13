//
//  EnvContext.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class EnvContext: NSObject {
    @objc static let shared = EnvContext()

    @objc static let networkConfig: NetworkConfig = {
        NetworkConfig()
    }()

    @objc lazy var rootNavController: UINavigationController = {
        BaseNavigationController()
    }()

    @objc lazy var client: Client = {
        Client()
    }()

    lazy var toast: ToastAlertCenter = {
        ToastAlertCenter()
    }()

    @objc 
    lazy var tracer: TracerManager = {
        let re = TracerManager()
        re.defaultParams = ["event_type": "house_app2c"]
        return re
    }()
    
    private override init() {
        super.init()
    }

    var homePageParams = TracerParams.momoid()

}

class NetworkConfig: NSObject {
    var host: String

    @objc override init() {
        self.host = "https://m.quduzixun.com"
        super.init()
    }
}

func recordEvent(key: String, params: TracerParams) {
    EnvContext.shared.tracer.writeEvent(key, traceParams: params)
}

func recordEvent(key: String, params: [String: Any]? = nil) {
    EnvContext.shared.tracer.writeEvent(key, params: params)
}


func thresholdTracer(threshold: Double) -> (String, TracerParams) -> Void {
    let startTime = Date().timeIntervalSince1970
    return { (key, params) in
        if Date().timeIntervalSince1970 - startTime > threshold {
            recordEvent(key: key, params: params)
        }
    }
}
