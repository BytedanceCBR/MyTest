//
//  FHDetailNearbyMapItemCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/12.
//

#import "FHDetailNearbyMapItemCell.h"

@interface FHDetailNearbyMapItemCell()
@property (nonatomic , strong) UILabel *labelLeft;
@property (nonatomic , strong) UILabel *labelRight;
@end

@implementation FHDetailNearbyMapItemCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpLabels];
    }
    return self;
}

- (void)setUpLabels
{
    _labelLeft = [UILabel new];
    _labelLeft.textAlignment = NSTextAlignmentLeft;
    _labelLeft.font = [UIFont themeFontMedium:14];
    _labelLeft.textColor = [UIColor colorWithHexString:@"#081f33"];
    [self.contentView addSubview:_labelLeft];
    
    [_labelLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(35);
    }];

    _labelRight = [UILabel new];
    _labelRight.textAlignment = NSTextAlignmentRight;
    _labelRight.font = [UIFont themeFontRegular:14];
    _labelRight.textColor = [UIColor colorWithHexString:@"#a1aab3"];
    [self.contentView addSubview:_labelRight];
    
    
    [_labelRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.bottom.height.equalTo(self.labelLeft);
    }];
    
    [_labelLeft setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_labelRight setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
}

- (void)updateText:(NSString *)name andDistance:(NSString *)distance
{
    _labelLeft.text = name;
    _labelRight.text = distance;
}


//fileprivate class LocationCell: UITableViewCell {
//
//    lazy var label: UILabel = {
//        let re = UILabel()
//        re.textAlignment = .left
//        re.font = CommonUIStyle.Font.pingFangMedium(14)
//        re.textColor = hexStringToUIColor(hex: "#081f33")
//        return re
//    }()
//
//    lazy var label2: UILabel = {
//        let re = UILabel()
//        re.font = CommonUIStyle.Font.pingFangRegular(14)
//        re.textColor = hexStringToUIColor(hex: "#a1aab3")
//        re.textAlignment = .right
//        return re
//    }()
//
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        contentView.addSubview(label2)
//        label2.snp.makeConstraints { maker in
//            maker.right.equalToSuperview().offset(-20)
//            maker.top.bottom.equalToSuperview
//            maker.height.equalTo(35)
//        }
//
//        contentView.addSubview(label)
//        label.snp.makeConstraints { maker in
//            maker.left.equalTo(20)
//            maker.top.equalTo(label2)
//            maker.height.equalTo(label2)
//            maker.bottom.equalTo(label2)
//            maker.right.equalTo(label2.snp.left).offset(-5)
//        }
//        label2.setContentCompressionResistancePriority(.required, for: .horizontal)
//        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
