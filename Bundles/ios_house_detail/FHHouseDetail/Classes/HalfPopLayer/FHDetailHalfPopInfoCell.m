//
//  FHDetailHalfPopInfoCell.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopInfoCell.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHDetailOldModel.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHDetailHalfPopInfoCell ()

@property(nonatomic , strong) UIImageView *tipImageView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *stateLabel;
@property(nonatomic , strong) UILabel *tipLabel;

@end

@implementation FHDetailHalfPopInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _tipImageView = [[UIImageView alloc] init];
        _titleLabel = [self labelWithFont:[UIFont themeFontMedium:14] color:[UIColor themeGray1]];
        _stateLabel = [self labelWithFont:[UIFont themeFontRegular:12] color:nil];
        _tipLabel = [self labelWithFont:[UIFont themeFontRegular:12] color:[UIColor themeGray3]];
        _tipLabel.numberOfLines = 0;
        _tipLabel.preferredMaxLayoutWidth = [[UIScreen mainScreen]bounds].size.width - 64;
        
        [self.contentView addSubview:_tipImageView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_stateLabel];
        [self.contentView addSubview:_tipLabel];
        
        [self initConstraints];
    }
    return self;
}

-(UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    
    return label;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)initConstraints
{
    [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(18);
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.top.mas_equalTo(18);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.tipImageView);
        make.left.mas_equalTo(self.tipImageView.mas_right).offset(8);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_lessThanOrEqualTo(self.contentView);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
}

-(void)updateWithModel:(FHDetailDataBaseExtraDetectiveDetectiveInfoDetectiveListModel *)model
{
    BOOL ok = model.status.integerValue == 0;
    NSString *text = ok?@"\U0000e666":@"\U0000e658";//@"detail_check_ok":@"detail_check_failed"
    UIColor *textColor = ok? [UIColor themeGreen1]:[UIColor themeOrange1];
    self.tipImageView.image =  ICON_FONT_IMG(24, text, textColor);
    
    self.titleLabel.text  = model.title;
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:12],NSForegroundColorAttributeName:ok?[UIColor themeGreen1]:[UIColor themeOrange1]};
    
    self.stateLabel.attributedText = [[NSAttributedString alloc] initWithString:model.subTitle?:@"" attributes:attr];
    
    self.tipLabel.text = model.explainContent;
}

-(void)updateWithReasonInfoItem:(FHDetailDataBaseExtraDetectiveReasonListItem *)reasonInfoItem
{
    BOOL ok = reasonInfoItem.status == 0;
    self.tipImageView.image = [UIImage imageNamed: ok?@"detail_check_ok":@"detail_check_failed"];
    self.titleLabel.text  = reasonInfoItem.title;
    self.stateLabel.hidden = YES;
    self.tipLabel.text = reasonInfoItem.content;
    [self.tipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
    }];
}


@end
