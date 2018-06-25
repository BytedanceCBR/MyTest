//
//  SimpleNavBar.swift
//  Bubble
//
//  Created by linlin on 2018/6/15.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class SimpleNavBar: UIView {

    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .normal)
        return btn
    }()

    lazy var title: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(backBtn)
        backBtn.snp.makeConstraints { maker in
            maker.left.equalTo(12)
            maker.width.height.equalTo(24)
            maker.top.equalTo(30)
        }

        addSubview(title)
        title.snp.makeConstraints { maker in
            maker.top.equalTo(28)
            maker.left.equalTo(backBtn.snp.right)
            maker.height.equalTo(28)
            maker.centerX.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class SearchNavBar: UIView {

    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .normal)
        return btn
    }()

    lazy var searchAreaBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.clear
        return btn
    }()

    lazy var searchAreaPanel: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        result.layer.masksToBounds = true
        result.layer.cornerRadius = 4
        result.layer.borderColor = hexStringToUIColor(hex: "#e8e8e8").cgColor
        result.layer.borderWidth = 0.5
        return result
    }()

    lazy var searchIcon: UIImageView = {
        let result = UIImageView()
        result.image = #imageLiteral(resourceName: "icon-search-titlebar")
        return result
    }()

    lazy var searchInput: UITextField = {
        let result = UITextField()
        result.background = nil
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        return result
    }()

    var searchable = false {
        didSet {
            searchAreaBtn.isHidden = searchable
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        addSubview(backBtn)
        backBtn.snp.makeConstraints { maker in
            maker.left.equalTo(12)
            maker.width.height.equalTo(24)
            maker.top.equalTo(30)
        }

        addSubview(searchAreaPanel)
        searchAreaPanel.snp.makeConstraints { maker in
            maker.left.equalTo(backBtn.snp.right).offset(2)
            maker.bottom.equalToSuperview().offset(-8)
            maker.right.equalToSuperview().offset(-15)
            maker.height.equalTo(28)
        }

        searchAreaPanel.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { maker in
            maker.left.top.equalTo(2)
            maker.height.width.equalTo(24)
        }

        searchAreaPanel.addSubview(searchInput)
        searchInput.snp.makeConstraints { maker in
            maker.left.equalTo(searchIcon.snp.right).offset(1)
            maker.right.equalToSuperview()
            maker.top.equalToSuperview().offset(5)
            maker.bottom.equalToSuperview().offset(-3)
            maker.height.equalTo(20)
        }

        searchAreaPanel.addSubview(searchAreaBtn)
        searchAreaBtn.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
