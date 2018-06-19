//
//  HomePageSearchPanel.swift
//  Bubble
//
//  Created by linlin on 2018/6/15.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import QuartzCore
import SnapKit

class HomePageSearchPanel: UIView {

    lazy var countryLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: "#505050")
        label.numberOfLines = 1
        label.text = "秦皇岛"
        return label
    }()

    lazy var changeCountryBtn: UIButton = {
        UIButton()
    }()


    lazy var searchBtn: UIButton = {
        UIButton()
    }()

    lazy var triangleImage: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "icon-triangle-open")
        return view
    }()

    lazy var verticalLineView: UIView = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#d8d8d8")
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.5
        return view
    }()

    lazy var searchIcon: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "icon-search-titlebar")
        return view
    }()

    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: "#999999")
        label.text = "小区/商圈/地铁"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setPanelStyle()
        setupCountryLabel()
        setupVerticalLine()
        setSearchArea()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setPanelStyle() {
        self.backgroundColor = UIColor.white
        self.layer.shadowRadius = 4
        self.layer.shadowColor = hexStringToUIColor(hex: "#000000").cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.06
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
    }

    private func setupCountryLabel() {
        addSubview(countryLabel)
        countryLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(15)
            maker.top.equalToSuperview().offset(10)
            maker.height.equalTo(20)
            maker.width.greaterThanOrEqualTo(28)
        }
        countryLabel.sizeToFit()

        addSubview(triangleImage)
        triangleImage.snp.makeConstraints { [unowned countryLabel] maker in
            maker.left.equalTo(countryLabel.snp.right).offset(4).priority(.high)
            maker.left.equalToSuperview().offset(47).priority(.medium)
            maker.top.equalToSuperview().offset(16)
            maker.height.width.equalTo(9)
        }


    }

    private func setupVerticalLine() {
        addSubview(verticalLineView)
        verticalLineView.snp.makeConstraints { maker in
            maker.left.equalTo(triangleImage.snp.right).offset(12)
            maker.top.equalTo(13)
            maker.width.equalTo(1)
            maker.height.equalTo(15)
        }

        addSubview(changeCountryBtn)
        changeCountryBtn.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.right.equalTo(verticalLineView.snp.left)
        }
    }

    private func setSearchArea() {
        addSubview(searchIcon)
        searchIcon.snp.makeConstraints { maker in
            maker.left.equalTo(verticalLineView.snp.right).offset(12)
            maker.top.equalTo(8)
            maker.width.height.equalTo(24)
        }

        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { maker in
            maker.left.equalTo(searchIcon.snp.right).offset(2)
            maker.height.equalTo(20)
            maker.right.equalToSuperview()
            maker.top.equalTo(10)
        }
        addSubview(searchBtn)
        searchBtn.snp.makeConstraints { maker in
            maker.left.equalTo(verticalLineView.snp.right)
            maker.top.bottom.right.equalToSuperview()
        }
    }
}
