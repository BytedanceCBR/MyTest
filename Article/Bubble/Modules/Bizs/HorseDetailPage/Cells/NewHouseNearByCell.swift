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
//        print("")
    }

    var tracerParams = TracerParams.momoid()

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
        return re
    }()

    lazy var mapImageView: UIImageView = {
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 200)
        let re = UIImageView(frame: frame)
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()
    
    lazy var mapAnnotionImageView: UIImageView = {
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 200)
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
        re.selectionIndicatorEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
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
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 200)
        let re = UIButton(frame: frame)
        return re
    }()
    
    var currentPoiType: POIType?
    
    lazy var emptyInfoLabel: UILabel = {
        let re = UILabel()
        let screenWidth = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: screenWidth, height: 200)
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

    fileprivate var pointAnnotation: MyMAAnnotation?

    var disposeBag = DisposeBag()
    
    var disposeCell = DisposeBag()

    fileprivate let poiData = BehaviorRelay<[MyMAAnnotation]>(value: [])

    var centerPoint: CLLocationCoordinate2D?

    private let lock = NSLock()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        EnvContext.shared.currentMapSelect = "公交"

        mapView.delegate = self
        
        contentView.addSubview(mapImageView)
        mapImageView.snp.makeConstraints { maker in
            maker.left.top.right.equalToSuperview()
            maker.height.equalTo(200)
        }
        mapAnnotionImageView.backgroundColor = UIColor.clear
        mapImageView.addSubview(mapAnnotionImageView)
        
        contentView.addSubview(mapMaskBtn)
        mapMaskBtn.snp.makeConstraints { maker in
            maker.edges.equalTo(mapImageView)
        }

        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(mapMaskBtn.snp.bottom)
            maker.height.equalTo(56)
        }
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
        self.mapView.takeSnapshot(in: frame) {[weak self] (image, state) in
            self?.mapImageView.image = image
        }
        
        contentView.addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.top.equalTo(segmentedControl.snp.bottom).offset(-0.5)
            maker.height.equalTo(0.5)
            
        }

        contentView.addSubview(locationList)
        locationList.snp.makeConstraints { maker in
            maker.top.equalTo(segmentedControl.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(156)
        }

        contentView.addSubview(emptyInfoLabel)
        emptyInfoLabel.snp.makeConstraints { maker in
            maker.center.equalTo(locationList.snp.center)
            maker.width.greaterThanOrEqualTo(100)
            maker.height.equalTo(20)
        }

        contentView.addSubview(seperateLineView)
        seperateLineView.snp.makeConstraints { maker in
            maker.height.equalTo(6)
            maker.bottom.left.right.equalToSuperview()
            maker.top.equalTo(locationList.snp.bottom)
         }
        locationList.estimatedRowHeight = 52
        locationList.rowHeight = UITableViewAutomaticDimension
        locationList.dataSource = locationListViewModel
        locationList.delegate = locationListViewModel
        

        segmentedControl.indexChangeBlock = { [unowned self] index in
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            let poiType = self.categorys[index]
            
            self.currentPoiType = poiType

            EnvContext.shared.currentMapSelect = poiType.rawValue
            
            let params = self.tracerParams <|>
                toTracerParams(categoryTraceParams(poiType: poiType), key: "map_tag")
            recordEvent(key: "click_map", params: params)
            self.emptyInfoLabel.text = "附近没有\(poiType.rawValue)信息"
            self.requestPOIInfoByType(poiType: poiType)
        }
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
        }
    }


    fileprivate func resetAnnotations(_ annotations: [MyMAAnnotation]) {
        guard let center = centerPoint else {
            return
        }
        let pointAnnotation = MyMAAnnotation()
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
        poiData.value.forEach { annotation in
            mapView.removeAnnotation(annotation)
        }
        if let pointAnnotation = pointAnnotation {
            mapView.removeAnnotations([pointAnnotation])
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

        if let annotation = annotation as? MyMAAnnotation {

            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)

            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            if annotation.type.rawValue == "交通" {
                annotationView?.image = #imageLiteral(resourceName: "icon-bus")
            } else {
                annotationView?.image = getMapPoiIcon(category: annotation.type.rawValue)
            }
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView?.centerOffset = CGPoint(x: 0, y: -18)

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
        let pois = response.pois.take(3).map { (poi) -> MyMAAnnotation in
            let re = MyMAAnnotation()
            re.type = categorys[segmentedControl.selectedSegmentIndex]
            re.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
            re.title = poi.name
            return re
        }

        if let center = centerPoint {
            let from = MAMapPointForCoordinate(center)
            let pois = response.pois.filter { poi in
                let to = MAMapPointForCoordinate(CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(poi.location.latitude),
                    longitude: CLLocationDegrees(poi.location.longitude)))
                let distance = MAMetersBetweenMapPoints(from, to)
                return distance < 5000 //5 公里
            }
            locationListViewModel.datas = pois
            emptyInfoLabel.isHidden = locationListViewModel.datas.count != 0
            locationList.isUserInteractionEnabled = locationListViewModel.datas.count == 0
            locationList.reloadData()
        }
        poiData.accept(pois)
        self.resetAnnotations(pois)

        self.snapshotMap()
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

fileprivate class MyMAAnnotation: MAPointAnnotation {
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
            maker.right.equalToSuperview().offset(-15)
            maker.top.equalTo(15)
            maker.height.equalTo(22)
            maker.bottom.equalToSuperview().offset(-15)
        }

        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(label2)
            maker.height.equalTo(22)
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
        return (datas.count>0) ? 3 : 0
    }
    
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("LocationListViewModel")
    }
}

