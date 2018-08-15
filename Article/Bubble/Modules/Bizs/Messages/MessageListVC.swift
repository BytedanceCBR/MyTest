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

class MessageListVC: BaseViewController, UITableViewDelegate, PageableVC  {
    
    var hasMore = false
    
    lazy var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()
    
    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        re.rightBtn.isHidden = true
        re.removeGradientColor()
        re.title.text = "消息"
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView(frame: CGRect.zero, style: .grouped)
        re.separatorStyle = .none
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
        re.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        return re
    }()

    lazy var emptyMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        return re
    }()
    
    let disposeBag = DisposeBag()
    
    private var tableListViewModel: ChatDetailListTableViewModel?

    var messageId: String?
    var tracerParams = TracerParams.momoid()

    private var minCursor: String?
    
    private let limit = "10"
    
    var pageableLoader: (() -> Void)?
    
    var dataLoader: ((Bool, Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        self.view.backgroundColor = UIColor.white
        self.tableListViewModel = ChatDetailListTableViewModel(navVC: self.navigationController)
        self.dataLoader = self.onDataLoaded()
        
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }

        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.bottom.right.left.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
        }
        tableView.dataSource = tableListViewModel
        tableView.delegate = tableListViewModel

        tableView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        tableView.separatorStyle = .none

        tableView.register(ChatDetailListCell.self, forCellReuseIdentifier: ChatDetailListCell.identifier)
        if let messageId = messageId {
            loadData(messageId: messageId)
        }
    }
    
    fileprivate func loadData(messageId: String) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            return
        }
        
        let loader = pageRequestUserMessageList(listId: messageId,
                                                limit: "10",
                                                query: "")
        pageableLoader = { [unowned self] in
            loader()
                .subscribe(onNext: { [unowned self] (responsed) in
                    if let responseData = responsed?.data?.items, responseData.count != 0 {
                        self.hasMore = responsed?.data?.hasMore ?? false
                        self.dataLoader?(self.hasMore, responseData.count)
                        self.tableListViewModel?.datas = responseData
                        self.tableView.reloadData()
  
                    } else {
                        self.showEmptyMaskView()
                    }
                    
                    }, onError: { (error) in
                        print(error)
                })
                .disposed(by: self.disposeBag)
        }
        self.tableListViewModel?.datas = []
        self.tableView.reloadData()
        pageableLoader?()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func showEmptyMaskView() {
        view.addSubview(emptyMaskView)
        emptyMaskView.icon.image = #imageLiteral(resourceName: "empty_message")
        emptyMaskView.snp.makeConstraints { maker in
            maker.top.bottom.right.left.equalTo(tableView)
        }
        emptyMaskView.label.text = "啊哦～你还没有收到消息～"
    }
    
    private func showNetworkError() {
        //TODO:
    }
    
    func loadMore() {
        
        tracerParams = tracerParams <|>
            toTracerParams("pre_load_more", key: "refresh_type")

        recordEvent(key: TraceEventName.category_refresh, params: tracerParams)

        self.pageableLoader?()
    }
    
}

class ChatDetailListTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var datas: [UserListMsgItem] = []

    let disposeBag = DisposeBag()
    
    weak var navVC: UINavigationController?
    
    init(navVC: UINavigationController?) {
        self.navVC = navVC
    }
    
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
                    createTagAttrString(
                        item.content,
                        textColor: hexStringToUIColor(hex: item.textColor),
                        backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
                })
                
                attrTexts?.forEach({ (attrText) in
                    text.append(attrText)
                })
                
                theCell.areaLabel.attributedText = text
                theCell.priceLabel.text = data.price
                theCell.roomSpaceLabel.text = data.pricePerSqm
                
                theCell.lineView.isHidden = (indexPath.row == items.count - 1) ? true : false

                if let img = data.images?.first , let url = img.url {
                    theCell.setImageByUrl(url)
                }
                
            }
        }
        
        return cell
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
                let houseType: HouseType = HouseType(rawValue: houseTypeId) ?? .newHouse

                switch houseType {
                case .newHouse:
                    openNewHouseDetailPage(houseId: Int64(houseId) ?? 0, disposeBag: disposeBag, navVC: navVC)()
                case .secondHandHouse:
                    openErshouHouseDetailPage(houseId: Int64(houseId) ?? 0, disposeBag: disposeBag, navVC: navVC)()
                default:
                    openErshouHouseDetailPage(houseId: Int64(houseId) ?? 0, disposeBag: disposeBag, navVC: navVC)()
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
