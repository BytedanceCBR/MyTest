//
//  SimpleConfirmAlert.swift
//  Bubble
//
//  Created by linlin on 2018/7/23.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import SnapKit

func createPhoneConfirmAlert(
        title: String,
        subTitle: String,
        phoneNumber: String,
        bubbleAlertController: BubbleAlertController) -> SimpleConfirmAlert {
    bubbleAlertController.setCustomerTitlteView(title: title)
    let re = SimpleConfirmAlert()
    re.titleLabel.text = subTitle
    re.phoneLabel.text = EnvContext.shared.client.accountConfig.userInfo.value?.mobile ?? ""
    bubbleAlertController.setCustomerPanel(view: re)
    return re
}

class SimpleConfirmAlert: UIView {

    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#707070")
        re.numberOfLines = 0
        return re
    }()

    lazy var phoneLabelBg: UIView = {
        let re = UIView()
        re.backgroundColor = color(248, 86, 86, 0.1)
        re.layer.cornerRadius = 4
        return re
    }()

    lazy var phoneLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#f85656")
        re.textAlignment = .center
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        return re
    }()

    lazy var configBtn: UIButton = {
        let re = UIButton()
        re.backgroundColor = hexStringToUIColor(hex: "#f85656")
        let attriStr = NSAttributedString(
                string: "确认",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#ffffff")])
        re.setAttributedTitle(attriStr, for: .normal)
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.top.equalTo(17)
            maker.height.equalTo(48)
        }

        addSubview(phoneLabelBg)
        phoneLabelBg.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(14)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.height.equalTo(40)
        }

        phoneLabelBg.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.height.equalTo(17)
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
        }

        addSubview(configBtn)
        configBtn.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(46)
            maker.top.equalTo(phoneLabelBg.snp.bottom).offset(20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
