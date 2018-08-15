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
class MineVC: BaseViewController {

    private var minePageViewModel: MinePageViewModel?

    private lazy var tableView: UITableView = {
        let re = UITableView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        re.separatorStyle = .none
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
        re.rowHeight = UITableViewAutomaticDimension
        return re
    }()

    let disposeBag = DisposeBag()

    var mineViewModel: MinePageViewModel?
    
    var tracerParams = TracerParams.momoid()


    private var stayTabParams = TracerParams.momoid()
    private var theThresholdTracer: ((String, TracerParams) -> Void)?

    deinit {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "我的"
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        self.mineViewModel = MinePageViewModel(
                tableView: tableView,
                navVC: self.navigationController)
        self.mineViewModel?.openVC = { [weak self] (vc) in
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        self.mineViewModel?.reload()
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        
        EnvContext.shared.client.accountConfig.userInfo
                .bind { [unowned self] user in
                    self.mineViewModel?.reload()
                }
                .disposed(by: disposeBag)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.theThresholdTracer = thresholdTracer()
        self.stayTabParams = TracerParams.momoid() <|>
                toTracerParams("mine", key: "tab_name") <|>
                toTracerParams("click_tab", key: "enter_type") <|>
                toTracerParams("0", key: "with_tips") <|>
                traceStayTime()
//        let url = URL(string: "sslocal://webview?url=http://www.baidu.com")
//        TTRoute.shared().openURL(byPushViewController: url)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.theThresholdTracer?(TraceEventName.stay_tab, self.stayTabParams)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let navVC = self.navigationController as? TTNavigationController {
            navVC.removeTabBarSnapshot(forSuperView: self.view)
        }
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
