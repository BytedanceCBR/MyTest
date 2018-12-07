//
//  NewHouseNearByCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class NewHouseNearByCell: BaseUITableViewCell, MAMapViewDelegate, AMapSearchDelegate {
    open override class var identifier: String {
        return "NewHouseNearByCell"
    }
    
    deinit {
//                print("")
    }
    
    var tracerParams = TracerParams.momoid()
    
    var callBackIndexChanged : (() -> Void)?
    
    var requestIndex: Int = 0
    
    fileprivate var poiAnnotationDatas : [String : [FHMAAnnotation]]?
    
    fileprivate var poiMapDatas : [String : [AMapPOI]]?
    
    var titleDatas : [String : String]?
    
    let mapView: MAMapView = {
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 160)
        let re = MAMapView(frame: frame)
        re.runLoopMode = RunLoopMode.defaultRunLoopMode;
        re.showsCompass = false
        re.showsScale = false
        re.isZoomEnabled = false
        re.isScrollEnabled = false
        re.zoomLevel = 14
        return re
    }()
    
    lazy var mapImageView: UIImageView = {
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 160)
        let re = UIImageView(frame: frame)
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()
    
    lazy var mapAnnotionImageView: UIImageView = {
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 160)
        let re = UIImageView(frame: frame)
        return re
    }()
    
    lazy var locationList: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
        re.allowsSelection = false
        re.isUserInteractionEnabled = true
        re.register(LocationCell.self, forCellReuseIdentifier: "item")
        return re
    }()
    
    let categorys: [POIType] = [.traffic, .mall, .hospital, .education]
    
    lazy var segmentedControl: FWSegmentedControl = {
        let re = FWSegmentedControl.segmentedWith(
            scType: SCType.text,
            scWidthStyle: SCWidthStyle.fixed,
            sectionTitleArray: nil,
            sectionImageArray: nil,
            sectionSelectedImageArray: nil,
            frame: CGRect.zero)
        re.selectionIndicatorHeight = 2
        re.sectionTitleArray = categorys.map {
            $0.rawValue
        }
        re.scSelectionIndicatorStyle = .fullWidthStripe
        
        let attributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                          NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#8a9299")]
        
        let selectedAttributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                                  NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#299cff")]
        re.titleTextAttributes = attributes
        re.selectedTitleTextAttributes = selectedAttributes
        re.selectionIndicatorColor = hexStringToUIColor(hex: "#299cff")
        re.selectionIndicatorEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        re.segmentEdgeInset = UIEdgeInsets(top: -10, left: 5, bottom: 0, right: 5)
        return re
    }()
    
    lazy var bottomLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
        return re
    }()
    
    lazy var locationListViewModel: LocationListViewModel = {
        LocationListViewModel(maskLabel: self.emptyInfoLabel)
    }()
    
    lazy var search: AMapSearchAPI = {
        let re = AMapSearchAPI()
        re?.delegate = self
        return re!
    }()
    
    lazy var mapMaskBtn: UIButton = {
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 160)
        let re = UIButton(frame: frame)
        return re
    }()
    
    var currentPoiType: POIType?
    
    lazy var emptyInfoLabel: UILabel = {
        let re = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 160)
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        re.isHidden = EnvContext.shared.client.reachability.connection == .none ?false:true
        re.textAlignment = .center
        re.text = "附近没有交通信息"
        return re
    }()
    
    lazy var seperateLineView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()
    
    fileprivate var pointAnnotation: FHMAAnnotation?
    
    var disposeBag = DisposeBag()
    
    var disposeCell = DisposeBag()
    
    fileprivate let poiData = BehaviorRelay<[FHMAAnnotation]>(value: [])
    
    var centerPoint: CLLocationCoordinate2D?
    
    private let lock = NSLock()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        EnvContext.shared.currentMapSelect = "公交"
        
        mapView.delegate = self
        
        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { maker in
            maker.left.top.right.equalToSuperview()
            maker.height.equalTo(56)
        }
        
        contentView.addSubview(mapImageView)
        mapImageView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(segmentedControl.snp.bottom)
            maker.height.equalTo(160)
        }
        mapAnnotionImageView.backgroundColor = UIColor.clear
        mapImageView.addSubview(mapAnnotionImageView)
        
        contentView.addSubview(mapMaskBtn)
        mapMaskBtn.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(segmentedControl.snp.bottom)
            maker.height.equalTo(160)
        }
        
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 160)
        self.mapView.takeSnapshot(in: frame) {[weak self] (image, state) in
            self?.mapImageView.image = image
        }
        
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.top.equalTo(mapImageView.snp.bottom).offset(-0.5)
            maker.height.equalTo(0.5)
        }

        contentView.addSubview(locationList)
        locationList.snp.makeConstraints { maker in
            maker.top.equalTo(mapImageView.snp.bottom).offset(10)
            maker.left.right.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-10)
            maker.height.equalTo(105)
        }

        contentView.addSubview(emptyInfoLabel)
        emptyInfoLabel.snp.makeConstraints { maker in
            maker.center.equalTo(locationList.snp.center)
            maker.width.greaterThanOrEqualTo(100)
            maker.height.equalTo(20)
        }
        
