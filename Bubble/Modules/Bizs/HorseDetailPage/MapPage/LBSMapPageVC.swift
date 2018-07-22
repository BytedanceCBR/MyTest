//
//  LBSMapPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/30.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
class LBSMapPageVC: BaseViewController, MAMapViewDelegate, AMapSearchDelegate {

    lazy var search: AMapSearchAPI = {
        let re = AMapSearchAPI()
        re?.delegate = self
        return re!
    }()

    fileprivate lazy var bottomView: BottomBarView = {
        let re = BottomBarView()
        return re
    }()

    var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        return re
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
        }

        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
        }

        let mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
        mapView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(bottomView.snp.top)
        }
    }

}

fileprivate class BottomBarView: UIView {

    init(){
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addItems(items: [BottomBarItemView]) {
        subviews.forEach { $0.removeFromSuperview() }
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        items.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
        }
    }

}

fileprivate class BottomBarItemView: UIView {

    lazy var iconButton: UIButton = {
        let re =  UIButton()
        return re
    }()

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(9)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        re.textAlignment = .center
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(iconButton)
        iconButton.snp.makeConstraints { maker in
            maker.height.width.equalTo(32)
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
        }

        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(iconButton.snp.bottom)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(13)
            maker.bottom.equalTo(-3)
        }

        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
