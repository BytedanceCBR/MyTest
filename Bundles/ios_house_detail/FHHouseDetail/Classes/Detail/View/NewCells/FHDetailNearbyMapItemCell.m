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
    _labelLeft.font = [UIFont themeFontRegular:14];
    _labelLeft.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_labelLeft];
    
    [_labelLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(35);
        make.right.equalTo(self.contentView).offset(-80);
    }];

    _labelRight = [UILabel new];
    _labelRight.textAlignment = NSTextAlignmentRight;
    _labelRight.font = [UIFont themeFontRegular:14];
    _labelRight.textColor = [UIColor themeGray3];
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
