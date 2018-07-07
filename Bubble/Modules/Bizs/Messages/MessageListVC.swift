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
        let re = UITableView()
        re.separatorStyle = .none
        return re
    }()

    let disposeBag = DisposeBag()
    
    lazy var tableListViewModel: ChatDetailListTableViewModel = {
        ChatDetailListTableViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        tableView.dataSource = tableListViewModel
        tableView.delegate = tableListViewModel
        
        tableView.register(ChatDetailListCell.self, forCellReuseIdentifier: ChatDetailListCell.identifier)
        tableView.reloadData()

        requestUserList(listId: "303", minCursor: "", limit: "10", query: "")
            .subscribe(onNext: { [unowned self] (responsed) in

                    if let responseData = responsed?.data?.items {
                                            let minCursor = responsed?.data?.minCursor
                                            let hasMore = responsed?.data?.hasMore
                        print("======= 1111 ===\(minCursor)==\(hasMore)=====\(responseData[0].title)=")

                        self.tableListViewModel.datas = responseData
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

}

class ChatDetailListTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {
    let imageIconMap: [String: UIImage] = ["300": UIImage(named: "icon-ershoufang")!,
                                           "301": UIImage(named: "icon-ershoufang")!,
                                           "302": UIImage(named: "icon-ershoufang")!,
                                           "303": UIImage(named: "icon-ershoufang")!]
    
    var datas: [UserListMsgItem] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("======= 55555555 \(datas.count) =======")

        return datas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = datas[section].items {
            print("======= 666666666 \(data.count) =======")
            return data.count
        }
        print("======= 7777777 =======")

        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("======= 44444 =======")

        let cell = tableView.dequeueReusableCell(withIdentifier: ChatDetailListCell.identifier)
        if let theCell = cell as? ChatDetailListCell {
            print("======= 11111 =======")

            if let items = datas[indexPath.section].items {
                print("======= 00000 =======")

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
                
                theCell.priceLabel.text = data.pricePerSqm
                theCell.roomSpaceLabel.text = ""
                theCell.majorImageView.image = imageIconMap["301"]

//                if let img = data.courtImage?.first , let url = img.url {
//                    theCell.setImageByUrl(url)
//                }
                print("======= 22222 =======")

            }
        }
        print("======= 333333 =======")

        return cell ?? ChatDetailListCell()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CategorySectionView()
        view.categoryLabel.text = datas[section].title
        return view
    }
    


    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