func parseNeighorhoodNearByNode(
    _ data: NeighborhoodDetailData,
    traceExtension: TracerParams = TracerParams.momoid(),
    houseId: String,
    navVC: UINavigationController?,
    disposeBag: DisposeBag) -> () -> TableSectionNode? {
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
                toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
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
//            recordEvent(key: "click_map", params: params)
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
                    traceParams: params,
                    disposeBag: disposeBag)
        }
        let cellRender = curry(fillNeighorhoodNearByCell)(data)(disposeBag)(mapSelector)

        return TableSectionNode(
            items: [oneTimeRender(cellRender)],
            selectors: selector != nil ? [selector!] : nil,
                tracer: [elementShowOnceRecord(params: showParams)],
            label: "",
            type: .node(identifier: NewHouseNearByCell.identifier))
    }
}

func fillNeighorhoodNearByCell(
    _ data: NeighborhoodDetailData,
    disposeBag: DisposeBag,
    selector: ((TracerParams) -> Void)?,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NewHouseNearByCell {
        if let lat = data.neighborhoodInfo?.gaodeLat, let lng = data.neighborhoodInfo?.gaodeLng {
            theCell.setLocation(lat: lat, lng: lng)
        }

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
    disposeBag: DisposeBag) -> () -> TableSectionNode {
    return {
        var selector: ((TracerParams) -> Void)?
        var mapSelector: ((TracerParams) -> Void)?
        let showParams = TracerParams.momoid() <|>
            toTracerParams("new_detail", key: "page_type") <|>
            toTracerParams("map", key: "element_type") <|>
            traceExt

        let params = TracerParams.momoid() <|>
            toTracerParams(newHouseData.logPB ?? "be_null", key: "log_pb") <|>
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
                traceParams: params,
                disposeBag: disposeBag)
        }
        let cellRender = curry(fillNewHouseNearByCell)(newHouseData)(disposeBag)(mapSelector)

        return TableSectionNode(
            items: [oneTimeRender(cellRender)],
            selectors: selector != nil ? [selector!] : nil,
                tracer: [elementShowOnceRecord(params: showParams)],
            label: "",
            type: .node(identifier: NewHouseNearByCell.identifier))
    }
}

func fillNewHouseNearByCell(
    _ data: NewHouseData,
    disposeBag: DisposeBag,
    selector: ((TracerParams) -> Void)?,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NewHouseNearByCell {
        if let lat = data.coreInfo?.geodeLat, let lng = data.coreInfo?.geodeLng {
            theCell.setLocation(lat: lat, lng: lng)
        }
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
