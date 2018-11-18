//
//  LBSMapPageVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/30.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import MapKit
import Reachability

enum OpenMapType: Int {
    case defautFirstType = 1 //默认选择第一个
    case autoMatchType = 2 //根据文本自动过滤
}

class LBSMapPageVC: BaseViewController, MAMapViewDelegate, AMapSearchDelegate {

    lazy var search: AMapSearchAPI = {
        let re = AMapSearchAPI()
        re?.delegate = self
        return re!
    }()

    fileprivate lazy var bottomView: BottomBarView = {
        let re = BottomBarView()
        return re
    }()
    
    var openMapType: OpenMapType?

    var navBar: LBSMapPageNavBar = {
        let re = LBSMapPageNavBar()
        re.title.text = "位置及周边"
        re.rightBtn.setTitle("导航", for: .normal)
        re.rightBtn.setTitleColor(hexStringToUIColor(hex: "#299cff"), for: .normal)
        re.rightBtn.isSelected = false
        return re
    }()
    
    lazy var mapContainer: UIView = {
        let re = UIView()
        return re
    }()

    var mapView: MAMapView?

    private let disposeBag = DisposeBag()

    let centerPointStr = BehaviorRelay<(String, String)?>(value: nil)

    let searchCategory = BehaviorRelay<String>(value: "银行")

    fileprivate let poiData = BehaviorRelay<[MyMAAnnotation]>(value: [])

    var tracerParams = TracerParams.momoid()

    var stayMapParams = TracerParams.momoid()

    var centerPointName: String

    var fromLogPb: Any?
    
    init(centerPointName: String) {
        self.centerPointName = centerPointName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { maker in
//            maker.width.equalTo(34).priority(.high)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
            maker.height.equalTo(43)
            maker.left.right.equalToSuperview()
        }

        view.addSubview(mapContainer)
        mapContainer.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
            maker.bottom.equalTo(bottomView.snp.top)
        }
        let mapView = MAMapView(frame: mapContainer.bounds)
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.showsScale = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = false
        mapView.zoomLevel = 15
        mapContainer.addSubview(mapView)
        mapView.snp.makeConstraints { maker in
            maker.top.bottom.right.left.equalToSuperview()
        }
//        if let stylePath = Bundle.main.path(forResource: "gaode_map_style", ofType: "data"){
//            if let styleUrl = URL(string:stylePath){
//                if let styleData = try? Data(contentsOf: styleUrl) {
//                    mapView.customMapStyleEnabled = true
//                    mapView.setCustomMapStyleWithWebData(styleData)
//                }
//            }
//        }
        
        
        self.mapView = mapView
        setupBottomBar()
        
        //绑定地图中心
        centerPointStr
            .filter { $0 != nil }
            .bind { [weak self] e in
                if let (lat, lng) = e {
                    self?.setLocation(lat: lat, lng: lng)
                }
            }
            .disposed(by: disposeBag)
        
        // 绑定切换分类逻辑
        Observable
            .combineLatest(centerPointStr, searchCategory)
            .filter { $0.0 != nil }
            .map { (e) -> (CLLocationCoordinate2D?, String) in
                let (center, category) = e
                if let lat = center?.0,  let theLat = Double(lat), let lng = center?.1, let theLng = Double(lng) {
                    let center = CLLocationCoordinate2D(latitude: theLat, longitude: theLng)
                    return (center, category)
                    
                } else {
                    return (nil, category)
                }
            }
            .filter { $0.0 != nil }
            .map { ($0.0!, $0.1) }
            .subscribe(onNext: { [unowned self] (e) in
                let (center, category) = e
                self.requestPOIInfo(center: center, category: category)
                self.setLocation(lat: "\(center.latitude)", lng: "\(center.longitude)")
            })
            .disposed(by: disposeBag)

        poiData
                .skip(1)
                .subscribe(onNext: { [unowned self] annotations in
                    self.setAnnotations(annotations)
                })
                .disposed(by: disposeBag)
        navBar.rightBtn.rx.tap
                .bind { [unowned self] void in
                    let params = self.tracerParams <|>
                            toTracerParams("navigation", key: "click_type")
                    recordEvent(key: "click_map", params: params)
                    self.creatOptionMenu()
                }
                .disposed(by: disposeBag)

