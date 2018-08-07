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

class SuggestionListVC: BaseViewController , UITextFieldDelegate {

    lazy var navBar: CategorySearchNavBar = {
        let result = CategorySearchNavBar()
        result.searchInput.placeholder = "二手房/租房/小区"
        result.searchable = true
        return result
    }()

    lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        return result
    }()

    let disposeBag = DisposeBag()

    var tableViewModel: SuggestionListTableViewModel
    var onSuggestSelect: ((String, String?) -> Void)?

    let houseType = BehaviorRelay<HouseType>(value: .secondHandHouse)

    private var popupMenuView: PopupMenuView?

    init() {
        tableViewModel = SuggestionListTableViewModel(houseType: houseType)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.panBeginAction = { [unowned self] in
            self.navBar.searchInput.resignFirstResponder()
        }
        self.view.backgroundColor = UIColor.white
        navBar.searchTypeLabel.text = houseType.value.stringValue()

        UIApplication.shared.statusBarStyle = .default

        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(58)
            } else {
                maker.height.equalTo(65)
            }
            maker.top.left.right.equalToSuperview()
        }

        navBar.searchInput.rx.textInput.text
                .throttle(0.6, scheduler: MainScheduler.instance)
                .filter { $0 != nil && $0 != "" }
                .subscribe(onNext: tableViewModel.sendQuery(tableView: tableView))
                .disposed(by: disposeBag)

        navBar.searchInput.rx.textInput.text
                .throttle(0.6, scheduler: MainScheduler.instance)
                .filter { $0 == nil || $0 == "" }
                .bind(onNext: { text in
                    self.tableViewModel.suggestions.accept([])
                })
                .disposed(by: disposeBag)

        navBar.searchTypeBtn.rx.tap
                .subscribe(onNext: { [unowned self] void in
                    self.displayPopupMenu()
                })
                .disposed(by: disposeBag)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
        }
        tableView.dataSource = tableViewModel
        tableView.delegate = tableViewModel

        tableViewModel.onSuggestionItemSelect = { [weak self] (condition, associationalWord) in
            self?.onSuggestSelect?(condition, associationalWord)
        }

        tableView.register(SuggestionItemCell.self, forCellReuseIdentifier: "item")
        tableView.register(SuggestionNewHouseItemCell.self, forCellReuseIdentifier: "newItem")

        houseType
            .subscribe(onNext: { [weak self] (type) in
                self?.navBar.searchInput.placeholder = searchBarPlaceholder(type)
                self?.navBar.searchTypeLabel.text = type.stringValue()
                if let tableView = self?.tableView {
                    if self?.navBar.searchInput.text?.isEmpty == false {
                        self?.tableViewModel.sendQuery(
                            tableView: tableView)(self?.navBar.searchInput.text)
                    }
                }
            })
            .disposed(by: disposeBag)
        NotificationCenter.default.rx
                .notification(.UIKeyboardDidShow, object: nil)
                .subscribe(onNext: { [unowned self] notification in
                    let userInfo = notification.userInfo!
                    let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardBounds.height, right: 0)
                }).disposed(by: disposeBag)
        NotificationCenter.default.rx
                .notification(.UIKeyboardDidHide, object: nil)
                .subscribe(onNext: { [unowned self] notification in
                    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                })
                .disposed(by: disposeBag)


        //绑定列表刷新
        Observable
                .combineLatest(tableViewModel.suggestions, tableViewModel.suggestionHistory)
                .map { (e) -> [SuggestionItem] in
                    let (suggestions, history) = e
                    if suggestions.count > 0 {
                        return suggestions
                    } else {
                        return history
                    }
                }
                .bind { [unowned tableView] _ in
                    tableView.reloadData()
                }
                .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBar.searchInput.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.navBar.searchInput.text != nil && !self.navBar.searchInput.text!.isEmpty {
            return true
        }
        return false
    }

    private func displayPopupMenu() {
        let menuItems = [HouseType.secondHandHouse,
                         HouseType.newHouse,
                         HouseType.neighborhood]

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

class SuggestionListTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {

    let suggestions = BehaviorRelay<[SuggestionItem]>(value: [])

    let suggestionHistory = BehaviorRelay<[SuggestionItem]>(value: [])
    
    let combineItems = BehaviorRelay<[SuggestionItem]>(value: [])

    var highlighted: String?

    let disposeBag = DisposeBag()

    var onSuggestionItemSelect: ((_ query: String,_ associationalWord: String?) -> Void)?

    let houseType: BehaviorRelay<HouseType>

    lazy var sectionHeaderView = SuggestionHeaderView()
    
    private lazy var suggestionHistoryDataSource: SuggestionHistoryDataSource = {
        SuggestionHistoryDataSource()
    }()

    init(houseType: BehaviorRelay<HouseType>) {
        self.houseType = houseType
        super.init()
        BehaviorRelay
                .combineLatest(suggestions, suggestionHistory)
                .map(itemSelector())
                .bind(to: combineItems)
                .disposed(by: disposeBag)
        houseType
            .bind(onNext: { [unowned self] houseType in
                self.suggestionHistory.accept(self.suggestionHistoryDataSource.getHistoryByType(houseType: houseType))
            })
            .disposed(by: disposeBag)

        suggestions
                .map { $0.count != 0 }
                .bind(to: sectionHeaderView.deleteBtn.rx.isHidden)
                .disposed(by: disposeBag)

        suggestions
                .map {
                    if $0.count == 0 {
                        return "历史记录"
                    }
                    return "猜你想搜的"
                }
                .bind(to: sectionHeaderView.label.rx.text)
                .disposed(by: disposeBag)


        sectionHeaderView.deleteBtn.rx.tap.bind { [unowned self] void in
            self.suggestionHistoryDataSource.cleanHistoryItems(houseType: self.houseType.value)
            self.suggestionHistory.accept([])
        }.disposed(by: disposeBag)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let datas = combineItems.value
        return datas.count > 0 ? 1 : 0
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
            let text = combineItems.value[indexPath.row].text {
            theCell.secondaryLabel.text = houseType.value.stringValue()
            let attrTextProcess = highlightedText(originalText: "\(text)", highlitedText: "")
            
            theCell.label.attributedText = attrTextProcess(attrText(text: text))
        } else {
            switch houseType.value {
            case .newHouse where suggestions.value.count == 0:
                fillNormalItem(cell: cell, item: combineItems.value[indexPath.row], highlighted: highlighted)
            case .newHouse:
                fillNewHouseItem(cell: cell, item: combineItems.value[indexPath.row], highlighted: highlighted)
            default:
                fillNormalItem(cell: cell, item: combineItems.value[indexPath.row], highlighted: highlighted)
            }
        }


        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = combineItems.value[indexPath.row]
        let info = item.info
        suggestionHistoryDataSource.addHistoryItem(item: combineItems.value[indexPath.row], houseType: houseType.value)
        suggestionHistory.accept(suggestionHistoryDataSource.getHistoryByType(houseType: houseType.value))
        
        onSuggestionItemSelect?(createQueryCondition(info), item.text)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaderView
    }

    func sendQuery(
            tableView: UITableView) -> (String?) -> Void {
        return { [unowned self] (query) in
            if let query = query {
                self.highlighted = query
                requestSuggestion(cityId: 133, horseType: self.houseType.value.rawValue, query: query)
                        .subscribe(onNext: { [unowned self] (responsed) in
                            if let responseData = responsed?.data {
                                self.suggestions.accept(responseData)
                            }
                        }, onError: { (error) in
                            print(error)
                        })
                        .disposed(by: self.disposeBag)
            }
        }
    }

    private func createQueryCondition(_ info: Any?) -> String {
        var queryCondition = ""
        if let conditions = info as? [String: Any] {
            do {
                if let condition = String(
                        data: try JSONSerialization.data(withJSONObject: conditions),
                        encoding: .utf8) {
                    queryCondition.append(condition)
                }
            } catch {
                print(error)
            }
        }
        return queryCondition
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
}

fileprivate func fillNormalItem(cell: UITableViewCell, item: SuggestionItem, highlighted: String?) {
    if let theCell = cell as? SuggestionItemCell {
        if var text = item.text {
            if let info = item.info as? [String: Any], info["is_cut"] != nil {
                // do nothing
            } else if item.text2 != nil && !item.text2!.isEmpty {
                text = text + "-\(item.text2!)"
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
        color: UIColor = hexStringToUIColor(hex: "#f85959"),
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
            var attributes: [NSAttributedStringKey: Any] = [.foregroundColor: hexStringToUIColor(hex: "#999999")]

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

