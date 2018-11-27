//
//  PriceChangeHistoryCell.swift
//  Article
//
//  Created by 张元科 on 2018/11/25.
//

import UIKit
import SnapKit

class PriceChangeHistoryCell: BaseUITableViewCell {
    
    lazy var leftIconImageView: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "ershou_price_tips_22")
        return re
    }()
    
    lazy var infoLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#3d6e99")
        return re
    }()
    
    lazy var rightArrowImageView: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "arrowicon-detail")
        return re
    }()
    
    lazy var sepLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8eaeb")
        return re
    }()
    
    open override class var identifier: String {
        return "PriceChangeHistoryCell"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(leftIconImageView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(rightArrowImageView)
        contentView.addSubview(sepLine)
        
        leftIconImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.centerY.equalTo(infoLabel)
            maker.width.height.equalTo(14)
        }
        
        infoLabel.snp.makeConstraints { maker in
            maker.left.equalTo(leftIconImageView.snp.right).offset(6)
            maker.right.equalToSuperview().offset(-32)
            maker.top.equalTo(10)
            maker.bottom.equalToSuperview().offset(-10)
        }
        
        rightArrowImageView.snp.makeConstraints { maker in
            maker.centerY.equalTo(infoLabel)
            maker.right.equalToSuperview().offset(-20)
            maker.width.height.equalTo(12)
        }
        
        sepLine.snp.makeConstraints { (maker) in
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.height.equalTo(1)
            maker.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

func parsePriceChangeHistoryNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode? {
    return {
        if ershouHouseData.priceChangeHistory == nil {
            return nil
        }
        let cellRender = curry(fillPriceChangeHistoryCell)(ershouHouseData)
        let selectors = openPriceChangeHistoryPage(priceChangeHistory: ershouHouseData.priceChangeHistory,houseId:ershouHouseData.id ?? "0", tracerParams: TracerParams.momoid(), navVC: nil)
        return TableSectionNode(
            items: [cellRender],
            selectors: [selectors],
            tracer: nil,
            label: "",
            type: .node(identifier: PriceChangeHistoryCell.identifier))
    }
}

func fillPriceChangeHistoryCell(_ ershouHouseData: ErshouHouseData, cell: BaseUITableViewCell) {
    guard let theCell = cell as? PriceChangeHistoryCell else {
        return
    }
    theCell.infoLabel.text = ershouHouseData.priceChangeHistory?.priceChangeDesc
}

func openPriceChangeHistoryPage(
    priceChangeHistory:PriceChangeHistory?,
    houseId:String,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> (TracerParams) -> Void {
    return { (theTracerParams) in
        if let pushUrl = priceChangeHistory?.detailUrl, pushUrl.count > 0 {
            let historyData = priceChangeHistory?.history ?? []
            if let url = "\(EnvContext.networkConfig.host)\(pushUrl)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                // js data
                let history  = ["history":historyData]
                let jsData   = ["data":history,"house_id":houseId] as [String : Any]
                let jsParams = ["requestPageData":jsData]
                let userInfo = TTRouteUserInfo(info: ["url":url, "title": "价格变动", "jsParams":jsParams])
                let jumpUrl = "fschema://webview_oc" //route协议
                TTRoute.shared().openURL(byPushViewController: URL(string: jumpUrl), userInfo: userInfo)
            }
        }
    }
}
