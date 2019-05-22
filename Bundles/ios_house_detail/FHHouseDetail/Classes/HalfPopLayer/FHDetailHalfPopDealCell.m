//
//  FHDetailHalfPopDealCell.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopDealCell.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHDetailRentModel.h"

@implementation FHDetailHalfPopDealCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [self labelWithFont:[UIFont themeFontSemibold:18] color:[UIColor themeGray1]];
        _infoLabel = [self labelWithFont:[UIFont themeFontRegular:14] color:[UIColor themeGray3]];
        _imgView = [[UIImageView alloc] init];
        
        _imgView.backgroundColor = [UIColor themeGray7];
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_infoLabel];
        [self.contentView addSubview:_imgView];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
        }];
        
        [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.titleLabel);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
        }];
        
        CGFloat imgHeight = 130.0/335*(CGRectGetWidth([[UIScreen mainScreen]bounds]) - 40);
        
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.titleLabel);
            make.height.mas_equalTo(floor(imgHeight));
            make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(4);
            make.bottom.mas_equalTo(self.contentView);
        }];
        
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

-(void)updateWithModel:(FHRentDetailDataBaseExtraDialogContentModel *)model
{
    self.titleLabel.text = model.title;
    self.infoLabel.text = model.text;
    
//    self.imgView
    [self.imgView bd_setImageWithURL:[NSURL URLWithString:model.image]];
}

@end
