//
//  FHMyJoinCommnityCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/21.
//

#import "FHMyJoinCommnityCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIImageView+fhUgcImage.h"
#import "FHUGCModel.h"

#define iconWidth 50

@interface FHMyJoinCommnityCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UIView *blackCoverView;

@end

@implementation FHMyJoinCommnityCell

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
        _titleLabel.text = model.socialGroupName;
        _descLabel.text = model.countText;
        
        if([model.socialGroupId isEqualToString:@"-1"]){
            self.blackCoverView.hidden = YES;
            self.icon.image = [UIImage imageNamed:@"fh_ugc_all_bg"];
        }else{
            self.blackCoverView.hidden = NO;
            [self.icon fh_setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil reSize:self.contentView.bounds.size];
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
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor whiteColor]];
    _descLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_descLabel];
}

- (void)initConstains {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.blackCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(13);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(self.contentView).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo(14);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end


