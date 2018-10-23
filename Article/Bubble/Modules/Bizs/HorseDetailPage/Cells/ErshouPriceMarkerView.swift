//
//  ErshouPriceMarkerView.swift
//  Article
//
//  Created by 张静 on 2018/8/8.
//

import UIKit
import Charts

class ErshouPriceMarkerView: MarkerView {

    var markerData: ((Int) -> ([(String,TrendItem)]))?

    var selectIndex: Int = 0
    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.lineBreakMode = .byTruncatingTail
        re.textColor = .white
        
        return re
    }()
    
    lazy var firstLabel: UILabel = {
        let re = UILabel()
        re.lineBreakMode = .byTruncatingTail
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = .white

        return re
    }()
    
    lazy var secondLabel: UILabel = {
        let re = UILabel()
        re.lineBreakMode = .byTruncatingTail
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = .white
        
        return re
    }()
    
    lazy var thirdLabel: UILabel = {
        let re = UILabel()
        re.lineBreakMode = .byTruncatingTail
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = .white
        
        return re
    }()
    
    
    public override func awakeFromNib() {

        self.addSubview(titleLabel)
        self.addSubview(firstLabel)
        self.addSubview(secondLabel)
        self.addSubview(thirdLabel)
        
        self.backgroundColor = hexStringToUIColor(hex: "#000000",alpha: 0.8)
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        
        titleLabel.snp.makeConstraints { maker in
            
            maker.top.equalToSuperview().offset(10)
            maker.left.equalTo(10)

        }
        firstLabel.snp.makeConstraints { maker in
            
            maker.top.equalTo(titleLabel.snp.bottom).offset(5)
            maker.left.equalTo(10)

        }
        secondLabel.snp.makeConstraints { maker in
            
            maker.top.equalTo(firstLabel.snp.bottom).offset(2)
            maker.left.equalTo(10)

        }
        thirdLabel.snp.makeConstraints { maker in
            
            maker.top.equalTo(secondLabel.snp.bottom).offset(2)
            maker.left.equalTo(10)

        }
        
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()

        let maxWidth = max(titleLabel.width, firstLabel.width, secondLabel.width, thirdLabel.width) + 20
        
        self.width = maxWidth
        
        titleLabel.width = self.width - 20
        firstLabel.width = self.width - 20
        secondLabel.width = self.width - 20
        thirdLabel.width = self.width - 20
  
        self.height = thirdLabel.bottom + 10
        if selectIndex < 3 {
            
            self.offset = CGPoint(x: 10, y: -self.height)
        }else {
            self.offset = CGPoint(x: -self.width - 10, y: -self.height)
        }

    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        if let index = entry.data as? Int {

            firstLabel.text = nil
            secondLabel.text = nil
            thirdLabel.text = nil
            
            guard let markerData = self.markerData else { return }
            selectIndex = index
            let items = markerData(index)
            guard items.count > 0 else { return }

            if items.count > 0 {

                let (name,item) = items.first!
                titleLabel.text = item.timeStr
                
                var trendName:String? = name
                if name.count > 7 {
                    trendName = name.prefix(7) + "..."
                }
                let price:Double = (Double(item.price ?? "") ?? 0.00) / 1000000.00
                firstLabel.text = "\(trendName ?? "")：\(String(format: "%.2f", price))万元/平"
            }
            if items.count > 1 {

                let (name,item) = items[1]
                titleLabel.text = item.timeStr
                var trendName:String? = name
                if name.count > 7 {
                    trendName = name.prefix(7) + "..."
                }
                let price:Double = (Double(item.price ?? "") ?? 0.00) / 1000000.00
                secondLabel.text = "\(trendName ?? "")：\(String(format: "%.2f", price))万元/平"
            }
            if items.count > 2 {

                let (name,item) = items[2]
                titleLabel.text = item.timeStr
                var trendName:String? = name
                if name.count > 7 {
                    trendName = name.prefix(7) + "..."
                }
                let price:Double = (Double(item.price ?? "") ?? 0.00) / 1000000.00
                thirdLabel.text = "\(trendName ?? "")：\(String(format: "%.2f", price))万元/平"
                
            }
            
            setNeedsLayout()
            layoutIfNeeded()


        }

    }

}

