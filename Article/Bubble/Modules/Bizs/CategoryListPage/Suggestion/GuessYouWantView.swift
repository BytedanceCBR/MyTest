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
                label.isHidden = false
            }
        }
    }
    
    var guessYouWangtViewHeight:CGFloat = 138 // 默认是2行
    
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
        label.isHidden = true
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
        tempViews.removeAll()
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
                trackShowEventData(item: item,rank: button.tag)
            }
            currentIndex += 1
        }
    }
    
    func guessYouWantTextLength(text:String) -> CGFloat {
        let button = GuessYouWantButton()
        button.label.text = text
        var size = button.label.sizeThatFits(CGSize(width: 121, height: 17))
        if size.width > 120 {
            size.width = 120
        }
        size.width += 12
        return size.width
    }
    
    func firstLineGreaterThanSecond(firstText:String, array:Array<GuessYouWant>, count:Int = 1) -> Array<GuessYouWant> {
        var remainWidth:CGFloat = UIScreen.main.bounds.width - 40
        let firstWordLength = guessYouWantTextLength(text: firstText)
        var firstLineLen:CGFloat = (firstWordLength + 10)
        var secondLineLen:CGFloat = 0
        var line:Int = 1
        remainWidth -= (firstWordLength + 10)
        if firstText.count == 0 {
            firstLineLen = 0
            remainWidth = UIScreen.main.bounds.width - 40
        }
        var vArray = array
        var retArray:[GuessYouWant] = []
        while vArray.count > 0 {
            if let item = vArray.first {
                if let text = item.text {
                    let len = guessYouWantTextLength(text: text)
                    if len > remainWidth {
                        var findIndex:Int = -1
                        if remainWidth >= 24 {
                            for index in 0 ..< vArray.count {
                                // 找满足长度的数据
                                let remainItem = vArray[index]
                                let remainLen = guessYouWantTextLength(text: remainItem.text ?? "")
                                if remainLen <= remainWidth {
                                    // 找到
                                    findIndex = index
                                    remainWidth -= (remainLen + 10)
                                    
                                    if line == 1 {
                                        firstLineLen += (remainLen + 10)
                                    } else if line == 2 {
                                        secondLineLen += (remainLen + 10)
                                    }
                                    vArray.remove(at: findIndex)
                                    retArray.append(remainItem)
                                    break;
                                }
                            }
                        }
                        
                        if findIndex >= 0 {
                            continue
                        } else {
                            if line >= 2 {
                                break
                            }
                            line += 1
                            remainWidth = UIScreen.main.bounds.width - 40
                        }
                    }
                    remainWidth -= (len + 10)
                    
                    if line == 1 {
                        firstLineLen += (len + 10)
                    } else if line == 2 {
                        secondLineLen += (len + 10)
                    }
                }
                vArray.remove(at: 0)
                retArray.append(item)
            }
        }
        if line >= 2 {
            guessYouWangtViewHeight = 138
        } else {
            // 只有1行数据需要展示
            guessYouWangtViewHeight = 99
        }
        if firstLineLen >= secondLineLen {
            return retArray
        } else {
            if count > 8 {
                retArray.removeLast()
                return retArray
            }
            var tempArrayData = array
            let tempArray = tempArrayData.fd_randamArray()
            return self.firstLineGreaterThanSecond(firstText:firstText, array:tempArray, count:count+1)
        }
    }
    
    @objc func buttonClick(btn:UIButton) {
        let tag = btn.tag
        if tag >= 0 && tag < guessYouWantItems.count {
            let item = guessYouWantItems[tag]
            if onGuessYouWantItemClick != nil {
                onGuessYouWantItemClick!(item)
                trackClickEventData(item: item, rank: tag)
            }
        }
    }
    
    func trackShowEventData(item:GuessYouWant, rank:Int)
    {
        let pramas = TracerParams.momoid() <|>
            toTracerParams(item.text ?? "be_null", key: "word") <|>
            toTracerParams(item.guessSearchId ?? "be_null", key: "word_id") <|>
            toTracerParams(wordTypeFor(item.guessSearchType), key: "word_type") <|>
            toTracerParams(rank, key: "rank")
        
        recordEvent(key: "hot_word_show", params: pramas)
    }
    
    func trackClickEventData(item:GuessYouWant, rank:Int) {
        let pramas = TracerParams.momoid() <|>
            toTracerParams(item.text ?? "be_null", key: "word") <|>
            toTracerParams(item.guessSearchId ?? "be_null", key: "word_id") <|>
            toTracerParams(wordTypeFor(item.guessSearchType), key: "word_type") <|>
            toTracerParams(rank, key: "rank")
        
        recordEvent(key: "hot_word_click", params: pramas)
    }
    
    func wordTypeFor(_ searchType:Int) -> String {
        switch searchType {
        case 1:
            return "operation"
        case 2:
            return "hot"
        case 3:
            return "history"
        default:
            return "be_null"
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

extension Array {
    mutating func fd_randamArray() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        self = list
        return list
    }
}
