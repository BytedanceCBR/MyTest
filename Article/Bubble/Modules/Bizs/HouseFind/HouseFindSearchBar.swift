//
//  HouseFindSearchBar.swift
//  Article
//
//  Created by leo on 2018/9/19.
//

import Foundation
import SnapKit
class HouseFindSearchBar: UIView {

    lazy var searchIcon: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "icon-search-titlebar")
        return re
    }()

    lazy var searchPlaceHolderLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        re.text = "你想住在哪?"
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 4
        self.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")

        addSubview(searchIcon)
        searchIcon.snp.makeConstraints { maker in
            maker.height.width.equalTo(16)
            maker.centerY.equalToSuperview()
            maker.left.equalTo(14)
        }

        addSubview(searchPlaceHolderLabel)
        searchPlaceHolderLabel.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.height.equalTo(20)
            maker.left.equalTo(searchIcon.snp.right).offset(9)
            maker.right.equalTo(-15)
        }
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
