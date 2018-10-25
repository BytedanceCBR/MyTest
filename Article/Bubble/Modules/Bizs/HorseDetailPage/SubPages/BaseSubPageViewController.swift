//
//  BaseSubPageViewController.swift
//  Bubble
//
//  Created by linlin on 2018/7/11.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Reachability
typealias FollowUpBottomBarBinder = (HouseDetailPageBottomBarView, UIButton) -> Void

class BaseSubPageViewController: BaseViewController {

    lazy var tableView: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }

        re.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        return re
    }()

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar()
        re.rightBtn2.setImage(UIImage(named: "star-simple-line-icons"), for: .normal)
        re.rightBtn2.setImage(#imageLiteral(resourceName: "tab-collect-yellow"), for: .selected)
        re.rightBtn2.adjustsImageWhenHighlighted = false
        re.rightBtn2.setImage(#imageLiteral(resourceName: "tab-collect-yellow"), for: [.highlighted, .selected]) //按钮isSelected状态时再次点击
        re.rightBtn2.isHidden = false
        return re
    }()

    lazy var bottomBar: HouseDetailPageBottomBarView = {
        let re = HouseDetailPageBottomBarView()
        return re
    }()

    lazy var infoMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        re.label.text = "网络异常"
        re.icon.image = UIImage(named:"group-4")
        return re
    }()

    var houseType: HouseType = .newHouse
    var followActionType: FollowActionType = .newHouse
    var identifier: String

    private let isHiddenBottomBar: Bool

    let disposeBag = DisposeBag()

    var bottomBarBinder: FollowUpBottomBarBinder

    var tracerParams = TracerParams.momoid()

    var stayTimeParams: TracerParams?

    init(identifier: String,
         isHiddenBottomBar: Bool = false,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.identifier = identifier
        self.isHiddenBottomBar = isHiddenBottomBar
        self.bottomBarBinder = bottomBarBinder
        super.init(nibName: nil, bundle: nil)
        bottomBarBinder(bottomBar, navBar.rightBtn2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(navBar)
        navBar.removeGradientColor()
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }

        let titleStr:String = !self.isHiddenBottomBar ? "电话咨询" : "询底价"
        bottomBar.contactBtn.setTitle(titleStr, for: .normal)
        bottomBar.contactBtn.setTitle(titleStr, for: .highlighted)
        
        self.view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
            maker.left.right.equalToSuperview()
            
        }

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(bottomBar.snp.top)

//            if !self.isHiddenBottomBar {
//                maker.bottom.equalTo(bottomBar.snp.top)
//            } else {
//                maker.bottom.equalToSuperview()
//            }

        }

        view.addSubview(infoMaskView)
        infoMaskView.snp.makeConstraints { maker in
            maker.edges.equalTo(tableView.snp.edges)
        }
        // 绑定网络状态监控
        Reachability.rx.isReachable
                .bind { [unowned self] reachable in
                    if !reachable {
                        self.infoMaskView.label.text = "网络不给力，试试刷新页面"
                    }
                }
                .disposed(by: disposeBag)

        if EnvContext.shared.client.reachability.connection == .none {
            self.bottomBar.isHidden = true
        } else {
            self.bottomBar.isHidden = false
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func followIt(
            houseType: HouseType,
            followAction: FollowActionType,
            followId: String) -> () -> Void {
        return { [unowned self] in
            requestFollow(
                    houseType: houseType,
                    followId: followId,
                    actionType: followAction)
                    .subscribe(onNext: { response in

                    }, onError: { error in

                    })
                    .disposed(by: self.disposeBag)
        }
    }
    
    func showEmptyInfo() {

    }

}
