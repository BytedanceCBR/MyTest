//
//  SuggestionListVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/24.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Reachability
enum EnterSuggestionType: Int {
    case enterSuggestionTypeHome = 1
    case enterSuggestionTypeFindTab = 2
    case enterSuggestionTypeList = 3
}

fileprivate func houseTypeSectionByConfig(config: SearchConfigResponseData) -> [HouseType] {
    var result: [HouseType] = []
    if let cfg = config.searchTabFilter {
        if cfg.count > 0 {
            result.append(.secondHandHouse)
        }
    }
    if let cfg = config.searchTabCourtFilter {
        if cfg.count > 0 {
            result.append(.newHouse)
        }
    }
    if let cfg = config.searchTabNeighborHoodFilter {
        if cfg.count > 0 {
            result.append(.neighborhood)
        }
    }
    return result
}

fileprivate func defaultHoustType(config: SearchConfigResponseData?) -> HouseType {
    if let config = config {
        let items = houseTypeSectionByConfig(config: config)
        return items.first ?? HouseType.secondHandHouse
    } else {
        return HouseType.secondHandHouse
    }
}

fileprivate class SuggectionTableView : UITableView {
    
    var handleTouch : (()->Void)?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        handleTouch?()
    }
    
}


class SuggestionListVC: BaseViewController , UITextFieldDelegate , TTRouteInitializeProtocol {

    lazy var navBar: CategorySearchNavBar = {
        let result = CategorySearchNavBar()
        result.searchInput.placeholder = "二手房/租房/小区"
        result.searchable = true
        return result
    }()
    
    lazy var guessYouWantView = GuessYouWantView()

    lazy var tableView: UITableView = {
        let result = SuggectionTableView(frame: CGRect.zero, style: .grouped)
        result.handleTouch = { [weak self] in
            self?.view.endEditing(true)
        }
        result.backgroundColor = UIColor.white

        result.separatorStyle = .none
        if CommonUIStyle.Screen.isIphoneX {
            result.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        }
        result.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        return result
    }()

    private lazy var containerView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let disposeBag = DisposeBag()

    var tableViewModel: SuggestionListTableViewModel
    var onSuggestSelect: ((String, String?, String?, TracerParams) -> Void)?
    var onSuggestionSelected: ((TTRouteObject?) -> Void)? {
        didSet {
            self.tableViewModel.onSuggestionSelected = onSuggestionSelected
        }
    }

    let houseType = BehaviorRelay<HouseType>(value: .secondHandHouse)

    private var popupMenuView: PopupMenuView?

    var filterConditionResetter: FilterConditionResetter?

    private var isFromHome: Bool

    var tracerParams = TracerParams.momoid()
    
    var homePageRollData:HomePageRollScreen?
    
    var canSearchWithRollData:Bool = false

    var stayTimeParams: TracerParams?

    var hasShowKeyboard = false

    var fromSource: EnterSuggestionType

