//
//  MineVC.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class MineVC: UIViewController {

    private var minePageViewModel: MinePageViewModel?

    private lazy var tableView: UITableView = {
        let re = UITableView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        re.separatorStyle = .none
        return re
    }()

    let disposeBag = DisposeBag()

    var mineViewModel: MinePageViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "我的"
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        self.mineViewModel = MinePageViewModel(tableView: tableView)
        self.mineViewModel?.userInfo = UserInfo()
        self.mineViewModel?.reload()


        requestUserInfo(query: "")
                .subscribe(onNext: { [unowned self] (response) in
                    if let responseData = response?.data {
                        self.mineViewModel?.userInfo = responseData
                        self.mineViewModel?.reload()
                    }
                }, onError: { (error) in
                    print(error)
                })
                .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
