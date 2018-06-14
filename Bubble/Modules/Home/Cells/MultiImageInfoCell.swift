//
//  MultiImageInfoCell.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
class MultiImageInfoCell: UITableViewCell {

    lazy var groupView: MarqueeGroupView = {
        MarqueeGroupView()
    }()

    lazy var primaryLabel: UILabel = {
        UILabel()
    }()

    lazy var secondaryLabel: UILabel = {
        UILabel()
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        groupView.showsHorizontalScrollIndicator = false
        groupView.itemProvider = {
            [WebImageItemView(),
             WebImageItemView(),
             WebImageItemView()]
        }
        layout()
        groupView.loadData()
    }

    func layout() {
        let scrollViewReactWrapper = UIView()
        self.contentView.addSubview(scrollViewReactWrapper)
        scrollViewReactWrapper.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.height.equalTo(120)
        }
        scrollViewReactWrapper.addSubview(groupView)

        groupView.snp.makeConstraints { (make) in
            make.right.left.top.bottom.equalToSuperview()
        }
        groupView.isUserInteractionEnabled = false
        scrollViewReactWrapper.addGestureRecognizer(groupView.panGestureRecognizer)
        self.contentView.addSubview(primaryLabel)
        primaryLabel.snp.makeConstraints { [unowned scrollViewReactWrapper] (make) in
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.height.equalTo(20)
            make.top.equalTo(scrollViewReactWrapper.snp.bottom)
        }
        primaryLabel.font = UIFont.systemFont(ofSize: 12)
        primaryLabel.text = "朝阳公园 南北通透四居 + 衣帽间"
        self.contentView.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.height.equalTo(18)
            make.top.equalTo(primaryLabel.snp.bottom)
        }
        secondaryLabel.font = UIFont.systemFont(ofSize: 10)
        secondaryLabel.textColor = UIColor.lightGray
        secondaryLabel.text = "60m/2室1厅/南北/双榆树西里/海淀-双榆树"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {

    }

}