//        contentView.addSubview(seperateLineView)
//        seperateLineView.snp.makeConstraints { maker in
//            maker.height.equalTo(6)
//            maker.bottom.left.right.equalToSuperview()
//            maker.top.equalTo(locationList.snp.bottom)
//        }
        locationList.estimatedRowHeight = 35
        locationList.rowHeight = UITableViewAutomaticDimension
        locationList.dataSource = locationListViewModel
        locationList.delegate = locationListViewModel
        
        
        segmentedControl.indexChangeBlock = { [unowned self] index in
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            self.changePoiData(index: index)
            
            let poiType = self.categorys[index]
            
            self.currentPoiType = poiType
            
            
            EnvContext.shared.currentMapSelect = poiType.rawValue
            
            let params = self.tracerParams <|>
                toTracerParams(categoryTraceParams(poiType: poiType), key: "map_tag")
            recordEvent(key: "click_map", params: params)
            self.emptyInfoLabel.text = "附近没有\(poiType.rawValue)信息"
            
            self.callBackIndexChanged?()
        }
        
        poiAnnotationDatas = [String : [FHMAAnnotation]]()
        poiMapDatas = [String : [AMapPOI]]()
        titleDatas = [String : String]()
        
        changeListLayout(poiCount: 0)
    }
    
    func resetMapData()
    {
        if let rawV = self.currentPoiType?.rawValue
        {
            EnvContext.shared.currentMapSelect = rawV
        }else
        {
            EnvContext.shared.currentMapSelect = "公交"
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
    
    func setLocation(lat: String, lng: String) {
        if let theLat = Double(lat), let theLng = Double(lng) {
            let center = CLLocationCoordinate2D(latitude: theLat, longitude: theLng)
            centerPoint = center
            locationListViewModel.center = center
            mapView.setCenter(center, animated: false)
            requestPOIInfoByType(poiType: categorys[segmentedControl.selectedSegmentIndex])
            requestIndex = segmentedControl.selectedSegmentIndex
        }
    }
    
    
    func changeListLayout(poiCount: Int)
    {
        locationList.snp.updateConstraints { maker in
            maker.top.equalTo(mapImageView.snp.bottom).offset(10)
            maker.left.right.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-10)
            maker.height.equalTo((poiCount > 3 ? 3 : (poiCount == 0 ? 2 : poiCount)) * 35)
        }
        
        if poiCount == 0
        {
            emptyInfoLabel.snp.updateConstraints { maker in
                maker.center.equalTo(locationList.snp.center)
                maker.width.greaterThanOrEqualTo(100)
                maker.height.equalTo(20)
            }
            
            mapMaskBtn.snp.updateConstraints { maker in
                maker.left.right.equalToSuperview()
                maker.top.equalTo(segmentedControl.snp.bottom)
                maker.height.equalTo(160)
            }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateLayoutForList()
    {
        let count  = locationListViewModel.datas.count
        changeListLayout(poiCount: count)
    }
    
    
    fileprivate func resetAnnotations(_ annotations: [FHMAAnnotation]) {
        guard let center = centerPoint else {
            return
        }
        let pointAnnotation = FHMAAnnotation()
        pointAnnotation.type = .center
        pointAnnotation.coordinate = center
        self.pointAnnotation = pointAnnotation
        
        (poiData.value + [pointAnnotation]).forEach { annotation in
            mapView.addAnnotation(annotation)
        }
        
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
    
    class func getImageFromView(view:UIView) ->UIImage{
        UIGraphicsBeginImageContextWithOptions(view.size,false,UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func requestPOIInfoByType(poiType: POIType) {
        
        if poiType == .center {
            return
        }
        
        guard let center = centerPoint else {
            assertionFailure()
            return
        }
        search.cancelAllRequests()
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = poiType == POIType.traffic ? "公交地铁" : poiType.rawValue
        //        request.types = poiType == POIType.traffic ? "公交地铁" : poiType.rawValue
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude: CGFloat(center.longitude))
        request.requireExtension = true
        request.requireSubPOIs = true
        request.cityLimit = true
        search.aMapPOIKeywordsSearch(request)
    }
    
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if let annotation = annotation as? FHMAAnnotation {
            
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            //            if annotation.type.rawValue == "交通" {
            //                annotationView?.image = #imageLiteral(resourceName: "icon-bus")
            //            } else {
            //                annotationView?.image = getMapPoiIcon(category: annotation.type.rawValue)
            //            }
            
            if annotation.type.rawValue == "center"
            {
                annotationView?.image = getMapPoiIcon(category: annotation.type.rawValue)
            }else
            {
                if annotation.title.count != 0
                {
                    
                    
                    let backImageView = UIImageView()
                    annotationView?.addSubview(backImageView)
                    
                    let titileLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 38))
                    titileLabel.text = annotation.title
                    
                    titileLabel.frame = CGRect(x: 0, y: 0, width: (titileLabel.text?.count ?? 5) * 13, height: 32)
                    backImageView.frame = CGRect(x: 0, y: 0, width: (titileLabel.text?.count ?? 5) * 14 + 10, height: 35)
                    
                    
                    var imageAnnotation =  UIImage(named: "mapcell_annotation_bg")
                    
                    let width = imageAnnotation?.size.width ?? 10
                    let height = imageAnnotation?.size.height ?? 10

                    imageAnnotation = imageAnnotation?.resizableImage(withCapInsets: UIEdgeInsets(top: height / 2.0, left: width / 2.0,  bottom: height / 2.0, right: width / 2.0), resizingMode: .stretch)
                    backImageView.image = imageAnnotation
//                    backImageView.contentMode = .center
                    backImageView.layer.cornerRadius = 17.5
                    backImageView.layer.masksToBounds = true
                    
                    titileLabel.textColor = hexStringToUIColor(hex: "#081f33")
                    annotationView?.addSubview(titileLabel)
                    titileLabel.font = CommonUIStyle.Font.pingFangRegular(12)
                    titileLabel.layer.masksToBounds = true
                    //                    titileLabel.layer.cornerRadius = 19
                    titileLabel.numberOfLines = 1
                    titileLabel.textAlignment = .center
                    titileLabel.backgroundColor = UIColor.clear
                    titileLabel.sizeToFit()
                    titileLabel.center = CGPoint(x: backImageView.center.x, y: backImageView.center.y - 2
                    )
                    
                    let bottomArrowView = UIImageView(image: UIImage(named: "mapcell_annotation_arrow"))
                    backImageView.addSubview(bottomArrowView)
                    bottomArrowView.backgroundColor = UIColor.clear
                    bottomArrowView.frame = CGRect(x: backImageView.frame.size.width/2.0 - 5, y: backImageView.frame.size.height - 12, width: 10.5, height: 10.5)
                }
            }
            
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView?.centerOffset = CGPoint(x: 0, y: -18)
            //            backImageView.frame = CGRect(x: 0, y: 0, width: titileLabel.frame.size.width, height: 38)
            
            return annotationView ?? MAAnnotationView(annotation: annotation, reuseIdentifier: "default")
        }
        
        return MAAnnotationView(annotation: annotation, reuseIdentifier: "default")
    }
    
    
    
    /* POI 搜索回调. */
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        if response.count == 0 {
            emptyInfoLabel.isHidden = false
            return
        }

        
        if let center = centerPoint {
            let from = MAMapPointForCoordinate(center)
            let poisMap = response.pois.filter { poi in
                let to = MAMapPointForCoordinate(CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(poi.location.latitude),
                    longitude: CLLocationDegrees(poi.location.longitude)))
                let distance = MAMetersBetweenMapPoints(from, to)
                return distance < 2000 //2 公里
                }.take(10)
            
            let pois = poisMap.take(3).map { (poi) -> FHMAAnnotation in
                let re = FHMAAnnotation()
                re.type = categorys[segmentedControl.selectedSegmentIndex]
                re.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
                re.title = poi.name
                return re
            }
            
            if let reuqestPoi = request as? AMapPOIKeywordsSearchRequest
            {
                poiMapDatas?[reuqestPoi.keywords] = poisMap
                titleDatas?[reuqestPoi.keywords == "公交地铁" ? "交通": reuqestPoi.keywords] = "(\(poisMap.count))"
            }
            
            if let reuqestPoi = request as? AMapPOIKeywordsSearchRequest
            {
                poiAnnotationDatas?[reuqestPoi.keywords] = pois
                if reuqestPoi.keywords == "公交地铁"
                {
                    changePoiData(index: 0)
                    self.callBackIndexChanged?()
                }
            }
            requestIndex += 1
            if requestIndex == 1
            {
                /**********************************队列组******************************************/
                for i in 1...3 {
                    DispatchQueue.global().async {
                        [weak self] in
                        guard let `self` = self else { return }
                        // 全局并发同步
                        self.requestPOIInfoByType(poiType: self.categorys.count > i ? self.categorys[i] : .center)
                    }
                }
            }
            
            segmentedControl.sectionTitleArray = categorys.map { [weak self] in
                $0.rawValue + (self?.titleDatas?[$0.rawValue] ?? "")
            }
        }
    }
    
    func changePoiData(index : Int)
    {
        
        poiData.value.forEach { annotation in
            mapView.removeAnnotation(annotation)
        }
        if let pointAnnotation = pointAnnotation {
            mapView.removeAnnotations([pointAnnotation])
        }
        
        if index < self.categorys.count,let pois = poiAnnotationDatas?[self.categorys[index] == POIType.traffic ? "公交地铁" : self.categorys[index].rawValue]
        {
            poiData.accept(pois)
            self.resetAnnotations(pois)
            
            self.snapshotMap()
            
            if centerPoint != nil {
                if let poisData = poiMapDatas?[self.categorys[index] == POIType.traffic ? "公交地铁" : self.categorys[index].rawValue]
                {
                    locationListViewModel.datas = poisData
                }
                
                let count  = locationListViewModel.datas.count
                
                changeListLayout(poiCount: count)
                
                emptyInfoLabel.isHidden = locationListViewModel.datas.count != 0
                locationList.isUserInteractionEnabled = locationListViewModel.datas.count == 0
                locationList.reloadData()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //        search.cancelAllRequests()
        disposeBag = DisposeBag()
    }
}

func categoryTraceParams(poiType: POIType) -> String {
    switch poiType {
    case .subway:
        return "subway"
    case .mall:
        return "shopping"
    case .hospital:
        return "hospital"
    case .education:
        return "school"
    default:
        return "be_null"
    }
}

enum POIType: String {
    case center
    case subway = "地铁"
    case mall = "购物"
    case hospital = "医院"
    case education = "教育"
    case traffic = "交通"
}

class FHMAAnnotation: MAPointAnnotation {
    var type: POIType = .center
}

fileprivate class LocationCell: UITableViewCell {
    
    lazy var label: UILabel = {
        let re = UILabel()
        re.textAlignment = .left
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        return re
    }()
    
    lazy var label2: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#a1aab3")
        re.textAlignment = .right
        return re
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label2)
        label2.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-20)
            maker.top.bottom.equalToSuperview
            maker.height.equalTo(35)
        }
        
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(label2)
            maker.height.equalTo(label2)
            maker.bottom.equalTo(label2)
            maker.right.equalTo(label2.snp.left).offset(-5)
        }
        label2.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class LocationListViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var datas: [AMapPOI] = []
    
    var center: CLLocationCoordinate2D?
    
    var labelMask: UILabel?
    init (maskLabel:UILabel?)
    {
        self.labelMask = maskLabel
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.labelMask?.isHidden = (datas.count != 0)
        return datas.count > 3 ? 3 : datas.count
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView()
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView()
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 20
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 15
//    }
//
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        if let theCell = cell as? LocationCell {
            if datas.count > indexPath.row
            {
                let poi = datas[indexPath.row]
                theCell.label.text = poi.name
                if let theCenter = center {
                    let from = MAMapPointForCoordinate(theCenter)
                    let to = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude)))
                    let distance = MAMetersBetweenMapPoints(from, to)
                    if distance < 1000 {
                        theCell.label2.text = String(format: "%d米", arguments: [Int(distance)])
                    } else {
                        theCell.label2.text = String(format: "%.1f公里", arguments: [distance / 1000])
                    }
                }
            }else
            {
                theCell.label.text = "暂无信息"
                theCell.label2.text = ""
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print("LocationListViewModel")
    }
}

