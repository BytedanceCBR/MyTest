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
class ChatVC: UIViewController {

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
        self.navigationController?.title = "消息"
        self.navigationItem.title = "消息"
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.left.right.bottom.equalToSuperview()
        }
        tableView.dataSource = tableViewModel
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        tableView.reloadData()
        
        // Do any additional setup after loading the view.
        requestSuggestion(cityId: 133, horseType: 2)
            .subscribe(onNext: { [unowned self] (responsed) in
                if let responseData = responsed?.data {
                    self.tableViewModel.suggestions = responseData
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



class ChatListTableViewModel: NSObject, UITableViewDataSource {
    var suggestions: [SuggestionItem] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ChatCell()
        return cell
    }

}