        self.tracerParams = EnvContext.shared.homePageParams <|>
                self.tracerParams <|>
//                toTracerParams(self.fromLogPb ?? "be_null", key: "log_pb") <|>
                toTracerParams("map_detail", key: "page_type")
        self.stayMapParams = self.tracerParams <|>
            traceStayTime()

        recordEvent(key: "enter_map", params: self.tracerParams)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stayMapParams = self.tracerParams <|>
            traceStayTime()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        recordEvent(key: "stay_map", params: self.stayMapParams)
    }

    fileprivate func cleanAllAnnotations() {
        poiData.value.forEach { annotation in
            mapView?.removeAnnotation(annotation)
        }
    }

    fileprivate func setAnnotations(_ annotations: [MyMAAnnotation]) {
        let pointAnnotation = MyMAAnnotation()
        pointAnnotation.type = ""
        if let centerStr = centerPointStr.value, let center = centerPoint(center: centerStr) {
            pointAnnotation.coordinate = center
        }
        pointAnnotation.title = self.centerPointName


        ([pointAnnotation] + poiData.value).forEach { annotation in
            mapView?.addAnnotation(annotation)
        }
    }
    
    func centerPoint(center: (String, String)) -> CLLocationCoordinate2D? {
        if let theLat = Double(center.0), let theLng = Double(center.1) {
            return CLLocationCoordinate2D(latitude: theLat, longitude: theLng)
        } else {
            return nil
        }
    }

    private func setupBottomBar() {
        let items = [Item(name: "银行", icon: #imageLiteral(resourceName: "tab-bank-1"), selectedIcon: #imageLiteral(resourceName: "tab-bank-pressed")),
                     Item(name: "公交", icon: #imageLiteral(resourceName: "tab-bus"), selectedIcon: #imageLiteral(resourceName: "tab-bus-pressed")),
                     Item(name: "地铁", icon: #imageLiteral(resourceName: "tab-subway"), selectedIcon: #imageLiteral(resourceName: "tab-subway-pressed")),
                     Item(name: "教育", icon: #imageLiteral(resourceName: "tab-education"), selectedIcon: #imageLiteral(resourceName: "tab-education-pressed")),
                     Item(name: "医院", icon: #imageLiteral(resourceName: "tab-hospital"), selectedIcon: #imageLiteral(resourceName: "tab-hospital-pressed")),
                     Item(name: "休闲", icon: #imageLiteral(resourceName: "tab-relaxation"), selectedIcon: #imageLiteral(resourceName: "tab-relaxation-pressed")),
                     Item(name: "购物", icon: #imageLiteral(resourceName: "tab-mall"), selectedIcon: #imageLiteral(resourceName: "tab-mall-pressed")),
                     Item(name: "健身", icon: #imageLiteral(resourceName:"tab-swim"), selectedIcon: #imageLiteral(resourceName: "tab-swim_press")),
                     Item(name: "美食", icon: #imageLiteral(resourceName: "tab-food"), selectedIcon: #imageLiteral(resourceName: "tab-food_press"))]
        let categoryParams = [
            "银行": "bank",
            "公交": "bus",
            "地铁": "subway",
            "教育": "school",
            "医院": "hospital",
            "休闲": "entertainment",
            "购物": "shopping",
            "健身": "gym",
            "美食": "food"
        ]
        let itemViews = items.map { item -> BottomBarItemView in
            let re = BottomBarItemView()
            re.label.text = item.name
            re.iconButton.setImage(item.icon, for: .normal)
            re.iconButton.setImage(item.selectedIcon, for: .selected)
            re.tapGesture.rx.event
                .bind { [weak re, unowned self] _ in
                    let params = self.tracerParams <|>
                            toTracerParams("map_tag", key: "click_type") <|>
                            toTracerParams(categoryParams[item.name], key: "map_tag")
                    recordEvent(key: "click_map", params: params)
                    re?.isSelected = true
                    if let centerPointV = self.centerPointStr.value{
                        if let coordinateCenter = self.centerPoint(center: centerPointV)
                        {
                              self.mapView?.zoomLevel = 15
                              self.mapView?.setCenter(coordinateCenter, animated: true)
//                            self.mapView?.setRegion(MACoordinateRegionMake(coordinateCenter, MACoordinateSpanMake(0.0195,0.0195)), animated: true)
                        }
                    }
                    self.searchCategory.accept(item.name)
                }
                .disposed(by: self.disposeBag)
            return re
        }

        func clearAllSelectedState(but view: BottomBarItemView) {
            itemViews.forEach { [unowned view] in
                if view != $0 {
                    $0.isSelected = false
                }
            }
        }

        itemViews.forEach { (view) in
            view.tapGesture.rx.event
                .subscribe({ (_) in
                    clearAllSelectedState(but: view)
                })
                .disposed(by: self.disposeBag)
        }
        
        
        if openMapType == .defautFirstType
        {
            itemViews.first?.isSelected = true
            if let category = itemViews.first?.label.text {
                searchCategory.accept(category)
            }
        }else
        {
            var isSlected = false
            for (index,value) in items.enumerated() {
                if value.name == EnvContext.shared.currentMapSelect
                {
                    if itemViews.count > index
                    {
                        itemViews[index].isSelected = true
                        isSlected = true
                    }
                    searchCategory.accept(EnvContext.shared.currentMapSelect)
                }
            }
            if !isSlected
            {
                itemViews.first?.isSelected = true
                if let category = itemViews.first?.label.text {
                    searchCategory.accept(category)
                }
            }
        }
        bottomView.addItems(items: itemViews)
    }

    func setLocation(lat: String, lng: String) {
        if let theLat = Double(lat), let theLng = Double(lng) {
            let center = CLLocationCoordinate2D(latitude: theLat, longitude: theLng)
            mapView?.setCenter(center, animated: false)
            mapView?.overlays.forEach({ (overlay) in
                if let overlayV = overlay as? MAOverlay
                {
                    mapView?.remove(overlayV)
                }
            })
        }
    }

    func requestPOIInfo(center: CLLocationCoordinate2D, category: String) {
        search.cancelAllRequests()

        if EnvContext.shared.client.reachability.connection == .none {
            EnvContext.shared.toast.showToast("网络异常")
            return
        }
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = category
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

            annotationView?.image = getMapPoiIcon(category: annotation.type)
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView?.centerOffset = CGPoint(x: 0, y: -18)
            annotationView?.canShowCallout = true

            return annotationView ?? MAAnnotationView(annotation: annotation, reuseIdentifier: "default")
        }

        return MAAnnotationView(annotation: annotation, reuseIdentifier: "default")
    }
    
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        let circleView = MACircle.init(mapRect: MAMapRectZero)
        let overlayRender = MAOverlayRenderer.init(overlay: circleView)
        return overlayRender
    }


    /* POI 搜索回调. */
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        self.cleanAllAnnotations()
        if response.count == 0 {
            EnvContext.shared.toast.showToast("暂无相关信息")
            return
        }
        
        let pois = response.pois.take(50).map { (poi) -> MyMAAnnotation in
            let re = MyMAAnnotation()
            re.type = searchCategory.value
            re.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
            re.title = poi.name
            return re
        }
        
//        let pois = response.pois.map { (poi) -> MyMAAnnotation in
//            let re = MyMAAnnotation()
//            re.type = searchCategory.value
//            re.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
//            re.title = poi.name
//            return re
//        }
        poiData.accept(pois)
    }
    
    func creatOptionMenu() {
        let applcation = UIApplication.shared
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let centerStr = centerPointStr.value {
            if (applcation.canOpenURL(URL(string: "qqmap://")!) == true) {
                let qqAction = UIAlertAction(title: "腾讯地图", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let urlString = "qqmap://map/routeplan?from=我的位置&type=drive&tocoord=\(centerStr.0),\(centerStr.1)&to=\(""))&coord_type=1&policy=0"
                    let url = URL(string:urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    applcation.openURL(url!)

                })
                optionMenu.addAction(qqAction)
            }

            if (applcation.canOpenURL(URL(string: "iosamap://")!) == true) {
                let gaodeAction = UIAlertAction(title: "高德地图", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let urlString = "iosamap://navi?sourceApplication=app名&backScheme=iosamap://&lat=\(centerStr.0)&lon=\(centerStr.1)&dev=0&style=2"
                    let url = URL(string:urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    applcation.openURL(url!)
                })
                optionMenu.addAction(gaodeAction)
            }

            if (applcation.canOpenURL(URL(string: "comgooglemaps://")!) == true) {
                let googleAction = UIAlertAction(title: "Google地图", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let urlString = "comgooglemaps://?x-source=app名&x-success=comgooglemaps://&saddr=&daddr=\(centerStr.0),\(centerStr.1)&directionsmode=driving"
                    let url = URL(string:urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    applcation.openURL(url!)

                })
                optionMenu.addAction(googleAction)
            }
            if let lat = Double(centerStr.0), let lng = Double(centerStr.1) {
                
                let appleAction = UIAlertAction(title: "苹果地图", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let loc = CLLocationCoordinate2DMake(lat, lng)
                    let currentLocation = MKMapItem.forCurrentLocation()
                    let toLocation = MKMapItem(placemark:MKPlacemark(coordinate:loc,addressDictionary:nil))
//                    toLocation.name = self.siteTitle
                    _ = MKMapItem.openMaps(with: [currentLocation,toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: NSNumber(value: true)])
                })
                optionMenu.addAction(appleAction)
            }
            
            
            if(applcation.canOpenURL(URL(string:"baidumap://")!) == true){
                let baiduAction = UIAlertAction(title: "百度地图", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let urlString = "baidumap://map/direction?origin={{我的位置}}&destination=latlng:\(centerStr.0),\(centerStr.1)|name=\("")&mode=driving&coord_type=gcj02"
                    let url = URL(string:urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    applcation.openURL(url!)
                    
                })
                optionMenu.addAction(baiduAction)
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            optionMenu.addAction(cancelAction)
        }
        self.present(optionMenu, animated: true)
    }

}

fileprivate let categoryIconMap = ["银行": #imageLiteral(resourceName: "icon-bank"),
                                   "公交": #imageLiteral(resourceName: "icon-bus"),
                                   "地铁": #imageLiteral(resourceName: "icon-subway"),
                                   "教育": #imageLiteral(resourceName: "icon_education"),
                                   "医院": #imageLiteral(resourceName: "icon_hospital"),
                                   "休闲": #imageLiteral(resourceName: "icon-relaxation"),
                                   "购物": #imageLiteral(resourceName: "icon-mall"),
                                   "健身": #imageLiteral(resourceName:"icon_swim"),
                                   "美食": #imageLiteral(resourceName:"icon-restaurant")]

func getMapPoiIcon(category: String) -> UIImage {
    return categoryIconMap[category] ?? #imageLiteral(resourceName: "icon-location")
}

fileprivate class MyMAAnnotation: MAPointAnnotation {
    var type: String = ""
}

fileprivate struct Item {
    let name: String
    let icon: UIImage
    let selectedIcon: UIImage
}

fileprivate class BottomBarView: UIView {

    lazy var contentScrollView: UIScrollView = {
        let result = UIScrollView(frame: self.frame)
        result.showsHorizontalScrollIndicator = false
        return result
    }()
    
    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addItems(items: [BottomBarItemView]) {
        subviews.forEach {
            $0.removeFromSuperview()
        }
        
        addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(43)
        }

        contentScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width/6.5 * CGFloat(items.count), height: 43)
        items.forEach { contentScrollView.addSubview($0) }
        items.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        items.snp.makeConstraints { maker in
            maker.top.bottom.equalToSuperview()
            maker.width.equalTo(UIScreen.main.bounds.width/6.5)
        }
        contentScrollView.backgroundColor = UIColor.white
    }

}

fileprivate class BottomBarItemView: UIView {

    lazy var iconButton: UIButton = {
        let re = UIButton()
        re.isUserInteractionEnabled = false
        return re
    }()

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(9)
        if isSelected {
            re.textColor = hexStringToUIColor(hex: "#299cff")
        } else {
            re.textColor = hexStringToUIColor(hex: "#8a9299")
        }
        re.textAlignment = .center
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    var isSelected: Bool = false {
        didSet {
            iconButton.isSelected = isSelected
            if isSelected {
                label.textColor = hexStringToUIColor(hex: "#299cff")
            } else {
                label.textColor = hexStringToUIColor(hex: "#8a9299")
            }
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        addSubview(iconButton)
        iconButton.snp.makeConstraints { maker in
            maker.height.width.equalTo(32)
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
        }

        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalTo(iconButton.snp.bottom).offset(-5)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(13)
            maker.bottom.equalTo(-3)
        }

        addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
