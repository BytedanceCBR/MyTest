//
// Created by linlin on 2018/7/9.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
class HouseDetailPageBottomBarView: UIView {

    lazy var contactBtn: UIButton = {
        let re = UIButton()
        re.setTitleColor(UIColor.white, for: .normal)
        re.setAttributedTitle(
            attributeText("电话咨询",
                          color: UIColor.white,
                          font: CommonUIStyle.Font.pingFangRegular(16)),
            for: .normal)
        re.layer.cornerRadius = 22
        re.backgroundColor = hexStringToUIColor(hex: "#299cff")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        self.lu.addTopBorder()
        addSubview(contactBtn)
        contactBtn.snp.makeConstraints { maker in
            maker.top.equalTo(10)
            maker.bottom.equalTo(-10)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.height.equalTo(44)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
