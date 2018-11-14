//
//  FHDetailSuggestTipCell.swift
//  Article
//
//  Created by 张静 on 2018/11/6.
//

import UIKit

class FHDetailSuggestTipCell: BaseUITableViewCell {

    
    func setBuySuggestion(suggestion: HousePriceRankSuggestion) {
        
        trendIcon.isHidden = true
        if let type = suggestion.type {
            
            subtitleLabel.text = suggestion.content
            trendIcon.isHidden = false

            if type == 1 {
                trendIcon.image = UIImage(named: "sentiment-satisfied-material")
            }else if type == 2 {
                trendIcon.image = UIImage(named: "sentiment-neutral-material")

            }else if type == 2 {
                trendIcon.image = UIImage(named: "sentiment-dissatisfied-material")
            }
        }
        
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
  
    }
    
    private func setupUI() {
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.left.top.equalTo(20)
            maker.right.bottom.equalTo(-20)
        }
        bgView.layer.cornerRadius = 4
        bgView.layer.masksToBounds = true
        
        trendIcon.isHidden = true
        bgView.addSubview(trendIcon)
        trendIcon.snp.makeConstraints { maker in
            maker.top.bottom.right.equalToSuperview()
        }
        
        bgView.addSubview(tipBgView)
        bgView.addSubview(tipLabel)
        
        tipBgView.snp.makeConstraints { maker in
            maker.top.equalTo(10)
            maker.left.equalTo(-4)
            maker.right.equalTo(tipLabel.snp.right).offset(12)
            maker.bottom.equalTo(tipLabel.snp.bottom).offset(3)
        }
        tipLabel.snp.makeConstraints { maker in
            maker.top.equalTo(tipBgView).offset(3)
            maker.left.equalTo(tipBgView).offset(15)
        }
        
        bgView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(tipBgView.snp.bottom).offset(10)
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.bottom.equalTo(-15)
        }
    }
    
    open override class var identifier: String {
        return "FHDetailSuggestTipCell"
    }
    
    lazy var tipBgView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHClearBlueColor)
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        return re
    }()
    
    lazy var tipLabel: UILabel = {
        let re = UILabel()
        re.textColor = .white
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.text = "购房小建议"
        return re
    }()
    
    lazy var subtitleLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: kFHMutedBlueColor)
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.numberOfLines = 0
        return re
    }()
    
    lazy var trendIcon: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFill
        re.image = UIImage(named: "sentiment-satisfied-material")
        return re
    }()
    
    lazy var bgView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f0f8ff")
        return re
    }()
    
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

func parsePriceRangeNode(_ priceRank: HousePriceRank?, traceExtension: TracerParams = TracerParams.momoid()) -> () -> TableSectionNode? {
    return {
        
        var buySuggestion: HousePriceRankSuggestion?
        if let thePriceRank = priceRank {
            buySuggestion = thePriceRank.buySuggestion
        }
        
        var suggestion: HousePriceRankSuggestion = HousePriceRankSuggestion()
        suggestion.type = 2
        suggestion.content = "该房源当前价格合理，房东诚心出售，建议尽快联系经纪人看房"
        
        let cellRender = oneTimeRender(curry(fillPriceRangeCell)(buySuggestion ?? suggestion))
        let params = TracerParams.momoid() <|>
            toTracerParams("price_reference", key: "element_type") <|>
            toTracerParams("old_detail", key: "page_type") <|>
        traceExtension
        
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: [elementShowOnceRecord(params: params)],
            label: "",
            type: .node(identifier: FHDetailSuggestTipCell.identifier))
        
    }
}

func fillPriceRangeCell(
    _ data: HousePriceRankSuggestion,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FHDetailSuggestTipCell {
        
        theCell.setBuySuggestion(suggestion: data)
    }
    
}


