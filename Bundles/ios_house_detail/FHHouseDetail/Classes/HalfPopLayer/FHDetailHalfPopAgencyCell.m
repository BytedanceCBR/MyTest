//
//  FHDetailHalfPopAgencyCell.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopAgencyCell.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import <BDWebImage/UIImageView+BDWebImage.h>

@interface FHDetailHalfPopAgencyCell ()

@property(nonatomic , strong)UIImageView *logoImgView;
@property(nonatomic , strong)UILabel *titleLabel;
@property(nonatomic , strong)UILabel *tipLabel;

@end

@implementation FHDetailHalfPopAgencyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _logoImgView = [[UIImageView alloc] init];
        _logoImgView.clipsToBounds = YES;
        _logoImgView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImgView.layer.borderColor = [UIColor themeGray6].CGColor;
        _logoImgView.layer.borderWidth = 0.5;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontMedium:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#222222"];
        
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.textColor = [UIColor themeGray3];
        _tipLabel.font = [UIFont themeFontRegular:12];
        
        [self.contentView addSubview:_logoImgView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_tipLabel];
        
        [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(self.contentView);
        }];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.logoImgView.mas_right).offset(15);
            make.top.mas_equalTo(4);
            make.right.mas_lessThanOrEqualTo(self.contentView).offset(-20);
            make.height.mas_equalTo(22);
        }];
        
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLabel);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
            make.right.mas_lessThanOrEqualTo(self.contentView).offset(-20);
            make.height.mas_equalTo(17);
        }];
        
    }
    return self;
}

-(void)updateWithIcon:(NSString *)iconUrl name:(NSString *)name tip:(NSString *)tip
{
    [self.logoImgView bd_setImageWithURL:[NSURL URLWithString:iconUrl]];
    
    _titleLabel.text = name;
    _tipLabel.text = tip;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
