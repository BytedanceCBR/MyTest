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
    
    var guessYouWantItems:[GuessYouWant] = [] {
        didSet {
            self.isHidden = guessYouWantItems.count <= 0
            if guessYouWantItems.count > 0 {
                reAddViews()
            }
        }
    }
    
    var onGuessYouWantItemClick: ((GuessYouWant) -> Void)?
    
    var tempViews:[UIView] = []
    
    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.text = "猜你想搜"
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(20)
            maker.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reAddViews() {
        for v in tempViews {
            v.removeFromSuperview()
        }
        var line:Int = 1
        var lastTopOffset:CGFloat = 50
        var leftView:UIView = self
        var remainWidth = UIScreen.main.bounds.width - 40
        var currentIndex:Int = 0
        var isFirtItem:Bool = true
        
        for item in guessYouWantItems {
            if let text = item.text {
                let button = GuessYouWantButton()
                button.label.text = text
                var size = button.label.sizeThatFits(CGSize(width: 121, height: 17))
                if size.width > 120 {
                    size.width = 120
                }
                size.width += 12
                button.tag = currentIndex
                button.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
                if size.width > remainWidth {
                    // 下一行
                    if line >= 2 {
                        // 已经添加完成
                        break
                    }
                    line += 1
                    lastTopOffset = 89
                    leftView = self
                    isFirtItem = true
                    remainWidth = UIScreen.main.bounds.width - 40
                }
                remainWidth -= (size.width + 10)
                self.addSubview(button)
                // 布局
                button.snp.makeConstraints { (maker) in
                    if isFirtItem {
                        maker.left.equalToSuperview().offset(20)
                    } else {
                        maker.left.equalTo(leftView.snp.right).offset(10)
                    }
                    maker.top.equalToSuperview().offset(lastTopOffset)
                    maker.width.equalTo(size.width)
                    maker.height.equalTo(29)
                }
                isFirtItem = false
                leftView = button
                tempViews.append(button)
            }
            currentIndex += 1
        }
    }
    
    @objc func buttonClick(btn:UIButton) {
        let tag = btn.tag
        if tag >= 0 && tag < guessYouWantItems.count {
            let item = guessYouWantItems[tag]
            if onGuessYouWantItemClick != nil {
                onGuessYouWantItemClick!(item)
            }
        }
    }
}

class GuessYouWantButton: UIButton {
    
    lazy var label: UILabel = {
        let re = UILabel()
        re.numberOfLines = 1
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        self.layer.cornerRadius = 4.0
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.top.equalToSuperview().offset(6)
            maker.bottom.right.equalToSuperview().offset(-6)
            maker.width.lessThanOrEqualTo(120)
            maker.height.equalTo(17)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
