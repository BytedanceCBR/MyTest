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
class NeighborhoodInfoCell: BaseUITableViewCell, MAMapViewDelegate, AMapSearchDelegate {
    let mapHightScale: CGFloat = 0.36
    open override class var identifier: String {
        return "NeighborhoodInfoCell"
    }
    
    var navVC: UINavigationController?
    
    let leftMarge: CGFloat = 20
    let rightMarge: CGFloat = -20
    var tracerParams:TracerParams = TracerParams.momoid()
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
    
    fileprivate var pointAnnotation: FHMAAnnotation?
    
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
    
    lazy var mapAnnotionImageView: UIImageView = {
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 200)
        let re = UIImageView(frame: frame)
        return re
    }()
    
    let mapView: MAMapView = {
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 200)
        let re = MAMapView(frame: frame)
        re.runLoopMode = RunLoopMode.defaultRunLoopMode;
        re.showsCompass = false
        re.showsScale = false
        re.isZoomEnabled = false
        re.isScrollEnabled = false
        re.zoomLevel = 14
        re.showsUserLocation = false
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
    
    var data: NeighborhoodInfo? {
        didSet {
            self.detailUrl = data?.evaluationInfo?.detailUrl
            self.name = data?.name
            self.lat = data?.gaodeLat
            self.lng = data?.gaodeLng
        }
    }
    var logPB: [String: Any]?
    var neighborhoodId:String?
    var centerPoint: CLLocationCoordinate2D?
    var detailUrl: String?
    var name: String?
    var lat: String?
    var lng: String?

    func setLocation(lat: String, lng: String) {
        if let theLat = Double(lat), let theLng = Double(lng) {
            let center = CLLocationCoordinate2D(latitude: theLat, longitude: theLng)
            centerPoint = center
            mapView.setCenter(center, animated: false)
            
            addUserAnnotation()
        }
    }
    
    fileprivate func addUserAnnotation()
    {
        guard let center = centerPoint else {
            return
        }
        
        let pointAnnotation = FHMAAnnotation()
        pointAnnotation.type = .center
        pointAnnotation.coordinate = center
        mapView.addAnnotation(pointAnnotation)
        self.pointAnnotation = pointAnnotation
        
        snapshotMap()
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if let annotation = annotation as? FHMAAnnotation {
            
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            if annotation.type.rawValue == "center"
            {
                annotationView?.image = UIImage(named: "icon-location")
            }
            
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView?.centerOffset = CGPoint(x: 0, y: -18)
            
            return annotationView ?? MAAnnotationView(annotation: annotation, reuseIdentifier: "default")
        }
        
        return MAAnnotationView(annotation: annotation, reuseIdentifier: "default")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        mapView.delegate = self

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
            // 等效高度为134
            maker.height.equalTo(UIScreen.main.bounds.width * mapHightScale)
            maker.top.equalTo(schoolKey.snp.bottom).offset(20)
        }
        
        mapAnnotionImageView.backgroundColor = UIColor.clear
        mapImageView.addSubview(mapAnnotionImageView)
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * mapHightScale)
        self.mapView.takeSnapshot(in: frame) {[weak self] (image, state) in
            self?.mapImageView.image = image
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
            maker.right.equalTo(-13)
            maker.centerY.equalTo(evaluateLabel)
        }
        
        let evaluateGest = UITapGestureRecognizer()
        evaluateGest.rx.event
            .subscribe(onNext: { [unowned self] (_) in
                if let urlStr = self.detailUrl {
                    openEvaluateWebPage(urlStr: urlStr, title: "小区评测", traceParams: self.tracerParams, disposeBag: self.disposeBag)(TracerParams.momoid())
                }
            })
            .disposed(by: self.disposeBag)
        bgView.addGestureRecognizer(evaluateGest)
        bgView.isUserInteractionEnabled = true

        mapImageView.addGestureRecognizer(mapViewGesture)
        mapImageView.isUserInteractionEnabled = true
        
        let selector = { [unowned self] in
            if let lat = self.lat,
                let lng = self.lng {
                let theParams = TracerParams.momoid() <|>
                    toTracerParams("map", key: "click_type") <|>
                    toTracerParams("map", key: "element_from") <|>
                    toTracerParams(self.neighborhoodId ?? "be_null", key: "group_id") <|>
                    toTracerParams(self.data?.logPB ?? "be_null", key: "log_pb") <|>
                    self.tracerParams
                
                let clickParams = theParams <|>
                    toTracerParams("map", key: "click_type")

                let userInfo = TTRouteUserInfo(info: ["tracer": theParams.paramsGetter([:])])
                //fschema://fh_house_detail_map
                recordEvent(key: "click_map", params: clickParams)
                let jumpUrl = "fschema://fh_house_detail_map?lat=\(lat)&lng=\(lng)&title=\(self.name ?? "")"
                if let thrUrl = jumpUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    TTRoute.shared()?.openURL(byViewController: URL(string: thrUrl),
                                              userInfo: userInfo)
                }
            }
        }
        
        mapViewGesture.rx.event
            .subscribe(onNext: { (_) in
                selector()
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func snapshotMap()
    {
        if let annotionView = mapView.view(for: self.pointAnnotation)
        {
            if let superAnnotionView = annotionView.superview
            {
                mapAnnotionImageView.image = NewHouseNearByCell.getImageFromView(view: superAnnotionView)
            }
        }else
        {
            mapAnnotionImageView.image = nil
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func schoolLabelIsHidden(isHidden: Bool) {
        schoolKey.isHidden = isHidden
        schoolLabel.isHidden = isHidden
        if isHidden {
            mapImageView.snp.makeConstraints { maker in
                maker.left.right.bottom.equalToSuperview()
                maker.height.equalTo(UIScreen.main.bounds.width * mapHightScale)
                maker.top.equalTo(nameKey.snp.bottom).offset(20)
            }
        } else {
            mapImageView.snp.makeConstraints { maker in
                maker.left.right.bottom.equalToSuperview()
                maker.height.equalTo(UIScreen.main.bounds.width * mapHightScale)
                maker.top.equalTo(schoolKey.snp.bottom).offset(20)
            }
        }
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
            searchIdTraceParam(ershouHouseData.neighborhoodInfo?.logPB) <|>
            groupIdTraceParam(ershouHouseData.neighborhoodInfo?.logPB) <|>
            imprIdTraceParam(ershouHouseData.neighborhoodInfo?.logPB) <|>
            toTracerParams("old_detail", key: "page_type") <|>
            toTracerParams("be_null", key: "element_type")
        let tracer = onceRecord(key: TraceEventName.house_show, params: houseShowParams.exclude("enter_from").exclude("element_from"))
        
        let tracerParam = EnvContext.shared.homePageParams <|>
            toTracerParams("neighborhood_evaluation", key: "element_type") <|>
            toTracerParams("old_detail", key: "page_type") <|>
        traceExtension
        
        let tracerEvaluationRecord = elementShowOnceRecord(params: tracerParam)

        let elementRecord: ElementRecord = { (params) in
            tracer(params)
            if ershouHouseData.neighborhoodInfo?.evaluationInfo != nil {
                tracerEvaluationRecord(params)
            }
        }
        let tracers = [elementRecord]

        let render = curry(fillNeighborhoodInfoCell)(ershouHouseData)(tracer)(neighborhoodId)(navVC)(ershouHouseData.logPB)(traceExtension <|> toTracerParams("old_detail", key: "enter_from"))
        
        return TableSectionNode(

                items: [render],
                selectors: nil,
                tracer: tracers,
                sectionTracer: nil,
                label: "",
                type: .node(identifier: NeighborhoodInfoCell.identifier))
    }
}

func fillNeighborhoodInfoCell(_ data: ErshouHouseData, tracer: ElementRecord, neighborhoodId: String, navVC: UINavigationController?, logPB: [String: Any]?,traceExtension: TracerParams = TracerParams.momoid(), cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodInfoCell {
        
        if let areaName = data.neighborhoodInfo?.areaName, let districtName = data.neighborhoodInfo?.districtName {
            theCell.nameValue.text = "\(districtName)-\(areaName)"
        }else {
            
            theCell.nameValue.text = data.neighborhoodInfo?.districtName
        }
        theCell.navVC = navVC
        theCell.neighborhoodId = neighborhoodId
        theCell.logPB = logPB
        theCell.tracerParams = traceExtension
        theCell.data = data.neighborhoodInfo
        theCell.bgView.isHidden = data.neighborhoodInfo?.evaluationInfo?.detailUrl?.count ?? 0 > 0 ? false : true

        if let lat = data.neighborhoodInfo?.gaodeLat, let lng = data.neighborhoodInfo?.gaodeLng {
            theCell.setLocation(lat: lat, lng: lng)
        
        if let evaluationInfo = data.neighborhoodInfo?.evaluationInfo {
            
            theCell.starsContainer.updateStarsCount(scoreValue: evaluationInfo.totalScore ?? 0)
            if let scoreValue = evaluationInfo.totalScore, scoreValue > 0
            {
                theCell.starsContainer.snp.updateConstraints { maker in
                    maker.height.equalTo(50)
                }
                theCell.starsContainer.isHidden = false
            }else
            {
                theCell.starsContainer.snp.updateConstraints { maker in
                    maker.height.equalTo(0)
                }
                theCell.starsContainer.isHidden = true
            }

            
            if let url = evaluationInfo.detailUrl, url.count > 0 {
                theCell.bgView.isHidden = false
            }else {
                theCell.bgView.isHidden = true
            }
        }else {
            theCell.starsContainer.snp.updateConstraints { maker in
                maker.height.equalTo(0)
            }
            theCell.starsContainer.isHidden = true
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
}

func openEvaluateWebPage(
    urlStr: String,
    title: String = "小区评测",
    traceParams: TracerParams,
    houseType: HouseType = .secondHandHouse,
    disposeBag: DisposeBag) -> (TracerParams) -> Void{
    return { (_) in
        if urlStr.count > 0 {
            
            var enterFrom = "old_detail"
            if houseType == .neighborhood {
                enterFrom = "neighborhood_detail"
            }
            if houseType == .rentHouse {
                enterFrom = "rent_detail"
            }
            
            let openParams = EnvContext.shared.homePageParams <|>
                toTracerParams(enterFrom, key: "enter_from") <|>
                traceParams.exclude("rank")
            
            recordEvent(key: "enter_neighborhood_evaluation", params: openParams)
            
            
            let jumpUrl = "sslocal://webview" //route协议
            let parmasMap = openParams.paramsGetter([:]) //埋点参数
            let stayPageTraceEventName = "stay_neighborhood_evaluation" //埋点Event ,不传不上报
            
            let userInfo = TTRouteUserInfo(info: ["event":stayPageTraceEventName,"tracer": parmasMap, "title": title, "url": urlStr,"bounce_disable":"1"])
            
            TTRoute.shared().openURL(byPushViewController: URL(string: jumpUrl), userInfo: userInfo)
            FRRouteHelper.openWebView(forURL: urlStr)
        }
    }
}

