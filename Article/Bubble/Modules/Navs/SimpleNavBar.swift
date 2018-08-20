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

    lazy var bgView: UIView = {
        let re = UIView()
        re.alpha = 0.5
        return re
    }()

    lazy var backBtn: UIButton = {
        let btn = ExtendHotAreaButton()
        return btn
    }()

    lazy var title: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    lazy var rightBtn: UIButton = {
        let re = ExtendHotAreaButton()
        re.isHidden = true
        return re
    }()

    lazy var seperatorLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return re
    }()

    var gradientlayer: CAGradientLayer?

    init(backBtnImg: UIImage = #imageLiteral(resourceName: "icon-return"), hiddenMaskBtn: Bool = true) {
        super.init(frame: CGRect.zero)
        backBtn.setBackgroundImage(backBtnImg, for: .normal)

        addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }

        addSubview(backBtn)
        backBtn.snp.makeConstraints { maker in
            maker.left.equalTo(12)
            maker.width.height.equalTo(24)
            maker.bottom.equalTo(-10)
        }

        addSubview(rightBtn)
        rightBtn.snp.makeConstraints { maker in
            maker.centerY.equalTo(backBtn.snp.centerY)
            maker.width.height.equalTo(24).priority(.high)
            maker.right.equalTo(-12)
        }

        addSubview(title)
        title.snp.makeConstraints { maker in
            maker.centerY.equalTo(backBtn.snp.centerY)
            maker.left.equalTo(backBtn.snp.right).offset(10)
            maker.height.equalTo(28)
            maker.centerX.equalToSuperview()
            maker.right.equalTo(rightBtn.snp.left).priority(.low)
        }
        setGradientColor()

        addSubview(seperatorLine)
        seperatorLine.snp.makeConstraints { maker in
            maker.height.equalTo(0.5)
            maker.left.right.bottom.equalToSuperview()
         }
    }
    
    func setGradientColor() {
        removeGradientColor()
        title.isHidden = true
        seperatorLine.isHidden = true
        bgView.backgroundColor = UIColor.clear
        bgView.alpha = 0.5
        let topColor = color(0, 0, 0, 1)
        let bottomColor = color(0, 0, 0, 0)
        let gradientColors = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations:[NSNumber] = [0.0, 1.0]

        gradientlayer = CAGradientLayer()
        gradientlayer?.colors = gradientColors
        gradientlayer?.locations = gradientLocations
        gradientlayer?.frame = self.frame
        if let gradientlayer = gradientlayer {
            bgView.layer.insertSublayer(gradientlayer, at: 0)
        }

    }

    func removeGradientColor() {
        title.isHidden = false
        seperatorLine.isHidden = false
        gradientlayer?.removeFromSuperlayer()
        gradientlayer = nil
        bgView.backgroundColor = UIColor.white
        bgView.alpha = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientlayer?.frame = self.bounds
    }
}

class SearchNavBar: UIView {

    lazy var backBtn: UIButton = {
        let btn = ExtendHotAreaButton()
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
        result.returnKeyType = .search
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
            maker.bottom.equalTo(-10)
        }

        addSubview(searchAreaPanel)
        searchAreaPanel.snp.makeConstraints { maker in
            maker.left.equalTo(backBtn.snp.right).offset(2)
            maker.bottom.equalToSuperview().offset(-8)
            maker.right.equalToSuperview().offset(-15)
            maker.height.equalTo(28)
        }

        searchAreaPanel.addSubview(searchIcon)
        searchAreaPanel.addSubview(searchInput)
        
        searchIcon.snp.makeConstraints { maker in
            maker.left.equalTo(2)
            maker.height.width.equalTo(24)
            maker.centerY.equalTo(searchInput)
        }
        
        searchInput.snp.makeConstraints { maker in
            maker.left.equalTo(searchIcon.snp.right).offset(1)
            maker.right.equalToSuperview()
            maker.top.equalToSuperview().offset(5)
            maker.bottom.equalToSuperview().offset(-3)

        }

        searchAreaPanel.addSubview(searchAreaBtn)
        searchAreaBtn.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        self.lu.addBottomBorder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class CategorySearchNavBar: UIView {

    lazy var backBtn: UIButton = {
        let btn = ExtendHotAreaButton()
        btn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .normal)
        return btn
    }()

