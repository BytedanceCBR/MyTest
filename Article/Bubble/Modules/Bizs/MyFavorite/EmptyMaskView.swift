//
// Created by linlin on 2018/7/22.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
class EmptyMaskView: UIView {

    lazy var icon: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "group-9")
        return re
    }()

    lazy var label: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#cacaca")
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        return re
    }()

    lazy var contentView: UIView = {
        let re = UIView()
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(-20)
            maker.width.equalToSuperview()
        }

        contentView.addSubview(icon)
        icon.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.width.height.equalTo(126)
            maker.top.equalToSuperview()
        }

        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(icon.snp.bottom).offset(10)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(20)
            maker.bottom.equalToSuperview()
        }

        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
