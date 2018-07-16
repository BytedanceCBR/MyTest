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
        let re = SimpleNavBar()
        re.backBtn.isHidden = true
        re.rightBtn.isHidden = true
        re.title.text = "消息"
        re.removeGradientColor()
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView()
        re.separatorStyle = .none
        return re
    }()

    let disposeBag = DisposeBag()
    //private let dataSource = DataSource()
    
    lazy var tableViewModel: ChatListTableViewModel = {
        ChatListTableViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.title = "消息"
//        self.navigationItem.title = "消息"

        self.view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
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
        
        // Do any additional setup after loading the view.
        requestUserUnread(query:"")
            .subscribe(onNext: { [unowned self] (responsed) in
                if let responseData = responsed?.data?.unread {
                    self.tableViewModel.datas = responseData
                    self.tableView.reloadData()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.isHidden = true
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
        print("click it \(datas[indexPath.row].id)")
        let vc = MessageListVC()
        vc.messageId = datas[indexPath.row].id
        let nav = EnvContext.shared.rootNavController
        nav.pushViewController(vc, animated: true)
    }

}
