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

    lazy var mapView: MAMapView = {
        let re = MAMapView(frame: CGRect.zero)
        re.showsCompass = false
        re.showsScale = false
        re.isZoomEnabled = false
        re.isScrollEnabled = false
        re.zoomLevel = 14
        return re
    }()

    lazy var locationList: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
        re.allowsSelection = false
        re.isUserInteractionEnabled = false
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
        re.selectionIndicatorHeight = 1
        re.sectionTitleArray = categorys.map {
            $0.rawValue
        }
        re.scSelectionIndicatorStyle = .fullWidthStripe

        let attributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16) ?? UIFont.systemFont(ofSize: 16),
                          NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#999999")]

        let selectedAttributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16) ?? UIFont.systemFont(ofSize: 16),
                                  NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#f85959")]
        re.titleTextAttributes = attributes
        re.selectedTitleTextAttributes = selectedAttributes
        re.selectionIndicatorColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var locationListViewModel: LocationListViewModel = {
        LocationListViewModel()
    }()

    lazy var search: AMapSearchAPI = {
        let re = AMapSearchAPI()
        re?.delegate = self
        return re!
    }()

    var disposeBag = DisposeBag()

    fileprivate let poiData = BehaviorRelay<[MyMAAnnotation]>(value: [])

    var currentPoiType = POIType.traffic

    var centerPoint: CLLocationCoordinate2D?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        mapView.delegate = self
        contentView.addSubview(mapView)
        mapView.snp.makeConstraints { maker in
            maker.left.top.right.equalToSuperview()
            maker.height.equalTo(200)
        }

        contentView.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(mapView.snp.bottom)
            maker.height.equalTo(56)
        }

        contentView.addSubview(locationList)
        locationList.snp.makeConstraints { maker in
            maker.top.equalTo(segmentedControl.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(156)
        }
        locationList.dataSource = locationListViewModel
        poiData
                .debug()
                .subscribe(onNext: { [unowned self] annotations in
                    self.resetAnnotations(annotations)
                })
                .disposed(by: disposeBag)
        segmentedControl.indexChangeBlock = { [weak self] index in
            self?.poiData.value.forEach { annotation in
                self?.mapView.removeAnnotation(annotation)
            }
            if let poiType = self?.categorys[index] {
                self?.requestPOIInfoByType(poiType: poiType)
            }
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
            requestPOIInfoByType(poiType: currentPoiType)
        }
    }


    fileprivate func resetAnnotations(_ annotations: [MyMAAnnotation]) {
        guard let center = centerPoint else {
            return
        }
        let pointAnnotation = MyMAAnnotation()
        pointAnnotation.type = .center
        pointAnnotation.coordinate = center


        ([pointAnnotation] + poiData.value).forEach { annotation in
            mapView.addAnnotation(annotation)
        }
    }

    func requestPOIInfoByType(poiType: POIType) {
        guard let center = centerPoint else {
            assertionFailure()
            return
        }
        search.cancelAllRequests()
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = poiType == POIType.traffic ? "地铁 公交" : poiType.rawValue
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude: CGFloat(center.longitude))
        request.requireExtension = true
        request.requireSubPOIs = true
        request.cityLimit = true
        search.aMapPOIKeywordsSearch(request)
    }

    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {

        if annotation.isKind(of: MAPointAnnotation.self) {

            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)

            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }

            annotationView?.image = #imageLiteral(resourceName: "icon-location")
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView?.centerOffset = CGPoint(x: 0, y: -18)

            return annotationView ?? MAAnnotationView(annotation: annotation, reuseIdentifier: "default")
        }

        return MAAnnotationView(annotation: annotation, reuseIdentifier: "default")
    }

    /* POI 搜索回调. */
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {

        if response.count == 0 {
            return
        }
        let upper = response.count > 3 ? 3 : response.count
        let pois = response.pois.map { (poi) -> MyMAAnnotation in
            let re = MyMAAnnotation()
            re.type = currentPoiType
            re.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
            re.title = poi.name
            return re
        }

        if let center = centerPoint {
            let from = MAMapPointForCoordinate(center)

            locationListViewModel.datas = response.pois.filter { poi in
                let to = MAMapPointForCoordinate(CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(poi.location.latitude),
                    longitude: CLLocationDegrees(poi.location.longitude)))
                let distance = MAMetersBetweenMapPoints(from, to)
                return distance < 5000 //5 公里
            }
            locationList.reloadData()
        }
        poiData.accept(pois)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        search.cancelAllRequests()
    }
}

enum POIType: String {
    case center
    case subway = "地铁"
    case mall = "购物"
    case hospital = "医疗"
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
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#222222")
        return re
    }()

    lazy var label2: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.textAlignment = .right
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(16)
            maker.height.equalTo(20)
            maker.bottom.equalToSuperview().offset(-16)
        }

        contentView.addSubview(label2)
        label2.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-15)
            maker.top.equalTo(16)
            maker.height.equalTo(20)
            maker.bottom.equalToSuperview().offset(-16)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class LocationListViewModel: NSObject, UITableViewDataSource {

    var datas: [AMapPOI] = []

    var center: CLLocationCoordinate2D?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count > 3 ? 3 : datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        if let theCell = cell as? LocationCell {
            let poi = datas[indexPath.row]
            theCell.label.text = poi.name
            if let theCenter = center {
                let from = MAMapPointForCoordinate(theCenter)
                let to = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude)))
                let distance = MAMetersBetweenMapPoints(from, to)
                theCell.label2.text = String(format: "%.1f公里", arguments: [distance / 1000])
            }

        }
        return cell
    }
}

func parseNewHouseNearByNode(_ newHouseData: NewHouseData) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillNewHouseNearByCell)(newHouseData)
        return TableSectionNode(items: [cellRender], label: "", type: .node(identifier: NewHouseNearByCell.identifier))
    }
}

func fillNewHouseNearByCell(_ data: NewHouseData, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NewHouseNearByCell {
        if let lat = data.coreInfo?.geodeLat, let lng = data.coreInfo?.geodeLng {
            theCell.setLocation(lat: lat, lng: lng)
        }
    }
}
