//
//  SearchUITextField.swift
//  Lark
//
//  Created by 刘晚林 on 2017/5/16.
//  Copyright © 2017年 Bytedance.Inc. All rights reserved.
//

import UIKit

open class SearchUITextField: BaseTextField {
    public var canEdit: Bool = true {
        didSet {
            handleTapView.isUserInteractionEnabled = !canEdit
        }
    }
    private let handleTapView = UIView()

    public var tapBlock: ((SearchUITextField) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        handleTapView.backgroundColor = UIColor.clear
        handleTapView.isUserInteractionEnabled = false
        self.addSubview(handleTapView)
        handleTapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchFieldTapHandler))
        handleTapView.addGestureRecognizer(tapGesture)

        self.backgroundColor = UIColor.white
        self.font = UIFont.systemFont(ofSize: 16)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 6
        self.borderStyle = .none
        self.clearButtonMode = .always
        self.exitOnReturn = true

        let icon = UIImageView(image: #imageLiteral(resourceName: "searchpanel_icon"))
        icon.frame = CGRect(x: 9, y: 8, width: 18, height: 18)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        leftView.addSubview(icon)
        self.leftView = leftView
        self.leftViewMode = .always

        backgroundColor = UIColorRGB(244, 245, 246)
        placeholder = "搜索"
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    fileprivate func searchFieldTapHandler(_ sender: SearchTextField) {
        self.tapBlock?(self)
    }
}

open class SearchUITextFieldWrapperView: UIView {
    public let searchUITextField = SearchUITextField()

    public init() {
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor(white: 255.0 / 255.0, alpha: 1.0)

        addSubview(searchUITextField)
        searchUITextField.snp.makeConstraints({ make in
            make.top.equalTo(6)
            make.height.equalTo(38)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        })

        snp.makeConstraints { (make) in
            make.height.equalTo(58)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
