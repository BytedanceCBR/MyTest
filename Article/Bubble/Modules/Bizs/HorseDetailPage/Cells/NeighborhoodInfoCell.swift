//
//  NeighborhoodInfoCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class NeighborhoodInfoCell: BaseUITableViewCell {
    
    open override class var identifier: String {
        return "NeighborhoodInfoCell"
    }
    
    var navVC: UINavigationController?
    
    let leftMarge: CGFloat = 20
    let rightMarge: CGFloat = -20
    
    lazy var nameKey: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.text = "名称"
        return re
    }()
    
    lazy var nameValue: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    
    
    lazy var mapImageView: UIImageView = {
        let re = UIImageView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()
    
    lazy var mapViewGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()
    
    let disposeBag = DisposeBag()
    
    var data: NeighborhoodInfo?
    var logPB: [String: Any]?
    var neighborhoodId:String?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameKey)
        nameKey.snp.makeConstraints { maker in
            maker.left.equalTo(leftMarge)
            maker.top.equalToSuperview()
            maker.height.equalTo(20)
            maker.width.equalTo(28)
        }
        
        contentView.addSubview(nameValue)
        nameValue.snp.makeConstraints { maker in
            maker.left.equalTo(nameKey.snp.right).offset(10)
            maker.height.equalTo(20)
            maker.right.equalToSuperview().offset(rightMarge)
        }
        
        
        mapImageView.contentMode = .scaleAspectFill
        contentView.addSubview(mapImageView)
        mapImageView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(UIScreen.main.bounds.width * 0.4)
            maker.top.equalTo(nameKey.snp.bottom).offset(16)
        }
        mapImageView.addGestureRecognizer(mapViewGesture)
        mapImageView.isUserInteractionEnabled = true
        
        let selector = { [unowned self] in
            if let lat = self.data?.gaodeLat,
                let lng = self.data?.gaodeLng {
                let theParams = TracerParams.momoid() <|>
                    toTracerParams("map_list", key: "click_type") <|>
                    toTracerParams("old_detail", key: "enter_from") <|>
                    toTracerParams("map", key: "element_from") <|>
                    toTracerParams(self.neighborhoodId ?? "be_null", key: "group_id") <|>
                    toTracerParams(self.logPB ?? "be_null", key: "log_pb")
                
                let clickParams = theParams <|>
                    toTracerParams("map", key: "click_type")
                openMapPage(
                    navVC: self.navVC,
                    lat: lat,
                    lng: lng,
                    title: self.data?.name ?? "",
                    clickMapParams: clickParams,
                    traceParams: theParams,
                    disposeBag: self.disposeBag)(TracerParams.momoid())
            }
        }
        
        mapViewGesture.rx.event
            .subscribe(onNext: { (_) in
                selector()
            })
            .disposed(by: self.disposeBag)
        
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

func parseNeighborhoodInfoNode(_ ershouHouseData: ErshouHouseData, traceExtension: TracerParams = TracerParams.momoid(), neighborhoodId: String, navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        
        if ershouHouseData.neighborhoodInfo == nil {
            
            return nil
        }

        let houseShowParams = EnvContext.shared.homePageParams <|>
            traceExtension <|>
            toTracerParams(ershouHouseData.neighborhoodInfo?.logPB ?? "be_null", key: "log_pb") <|>
            toTracerParams(ershouHouseData.neighborhoodInfo?.id ?? "be_null", key: "group_id") <|>
            toTracerParams("no_pic", key: "card_type") <|>
            toTracerParams("neighborhood", key: "house_type") <|>
            toTracerParams("old_detail", key: "page_type") <|>
            toTracerParams("be_null", key: "element_type")
        let tracer = onceRecord(key: TraceEventName.house_show, params: houseShowParams.exclude("enter_from").exclude("element_from"))
        
        let render = curry(fillNeighborhoodInfoCell)(ershouHouseData.neighborhoodInfo)(tracer)(neighborhoodId)(navVC)(ershouHouseData.logPB)
        
        return TableSectionNode(

                items: [render],
                selectors: nil,
                tracer: [tracer],
                label: "",
                type: .node(identifier: NeighborhoodInfoCell.identifier))
    }
}

func fillNeighborhoodInfoCell(_ data: NeighborhoodInfo?, tracer: ElementRecord, neighborhoodId: String, navVC: UINavigationController?, logPB: [String: Any]?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodInfoCell {
        
        theCell.nameValue.text = data?.name
        theCell.navVC = navVC
        theCell.neighborhoodId = neighborhoodId
        theCell.logPB = logPB
        theCell.data = data
        
        if let url = data?.gaodeImageUrl {
            theCell.mapImageView.bd_setImage(with: URL(string: url))
        }
        

//        tracer(TracerParams.momoid())

        
    }
}
