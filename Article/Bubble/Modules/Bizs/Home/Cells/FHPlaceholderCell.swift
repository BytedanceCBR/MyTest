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
        let re = UIImageView(image: UIImage(named: "house-invalid-name"))
        re.contentMode = .scaleAspectFill
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
            maker.right.equalTo(-20)
            maker.bottom.equalToSuperview()
            maker.left.equalTo(20)
            maker.top.equalTo(20)
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
  
    if let theCell = cell as? FHPlaceholderCell {
        
        if isFirst {
            theCell.majorImageView.snp.updateConstraints { maker in
                maker.top.equalTo(20)
            }
        }else {
            theCell.majorImageView.snp.updateConstraints { maker in
                maker.top.equalTo(0)
            }
        }
    }
}

func parseHousePlaceholderNode() -> () -> TableSectionNode? {
    return {
        var defaultItems :[TableCellRender] = [] //默认5个占位cell
        for i in 0..<5 {
            
          defaultItems.append(curry(fillHousePlaceholderItemCell)(i == 0))
        }
        return TableSectionNode(
            items: defaultItems,
            selectors: nil,
            tracer: nil,
            label: "placeholder",
            type: .node(identifier: FHPlaceholderCell.identifier))
    }
}

