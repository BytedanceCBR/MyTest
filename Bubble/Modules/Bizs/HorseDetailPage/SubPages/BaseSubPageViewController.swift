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
class BaseSubPageViewController: BaseViewController {

    lazy var tableView: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
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

    init(identifier: String, isHiddenBottomBar: Bool = false) {
        self.identifier = identifier
        self.isHiddenBottomBar = isHiddenBottomBar
        super.init(nibName: nil, bundle: nil)
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
            maker.left.right.top.equalToSuperview()
        }

        if !self.isHiddenBottomBar {
            self.view.addSubview(bottomBar)
            bottomBar.snp.makeConstraints { maker in
                maker.left.right.bottom.equalToSuperview()
            }
        }


        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            if !self.isHiddenBottomBar {
                maker.bottom.equalTo(bottomBar.snp.top)
            } else {
                maker.bottom.equalToSuperview()
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
                    .debug()
                    .subscribe(onNext: { response in

                    }, onError: { error in

                    })
                    .disposed(by: self.disposeBag)
        }
    }

}
