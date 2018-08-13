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


