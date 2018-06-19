//
//  CategorySectionView.swift
//  Bubble
//
//  Created by linlin on 2018/6/15.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit

class CategorySectionView: UIView {

    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(16)
        label.textColor = hexStringToUIColor(hex: "#222222")
        label.text = "二手房源"
        return label
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.height.equalTo(22)
            maker.top.equalToSuperview().offset(16)
            maker.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
