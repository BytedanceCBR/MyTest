//
// Created by linlin on 2018/7/11.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class HouseCommentVC: BaseSubPageViewController, PageableVC {
    
    var hasMore = true

    let courtId: Int64

    var houseCommentViewModel: HouseCommentViewModel?


    init(courtId: Int64, isHiddenBottomBar: Bool = false,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.courtId = courtId
        super.init(identifier: "\(courtId)",isHiddenBottomBar: false, bottomBarBinder: bottomBarBinder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title.text = "全网点评"
        houseCommentViewModel = HouseCommentViewModel(tableView: tableView)
        if EnvContext.shared.client.reachability.connection == .none {
            infoMaskView.isHidden = false
            infoMaskView.label.text = "网络异常"
            infoMaskView.retryBtn.isHidden = true
            infoMaskView.isUserInteractionEnabled = false
        } else {
            houseCommentViewModel?.request(courtId: courtId)
        }
//        infoMaskView.tapGesture.rx.event
//            .bind { [unowned self] (_) in
//                if EnvContext.shared.client.reachability.connection == .none {
//                    // 无网络时直接返回空，不请求
//                    EnvContext.shared.toast.showToast("网络异常")
//                    return
//                }
//                self.houseCommentViewModel?.request(courtId: self.courtId)
//            }
//            .disposed(by: disposeBag)
        self.houseCommentViewModel?.datas.bind(onNext: { [unowned self] (datas) in
            if datas.count > 0 {
                self.infoMaskView.isHidden = true
            }
            })
            .disposed(by: disposeBag)
        houseCommentViewModel?.onDataLoaded = self.onDataLoaded()
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        tracerParams = (EnvContext.shared.homePageParams <|> tracerParams <|>
            toTracerParams("house_comment_detail", key: "page_type") <|>
            toTracerParams("house_comment", key: "element_from") <|>
            toTracerParams(courtId, key: "group_id") <|>
            beNull(key: "rank") <|>
            beNull(key: "card_type")).exclude("house_type")

        stayTimeParams = tracerParams <|> traceStayTime()

        recordEvent(key: "go_detail", params: self.tracerParams.exclude("house_type"))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let stayTimeParams = self.stayTimeParams {
            recordEvent(key: "stay_page", params: stayTimeParams)
        }
        self.stayTimeParams = nil
        EnvContext.shared.toast.dismissToast()
    }

    func loadMore() {
        houseCommentViewModel?.pageableLoader?()
    }
}
