//
//  LBSMapPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/30.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class LBSMapPageVC: BaseViewController, MAMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
    }

}
