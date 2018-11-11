//
//  FHErshouDetailPriceRankCell.swift
//  Article
//
//  Created by 张静 on 2018/11/11.
//

import UIKit

class FHErshouDetailPriceRankCell: BaseUITableViewCell {

    fileprivate func setPriceRank(priceRank: HousePriceRank?) {
    
        // add by zjing for test

//        var text = "\(priceRank.position ?? 0 / total)"
        let attributeText = NSMutableAttributedString()
        
        let attr1 = NSMutableAttributedString(string: "1/")
        attr1.yy_font = CommonUIStyle.Font.pingFangRegular(16)
        attributeText.append(attr1)

        let attr2 = NSMutableAttributedString(string: "23")
        attr2.yy_font = CommonUIStyle.Font.pingFangRegular(12)
        attributeText.append(attr2)
        rankLabel.attributedText = attributeText
        
//        if let total = priceRank.total, total > 0 {
//
//            rankLabel.text = "\(priceRank.position ?? 0 / total)"
//        }
//        subtitleLabel.text = priceRank.analyseDetail
        
        
        
//        rankLabel.text = "1/23"
        subtitleLabel.text = "对照组：二手房详情页线上+部分字段及教育资源补\n实验组A：二手房有小区评测，小区详情页有小区评测\n实验组B：二手房详情页补充房源概况"

        let subAttr = NSMutableAttributedString(string: "对照组：二手房详情页线上+部分字段及教育资源补\n实验组A：二手房有小区评测，小区详情页有小区评测\n实验组B：二手房详情页补充房源概况")
        subAttr.yy_lineSpacing = 6
        subtitleLabel.attributedText = subAttr
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
    }
    
    private func setupUI() {
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
        }
        bgView.layer.cornerRadius = 4
        bgView.layer.masksToBounds = true
        
        bgView.addSubview(tipLabel)
        bgView.addSubview(rankLabel)

        tipLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalToSuperview()
            maker.height.equalTo(50)
        }
        rankLabel.snp.makeConstraints { maker in
            maker.right.equalTo(-15)
            maker.top.equalToSuperview()
            maker.height.equalTo(tipLabel)
        }
        bgView.addSubview(line)
        line.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(tipLabel.snp.bottom)
//            maker.height.equalTo(TTDeviceHelper.ssOnePixel())
            maker.height.equalTo(1)

        }
        
        bgView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(line.snp.bottom).offset(17)
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.bottom.equalTo(-17)
        }
    }
    
    open override class var identifier: String {
        return "FHErshouDetailPriceRankCell"
    }
    
    lazy var bgView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHPaleGreyColor, alpha: 0.4)
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        return re
    }()
    
    lazy var tipLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.text = "同小区同户型挂牌价排名"
        return re
    }()
    
    lazy var rankLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        return re
    }()
    
    lazy var line: UIView = {
        let re = UIView()
        re.backgroundColor = .white
        return re
    }()
    
    lazy var subtitleLabel: UILabel = {
        let re = UILabel()
        re.textColor = hexStringToUIColor(hex: "#737a80")
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.numberOfLines = 0
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

func parsePriceRankNode(_ priceRank: HousePriceRank?, traceExtension: TracerParams = TracerParams.momoid()) -> () -> TableSectionNode? {
    return {
        
        // add by zjing for test
//        if let thePriceRank = priceRank {

            let cellRender = oneTimeRender(curry(fillPriceRankCell)(nil))
            let params = TracerParams.momoid() <|>
                toTracerParams("price_reference", key: "element_type") <|>
                toTracerParams("old_detail", key: "page_type") <|>
            traceExtension
            
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: FHErshouDetailPriceRankCell.identifier))
            
//        }else {
//
//            return nil
//        }
    }
}

func fillPriceRankCell(
    _ data: HousePriceRank?,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FHErshouDetailPriceRankCell {
        
        theCell.setPriceRank(priceRank: data)
    }
    
}