func parseNeighorhoodNearByNode(
    _ data: NeighborhoodDetailData,
    traceExtension: TracerParams = TracerParams.momoid(),
    houseId: String,
    navVC: UINavigationController?,
    disposeBag: DisposeBag,
    callBack: @escaping () -> Void) -> () -> TableSectionNode? {
    return {
        
        if data.neighborhoodInfo == nil {
            
            return nil
        }
        
        var selector: ((TracerParams) -> Void)?
        var mapSelector: ((TracerParams) -> Void)?
        
        let showParams = TracerParams.momoid() <|>
            toTracerParams("map", key: "element_type") <|>
            toTracerParams("neighborhood_detail", key: "page_type") <|>
        traceExtension
        
        
        let params = TracerParams.momoid() <|>
            toTracerParams("map", key: "element_from") <|>
            toTracerParams(selectTraceParam(traceExtension, key: "log_pb") ?? "be_null", key: "log_pb") <|>
            toTracerParams(houseId, key: "group_id") <|>
            toTracerParams("map_list", key: "click_type") <|>
            toTracerParams("neighborhood_detail", key: "enter_from")
        let mapSelectorParams =  EnvContext.shared.homePageParams <|>
            params <|>
            beNull(key: "map_tag") <|>
            toTracerParams("neighborhood_detail", key: "page_type") <|>
            toTracerParams("neighborhood_nearby", key: "element_type") <|>
            toTracerParams("map", key: "click_type")
        if let lat = data.neighborhoodInfo?.gaodeLat, let lng = data.neighborhoodInfo?.gaodeLng {

            selector = openMapPage(
                navVC:navVC,
                lat:lat,
                lng: lng,
                title: data.name ?? "",
                clickMapParams: mapSelectorParams,
                traceParams: params,
                disposeBag: disposeBag)
            
            mapSelector = openMapPage(
                navVC:navVC,
                lat:lat,
                lng: lng,
                title: data.name ?? "",
                clickMapParams: mapSelectorParams,
                traceParams: params <|> toTracerParams("map", key: "click_type"),
                disposeBag: disposeBag)
        }
        let cellRender = curry(fillNeighorhoodNearByCell)(data)(disposeBag)(callBack)(mapSelector)
        
        return TableSectionNode(
            items: [oneTimeRender(cellRender)],
            selectors: selector != nil ? [selector!] : nil,
            tracer: [elementShowOnceRecord(params: showParams)],
            sectionTracer: nil,
            label: "",
            type: .node(identifier: NewHouseNearByCell.identifier))
    }
}

