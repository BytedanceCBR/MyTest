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

    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.lineBreakMode = .byTruncatingTail
        re.textColor = hexStringToUIColor(hex: "#505050")
        
        return re
    }()
    
    lazy var firstLabel: UILabel = {
        let re = UILabel()
        re.lineBreakMode = .byTruncatingTail
        re.font = CommonUIStyle.Font.pingFangRegular(11)
        re.textColor = hexStringToUIColor(hex: "#505050")
        
        return re
    }()
    
    lazy var secondLabel: UILabel = {
        let re = UILabel()
        re.lineBreakMode = .byTruncatingTail
        re.font = CommonUIStyle.Font.pingFangRegular(11)
        re.textColor = hexStringToUIColor(hex: "#505050")
        
        return re
    }()
    
    lazy var thirdLabel: UILabel = {
        let re = UILabel()
        re.lineBreakMode = .byTruncatingTail
        re.font = CommonUIStyle.Font.pingFangRegular(11)
        re.textColor = hexStringToUIColor(hex: "#505050")
        
        return re
    }()
    
    
    public override func awakeFromNib() {

        self.addSubview(titleLabel)
        self.addSubview(firstLabel)
        self.addSubview(secondLabel)
        self.addSubview(thirdLabel)
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = hexStringToUIColor(hex: "#ffaf45").cgColor
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
        
        self.width = maxWidth < 180 ? maxWidth: 180
        
        titleLabel.width = self.width - 20
        firstLabel.width = self.width - 20
        secondLabel.width = self.width - 20
        thirdLabel.width = self.width - 20
  
        self.height = thirdLabel.bottom + 10
        
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        if let index = entry.data as? Int {

            guard let markerData = self.markerData else { return }
            
            let items = markerData(index)
            guard items.count > 0 else { return }
            

            if items.count > 0 {

                let (name,item) = items.first!
                titleLabel.text = item.timeStr
                
                let price:Int = (Int(item.price ?? "") ?? 0) / 100
                firstLabel.text = "\(name)：\(price)元/平"
            }
            if items.count > 1 {

                let (name,item) = items[1]
                let price:Int = (Int(item.price ?? "") ?? 0) / 100
                secondLabel.text = "\(name)：\(price)元/平"
            }
            if items.count > 2 {

                let (name,item) = items[2]
                let price:Int = (Int(item.price ?? "") ?? 0) / 100
                thirdLabel.text = "\(name)：\(price)元/平"
                
            }
            
            setNeedsLayout()
            layoutIfNeeded()


        }



    }
    
    

}

