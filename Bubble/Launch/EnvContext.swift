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

    lazy var rootNavController: UINavigationController = {
        BaseNavigationController()
    }()
}
