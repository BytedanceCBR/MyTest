//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
// 楼盘信息
class FloorPanInfoVC: BaseSubPageViewController, UIViewControllerErrorHandler {

    let floorPanId: String

    let newHouseData: NewHouseData

    var floorPanInfoViewModel: FloorPanInfoViewModel?

    init(isHiddenBottomBar: Bool,
         floorPanId: String,
         newHouseData: NewHouseData,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.floorPanId = floorPanId
        self.newHouseData = newHouseData
        super.init(identifier: floorPanId,
                   isHiddenBottomBar: isHiddenBottomBar,
                bottomBarBinder: bottomBarBinder)
        self.navBar.title.text = "楼盘信息"
        self.floorPanInfoViewModel = FloorPanInfoViewModel(tableView: tableView, newHouseData: newHouseData)
        self.navBar.backBtn.rx.tap
            .subscribe(onNext: { [unowned self] void in
                if let navVC = self.navigationController {
                    navVC.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: 0,
                                                   right: 0)
        
        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView.isHidden = false
            infoMaskView.label.text = "网络异常"
        } else {
            self.tt_startUpdate()
            self.floorPanInfoViewModel?.request(
                floorPanId: floorPanId,
                newHouseData: newHouseData)
        }

        self.floorPanInfoViewModel?.datas
            .skip(1)
            .bind(onNext: { [unowned self] (datas) in
                if datas.count > 0 {
                    self.infoMaskView.isHidden = true
                }
                self.tt_endUpdataData()
            })
            .disposed(by: disposeBag)

        tracerParams = (EnvContext.shared.homePageParams <|>
            tracerParams <|>
            toTracerParams("house_info_detail", key: "page_type") <|>
            toTracerParams("new_detail", key: "enter_from") <|>
            toTracerParams("house_info", key: "element_from") <|>
            toTracerParams(floorPanId, key: "group_id") <|>
            beNull(key: "rank") <|>
            beNull(key: "card_type")).exclude("house_type")

        stayTimeParams = tracerParams <|>
            traceStayTime()

        recordEvent(key: "go_detail", params: self.tracerParams)
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = self.stayTimeParams {
            recordEvent(key: "stay_page", params: stayTimeParams)
        }
        EnvContext.shared.toast.dismissToast()
        self.stayTimeParams = nil
    }

    func tt_hasValidateData() -> Bool {
        return self.floorPanInfoViewModel?.datas.value.count ?? 0 > 0
    }
}
