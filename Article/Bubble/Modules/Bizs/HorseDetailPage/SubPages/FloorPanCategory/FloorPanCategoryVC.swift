//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class FloorPanCategoryVC: BaseSubPageViewController {

    var floorPanId: String

    lazy var segmentedControl: FWSegmentedControl = {
        let re = FWSegmentedControl.segmentedWith(
                scType: SCType.text,
                scWidthStyle: SCWidthStyle.fixed,
                sectionTitleArray: nil,
                sectionImageArray: nil,
                sectionSelectedImageArray: nil,
                frame: CGRect.zero)
        re.selectionIndicatorHeight = 1
        re.sectionTitleArray = ["全部"]
        re.scSelectionIndicatorStyle = .fullWidthStripe
        re.scWidthStyle = .dynamic
        re.segmentEdgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let attributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(15),
                          NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#222222")]

        let selectedAttributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(15),
                                  NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#f85959")]
        re.titleTextAttributes = attributes
        re.selectedTitleTextAttributes = selectedAttributes
        re.selectionIndicatorColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()
    
    lazy var bottomLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return re
    }()

    var leftFilterView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()
    
    var leftView: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()

    var floorPanCategoryViewModel: FloorPanCategoryViewModel?
    

    init(isHiddenBottomBar: Bool, floorPanId: String, bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.floorPanId = floorPanId
        super.init(identifier: floorPanId,
                   isHiddenBottomBar: isHiddenBottomBar,
                bottomBarBinder: bottomBarBinder)
        self.navBar.title.text = "楼盘户型"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.floorPanCategoryViewModel = FloorPanCategoryViewModel(
                tableView: tableView,
                navVC: self.navigationController,
                segmentedControl: segmentedControl,
                leftFilterView: leftFilterView,
                bottomBarBinder: bottomBarBinder)
        self.view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.top.equalTo(navBar.snp.bottom)
            maker.height.equalTo(40)
        }

        self.view.addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(segmentedControl.snp.bottom)
            maker.height.equalTo(0.5)
           
        }
        
        self.view.addSubview(leftView)
        leftView.snp.makeConstraints { maker in
            maker.width.equalTo(80)
            maker.top.equalTo(bottomLine.snp.bottom)
            maker.left.equalToSuperview()
            maker.bottom.equalTo(tableView)
        }
        
        self.view.addSubview(leftFilterView)
        leftFilterView.snp.makeConstraints { maker in
            maker.width.equalTo(80)
            maker.top.equalTo(bottomLine.snp.bottom)
            maker.left.equalToSuperview()
        }

        tableView.snp.remakeConstraints { maker in
            maker.top.equalTo(segmentedControl.snp.bottom)
            maker.left.equalTo(leftFilterView.snp.right)
            maker.bottom.equalTo(bottomBar.snp.top)
            maker.right.equalToSuperview()
        }

        floorPanCategoryViewModel?.request(courtId: Int64(floorPanId)!)
        tracerParams = tracerParams <|>
            toTracerParams("click", key: "enter_type") <|>
            toTracerParams(HouseCategory.house_model_list.rawValue, key: EventKeys.category_name)

        stayTimeParams = tracerParams <|> traceStayTime()

        recordEvent(key: TraceEventName.enter_category, params: tracerParams)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams)
        }
    }
}
