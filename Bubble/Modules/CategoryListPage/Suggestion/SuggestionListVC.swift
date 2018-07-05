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

class SuggestionListVC: BaseViewController {

    lazy var navBar: SearchNavBar = {
        let result = SearchNavBar()
        result.searchInput.placeholder = "小区/商圈/地铁"
        result.searchable = true
        return result
    }()

    lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        return result
    }()

    let disposeBag = DisposeBag()

    lazy var tableViewModel: SuggestionListTableViewModel = {
        SuggestionListTableViewModel()
    }()

    var onSuggestSelect: ((@escaping (String) -> String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        UIApplication.shared.statusBarStyle = .default

        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(CommonUIStyle.NavBar.height)
        }

        navBar.searchInput.rx.textInput.text
                .throttle(0.6, scheduler: MainScheduler.instance)
//                .debounce(0.8, scheduler: MainScheduler.instance)
                .subscribe(onNext: tableViewModel.sendQuery(tableView: tableView))
                .disposed(by: disposeBag)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
        }
        tableView.dataSource = tableViewModel
        tableView.delegate = tableViewModel
        tableViewModel.onSuggestionItemSelect = { [weak self] condition in
            self?.onSuggestSelect?({
                let reuslt = "\($0)&suggestion_params=\(condition)"
                return reuslt
            })
        }
        tableView.register(SuggestionItemCell.self, forCellReuseIdentifier: "item")
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        navBar.searchInput.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

class SuggestionListTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {

    var suggestions: [SuggestionItem] = []

    var highlighted: String?

    let disposeBag = DisposeBag()

    var onSuggestionItemSelect: ((String) -> Void)?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        if let theCell = cell as? SuggestionItemCell {
            let item = suggestions[indexPath.row]
            if let text = item.text {
                let attrTextProcess = highlightedText(originalText: text, highlitedText: highlighted)
                        <*> commitText(commit: item.text2)

                theCell.label.attributedText = attrTextProcess(attrText(text: text))
            }
            theCell.secondaryLabel.text = "约\(item.count)套"
        }
        return cell ?? UITableViewCell()
    }

    func sendQuery(tableView: UITableView) -> (String?) -> Void {
        return { [unowned self, unowned tableView] (query) in
            if let query = query {
                self.highlighted = query
                requestSuggestion(cityId: 133, horseType: 2, query: query)
                        .debug()
                        .subscribe(onNext: { [unowned self] (responsed) in
                            if let responseData = responsed?.data {
                                self.suggestions = responseData
                                tableView.reloadData()
                            }
                        }, onError: { (error) in
                            print(error)
                        })
                        .disposed(by: self.disposeBag)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = suggestions[indexPath.row].info
        onSuggestionItemSelect?(createQueryCondition(info))
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
//    private func createQueryCondition(_ info: Any?) -> String {
//        var queryCondition = ""
//        if let conditions = info as? [String: Any] {
//            let querys = conditions.map { key, value -> String in "\(key)=\(value)" }
//            queryCondition.append(join(querys, withStr: "&"))
//        }
//        return queryCondition
//    }
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

class HistoryRepository {

}

class SuggestionItemCell: UITableViewCell {

    var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    var secondaryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(13)
        result.textColor = hexStringToUIColor(hex: "#999999")
        return result
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(11)
            maker.bottom.equalToSuperview().offset(-11)
            maker.width.greaterThanOrEqualTo(250)
        }

        contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { maker in
            maker.top.equalTo(12)
            maker.right.equalToSuperview().offset(-15)
            maker.left.equalTo(label.snp.right).offset(5).priority(.high)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
