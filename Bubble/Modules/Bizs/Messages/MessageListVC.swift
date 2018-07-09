//
//  MessageListVC.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class MessageListVC: BaseViewController, UITableViewDelegate {
    
    lazy var tableView: UITableView = {
        let re = UITableView(frame: CGRect.zero, style: .grouped)
        re.separatorStyle = .none
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
        return re
    }()
    
    let disposeBag = DisposeBag()
    
    lazy var tableListViewModel: ChatDetailListTableViewModel = {
        ChatDetailListTableViewModel()
    }()
    
    var messageId: String?
    
    private var minCursor: String?
    
    private let limit = "10"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.top.bottom.right.left.equalToSuperview()
        }
        tableView.dataSource = tableListViewModel
        tableView.delegate = tableListViewModel
        
        tableView.register(ChatDetailListCell.self, forCellReuseIdentifier: ChatDetailListCell.identifier)
        if let messageId = messageId {
            requestUserList(listId: messageId, minCursor: "", limit: "10", query: "")
                .subscribe(onNext: { [unowned self] (responsed) in
                    
                    if let responseData = responsed?.data?.items {
//                        let minCursor = responsed?.data?.minCursor
//                        let hasMore = responsed?.data?.hasMore
                        self.tableListViewModel.datas = responseData
                        self.tableView.reloadData()
                    }
                    
                    }, onError: { (error) in
                        print(error)
                })
                .disposed(by: disposeBag)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class ChatDetailListTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var datas: [UserListMsgItem] = []

    let disposeBag = DisposeBag()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = datas[section].items {
            return data.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatDetailListCell.identifier, for: indexPath)
        if let theCell = cell as? ChatDetailListCell {
            
            if let items = datas[indexPath.section].items {
                let data = items[indexPath.row]
                theCell.majorTitle.text = data.title
                theCell.extendTitle.text = data.description
                let text = NSMutableAttributedString()
                
                let attrTexts = data.tags?.map({ (item) -> NSAttributedString in
                    createTagAttrString(item.content ?? "")
                })
                
                attrTexts?.forEach({ (attrText) in
                    text.append(attrText)
                })
                
                theCell.areaLabel.attributedText = text
                theCell.priceLabel.text = data.price
                theCell.roomSpaceLabel.text = data.pricePerSqm
                
                if let img = data.images?.first , let url = img.url {
                    theCell.setImageByUrl(url)
                }
                
            }
        }
        
        return cell ?? ChatDetailListCell()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UserMsgSectionView()
        view.tipsLabel.text = datas[section].title
        view.dateLabel.text = datas[section].dateStr
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let houseId = datas[indexPath.section].items?[indexPath.row].id {
            if let houseTypeId = datas[indexPath.section].items?[indexPath.row].houseType {
                var houseType: HouseType = HouseType(rawValue: houseTypeId) ?? .newHouse

                switch houseType {
                case .newHouse:
                    openNewHouseDetailPage(houseId: Int64(houseId) ?? 0, disposeBag: disposeBag)()
                case .secondHandHouse:
                    openErshouHouseDetailPage(houseId: Int64(houseId) ?? 0, disposeBag: disposeBag)()
                default:
                    openErshouHouseDetailPage(houseId: Int64(houseId) ?? 0, disposeBag: disposeBag)()
                }
            } else {
                assertionFailure()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
