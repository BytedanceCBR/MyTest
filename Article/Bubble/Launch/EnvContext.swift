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

    lazy var tracer: TracerManager = {
        TracerManager()
    }()
    
    private override init() {
        super.init()
    }

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

func thresholdTracer(threshold: Double) -> (String, TracerParams) -> Void {
    let startTime = Date().timeIntervalSince1970
    return { (key, params) in
        if Date().timeIntervalSince1970 - startTime > threshold {
            recordEvent(key: key, params: params)
        }
    }
}
