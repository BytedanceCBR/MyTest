//
// Created by linlin on 2018/7/9.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
class HouseDetailPageBottomBarView: UIView {

    lazy var favouriteBtn: UIButton = {
        let re = UIButton()
        re.setBackgroundImage(#imageLiteral(resourceName: "tab-collect"), for: .normal)
        re.setBackgroundImage(#imageLiteral(resourceName: "tab-collect-yellow"), for: .selected)
        return re
    }()

    lazy var favouriteLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(10)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.textAlignment = .center
        re.text = "关注"
        return re
    }()


    lazy var contactBtn: UIButton = {
        let re = UIButton()
        re.setTitleColor(UIColor.white, for: .normal)
        re.setTitle("电话咨询", for: .normal)
        re.backgroundColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        self.lu.addTopBorder()
        addSubview(favouriteBtn)
        favouriteBtn.snp.makeConstraints { maker in
            maker.left.equalTo(33)
            maker.top.equalTo(4)
            maker.height.width.equalTo(24)
        }

        addSubview(favouriteLabel)
        favouriteLabel.snp.makeConstraints { maker in
            maker.centerX.equalTo(favouriteBtn.snp.centerX)
            maker.top.equalTo(favouriteBtn.snp.bottom).offset(2)
            maker.height.equalTo(10)
            maker.bottom.equalTo(-4)
        }

        addSubview(contactBtn)
        contactBtn.snp.makeConstraints { maker in
            maker.top.right.bottom.equalToSuperview()
            maker.left.equalTo(favouriteBtn.snp.right).offset(33)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
