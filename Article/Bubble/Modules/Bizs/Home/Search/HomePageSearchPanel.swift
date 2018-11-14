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

    var isHighlighted = false

    lazy var countryLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = CommonUIStyle.Font.pingFangSemibold(14)
        label.textColor = hexStringToUIColor(hex: "#081f33")
        label.numberOfLines = 1
        label.text = "深圳"
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
        view.backgroundColor = hexStringToUIColor(hex: "#dae0e6")
        return view
    }()
    
    lazy var searchIconBackView: UIView = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: kFHClearBlueColor)
        return view
    }()

    lazy var searchIcon: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "icon-home-search")
        return view
    }()

    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: "#8a9299")
        label.text = UIScreen.main.bounds.width < 375 ? "输入小区/商圈/地铁" : "请输入小区/商圈/地铁"
        return label
    }()

    init(frame: CGRect, isHighlighted: Bool = false) {
        self.isHighlighted = isHighlighted
        super.init(frame: frame)
        setPanelStyle()
        setupCountryLabel()
        setupVerticalLine()
        setSearchArea()
    }
    
    override init(frame: CGRect) {
        self.isHighlighted = false
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
        if isHighlighted {
            self.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        } else {
            self.backgroundColor = UIColor.white
        }
        self.layer.borderWidth = 1
        self.layer.borderColor = hexStringToUIColor(hex: kFHClearBlueColor).cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
    }

    private func setupCountryLabel() {
        addSubview(countryLabel)
        countryLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(15)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(20)
            maker.width.greaterThanOrEqualTo(28)
        }
        countryLabel.sizeToFit()

        addSubview(triangleImage)
        triangleImage.snp.makeConstraints { [unowned countryLabel] maker in
            maker.left.equalTo(countryLabel.snp.right).offset(4).priority(.high)
            maker.left.equalToSuperview().offset(47).priority(.medium)
            maker.centerY.equalToSuperview()
            maker.height.width.equalTo(9)
        }
    }

    private func setupVerticalLine() {
        addSubview(verticalLineView)
        verticalLineView.snp.makeConstraints { maker in
            maker.left.equalTo(triangleImage.snp.right).offset(12)
            maker.centerY.equalToSuperview()
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

        addSubview(searchIconBackView)
        searchIconBackView.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.equalTo(50 * CommonUIStyle.Screen.widthScale)
            maker.height.equalToSuperview()
        }
        
        searchIconBackView.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(16)
        }
        
        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { maker in
            maker.left.equalTo(verticalLineView.snp.right).offset(10)
            maker.height.equalTo(20)
            maker.right.equalTo(searchIcon.snp.left).offset(-1)
            maker.centerY.equalToSuperview()
        }
        
        addSubview(searchBtn)
        searchBtn.snp.makeConstraints { maker in
            maker.left.equalTo(verticalLineView.snp.right)
            maker.top.bottom.right.equalToSuperview()
        }
        
    }
}

class CategorySearchNavPanel: HomePageSearchPanel {
    
}
