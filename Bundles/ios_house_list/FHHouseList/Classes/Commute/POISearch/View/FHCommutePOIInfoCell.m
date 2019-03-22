//
//  FHCommutePOIInfoCell.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import "FHCommutePOIInfoCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <Masonry/Masonry.h>

#define TOP_MARGIN      20
#define ITEM_VER_MARGIN 4

@interface FHCommutePOIInfoCell ()

@property(nonatomic , strong) UILabel *nameLabel;
@property(nonatomic , strong) UILabel *addressLabel;

@end

@implementation FHCommutePOIInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UILabel *)label:(UIFont *)font textColor:(UIColor *)textColor
{
    
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    
    return label;
}

-(void)initUIs
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _nameLabel = [self label:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    _addressLabel = [self label:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_addressLabel];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.top.mas_equalTo(TOP_MARGIN);
        make.right.mas_lessThanOrEqualTo(-HOR_MARGIN);
        make.height.mas_equalTo(20);
    }];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.right.mas_lessThanOrEqualTo(self.contentView).offset(-HOR_MARGIN);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(ITEM_VER_MARGIN);
    }];
}


-(void)updateName:(NSString *)name address:(NSString *)address
{
    _nameLabel.text = name;
    _addressLabel.text = address;
}


@end
