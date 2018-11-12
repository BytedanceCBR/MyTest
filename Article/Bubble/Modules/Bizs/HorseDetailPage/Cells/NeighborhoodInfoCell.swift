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
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.text = "所属区域"
        return re
    }()
    
    lazy var nameValue: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var schoolKey: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        re.text = "教育资源"
        return re
    }()
    
    lazy var schoolLabel: UILabel = {
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
    
    lazy var bgView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#000000",alpha: 0.5)
        return re
    }()
    lazy var evaluateLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.text = "小区测评"
        re.textColor = .white
        return re
    }()
    
    lazy var rightArrow: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "arrowicon-feed-white")
        return re
    }()
    
    lazy var starsContainer: FHStarsCountView = {
        let re = FHStarsCountView()
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
        
        contentView.addSubview(starsContainer)
        starsContainer.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(50)
        }
        
        contentView.addSubview(nameKey)
        nameKey.snp.makeConstraints { maker in
            maker.left.equalTo(leftMarge)
            maker.top.equalTo(starsContainer.snp.bottom)
            maker.height.equalTo(20)
        }
        
        contentView.addSubview(nameValue)
        nameValue.snp.makeConstraints { maker in
            maker.left.equalTo(nameKey.snp.right).offset(12)
            maker.top.equalTo(nameKey)
            maker.height.equalTo(20)
        }
        
        contentView.addSubview(schoolKey)
        schoolKey.snp.makeConstraints { maker in
            maker.left.equalTo(nameKey)
            maker.top.equalTo(nameKey.snp.bottom).offset(10)
            maker.height.equalTo(20)
        }
        
        contentView.addSubview(schoolLabel)
        schoolLabel.snp.makeConstraints { maker in
            maker.left.equalTo(schoolKey.snp.right).offset(12)
            maker.top.equalTo(schoolKey)
            maker.height.equalTo(20)
        }
        
        mapImageView.contentMode = .scaleAspectFill
        contentView.addSubview(mapImageView)
        mapImageView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(UIScreen.main.bounds.width * 0.4)
            maker.top.equalTo(schoolKey.snp.bottom).offset(20)
        }
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalTo(mapImageView)
            maker.height.equalTo(40)
        }
        bgView.addSubview(evaluateLabel)
        evaluateLabel.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(20)
        }
        bgView.addSubview(rightArrow)
        rightArrow.snp.makeConstraints { maker in
            maker.right.equalTo(-20)
            maker.centerY.equalTo(evaluateLabel)
        }
        
        let evaluateGest = UITapGestureRecognizer()
        evaluateGest.rx.event
            .subscribe(onNext: { [weak self] (_) in

                if let url = self?.data?.evaluationInfo?.detailUrl {
                    TTRoute.shared().openURL(byPushViewController: URL(string: url), userInfo: nil)
                }
                
            })
            .disposed(by: self.disposeBag)
        bgView.addGestureRecognizer(evaluateGest)
        bgView.isUserInteractionEnabled = true

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
        
        let render = curry(fillNeighborhoodInfoCell)(ershouHouseData)(tracer)(neighborhoodId)(navVC)(ershouHouseData.logPB)
        
        return TableSectionNode(

                items: [render],
                selectors: nil,
                tracer: [tracer],
                label: "",
                type: .node(identifier: NeighborhoodInfoCell.identifier))
    }
}

func fillNeighborhoodInfoCell(_ data: ErshouHouseData, tracer: ElementRecord, neighborhoodId: String, navVC: UINavigationController?, logPB: [String: Any]?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodInfoCell {
        
        theCell.nameValue.text = data.neighborhoodInfo?.name
        theCell.navVC = navVC
        theCell.neighborhoodId = neighborhoodId
        theCell.logPB = logPB
        theCell.data = data.neighborhoodInfo
        theCell.bgView.isHidden = data.neighborhoodInfo?.evaluationInfo?.detailUrl?.count ?? 0 > 0 ? false : true
        if let totalScore = data.neighborhoodInfo?.evaluationInfo?.totalScore {
            
            theCell.evaluateLabel.text = "\(totalScore)"
        }
        theCell.starsContainer.updateStarsCount(scoreValue: data.neighborhoodInfo?.evaluationInfo?.totalScore ?? 0)

        if let url = data.neighborhoodInfo?.gaodeImageUrl {
            theCell.mapImageView.bd_setImage(with: URL(string: url))
        }
        
        if let schoolInfo = data.neighborhoodInfo?.schoolInfo?.first, let schoolName = schoolInfo.schoolName {
            
            theCell.schoolLabel.text = schoolName
            theCell.schoolLabel.snp.updateConstraints { (maker) in
                maker.height.equalTo(20)
            }
            theCell.schoolKey.snp.updateConstraints { (maker) in
                maker.height.equalTo(20)
            }
            theCell.mapImageView.snp.makeConstraints { maker in
                maker.top.equalTo(theCell.schoolKey.snp.bottom).offset(20)
            }
            theCell.schoolLabel.isHidden = false
            theCell.schoolKey.isHidden = false
        }else {
            theCell.schoolLabel.snp.updateConstraints { (maker) in
                maker.height.equalTo(0)
            }
            theCell.schoolKey.snp.updateConstraints { (maker) in
                maker.height.equalTo(0)
            }
            theCell.mapImageView.snp.makeConstraints { maker in
                maker.top.equalTo(theCell.schoolKey.snp.bottom).offset(10)
            }
            theCell.schoolLabel.isHidden = true
            theCell.schoolKey.isHidden = true

        }
        
    }
}
