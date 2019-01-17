//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class FloorPanCategoryVC: BaseSubPageViewController, UIViewControllerErrorHandler {

    var floorPanId: String
    
    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "house_model_list")

    lazy var emptyMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()
    
    private var errorVM : NHErrorViewModel?
    
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
        re.scSelectionIndicatorStyle = .contentWidthStripe
        re.scWidthStyle = .dynamic
        re.segmentEdgeInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let attributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(15),
                          NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHDarkIndigoColor)]

        let selectedAttributes = [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(15),
                                  NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: kFHClearBlueColor)]
        re.titleTextAttributes = attributes
        re.selectedTitleTextAttributes = selectedAttributes
        re.selectionIndicatorColor = hexStringToUIColor(hex: kFHClearBlueColor)
        return re
    }()
    
    lazy var bottomLine: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHSilver2Color)
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

    var logPB: Any?
    
    var isHiddenBottom: Bool = false

    init(isHiddenBottomBar: Bool,
         floorPanId: String,
         followPage: BehaviorRelay<String>,
         logPB: Any?,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.logPB = logPB
        self.floorPanId = floorPanId
        self.followPage = followPage
        self.isHiddenBottom = isHiddenBottomBar
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
        self.navBar.seperatorLine.isHidden = true
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        var traceParamsDict = tracerParams.paramsGetter([:])
        
        self.floorPanCategoryViewModel = FloorPanCategoryViewModel(
                tableView: tableView,
                navVC: self.navigationController,
                isHiddenBottomBar: isHiddenBottom,
                logPBVC: traceParamsDict["log_pb"],
                followPage: self.followPage,
                segmentedControl: segmentedControl,
                leftFilterView: leftFilterView,
                bottomBarBinder: bottomBarBinder)
        self.floorPanCategoryViewModel?.logPB = logPB
        self.view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
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
        

        tracerParams = tracerParams <|>
            toTracerParams("click", key: "enter_type") <|>
            toTracerParams(HouseCategory.house_model_list.rawValue, key: EventKeys.category_name)
  
        stayTimeParams = tracerParams.exclude("card_type") <|> traceStayTime()
        if let logpb = self.logPB as? [String: Any]
        {
            stayTimeParams = tracerParams <|> traceStayTime() <|>
            toTracerParams(logpb, key: "log_pb")
            
            tracerParams = tracerParams <|>
            toTracerParams(logpb, key: "log_pb")
        }
        recordEvent(key: TraceEventName.enter_category, params: tracerParams.exclude("card_type"))
        
       
        self.view.addSubview(emptyMaskView)
        emptyMaskView.snp.makeConstraints { maker in
            maker.top.bottom.right.left.equalTo(view)
        }
        self.errorVM = NHErrorViewModel(errorMask:emptyMaskView,requestRetryText:"网络异常")
        
        self.errorVM?.onRequestViewDidLoad()
        //FIXME: uncomment this
//        self.errorVM?.onRequest()
        self.tt_startUpdate()
        floorPanCategoryViewModel?.request(courtId: Int64(floorPanId)!)
        self.floorPanCategoryViewModel?.onRequestFinished = { [weak self] in
            self?.tt_endUpdataData()
        }
        
        self.floorPanCategoryViewModel?.tracerParams = tracerParams
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        followPage.accept("house_model_list")
        view.bringSubview(toFront: emptyMaskView)
        emptyMaskView.snp.remakeConstraints { maker in
            maker.top.bottom.right.left.equalTo(view)
        }
        
        view.bringSubview(toFront: bottomBar)
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams.exclude("card_type"))
        }
        EnvContext.shared.toast.dismissToast()
    }

    func tt_hasValidateData() -> Bool {
        return self.floorPanCategoryViewModel?.items.value.count ?? 0 > 0
    }

}
