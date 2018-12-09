//
//  FHAlertView.swift
//  NewsLite
//
//  Created by linlin on 2018/12/6.
//

import Foundation
import SnapKit
class FHAlertView: UIView {
    lazy var cycleIndicatorView: CycleIndicatorView = {
        let re = CycleIndicatorView()
        re.startAnimating()
        return re
    }()

    lazy var message: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = UIColor.white
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 4
        self.backgroundColor = color(8, 31, 51, 0.96)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(cycleIndicatorView)
        addSubview(message)
        cycleIndicatorView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
            make.height.width.equalTo(24)
        }

        message.snp.makeConstraints { (make) in
            make.left.equalTo(cycleIndicatorView.snp.right).offset(4)
            make.centerY.equalTo(cycleIndicatorView.snp.centerY)
            make.height.equalTo(20)
            make.right.equalTo(-20)
        }
    }
}
