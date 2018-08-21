//
//  HomeHeaderSearchView.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class HomeHeaderSearchView: UIView {

    var searchBar: SearchUITextField!

    override init(frame: CGRect) {
        super.init(frame: frame)
        searchBar = SearchUITextField()
        backgroundColor = UIColor.gray
        addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(70)
            make.height.equalTo(30)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hiddenSearchItem() {
//        searchBar.isHidden = true
        searchBar.alpha = 0
    }

    func showSearchItem() {
//        searchBar.isHidden = false
        searchBar.alpha = 1
    }

}
