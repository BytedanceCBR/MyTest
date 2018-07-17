//
//  EnvContext.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class EnvContext {
    static let shared = EnvContext()

    static let networkConfig: NetworkConfig = {
        NetworkConfig()
    }()

    lazy var rootNavController: UINavigationController = {
        BaseNavigationController()
    }()

    lazy var client: Client = {
        Client()
    }()
}

class NetworkConfig {
    var host: String

    init() {
        self.host = "http://m.quduzixun.com"
    }
}