func fillNeighorhoodNearByCell(
    _ data: NeighborhoodDetailData,
    disposeBag: DisposeBag,
    callBack: @escaping () -> Void,
    selector: ((TracerParams) -> Void)?,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NewHouseNearByCell {
        if let lat = data.neighborhoodInfo?.gaodeLat, let lng = data.neighborhoodInfo?.gaodeLng {
            theCell.setLocation(lat: lat, lng: lng)
        }
        theCell.callBackIndexChanged = callBack
        theCell.mapMaskBtn.rx.controlEvent(UIControlEvents.touchUpInside)
            .bind { () in
                selector?(TracerParams.momoid())
            }
            .disposed(by: theCell.disposeCell)
        
    }
}

func parseNewHouseNearByNode(
    _ newHouseData: NewHouseData,
    traceExt: TracerParams = TracerParams.momoid(),
    houseId: String,
    navVC: UINavigationController?,
    disposeBag: DisposeBag,
    callBack: @escaping () -> Void) -> () -> TableSectionNode {
    return {
        var selector: ((TracerParams) -> Void)?
        var mapSelector: ((TracerParams) -> Void)?
        let showParams = TracerParams.momoid() <|>
            toTracerParams("new_detail", key: "page_type") <|>
            toTracerParams("map", key: "element_type") <|>
        traceExt
        
        let params = TracerParams.momoid() <|>
            toTracerParams("map", key: "element_from") <|>
            toTracerParams(selectTraceParam(traceExt, key: "log_pb") ?? "be_null", key: "log_pb") <|>
            toTracerParams(houseId, key: "group_id") <|>
            toTracerParams("map_list", key: "click_type") <|>
            toTracerParams("new_detail", key: "enter_from")
        let mapSelectorParams = EnvContext.shared.homePageParams <|>
            params <|>
            beNull(key: "map_tag") <|>
            toTracerParams("new_detail", key: "page_type") <|>
            toTracerParams("neighborhood_nearby", key: "element_type") <|>
            toTracerParams("map", key: "click_type") <|>
        traceExt
        if let lat = newHouseData.coreInfo?.geodeLat, let lng = newHouseData.coreInfo?.geodeLng {
            //            recordEvent(key: "click_map", params: params)
            
            selector = openMapPage(
                navVC:navVC,
                lat:lat,
                lng: lng,
                title: newHouseData.coreInfo?.name ?? "",
                clickMapParams: mapSelectorParams,
                traceParams: params,
                disposeBag: disposeBag)
            
            mapSelector = openMapPage(
                navVC:navVC,
                lat:lat,
                lng: lng,
                title: newHouseData.coreInfo?.name ?? "",
                clickMapParams: mapSelectorParams,
                traceParams: params <|> toTracerParams("map", key: "click_type"),
                disposeBag: disposeBag)
        }
        let cellRender = curry(fillNewHouseNearByCell)(newHouseData)(disposeBag)(callBack)(mapSelector)
        
        return TableSectionNode(
            items: [oneTimeRender(cellRender)],
            selectors: selector != nil ? [selector!] : nil,
            tracer: [elementShowOnceRecord(params: showParams)],
            sectionTracer: nil,
            label: "",
            type: .node(identifier: NewHouseNearByCell.identifier))
    }
}

