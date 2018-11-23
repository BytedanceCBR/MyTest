//
//  EnvContext.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

@objc class EnvContext: NSObject {
    @objc static let shared = EnvContext()

    @objc static let networkConfig: NetworkConfig = {
        NetworkConfig()
    }()

    @objc lazy var rootNavController: UINavigationController = {
        BaseNavigationController()
    }()

    @objc let client = Client()

    @objc lazy var toast: ToastAlertCenter = {
        ToastAlertCenter()
    }()

    @objc 
    lazy var tracer: TracerManager = {
        let re = TracerManager()
        re.defaultParams = ["event_type": "house_app2c_v2"]
        return re
    }()
    
    @objc
    lazy var currentMapSelect :String = {
        return "公交"
    }()//全局用户状态

    private override init() {
        super.init()
    }

    var homePageParams = TracerParams.momoid() <|> toTracerParams("be_null", key: "origin_search_id")
                        <|> toTracerParams("be_null", key: "origin_from")

    @objc
    func setTraceValue(value: String, key: String) {
        homePageParams = homePageParams <|> toTracerParams(value, key: key)
    }
    
    @objc
    func homePageParamsMap() -> [String: Any] {
        return homePageParams.paramsGetter([:])
    }
    
    @objc
    func recordEvent(key: String, params: [String: Any]? = nil) {
        tracer.writeEvent(key, params: params)
    }
    

}

class NetworkConfig: NSObject {
    @objc var host: String {
        get {
            //因为baseURL会改变，改为每次都取值
            return CommonURLSetting.baseURL()
        }
    }

    @objc override init() {
        super.init()
    }
}

func recordEvent(key: String, params: TracerParams) {
    EnvContext.shared.tracer.writeEvent(key, traceParams: params)
}

func recordEvent(key: String, params: [String: Any]? = nil) {
    EnvContext.shared.tracer.writeEvent(key, params: params)
}



func thresholdTracer(_ threshold: Double = 0) -> (String, TracerParams) -> Void {
    let startTime = Date().timeIntervalSince1970
    return { (key, params) in
        if Date().timeIntervalSince1970 - startTime > threshold {
            recordEvent(key: key, params: params)
        }
    }
}
