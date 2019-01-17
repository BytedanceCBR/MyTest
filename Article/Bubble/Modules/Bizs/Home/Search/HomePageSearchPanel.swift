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
import RxCocoa
import RxSwift

class HomePageSearchPanel: UIView {

    var isHighlighted = false

    lazy var countryLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = CommonUIStyle.Font.pingFangSemibold(14)
        label.textColor = hexStringToUIColor(hex: "#081f33")
        label.numberOfLines = 1
        if let city = EnvContext.shared.client.userCurrentCityText?.object(forKey: "usercurrentcity") as? String
        {
            label.text = city
        }else
        {
            label.text = "深圳"
        }
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

    lazy var categoryPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: "#8a9299")
        label.text = UIScreen.main.bounds.width < 375 ? "输入小区/商圈/地铁" : "请输入小区/商圈/地铁"
        return label
    }()
    
    lazy var categoryLabel1: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        label.text = ""
        return label
    }()
    
    lazy var categoryLabel2: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.font = CommonUIStyle.Font.pingFangRegular(14)
        label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        label.text = ""
        return label
    }()
    
    lazy var categoryBgView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    var searchTitleIndex: Int = 0
    var searchTitles:[String] = [] {
        didSet {
            searchTitleIndex = 0
            if searchTitles.count > 0 {
                setupTimer()
                categoryBgView.isHidden = false
                categoryPlaceholderLabel.isHidden = true
                self.updateTitleText()
            } else {
                self.dispose?.dispose()
                categoryBgView.isHidden = true
                categoryPlaceholderLabel.isHidden = false
            }
        }
    }

    let disposeBag = DisposeBag()
    var dispose:Disposable?

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
    
    func setupTimer()
    {
        // 取消定时器
        self.dispose?.dispose()
        
        let interval = Observable<Int>.interval(5, scheduler: MainScheduler.instance)

        dispose = interval.subscribe {[weak self] (event) in
            self?.animateTitle()
            }
        
        dispose?.disposed(by: disposeBag)
    }
    
    func animateTitle()
    {
        if categoryBgView.isHidden {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.categoryLabel1.alpha = 0
            self.categoryLabel2.alpha = 1
            self.categoryLabel1.frame.origin.y = -11
            self.categoryLabel2.frame.origin.y = 9
        }) { (_) in
            self.categoryLabel1.alpha = 1
            self.categoryLabel2.alpha = 0
            self.categoryLabel1.frame.origin.y = 9
            self.categoryLabel2.frame.origin.y = 29
        
            self.nextTitleIndex()
            self.updateTitleText()
        }
    }
    
    func updateTitleText() {
        if searchTitleIndex >= 0 && searchTitles.count > 0 && searchTitleIndex < searchTitles.count {
            self.categoryLabel1.text = searchTitles[searchTitleIndex]
            let tempIndex = (searchTitleIndex + 1) % searchTitles.count
            self.categoryLabel2.text = searchTitles[tempIndex]
        }
    }
    
    func nextTitleIndex()
    {
        if searchTitleIndex >= 0 && searchTitles.count > 0 && searchTitleIndex < searchTitles.count {
            self.searchTitleIndex = (searchTitleIndex + 1) % searchTitles.count
        }
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
            maker.width.equalTo(28)
        }
        countryLabel.sizeToFit()

        addSubview(triangleImage)
        triangleImage.snp.makeConstraints { [unowned countryLabel] maker in
            maker.left.equalTo(countryLabel.snp.right).offset(8)
            maker.centerY.equalToSuperview()
            maker.height.width.equalTo(10)
        }
    }

    private func setupVerticalLine() {
        addSubview(verticalLineView)
        verticalLineView.snp.makeConstraints { maker in
            maker.left.equalTo(triangleImage.snp.right).offset(11)
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
        
        addSubview(categoryPlaceholderLabel)
        categoryPlaceholderLabel.snp.makeConstraints { maker in
            maker.left.equalTo(verticalLineView.snp.right).offset(10)
            maker.height.equalTo(20)
            maker.right.equalTo(searchIconBackView.snp.left).offset(-2)
            maker.centerY.equalToSuperview()
        }
        
        addSubview(categoryBgView)
        
        categoryBgView.snp.makeConstraints { maker in
            maker.left.equalTo(verticalLineView.snp.right).offset(10)
            maker.height.equalTo(38)
            maker.right.equalTo(searchIconBackView.snp.left).offset(-2)
            maker.centerY.equalToSuperview()
        }
        
        categoryBgView.addSubview(categoryLabel1)
        categoryLabel1.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(9)
            maker.height.equalTo(20)
            maker.left.right.centerY.equalToSuperview()
        }
        
        categoryBgView.addSubview(categoryLabel2)
        categoryLabel2.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(29)
            maker.height.equalTo(20)
            maker.left.right.equalToSuperview()
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
