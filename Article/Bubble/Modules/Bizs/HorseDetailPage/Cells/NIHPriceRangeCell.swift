//
//  NIHPriceRangeCell.swift
//  Article
//
//  Created by 张静 on 2018/8/28.
//

import UIKit

class NIHPriceRangeCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "NIHPriceRangeCell"
    }
    lazy var tipLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.numberOfLines = 0
        return re
    }()
    
    lazy var maxView: UIView = {
        let re = UIView()
        return re
    }()
    
    lazy var maxLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#a1aab3")
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.text = "最高参考价"
        return re
    }()
    lazy var maxPriceLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        re.font = CommonUIStyle.Font.pingFangMedium(12)
        return re
    }()
    
    lazy var currentView: UIView = {
        let re = UIView()
        return re
    }()
    lazy var currentLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#a1aab3")
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.text = "当前单价"
        return re
    }()
    lazy var currentPriceLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#299cff")
        re.font = CommonUIStyle.Font.pingFangMedium(12)
        return re
    }()
    
    lazy var minView: UIView = {
        let re = UIView()
        return re
    }()
    lazy var minLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#a1aab3")
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.text = "最低参考价"
        return re
    }()
    lazy var minPriceLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#8a9299")
        re.font = CommonUIStyle.Font.pingFangMedium(12)
        return re
    }()

    lazy var minLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#299cff", alpha: 0.2)
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        return re
    }()
    
    lazy var currentLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#299cff")
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        return re
    }()
    
    lazy var maxLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#299cff", alpha: 0.2)
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        return re
    }()

    func setPriceRange(priceRange: HousePriceRange) {

        maxView.isHidden = true
        currentView.isHidden = true
        minView.isHidden = true

        if let maxPrice = priceRange.price_max, maxPrice > 0 {
            maxPriceLabel.text = "\(maxPrice / 100)元/平"
            maxView.isHidden = false
            maxView.snp.updateConstraints { (maker) in
                maker.height.equalTo(46)
            }
        }else {
            maxView.snp.updateConstraints { (maker) in
                maker.height.equalTo(0)
            }
        }
        if let currentPrice = priceRange.cur_price, currentPrice > 0 {
            currentPriceLabel.text = "\(currentPrice / 100)元/平"
            currentView.isHidden = false
            currentView.snp.updateConstraints { (maker) in
                maker.height.equalTo(46)
            }
        }else {
            currentView.snp.updateConstraints { (maker) in
                maker.height.equalTo(0)
            }
        }
        if let minPrice = priceRange.price_min, minPrice > 0  {
            minPriceLabel.text = "\(minPrice / 100)元/平"
            minView.isHidden = false
            minView.snp.updateConstraints { (maker) in
                maker.height.equalTo(46)
            }
        }else {
            minView.snp.updateConstraints { (maker) in
                maker.height.equalTo(0)
            }
        }
        
        var theMaxPrice = 0
        var tipStr: String?
        
        if let maxPrice = priceRange.price_max, let currentPrice = priceRange.cur_price, let minPrice = priceRange.price_min {
            
            if currentPrice <= minPrice {
                tipStr = "该房源当前价格偏低，请勿错过入手好时机，建议尽快联系经纪人看房。"
            }else if currentPrice > minPrice && currentPrice < maxPrice {
                tipStr = "该房源当前价格合理，房东诚心出售，建议尽快联系经纪人看房。"
            }else {
                tipStr = "该房源当前价格偏高，请结合综合情况合理评估，详情咨询经纪人。"
            }
        }

        tipLabel.text = tipStr
        
        if let maxPrice = priceRange.price_max, maxPrice > theMaxPrice {
            
           theMaxPrice = maxPrice
        }
        if let currentPrice = priceRange.cur_price, currentPrice > theMaxPrice {
            
            theMaxPrice = currentPrice
        }
        if let minPrice = priceRange.price_min, minPrice > theMaxPrice {
            
            theMaxPrice = minPrice
        }
        
        var lineWidth = Double(180 * CommonUIStyle.Screen.widthScale)
        if UIScreen.main.bounds.width < 375 {
            lineWidth = Double(150 * CommonUIStyle.Screen.widthScale)
        }
        if theMaxPrice > 0 {
    
            let maxPercent = Double(priceRange.price_max ?? 0) / Double(theMaxPrice)
            maxLine.snp.updateConstraints { maker in
                maker.width.equalTo(lineWidth * maxPercent)
            }
            
            let currentPercent = Double(priceRange.cur_price ?? 0) / Double(theMaxPrice)
            currentLine.snp.updateConstraints { maker in
                maker.width.equalTo(lineWidth * currentPercent)
            }
            
            let minPercent = Double(priceRange.price_min ?? 0) / Double(theMaxPrice)
            minLine.snp.updateConstraints { maker in
                maker.width.equalTo(lineWidth * minPercent)
            }
        }else {
            
            maxLine.snp.updateConstraints { maker in
                maker.width.equalTo(0)
            }
            currentLine.snp.updateConstraints { maker in
                maker.width.equalTo(0)
            }
            minLine.snp.updateConstraints { maker in
                maker.width.equalTo(0)
            }
        }
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(tipLabel)
        
        addSubview(maxView)
        addSubview(currentView)
        addSubview(minView)
        
        maxView.addSubview(maxLabel)
        maxView.addSubview(maxLine)
        maxView.addSubview(maxPriceLabel)
    
        currentView.addSubview(currentLabel)
        currentView.addSubview(currentLine)
        currentView.addSubview(currentPriceLabel)

        minView.addSubview(minLabel)
        minView.addSubview(minLine)
        minView.addSubview(minPriceLabel)

        tipLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(-10)
            maker.top.equalToSuperview()
        }
        
        maxView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(tipLabel.snp.bottom)
            maker.height.equalTo(0)
        }
        
        currentView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(maxView.snp.bottom)
            maker.height.equalTo(0)
        }
        
        minView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(currentView.snp.bottom)
            maker.height.equalTo(0)
            maker.bottom.equalToSuperview().offset(-30)

        }
        
        maxLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(30)
        }
        maxLine.snp.makeConstraints { maker in
            maker.left.equalTo(90)
            maker.top.bottom.equalTo(maxLabel)
            maker.width.equalTo(0)
        }
        maxPriceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(maxLine.snp.right).offset(11)
            maker.centerY.equalTo(maxLabel)
            maker.trailing.equalToSuperview().offset(-10)
        }
        
        currentLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(30)
        }
        currentLine.snp.makeConstraints { maker in
            maker.left.equalTo(90)
            maker.top.bottom.equalTo(currentLabel)
            maker.width.equalTo(0)
        }
        currentPriceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(currentLine.snp.right).offset(11)
            maker.centerY.equalTo(currentLabel)
            maker.trailing.equalToSuperview().offset(-10)
        }
        
        minLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(30)
        }
        minLine.snp.makeConstraints { maker in
            maker.left.equalTo(90)
            maker.top.bottom.equalTo(minLabel)
            maker.width.equalTo(0)
        }
        minPriceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(minLine.snp.right).offset(11)
            maker.centerY.equalTo(minLabel)
            maker.trailing.equalToSuperview().offset(-10)
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


func parsePriceRangeNode(_ priceRange: HousePriceRange?, traceExtension: TracerParams = TracerParams.momoid()) -> () -> TableSectionNode? {
    return {
        
        if let thePriceRange = priceRange {

            if thePriceRange.price_min ?? 0 == 0 && thePriceRange.price_max ?? 0 == 0 {
                
                return nil
            }
            let cellRender = oneTimeRender(curry(fillPriceRangeCell)(thePriceRange))
            let params = TracerParams.momoid() <|>
            toTracerParams("price_reference", key: "element_type") <|>
            toTracerParams("old_detail", key: "page_type") <|>
            traceExtension
            
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: NIHPriceRangeCell.identifier))
            
        }else {
            
            return nil
        }
    }
}

func fillPriceRangeCell(
    _ data: HousePriceRange,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NIHPriceRangeCell {

        theCell.setPriceRange(priceRange: data)
    }
    
}


