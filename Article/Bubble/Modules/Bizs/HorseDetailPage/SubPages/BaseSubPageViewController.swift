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

typealias FollowUpBottomBarBinder = (HouseDetailPageBottomBarView) -> Void

class BaseSubPageViewController: BaseViewController {

    lazy var tableView: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
        re.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        return re
    }()

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar()
        return re
    }()

    lazy var bottomBar: HouseDetailPageBottomBarView = {
        let re = HouseDetailPageBottomBarView()
        return re
    }()

    var houseType: HouseType = .newHouse
    var followActionType: FollowActionType = .newHouse
    var identifier: String

    private let isHiddenBottomBar: Bool

    let disposeBag = DisposeBag()

    var bottomBarBinder: FollowUpBottomBarBinder

    init(identifier: String,
         isHiddenBottomBar: Bool = false,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.identifier = identifier
        self.isHiddenBottomBar = isHiddenBottomBar
        self.bottomBarBinder = bottomBarBinder
        super.init(nibName: nil, bundle: nil)
        bottomBarBinder(bottomBar)
//        followStatus
//                .filter { (result) -> Bool in
//                    if case .success(_) = result {
//                        return true
//                    } else {
//                        return false
//                    }
//                }
//                .map { (result) -> Bool in
//                    if case let .success(status) = result {
//                        return status
//                    } else {
//                        return false
//                    }
//                }
//                .bind(to: bottomBar.favouriteBtn.rx.isSelected)
//                .disposed(by: disposeBag)
//        bottomBar.favouriteBtn.rx.tap
//                .bind(onNext: self.followThisItem)
//                .disposed(by: disposeBag)
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

        if !self.isHiddenBottomBar {
            self.view.addSubview(bottomBar)
            bottomBar.snp.makeConstraints { maker in
                if #available(iOS 11, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    maker.bottom.equalToSuperview()
                }
                maker.left.right.equalToSuperview()
            }
        }


        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            if !self.isHiddenBottomBar {
                maker.bottom.equalTo(bottomBar.snp.top)
            } else {
                if #available(iOS 11, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    maker.bottom.equalToSuperview()
                }
            }

        }
        // Do any additional setup after loading the view.

        bottomBar.favouriteBtn.rx.tap
            .bind(onNext: self.followIt(
                houseType: houseType,
                followAction: followActionType,
                followId: identifier))
            .disposed(by: disposeBag)
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

}
