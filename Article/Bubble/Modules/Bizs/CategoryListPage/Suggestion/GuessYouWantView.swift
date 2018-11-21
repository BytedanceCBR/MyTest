//
//  GuessYouWantView.swift
//  Article
//
//  Created by 张元科 on 2018/11/21.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class GuessYouWantView: UIView {
    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return re
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addSubview(label)
        label.text = "123456"
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(10)
            maker.height.equalTo(100)
            maker.bottom.equalTo(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
