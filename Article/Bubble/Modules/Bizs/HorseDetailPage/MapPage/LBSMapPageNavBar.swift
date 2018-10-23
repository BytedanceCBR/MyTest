//
// Created by leo on 2018/7/26.
//

import Foundation

class LBSMapPageNavBar: UIView {

    lazy var backBtn: ExtendHotAreaButton = {
        let btn = ExtendHotAreaButton()
        return btn
    }()

    lazy var title: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    lazy var rightBtn: UIButton = {
        let re = UIButton()
        return re
    }()

    lazy var seperatorLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
        return re
    }()


    init(backBtnImg: UIImage = #imageLiteral(resourceName: "icon-return")) {
        super.init(frame: CGRect.zero)
        backBtn.setBackgroundImage(backBtnImg, for: .normal)
        backBtn.setBackgroundImage(#imageLiteral(resourceName: "icon-return"), for: .highlighted)

        addSubview(backBtn)
        backBtn.snp.makeConstraints { maker in
            maker.left.equalTo(12)
            maker.width.height.equalTo(24)
            maker.bottom.equalTo(-10)
        }

        addSubview(rightBtn)
        rightBtn.snp.makeConstraints { maker in
            maker.centerY.equalTo(backBtn.snp.centerY)
            maker.right.equalTo(-12)
            maker.height.equalTo(24)
        }

        addSubview(title)
        title.snp.makeConstraints { maker in
            maker.left.greaterThanOrEqualTo(backBtn.snp.right).offset(10)
            maker.centerY.equalTo(backBtn.snp.centerY)
            maker.height.equalTo(28)
            maker.centerX.equalToSuperview()
            maker.right.lessThanOrEqualTo(rightBtn.snp.left).offset(-10).priority(.high)
        }

        addSubview(seperatorLine)
        seperatorLine.snp.makeConstraints { maker in
            maker.height.equalTo(0.5)
            maker.left.right.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
