//
//  FHUGCRecommendCircleSubCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/4/27.
//

#import "FHUGCRecommendCircleSubCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCModel.h"

#define iconWidth 50

@interface FHUGCRecommendCircleSubCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *descIcon;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UIView *blackCoverView;
@property(nonatomic, strong) UIView *descView;

@end
@implementation FHUGCRecommendCircleSubCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstains];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHUGCScialGroupDataModel class]]){
        FHUGCScialGroupDataModel *model = (FHUGCScialGroupDataModel *)data;
        _titleLabel.text = model.name;
        _descLabel.text = model.suggestReason;
        
        if(model.avatar.length > 0){
            [self.icon bd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil];
        }
        
        if (model.tagIcon.length > 0 && ![model.socialGroupId isEqualToString:@"-1"]) {
            self.descIcon.hidden = NO;
            [self.descIcon bd_setImageWithURL:[NSURL URLWithString:model.tagIcon] placeholder:nil];
            [self.descIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(11);
            }];
        }else{
            self.descIcon.hidden = YES;
            [self.descIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(0);
            }];
        }
        
        if (model.suggestReason.length >0) {
            self.descLabel.hidden = NO;
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView).offset(13);
                make.left.mas_equalTo(self.contentView).offset(10);
                make.right.mas_equalTo(self.contentView).offset(-10);
                make.height.mas_equalTo(20);
            }];
        }else {
            self.descLabel.hidden = YES;
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.contentView);
                make.left.mas_equalTo(self.contentView).offset(10);
                make.right.mas_equalTo(self.contentView).offset(-10);
                make.height.mas_equalTo(20);
            }];
        }
        
        if([model.socialGroupId isEqualToString:@"-1"]){
            self.blackCoverView.hidden = YES;
        }else{
            self.blackCoverView.hidden = NO;
        }
    }
}

- (void)initView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    self.icon = [[UIImageView alloc] init];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = 4;
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.layer.borderWidth = 0.5;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
    [self.contentView addSubview:_icon];
    
    self.blackCoverView = [[UIView alloc] init];
    _blackCoverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _blackCoverView.hidden = YES;
    [self.contentView addSubview:_blackCoverView];
    
    self.descView = [[UIView alloc] init];
    [self.contentView addSubview:_descView];
    
    self.descIcon = [[UIImageView alloc] init];
    [_descView addSubview:_descIcon];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor whiteColor]];
    _descLabel.textAlignment = NSTextAlignmentCenter;
    [_descView addSubview:_descLabel];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
}

- (void)initConstains {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.blackCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(13);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    [self.descView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.centerX.mas_equalTo(self.contentView);
        make.width.mas_lessThanOrEqualTo(100);
        make.height.mas_equalTo(14);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self.descView);
        make.left.mas_equalTo(self.descIcon.mas_right);
    }];
    
    [self.descIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.descView);
        make.centerY.mas_equalTo(self.descLabel);
        make.right.equalTo(self.descLabel.mas_left);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(12);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
