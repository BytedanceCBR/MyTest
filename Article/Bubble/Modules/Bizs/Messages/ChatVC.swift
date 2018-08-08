//
//  ChatVC.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
class ChatVC: BaseViewController {
    
    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        re.backBtn.isHidden = true
        re.rightBtn.isHidden = true
        re.title.text = "消息"
        re.removeGradientColor()
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView()
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
        re.separatorStyle = .none
        return re
    }()

    let disposeBag = DisposeBag()
    
    private var tableViewModel: ChatListTableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = false

        self.view.addSubview(navBar)
        self.tableViewModel = ChatListTableViewModel(navVC: self.navigationController)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
        }
        tableView.dataSource = tableViewModel
        tableView.delegate = tableViewModel
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        tableView.reloadData()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        requestUserUnread(query:"")
                .subscribe(onNext: { [unowned self] (responsed) in
                    if let responseData = responsed?.data?.unread {
                        self.tableViewModel?.datas = responseData
                        self.tableView.reloadData()
                    }
                }, onError: { (error) in
                    print(error)
                })
                .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let navVC = self.navigationController as? TTNavigationController {
            navVC.removeTabBarSnapshot(forSuperView: self.view)
        }
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



class ChatListTableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    let imageIconMap: [String: UIImage] = ["300": UIImage(named: "icon-xinfang")!,
                                           "301": UIImage(named: "icon-ershoufang")!,
                                           "302": UIImage(named: "icon-zufang")!,
                                           "303": UIImage(named: "icon-xiaoqu")!]

    
    let listIdMap: [String: String] = ["301": "二手房",
                                           "300": "新房",
                                           "302": "租房",
                                           "303": "小区"]
    var datas: [UserUnreadInnerMsg] = []
    
    private let disposeBag = DisposeBag()
    
    weak var navVC: UINavigationController?
    
    init(navVC: UINavigationController?) {
        self.navVC = navVC
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier)
        if let theCell = cell as? ChatCell {
            let item = datas[indexPath.row]
            if let id = item.id {
                theCell.iconImageView.image = imageIconMap[id]
                theCell.label.text = listIdMap[id]
            }
            if let text = item.content {
                theCell.secondaryLabel.text = text
            }
            if let text2 = item.dateStr {
                theCell.rightLabel.text = text2
            }
        }
        return cell ?? ChatCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MessageListVC()
        vc.messageId = datas[indexPath.row].id
        vc.navBar.title.text = listIdMap[vc.messageId ?? "301"]
        vc.navBar.backBtn.rx.tap
            .subscribe(onNext: { [unowned self] void in
                self.navVC?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        self.navVC?.pushViewController(vc, animated: true)
    }

}