    lazy var searchAreaBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.clear
        return btn
    }()

    lazy var searchTypeBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = UIColor.clear
        return result
    }()

    lazy var searchTypeLabel: UILabel = {
        let result = UILabel()
        result.textColor = hexStringToUIColor(hex: "#505050")
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        return result
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
        result.returnKeyType = .search
        return result
    }()

    var searchable = false {
        didSet {
            searchAreaBtn.isHidden = searchable
        }
    }
    
    var canSelectType = true {
        didSet {
            triangleImage.isHidden = !canSelectType

        }
    }

    var isShowTypeSelector = false {
        didSet {
            self.adjustTypeSelector(isShowSelector: isShowTypeSelector)
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        addSubview(backBtn)
        backBtn.snp.makeConstraints { maker in
            maker.left.equalTo(12)
            maker.width.height.equalTo(24)
            maker.bottom.equalToSuperview().offset(-10)
        }

        addSubview(searchAreaPanel)
        searchAreaPanel.snp.makeConstraints { maker in
            maker.left.equalTo(backBtn.snp.right).offset(2)
            maker.bottom.equalToSuperview().offset(-8)
            maker.right.equalToSuperview().offset(-15)
            maker.height.equalTo(28)
        }

        searchAreaPanel.addSubview(searchTypeLabel)
        searchTypeLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(10)
            maker.top.equalTo(4)
            maker.bottom.equalToSuperview().offset(-4)
            maker.height.equalTo(20)
        }
        searchTypeLabel.sizeToFit()


        searchAreaPanel.addSubview(triangleImage)
        triangleImage.snp.makeConstraints { maker in
            maker.left.equalTo(searchTypeLabel.snp.right).offset(6).priority(.high)
//            maker.left.equalToSuperview().offset(58).priority(.medium)
            maker.height.width.equalTo(9)
            maker.centerY.equalToSuperview()
        }

        searchAreaPanel.addSubview(verticalLineView)
        verticalLineView.snp.makeConstraints { maker in
            maker.width.equalTo(2)
            maker.height.equalTo(15)
            maker.centerY.equalToSuperview()
            maker.left.equalTo(triangleImage.snp.right).offset(10)
        }

        searchAreaPanel.addSubview(searchTypeBtn)
        searchTypeBtn.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.right.equalTo(verticalLineView.snp.left)
        }

        searchAreaPanel.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { maker in
            maker.left.equalTo(verticalLineView.snp.right).offset(2)
            maker.top.equalTo(2)
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
            maker.right.top.bottom.equalToSuperview()
            maker.left.equalTo(searchIcon.snp.left)
        }
        self.lu.addBottomBorder()
    }
    
    
    func adjustTypeSelector(isShowSelector: Bool) {

        searchTypeLabel.isHidden = !isShowSelector
        triangleImage.isHidden = !isShowSelector
        verticalLineView.isHidden = !isShowSelector
        searchIcon.snp.remakeConstraints { maker in
            if isShowSelector {
                maker.left.equalTo(verticalLineView.snp.right).offset(2)
            } else {
                maker.left.equalToSuperview().offset(2)
            }

            maker.top.equalTo(2)
            maker.height.width.equalTo(24)
        }

//        searchInput.snp.makeConstraints { maker in
//            maker.left.equalTo(searchIcon.snp.right).offset(1)
//            maker.right.equalToSuperview()
//            maker.top.equalToSuperview().offset(5)
//            maker.bottom.equalToSuperview().offset(-3)
//            maker.height.equalTo(20)
//        }
//
//        searchAreaBtn.snp.makeConstraints { maker in
//            maker.right.top.bottom.equalToSuperview()
//            maker.left.equalTo(searchIcon.snp.left)
//        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ExtendHotAreaButton: UIButton {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds = self.bounds
        let widthDelta = bounds.width
        let heightDelta = bounds.height
        bounds = bounds.insetBy(dx: -1 * widthDelta, dy: -1 * heightDelta)
        return bounds.contains(point)
    }

}
