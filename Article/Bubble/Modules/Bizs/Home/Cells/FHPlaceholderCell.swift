//
//  FHPlaceholderCell.swift
//  Article
//
//  Created by 张静 on 2018/9/14.
//

import UIKit

class FHPlaceholderCell: BaseUITableViewCell {

    override open class var identifier: String {
        return "FHPlaceholderCell"
    }
    
    lazy var majorImageView: UIImageView = {
        let re = UIImageView(image: UIImage(named: "house_cell_placeholder"))
        re.contentMode = .scaleAspectFill
        re.layer.masksToBounds = true
        return re
    }()
    
    lazy var view1: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHPaleGreyColor)
        return re
    }()
    
    lazy var view2: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHPaleGreyColor)
        return re
    }()
    
    lazy var view3: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHPaleGreyColor)
        return re
    }()
    
    lazy var view4: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: kFHPaleGreyColor)
        return re
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .white
        self.contentView.addSubview(majorImageView)
        
        majorImageView.snp.makeConstraints { maker in
            maker.bottom.equalToSuperview()
            maker.left.equalTo(20)
            maker.top.equalTo(20)
            maker.width.equalTo(114)
            maker.height.equalTo(85)
        }
        
        contentView.addSubview(view1)
        contentView.addSubview(view2)
        contentView.addSubview(view3)
        contentView.addSubview(view4)
        
        view1.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(10)
            maker.top.equalTo(majorImageView)
            maker.right.equalTo(-20)
            maker.height.equalTo(14)
        }
        
        view2.snp.makeConstraints { maker in
            maker.left.equalTo(view1)
            maker.top.equalTo(view1.snp.bottom).offset(10)
            maker.right.equalTo(-20 - 44)
            maker.height.equalTo(8)
        }
        
        view3.snp.makeConstraints { maker in
            maker.left.equalTo(view1)
            maker.top.equalTo(view2.snp.bottom).offset(15)
            maker.right.equalTo(view2.snp.centerX).offset(10)
            maker.height.equalTo(15)
        }
        
        view4.snp.makeConstraints { maker in
            maker.left.equalTo(view1)
            maker.bottom.equalTo(majorImageView)
            maker.right.equalTo(-20 - 65)
            maker.height.equalTo(10)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

func fillHousePlaceholderItemCell(isFirst: Bool = false, cell: BaseUITableViewCell) {
  
//    if let theCell = cell as? FHPlaceholderCell {
//
//        if isFirst {
//            theCell.majorImageView.snp.updateConstraints { maker in
//                maker.top.equalTo(0)
//            }
//        }else {
//            theCell.majorImageView.snp.updateConstraints { maker in
//                maker.top.equalTo(0)
//            }
//        }
//    }
}

func fillHouseListPlaceholderItemCell(isFirst: Bool = false, cell: BaseUITableViewCell) {
    
//    if let theCell = cell as? FHPlaceholderCell {
//
//        if isFirst {
//            theCell.majorImageView.snp.updateConstraints { maker in
//                maker.top.equalTo(0)
//            }
//        }else {
//            theCell.majorImageView.snp.updateConstraints { maker in
//                maker.top.equalTo(0)
//            }
//        }
//    }
}

func parseHousePlaceholderNode(nodeCount: Int = 5) -> () -> TableSectionNode? {
    return {
        var defaultItems :[TableCellRender] = [] //默认5个占位cell
        for i in 0..<nodeCount {
          defaultItems.append(curry(fillHousePlaceholderItemCell)(i == 0))
        }
        return TableSectionNode(
            items: defaultItems,
            selectors: nil,
            tracer: nil,
            sectionTracer: nil,
            label: "placeholder",
            type: .node(identifier: FHPlaceholderCell.identifier))
    }
}

func parseHousePlaceholderRowNode(nodeCount: Int = 5) -> () -> [TableRowNode] {
    
    var defaultItems :[TableCellRender] = [] //默认5个占位cell
    for i in 0..<nodeCount {
        
        defaultItems.append(curry(fillHouseListPlaceholderItemCell)(i == 0))
    }
    return {
        let renders = defaultItems.map({ (render) -> TableRowNode in
            return TableRowNode(
                itemRender: render,
                selector: nil,
                tracer: nil,
                type: .node(identifier: FHPlaceholderCell.identifier), editor: nil)
        })
        return renders
    }
}