func fillNewHouseNearByCell(
    _ data: NewHouseData,
    disposeBag: DisposeBag,
    callBack: @escaping () -> Void,
    selector: ((TracerParams) -> Void)?,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NewHouseNearByCell {
        if let lat = data.coreInfo?.geodeLat, let lng = data.coreInfo?.geodeLng {
            theCell.setLocation(lat: lat, lng: lng)
        }
        theCell.callBackIndexChanged = callBack
        theCell.mapMaskBtn.rx.tap
            .bind { () in
                selector?(TracerParams.momoid())
            }
            .disposed(by: theCell.disposeCell)
    }
}

func openMapPage(
    navVC: UINavigationController? = EnvContext.shared.rootNavController,
    lat: String,
    lng: String,
    title: String,
    clickMapParams: TracerParams,
    traceParams: TracerParams,
    openMapType: OpenMapType? = .autoMatchType,
    disposeBag: DisposeBag) -> (TracerParams) -> Void{
    return { (_) in
        recordEvent(key: "click_map", params: clickMapParams)
        let vc = LBSMapPageVC(centerPointName: title)
        vc.openMapType = openMapType
        vc.tracerParams = traceParams
        vc.centerPointStr.accept((lat, lng))
        vc.navBar.backBtn.rx.tap
            .subscribe(onNext: { void in
                navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        navVC?.pushViewController(vc, animated: true)
    }
}