    let tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        re.cancelsTouchesInView = false
        return re
    }()

    init(isFromHome: EnterSuggestionType = .enterSuggestionTypeHome) {
        self.isFromHome = isFromHome == .enterSuggestionTypeHome ? true : false
        self.fromSource = isFromHome
        self.houseType.accept(defaultHoustType(config: EnvContext.shared.client.configCacheSubject.value))
        tableViewModel = SuggestionListTableViewModel(
            houseType: houseType,
            isFromHome: isFromHome)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(routeParamObj paramObj: TTRouteParamObj?) {
        
        let fromHomeType : EnterSuggestionType = (paramObj?.allParams["from_home"] as? EnterSuggestionType) ?? EnterSuggestionType.enterSuggestionTypeHome
        
        if let tracerParams = paramObj?.allParams["tracer"] as? [String: Any] {
            for tkey in tracerParams.keys {
                self.tracerParams = self.tracerParams <|> toTracerParams( tracerParams[tkey] ?? "", key:tkey)
            }
        }
        
        self.isFromHome = (fromHomeType == .enterSuggestionTypeHome) ? true : false
        self.fromSource = fromHomeType
        self.houseType.accept(defaultHoustType(config: EnvContext.shared.client.configCacheSubject.value))
        
        let ht = paramObj?.allParams["house_type"]
        
        if let houseType = ht as? HouseType {
            self.houseType.accept(houseType)
        }else if let htype = ht as? Int{
            
            var eHouseType : HouseType? = nil
            switch htype {
            case HouseType.newHouse.rawValue:
                eHouseType = HouseType.newHouse
            case HouseType.secondHandHouse.rawValue:
                eHouseType = HouseType.secondHandHouse
            case HouseType.rentHouse.rawValue:
                eHouseType = HouseType.rentHouse
            case HouseType.neighborhood.rawValue:
                eHouseType = HouseType.neighborhood
            default:
                eHouseType = nil
            }

            if let etype = eHouseType {
                self.houseType.accept(etype)
            }
        }
        
        
        tableViewModel = SuggestionListTableViewModel(
            houseType: houseType,
            isFromHome: fromHomeType)
        
        super.init(nibName:nil ,bundle : nil)
        
        self.navBar.searchable = true
        
        if let sugDelegate = paramObj?.allParams["sug_delegate"] as? FHHouseSuggestionDelegate {
            if let _ = sugDelegate.suggestionSelected  {
                self.onSuggestionSelected = { [weak sugDelegate,weak self](routeObj) in
                    sugDelegate?.suggestionSelected?(routeObj)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            self.filterConditionResetter = { [weak sugDelegate] in
                sugDelegate?.resetCondition()
            }
            
            self.navBar.backBtn.rx.tap
                .subscribe(onNext: { [weak self , weak sugDelegate] void in
                    sugDelegate?.backAction(self)
                })
                .disposed(by: self.disposeBag)
        }        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableViewModel.tracerParams = self.tracerParams
        self.panBeginAction = { [unowned self] in
            self.navBar.searchInput.resignFirstResponder()
        }
        self.navBar.searchInput.delegate = self
        self.view.backgroundColor = UIColor.white
        navBar.searchTypeLabel.text = houseType.value.stringValue()
        tableViewModel.searchInputField = self.navBar.searchInput
        tableViewModel.filterConditionResetter = self.filterConditionResetter
        //绑定联想词和历史选择处理
        tableViewModel.onSuggestionSelected = self.onSuggestionSelected
        tableViewModel.dismissVC = { [unowned self] in
            self.dismissSelfVCIfNeeded()
        }
        
        tableViewModel.homePageRollData = self.homePageRollData

        UIApplication.shared.statusBarStyle = .default

        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(44 + CommonUIStyle.StatusBar.height)
        }

        bindNavBarObv()

        view.addSubview(containerView)
        containerView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
            maker.bottom.equalToSuperview()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
            maker.bottom.equalToSuperview()

        }
        tableView.dataSource = tableViewModel
        tableView.delegate = tableViewModel

        tableViewModel.onSuggestionItemSelect = { [weak self] (condition, query, associationalWord) in
            //TODO: 解决打点穿参数的问题
            self?.onSuggestSelect?(condition, query, associationalWord, TracerParams.momoid())
        }

        tableView.register(SuggestionItemCell.self, forCellReuseIdentifier: "item")
        tableView.register(SuggestionNewHouseItemCell.self, forCellReuseIdentifier: "newItem")

        bindHouseTypeObv()

//        bindKeyBroadChangeObv()

        //绑定列表刷新
        bindDataSourceObv()

        bindTextFieldChangeObv()

        containerView.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .bind { [unowned self] (gesture) in
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)

        // 根据默认搜索配置，设置是否显示切换房源类型箭头
//        if let config = EnvContext.shared.client.configCacheSubject.value {
//            if houseTypeSectionByConfig(config: config).count <= 1 {
//                self.navBar.hiddenChangeHouseTypeArrow()
//            }
//        }
    }

    func bindTextFieldChangeObv() {
        NotificationCenter.default.rx
            .notification(NSNotification.Name.UITextFieldTextDidChange, object: nil)
            .subscribe(onNext: { [unowned self] notification in
                let maxCount = 80
                if let text = self.navBar.searchInput.text, text.count > maxCount {
                    let index = text.index(text.startIndex, offsetBy: 0)
                    let endIndex = text.index(text.startIndex, offsetBy: maxCount)

                    self.navBar.searchInput.text =  String(text[index..<endIndex])
                }
            })
            .disposed(by: disposeBag)
    }

    /// 绑定列表刷新
    func bindDataSourceObv() {
        //绑定列表刷新
        Observable
            .combineLatest(tableViewModel.suggestions, tableViewModel.suggestionHistory, tableViewModel.guessYouWantItems)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .map { (e) -> [SuggestionItem] in
                let (suggestions, history, _) = e
                if suggestions.count > 0 {
                    return suggestions
                } else {
                    return history
                }
            }
            .bind { [unowned tableView, unowned self] _ in
                tableView.reloadData()
                if self.hasShowKeyboard == false {
                    self.navBar.searchInput.becomeFirstResponder()
                    self.hasShowKeyboard = true
                }
                self.tableView.isHidden = (self.tableViewModel.combineItems.value.count == 0 && self.tableViewModel.guessYouWantItems.value.count == 0)
            }
            .disposed(by: disposeBag)
        
        tableViewModel.suggestionHistory.subscribe {[unowned self] (_) in
            self.tableView.reloadData()
        }.disposed(by: disposeBag)
    }

    func bindNavBarObv() {

        navBar.searchInput.rx.textInput.text
            .throttle(0.6, scheduler: MainScheduler.instance)
            .filter { $0 != nil && $0 != "" }
            .subscribe(onNext: { [weak self](text) in
                if let tableView = self?.tableView
                {
                    self?.tableViewModel.sendQuery(
                        tableView: tableView,
                        theHouseType: self?.houseType.value ?? HouseType.secondHandHouse)(text)
                }
            })
            .disposed(by: disposeBag)

        navBar.searchInput.rx.textInput.text
            .throttle(0.6, scheduler: MainScheduler.instance)
            .filter { $0 == nil || $0 == "" }
            .bind(onNext: { [unowned self] text in
                self.tableViewModel.suggestions.accept([])
                self.tableViewModel.searchedStr = ""
            })
            .disposed(by: disposeBag)

        navBar.searchTypeBtn.rx.tap
            .subscribe(onNext: { [unowned self, unowned navBar] void in
                if navBar.canSelectType {
                    self.displayPopupMenu()
                }
            })
            .disposed(by: disposeBag)
    }

    func bindHouseTypeObv() {
        houseType
            .debug("bindHouseTypeObv")
            .subscribe(onNext: { [weak self] (type) in
                self?.navBar.searchInput.placeholder = searchBarPlaceholder(type)
                self?.navBar.searchTypeLabel.text = type.stringValue()
                let size = self?.navBar.searchTypeLabel.sizeThatFits(CGSize(width: 100, height: 20)) ?? CGSize(width: 42, height: 20)
                self?.navBar.searchTypeLabel.snp.updateConstraints({ (maker) in
                    maker.width.equalTo(size.width)
                })
                self?.canSearchWithRollData = false
                if let tableView = self?.tableView {
                    if self?.navBar.searchInput.text?.isEmpty == false {
                        self?.tableViewModel.sendQuery(
                            tableView: tableView,
                            focusQuery: true,
                            theHouseType: type)(self?.navBar.searchInput.text)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

//    func bindKeyBroadChangeObv() {
//        NotificationCenter.default.rx
//            .notification(.UIKeyboardDidShow, object: nil)
//            .debounce(1, scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [unowned self] notification in
//                let userInfo = notification.userInfo!
//                let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardBounds.height, right: 0)
//            }).disposed(by: disposeBag)
//        NotificationCenter.default.rx
//            .notification(.UIKeyboardDidHide, object: nil)
//            .debounce(1, scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [unowned self] notification in
//                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            })
//            .disposed(by: disposeBag)
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tracerParams = self.tracerParams <|>
                EnvContext.shared.homePageParams <|>
                toTracerParams(categoryEnterNameByHouseType(houseType: houseType.value), key: "category_name") <|>
                self.tableViewModel.search
        stayTimeParams = tracerParams <|> traceStayTime()
        self.tableViewModel.requestHistoryFromRemote(houseType: "\(self.houseType.value.rawValue)")
        if let rollData = homePageRollData {
            self.canSearchWithRollData = true
            navBar.searchInput.placeholder = rollData.text ?? ""
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        var offset: CGFloat = -1
//        tableView.rx.didScroll
////            .throttle(0.2, scheduler: MainScheduler.instance)
//            .bind { [weak self] void in
//                guard let `self` = self else { return }
//                if self.tableViewModel.combineItems.value.count > 0,
//                    offset != self.tableView.contentOffset.y,
//                    offset != -1 {
//                    self.view.endEditing(true)
//                }
//                offset = self.tableView.contentOffset.y
//            }.disposed(by: disposeBag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navBar.searchInput.resignFirstResponder()
        EnvContext.shared.toast.dismissToast()
        self.tableViewModel.associatedCount = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let popmenu = self.popupMenuView {
            popmenu.removeFromSuperview()
            self.popupMenuView = nil
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        var userInputText: String = self.navBar.searchInput.text ?? ""
        
        // 如果外部传入搜索文本homePageRollData，直接当搜索内容进行搜索
        if let rollText = self.homePageRollData?.text, self.canSearchWithRollData == true {
            if userInputText.count <= 0 && rollText.count > 0 {
                userInputText = rollText
            }
        }

        let info = ["search": ["full_text": userInputText],
                    "query_type": "enter",
                    "house_type": houseTypeString(self.houseType.value)] as [String : Any]

        self.tableViewModel.search = self.tableViewModel.search <|>
            toTracerParams(createQueryCondition(info), key: "search")
        let houseSearchParams = TracerParams.momoid() <|>
            toTracerParams(userInputText, key: "enter_query") <|>
            toTracerParams(userInputText, key: "search_query") <|>
            toTracerParams(pageTypeString(self.houseType.value), key: "page_type") <|>
            toTracerParams("enter", key: "query_type")

        // 保存关键词搜索到历史记录
        var searchItem = SuggestionItem()
        searchItem.text = userInputText
        let dic3: Dictionary = ["full_text":userInputText]
        searchItem.info = dic3
        //            filterConditionResetter?()
        //判断搜索item不为空
        if userInputText.trimmingCharacters(in: .whitespaces).isEmpty == false {
            self.tableViewModel.requestHistoryFromRemote(houseType: "\(self.houseType.value.rawValue)")
        }
        //需要拼接placeHolder
        let fullText = userInputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var jumpUrl = "fschema://house_list?house_type=\(self.houseType.value.rawValue)&full_text=\(fullText ??  userInputText)"
        jumpUrl = jumpUrl + "&placeholder=\(fullText ?? userInputText)"
        var infos:[String: Any] = [:]
        infos["houseSearch"] = houseSearchParams.paramsGetter([:])

        let userInfo = TTRouteUserInfo(info: infos)

        if self.onSuggestionSelected != nil {
            let routerObj = TTRoute.shared()?.routeObj(withOpen: URL(string: jumpUrl), userInfo: userInfo)
            self.onSuggestionSelected?(routerObj)
        } else {
            onSuggestSelect?("&full_text=\(userInputText)", nil, userInputText, houseSearchParams)
        }
        self.dismissSelfVCIfNeeded()
        return true

    }


    /// 如果从home和找房tab叫起，则当用户跳转到列表页，则后台关闭此页面
    fileprivate func dismissSelfVCIfNeeded() {
        // 如果从home和找房tab叫起，则当用户跳转到列表页，则后台关闭此页面
        if self.fromSource == EnterSuggestionType.enterSuggestionTypeFindTab ||
            self.fromSource == EnterSuggestionType.enterSuggestionTypeHome {
            self.removeFromParentViewController()
        }
    }

    private func displayPopupMenu() {
        var menuItems = [HouseType.secondHandHouse,
                         HouseType.newHouse,
                         HouseType.neighborhood]

        if let config = EnvContext.shared.client.configCacheSubject.value {
            menuItems = houseTypeSectionByConfig(config: config)
        }

//        if menuItems.count == 1 {
//            self.navBar.hiddenChangeHouseTypeArrow()
//            return
//        }

        let popupMenuItems = menuItems.map { type -> PopupMenuItem in
            let result = PopupMenuItem(label: type.stringValue(), isSelected: self.houseType.value == type)
            result.onClick = { [weak self] in
                self?.houseType.accept(type)
                self?.popupMenuView?.removeFromSuperview()
                self?.popupMenuView = nil
            }
            return result
        }
        popupMenuView = PopupMenuView(targetView: navBar.searchTypeBtn, menus: popupMenuItems)
        view.addSubview(popupMenuView!)
        popupMenuView?.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        popupMenuView?.showOnTargetView()
    }
}

fileprivate func convertDataToSuggestionItem(data: SearchHistoryResponse.Item) -> SuggestionItem {
    var suggestionItem = SuggestionItem()
    suggestionItem.id = data.historyId
    suggestionItem.text = data.listText
    suggestionItem.openUrl = data.openUrl
    suggestionItem.placeHolder = data.text
    suggestionItem.userOriginEnter = data.userOriginEnter
    return suggestionItem
}

func categoryEnterNameByHouseType(houseType: HouseType) -> String {
    switch houseType {
    case .neighborhood:
        return "neighborhood_list"
    case .secondHandHouse:
        return "old_list"
    case .newHouse:
        return "new_list"
    case .rentHouse:
        return "rent_list"
    default:
        return "be_null"
    }
}

class SuggestionListTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {

    weak var searchInputField: UITextField?

    let suggestions = BehaviorRelay<[SuggestionItem]>(value: [])

    let suggestionHistory = BehaviorRelay<[SuggestionItem]>(value: [])
    
    let combineItems = BehaviorRelay<[SuggestionItem]>(value: [])
    
    let guessYouWantItems = BehaviorRelay<[GuessYouWant]>(value:[])
    
    var suggestionHistoryRecords:[ElementRecord] = []

    var highlighted: String?
    
    var searchedStr: String?

    let disposeBag = DisposeBag()

    var sendSuggestionQueryBag = DisposeBag()

    var sendHistoryQueryBag = DisposeBag()
    
    var guessYouwantBag = DisposeBag()

    var onSuggestionItemSelect: ((_ query: String, _ suggestion: String?,_ associationalWord: String?) -> Void)?
    var onSuggestionSelected: ((TTRouteObject?) -> Void)? // 列表页面点击搜索进入

    let houseType: BehaviorRelay<HouseType>

    lazy var sectionHeaderView = SuggestionHeaderView()

    var filterConditionResetter: FilterConditionResetter?

    var associatedCount = 0

    var logPB: Any?

    private var isFromHome: EnterSuggestionType

    var tracerParams = TracerParams.momoid()

    var search = TracerParams.momoid() <|> beNull(key: "search")

    var dismissVC: (() -> Void)?
    
    var homePageRollData:HomePageRollScreen?
    
    var isFirstGuessHeightShow:Bool = true

    init(houseType: BehaviorRelay<HouseType>, isFromHome: EnterSuggestionType) {
        self.houseType = houseType
        self.isFromHome = isFromHome
        super.init()
        BehaviorRelay
                .combineLatest(suggestions, suggestionHistory)
                .map(itemSelector())
                .bind(to: combineItems)
                .disposed(by: disposeBag)
        houseType
            .bind(onNext: { [unowned self] houseType in
                self.suggestionHistory.accept([])
                self.requestHistoryFromRemote(houseType: "\(houseType.rawValue)")
                self.requestGuessYouWantData()
            })
            .disposed(by: disposeBag)

        
        suggestionHistory
            .map { $0.count == 0 }
            .bind(to: sectionHeaderView.deleteBtn.rx.isHidden)
            .disposed(by: disposeBag)
        
        suggestionHistory
            .map {
                if $0.count != 0 {
                    return "历史记录"
                }
                return ""
            }
            .bind(to: sectionHeaderView.label.rx.text)
            .disposed(by: disposeBag)


        sectionHeaderView.deleteBtn.rx.tap.bind { [unowned self] void in
            self.requestDeleteHistory()
        }.disposed(by: disposeBag)
        
        sectionHeaderView.guessView.onGuessYouWantItemClick = {[unowned self] (item:GuessYouWant) in
            self.guessYouWantItemClick(item: item)
        }
        
        suggestionHistory.subscribe {[unowned self] (event) in
            if let elements = event.element {
                self.suggestionHistoryRecords = elements.enumerated().map({ (arg0) -> ElementRecord in
                    let (offset, element) = arg0
                    let pramas = TracerParams.momoid() <|>
                        toTracerParams(element.text ?? "be_null", key: "word") <|>
                        toTracerParams(element.id ?? "be_null", key: "history_id") <|>
                        toTracerParams(offset, key: "rank") <|>
                        toTracerParams("list", key: "show_type")
                      return onceRecord(key: "search_history_show", params: pramas)
                })
            }
        }.disposed(by: disposeBag)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return combineItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: houseType.value == .newHouse && suggestions.value.count > 0 ? "newItem" : "item",
                for: indexPath)
        if suggestions.value.count == 0,
            let theCell = cell as? SuggestionItemCell,
            combineItems.value.count > indexPath.row,
            let text = combineItems.value[indexPath.row].text {
            theCell.secondaryLabel.text = houseType.value.stringValue()
            let attrTextProcess = highlightedText(originalText: "\(text)", highlitedText: "")
            
            theCell.label.attributedText = attrTextProcess(attrText(text: text))
        } else {
            if combineItems.value.count != 0 {
                switch houseType.value {
                case .newHouse where suggestions.value.count == 0:
                    fillNormalItem(cell: cell, item: combineItems.value[indexPath.row], highlighted: highlighted)
                case .newHouse:
                    fillNewHouseItem(cell: cell, item: combineItems.value[indexPath.row], highlighted: highlighted)
                default:
                    fillNormalItem(cell: cell, item: combineItems.value[indexPath.row], highlighted: highlighted)
                }
            }
        }


        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if combineItems.value.count <= indexPath.row {
            assertionFailure()
            return
        }
        let item = combineItems.value[indexPath.row]
        var info = item.info
        if let theInfo = info as? [String: Any] {
            info = ["search": theInfo,
                    "query_type": suggestions.value.count > 0 ? "associate" : "history",
                    "house_type": houseTypeString(self.houseType.value)]
        }

//        let condition = createQueryCondition(info)
        let params = TracerParams.momoid() <|>
            toTracerParams(item.text ?? "be_null", key: "word_text") <|>
            toTracerParams(self.associatedCount, key: "associate_cnt") <|>
            toTracerParams(indexPath.row, key: "rank") <|>
            toTracerParams(item.idFromInfo() ?? "be_null", key: "word_id") <|>
            //            toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>  // add by zjing not sure
            toTracerParams("search", key: "element_type") <|>
            toTracerParams(self.houseType.value.traceTypeValue(), key: "associate_type") <|>
//            toTracerParams(houseTypeString(self.houseType.value), key: "house_type") <|>
            self.tracerParams <|>
            toTracerParams(item.logPB ?? "be_null", key: "log_pb")
        //这里做此判断，是否是联想词发起的搜索
        if suggestions.value.count > 0 {
            recordEvent(key: "associate_word_click", params: params.exclude("element_from").exclude("enter_from").exclude("enter_type"))
        } else {
            // 搜索历史发起的搜索
            let element = item
            let tempPramas = TracerParams.momoid() <|>
                toTracerParams(element.text ?? "be_null", key: "word") <|>
                toTracerParams(element.id ?? "be_null", key: "history_id") <|>
                toTracerParams(indexPath.row, key: "rank") <|>
                toTracerParams("list", key: "show_type")
            recordEvent(key: "search_history_click", params: tempPramas)
        }

        if let openUrl = item.openUrl {
            var jumpUrl = openUrl
            if let placeholder = item.placeHolder?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                jumpUrl = jumpUrl + "&placeholder=\(placeholder)"
            } else if let placeholder = item.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                jumpUrl = jumpUrl + "&placeholder=\(placeholder)"
            }
            let queryType = self.suggestions.value.count > 0 ? "associate" : "history"

            var userInput = self.searchInputField?.text ?? "be_null"
            if userInput.isEmpty {
                userInput = "be_null"
            }
            var houseSearchParams = ["page_type": self.pageTypeString(),
                                     "query_type": queryType,
                                     "enter_query": item.userOriginEnter ?? userInput,
                                     "search_query": item.text ?? "be_null"]

            if suggestions.value.count == 0 {
                //如果点击的是历史，就统一都报text
                houseSearchParams["enter_query"] = item.text ?? "be_null"
            }
            var infos: [String: Any] = [:]
            infos["houseSearch"] = houseSearchParams
            if let info = item.info {
                infos["suggestion"] = createQueryCondition(info)
            }
            let userInfo = TTRouteUserInfo(info: infos)
            let routerObj = TTRoute.shared()?.routeObj(withOpen: URL(string: jumpUrl), userInfo: userInfo)
            if self.onSuggestionSelected != nil {
                self.onSuggestionSelected?(routerObj)

            } else {
                TTRoute.shared()?.openURL(byPushViewController: URL(string: jumpUrl), userInfo: userInfo)
            }

            // 如果从home和找房tab叫起，则当用户跳转到列表页，则后台关闭此页面
            dismissVC?()
        }

        else {
            onSuggestionItemSelect?("", createQueryCondition(item.info), item.text)
        }

        // 如果调用这里，会造UI栈中存在两个CategoryVC时，同时发起请求
//        filterConditionResetter?()

    }
    
    fileprivate func guessYouWantItemClick(item:GuessYouWant) {
        if let openUrl = item.openUrl {
            var jumpUrl = openUrl
            if let placeholder = item.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                jumpUrl = jumpUrl + "&placeholder=\(placeholder)"
            }
            let queryType = "hot"// 猜你想搜
            
            let houseSearchParams = ["page_type": self.pageTypeString(),
                                     "query_type": queryType,
                                     "enter_query": item.text ?? "be_null",
                                     "search_query": item.text ?? "be_null"]

            var infos: [String: Any] = [:]
            infos["houseSearch"] = houseSearchParams
            if let info = item.extinfo {
                infos["suggestion"] = createQueryCondition(info)
            }
            let userInfo = TTRouteUserInfo(info: infos)
            let routerObj = TTRoute.shared()?.routeObj(withOpen: URL(string: jumpUrl), userInfo: userInfo)
            if self.onSuggestionSelected != nil {
                self.onSuggestionSelected?(routerObj)
            } else {
                TTRoute.shared()?.openURL(byPushViewController: URL(string: jumpUrl), userInfo: userInfo)
            }
            
            // 如果从home和找房tab叫起，则当用户跳转到列表页，则后台关闭此页面
            dismissVC?()
        }
    }

    fileprivate func pageTypeString() -> String {
        if isFromHome == EnterSuggestionType.enterSuggestionTypeFindTab {
            switch self.houseType.value {
            case .neighborhood:
                return "findtab_neighborhood"
            case .newHouse:
                return "findtab_new"
            default:
                return "findtab_old"
            }
        } else if isFromHome == EnterSuggestionType.enterSuggestionTypeHome {
            return "maintab"
        } else {
            switch self.houseType.value {
            case .neighborhood:
                return "neighborhood_list"
            case .newHouse:
                return "new_list"
            default:
                return "old_list"
            }
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if suggestions.value.count > 0 {
            return nil
        }
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // 仅在现实新房推荐数据显示的时候，返回新房suggestioncell的高度
        if houseType.value == HouseType.newHouse && suggestions.value.count > 0 {
            return 68
        }
        return 42
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let guessHeight:CGFloat = isFirstGuessHeightShow ? 138 : CGFloat (guessYouWantItems.value.count > 0 ? 138 : 0)
        let sectionHeaderHeight = CGFloat (suggestionHistory.value.count > 0 ? 40 : 0)
        if suggestions.value.count > 0 {
            return CGFloat.leastNormalMagnitude
        }
        return sectionHeaderHeight + guessHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if suggestionHistoryRecords.count <= indexPath.row {
            return
        }
        let item = suggestionHistoryRecords[indexPath.row]
        item(TracerParams.momoid())
    }

    func sendQuery(
        tableView: UITableView,
        focusQuery: Bool = false,
        theHouseType: HouseType) -> (String?) -> Void {
        return { [unowned self] (query) in
            self.associatedCount = self.associatedCount + 1
            if let query = query {
                if self.searchedStr == query && !focusQuery
                {
                    return
                }
                self.highlighted = query
                self.searchedStr = query
                let cityId = EnvContext.shared.client.generalBizconfig.currentSelectCityId.value
                self.sendSuggestionQueryBag = DisposeBag()
                requestSuggestion(cityId: cityId ?? 122, horseType: theHouseType.rawValue, query: query)
                        .subscribe(onNext: { [unowned self] (responsed) in
                            if let responseData = responsed?.data {
                                self.suggestions.accept(responseData)

                                let wordList = responseData.enumerated().map({ (e) -> [String: Any] in
                                    let (offset, item) = e
                                    return ["text": item.text ?? "be_null",
                                            "word_id": item.idFromInfo() ?? "be_null",
                                            "rank": offset]
                                })
                                let pramas = TracerParams.momoid() <|>
                                    mapTracerParams(["word_list": createQueryCondition(wordList)]) <|>
                                    toTracerParams(self.associatedCount, key: "associate_cnt") <|>
                                    toTracerParams(self.houseType.value.traceTypeValue(), key: "associate_type") <|>
                                    toTracerParams(wordList.count, key: "word_cnt") <|>
                                    toTracerParams("search", key: "element_type") <|>
                                    self.tracerParams
                                        .exclude("category_name")
                                        .exclude("element_from")
                                        .exclude("enter_from")
                                        .exclude("enter_type") <|>
                                    toTracerParams(responseData.first?.logPB ?? "be_null", key: "log_pb")


                                recordEvent(key: "associate_word_show", params: pramas)
                            }
                        }, onError: { (error) in
//                            print(error)
                        })
                        .disposed(by: self.sendSuggestionQueryBag)
            }
        }
    }

    fileprivate func requestHistoryFromRemote(houseType: String? = nil) {
        if EnvContext.shared.client.reachability.connection == .none {
            EnvContext.shared.toast.showToast("网络异常")
        } else {
            self.sendHistoryQueryBag = DisposeBag()
            requestSearchHistory(houseType: (houseType == nil ? "\(self.houseType.value.rawValue)" : houseType!))
                //            .debug()
                .subscribe(onNext: {[unowned self] (payload) in
                    let historys = payload?.data?.data?.map(convertDataToSuggestionItem)
                    self.suggestionHistory.accept(historys ?? [])
                    }, onError: { (error) in
//                        print(error)
                })
                .disposed(by: sendHistoryQueryBag)
        }
    }

    fileprivate func requestDeleteHistory() {
        let houseType = self.houseType.value
        let houseTypeStr = "\(houseType.rawValue)"
        if EnvContext.shared.client.reachability.connection == .none {
            EnvContext.shared.toast.showToast("网络异常")
        } else {
            requestDeleteSearchHistory(houseType: houseTypeStr)
                //            .debug()
                .subscribe(onNext: { [unowned self] (payload) in
                    self.suggestionHistory.accept([])
                    }, onError: { (error) in
                        EnvContext.shared.toast.showToast("历史记录删除失败")
                })
                .disposed(by: disposeBag)
        }
    }

    func itemSelector() -> (([SuggestionItem] , [SuggestionItem])) -> [SuggestionItem] {
        return { (e) in
            let (suggestions, history) = e
            if suggestions.count > 0 {
                return suggestions
            } else {
                return history
            }
        }
    }
    
    func requestGuessYouWantData()
    {
        self.guessYouwantBag = DisposeBag()
        let houseType = self.houseType.value
        let cityId = EnvContext.shared.client.generalBizconfig.currentSelectCityId.value
        requestGuessYouWant(cityId: cityId ?? 122, houseType: houseType.rawValue).subscribe(onNext: { [unowned self] (response) in
                self.isFirstGuessHeightShow = false
                if let data = response?.data?.data , data.count > 0 {
                    // 把外部传入的搜索词放到第一个位置
                    var tempData = data
                    if let text = self.homePageRollData?.text, self.homePageRollData?.houseType == houseType.rawValue {
                        var index:Int = 0
                        var tempGuess:GuessYouWant = GuessYouWant(JSON: [:])!
                        tempGuess.text = text
                        tempGuess.openUrl = self.homePageRollData?.openUrl
                        tempGuess.guessSearchId = self.homePageRollData?.guessSearchId
                        tempGuess.houseType = self.homePageRollData?.houseType ?? 0
                        for item in data {
                            if item.text == text {
                                tempGuess = item
                                tempData.remove(at: index)
                                break
                            }
                            index += 1
                        }
                        tempData.insert(tempGuess, at: 0)
                    }
                    //
                    self.guessYouWantItems.accept(tempData)
                    self.sectionHeaderView.guessView.guessYouWantItems = tempData
                } else {
                    self.guessYouWantItems.accept([])
                    self.sectionHeaderView.guessView.guessYouWantItems = []
                }
            }, onError: {[unowned self] (error) in
                self.isFirstGuessHeightShow = false
        }).disposed(by: guessYouwantBag)
    }
}

func createQueryCondition(_ info: Any?) -> String {
    var queryCondition = ""
    if let conditions = info as? String {
        queryCondition.append(conditions)
    } else {
        do {
            if let condition = String(
                data: try JSONSerialization.data(withJSONObject: info ?? []),
                encoding: .utf8) {
                queryCondition.append(condition)
            }
        } catch {
//            print(error)
        }
    }
    return queryCondition
}

fileprivate func fillNormalItem(cell: UITableViewCell, item: SuggestionItem, highlighted: String?) {
    if let theCell = cell as? SuggestionItemCell {
        if var text = item.text {
            if let text2 = item.text2,
                text2.isEmpty == false {
                text = text + " (\(text2))"
            }
            let attrTextProcess = highlightedText(originalText: text, highlitedText: highlighted)
//                    <*> commitText(commit: item.text2)

            theCell.label.attributedText = attrTextProcess(attrText(text: text))
        }
        theCell.secondaryLabel.text = "约\(item.count)套"
    }
}

fileprivate func fillNewHouseItem(cell: UITableViewCell, item: SuggestionItem, highlighted: String?) {
    if let theCell = cell as? SuggestionNewHouseItemCell {
        if let text = item.text {
            let attrTextProcess = highlightedText(originalText: text, highlitedText: highlighted)

            theCell.label.attributedText = attrTextProcess(attrText(text: text))
        }
        if let text = item.text2 {
            theCell.subLabel.attributedText = highlightedText(originalText: text, highlitedText: highlighted)(attrText(text: text))
        }
        theCell.secondaryLabel.text = item.tips
        theCell.secondarySubLabel.text = item.tips2
    }
}

typealias AttributedStringProcess = (NSMutableAttributedString) -> NSMutableAttributedString

func attrText(text: String) -> NSMutableAttributedString {
    return NSMutableAttributedString(string: text)
}

func highlightedText(
        originalText: String,
        highlitedText: String?,
        color: UIColor = hexStringToUIColor(hex: "#299cff"),
        font: UIFont? = CommonUIStyle.Font.pingFangRegular(15)) -> AttributedStringProcess {
    return { attrText in
        var attributes: [NSAttributedStringKey: Any] = [.foregroundColor: color]
        if let font = font {
            attributes[.font] = font
        }

        func highlitedIt(_ content: String, highlitedText: String, offset: Int) {
            if let range = content.range(of: highlitedText) {
                attrText.setAttributes(attributes, range: NSMakeRange(
                        offset + range.lowerBound.encodedOffset,
                        range.upperBound.encodedOffset - range.lowerBound.encodedOffset))
                let subContent = String(content[range.upperBound...])
                if !subContent.isEmpty {
                    highlitedIt(
                            subContent,
                            highlitedText: highlitedText,
                            offset: offset + (content.count - subContent.count))
                }
            }

        }

        if let highlitedText = highlitedText {
            highlitedIt(originalText, highlitedText: highlitedText, offset: 0)
        }
        return attrText
    }
}

func commitText(commit: String?) -> AttributedStringProcess {
    return { attrText in
        if let commit = commit {
            let attrContent = "  \(commit)"
            let attributeText = NSMutableAttributedString(string: attrContent)
            var attributes: [NSAttributedStringKey: Any] = [.foregroundColor: hexStringToUIColor(hex: "#45494d")]

            attributes[.font] = CommonUIStyle.Font.pingFangRegular(13)

            attributeText.setAttributes(attributes, range: NSRange(location: 0, length: attrContent.count))
            attrText.append(attributeText)
        }
        return attrText
    }
}

infix operator <*>: SequencePrecedence

func <*>(l: @escaping AttributedStringProcess, r: @escaping AttributedStringProcess) -> AttributedStringProcess {
    return { attrText in
        r(l(attrText))
    }
}

