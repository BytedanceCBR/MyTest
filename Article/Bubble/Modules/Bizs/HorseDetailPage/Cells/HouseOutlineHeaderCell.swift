//
//  HouseOutlineHeaderCell.swift
//  NewsLite
//
//  Created by 张元科 on 2018/11/7.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HouseOutlineHeaderCell: BaseUITableViewCell {
    
    open override class var identifier: String {
        return "HouseOutlineHeaderCell"
    }
    
    var tracerParams:TracerParams?
    let disposeBag = DisposeBag()
    var reportUrl:String?

    var ershouHouseData: ErshouHouseData?
    
    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var infoButton: UIButton = {
        let re = UIButton()
        re.setImage(UIImage(named: "info-outline-material"), for: .normal)
        
        re.setTitle("举报", for: .normal)
        let attriStr = NSAttributedString(
            string: "举报",
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(12) ,
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#299cff")])
        re.setAttributedTitle(attriStr, for: .normal)
        re.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5)
        return re
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(self).offset(-60)
            maker.top.equalTo(10)
            maker.height.equalTo(26)
            maker.bottom.equalToSuperview().offset(0)
        }
        
        contentView.addSubview(infoButton)
        
        infoButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(label)
            maker.right.equalTo(self).offset(-25)
        }
        
        infoButton.rx.tap
            .subscribe(onNext: {[weak self] (void) in
                if let urlStr = self?.reportUrl {
                    if let ershouHouseData = self?.ershouHouseData,
                        let commonParams = TTNetworkManager.shareInstance()?.commonParamsblock() {

                        let openUrl = "fschema://webview_oc"
                        let model = ershouHouseData.toJSON()
                        let pageData: [String: Any] = ["data": model]
                        let commonParamsData: [String: Any] = ["data": commonParams]

                        let jsParams = ["requestPageData": pageData,
                                        "getNetCommonParams": commonParamsData]
                        let info: [String: Any] = ["url": "http://i.haoduofangs.com\(urlStr)", "jsParams": jsParams]
                        let userInfo = TTRouteUserInfo(info: info)
                        TTRoute.shared().openURL(byPushViewController: URL(string: openUrl), userInfo: userInfo)
                    }
                }
            }).disposed(by: disposeBag)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

func parseHouseOutlineHeaderNode(
    _ title: String,
    _ ershouHouseData: ErshouHouseData,
    traceExtension: TracerParams = TracerParams.momoid(),
    filter: (() -> Bool)? = nil) -> () -> TableSectionNode? {
    return {
        if let filter = filter, filter() == false {
            return nil
        } else {
            let cellRender = curry(fillHouseOutlineHeaderCell)(title)(ershouHouseData)(ershouHouseData.outLineOverreview?.reportUrl)(traceExtension)
            
            let params = EnvContext.shared.homePageParams <|>
                toTracerParams("house_info", key: "element_type") <|>
                toTracerParams("old_detail", key: "page_type") <|>
            traceExtension
            
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                sectionTracer: nil,
                label: "",
                type: .node(identifier: HouseOutlineHeaderCell.identifier))
        }
    }
}

func fillHouseOutlineHeaderCell(_ title: String,
                                _ ershouHouseData: ErshouHouseData,
                                _ openUrl:String?,
                                traceExtension: TracerParams = TracerParams.momoid(),
                                cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? HouseOutlineHeaderCell {
        theCell.label.text = title
        theCell.reportUrl = openUrl
        theCell.ershouHouseData = ershouHouseData
    }
}
