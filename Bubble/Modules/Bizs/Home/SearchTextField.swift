//
//  SearchTextField.swift
//  Lark
//
//  Created by 刘晚林 on 2017/3/25.
//  Copyright © 2017年 Bytedance.Inc. All rights reserved.
//

import UIKit

open class SearchTextField: UIControl {

    fileprivate(set) var input: UITextField!

    init() {
        super.init(frame: CGRect.zero)

        self.backgroundColor = UIColorRGB(244, 245, 246)
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true

        // 搜索框前面的图标
        let icon = UIImageView()
//        icon.image = Resources.search_icon
        self.addSubview(icon)
        icon.snp.makeConstraints({ make in
            make.size.equalTo(CGSize(width: 14, height: 14))
            make.left.equalTo(6)
            make.centerY.equalToSuperview()
        })

        // 搜索输入框
        let input = UITextField()
        if #available(iOS 8.2, *) {
            input.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
        } else {
            // Fallback on earlier versions
        }
        input.clearButtonMode = .always
        input.returnKeyType = .search
        self.addSubview(input)
        input.snp.makeConstraints({ make in
            make.left.equalTo(icon.snp.right).offset(6).priority(.high)
            make.right.top.bottom.equalToSuperview()
        })
        self.input = input
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
