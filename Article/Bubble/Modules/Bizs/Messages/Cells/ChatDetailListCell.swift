//
//  ChatCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//



import UIKit
import SnapKit
import CoreGraphics

class ChatDetailListCell: BaseUITableViewCell {

    override open class var identifier: String {
        return "ChatDetailListCell"
    }
    
    var imageRequest: BDWebImageRequest?
    
    lazy var majorImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var majorTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(16)
        label.textColor = hexStringToUIColor(hex: "#222222")
        return label
    }()
    
    lazy var extendTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#505050")
        return label
    }()
    
    lazy var areaLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping//按照单词分割换行，保证换行时的单词完整。
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = CommonUIStyle.Font.pingFangMedium(14)
        label.textColor = hexStringToUIColor(hex: "#f85959")
        return label
    }()
    
    lazy var roomSpaceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#999999")
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.height.equalTo(0.5)
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(15)
            maker.right.equalToSuperview().offset(-15)
        }
        
        self.contentView.addSubview(majorImageView)
        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(15)
            maker.top.equalToSuperview().offset(16)
            maker.bottom.equalTo(-16)
            maker.width.equalTo(114)
            maker.height.equalTo(85)
        }
        
        let infoPanel = UIView()
        self.addSubview(infoPanel)
        infoPanel.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(5)
            maker.top.bottom.equalToSuperview()
            maker.right.equalToSuperview().offset(-15)
        }
        
        infoPanel.addSubview(majorTitle)
        majorTitle.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(23)
            maker.top.equalToSuperview().offset(13)
        }
        
        infoPanel.addSubview(extendTitle)
        extendTitle.snp.makeConstraints { [unowned majorTitle] maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(majorTitle.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }
        
        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { [unowned extendTitle] maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(5)
            maker.width.greaterThanOrEqualTo(100)
            maker.height.equalTo(15)
        }
        infoPanel.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { [unowned areaLabel] maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(areaLabel.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }
        
        
        infoPanel.addSubview(roomSpaceLabel)
        roomSpaceLabel.snp.makeConstraints { [unowned priceLabel] maker in
            maker.left.equalTo(priceLabel.snp.right).offset(5)
            maker.top.equalTo(priceLabel.snp.top)
            maker.height.equalTo(17)
        }
    }
    
    func setImageByUrl(_ url: String) {
        imageRequest = majorImageView.bd_setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "default_image"))
    }
    
    override func prepareForReuse() {
        imageRequest?.cancel()
        imageRequest = nil
    }
}



class UserMsgSectionView: UIView {
    
    lazy var timeAreaBgView: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 13.5
        re.backgroundColor = color(0, 0, 0, 0.15)
        return re
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangMedium(18)
        label.textColor = hexStringToUIColor(hex: "#222222")
        label.text = ""
        return label
    }()
    
    lazy var tipsBgView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        return re
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangMedium(14)
        label.textColor = hexStringToUIColor(hex: "#ffffff")
        label.text = ""
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)

        self.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        addSubview(timeAreaBgView)
        timeAreaBgView.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(20)
            maker.height.equalTo(27)
        }
        
        timeAreaBgView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.height.equalTo(22)
            maker.top.equalTo(4)
            maker.bottom.equalTo(-4)
        }
        
        addSubview(tipsBgView)
        tipsBgView.snp.makeConstraints { (maker) in
            maker.top.equalTo(timeAreaBgView.snp.bottom).offset(15)
            maker.bottom.left.right.equalToSuperview()
        }
        
        tipsBgView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.right.equalTo(-37)
            maker.height.equalTo(25)
            maker.top.equalTo(18)
            maker.bottom.equalTo(-17)
        }
        self.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.height.equalTo(0.5)
            maker.bottom.equalToSuperview()
            maker.left.right.equalToSuperview()
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



