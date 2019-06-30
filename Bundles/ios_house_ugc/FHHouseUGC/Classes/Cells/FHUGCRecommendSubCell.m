//
//  FHUGCRecommendSubCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHUGCRecommendSubCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import <UIImageView+BDWebImage.h>
#import "FHUGCFollowButton.h"
#import "FHFeedContentModel.h"
#import "FHUGCConfig.h"
#import "TTBaseMacro.h"

#define iconWidth 48

@interface FHUGCRecommendSubCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UILabel *sourceLabel;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) FHUGCFollowButton *joinBtn;

@property(nonatomic, strong) FHFeedContentRecommendSocialGroupListModel *model;

@end

@implementation FHUGCRecommendSubCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
    [self initNotification];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHFeedContentRecommendSocialGroupListModel class]]){
        FHFeedContentRecommendSocialGroupListModel *model = (FHFeedContentRecommendSocialGroupListModel *)data;
        _model = model;
        _titleLabel.text = model.socialGroupName;
        _descLabel.text = model.countText;
        _sourceLabel.text = model.suggestReason;
        _joinBtn.groupId = model.socialGroupId;
        _joinBtn.followed = [model.hasFollow boolValue];
        [self.icon bd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil];
    }
}

- (void)initViews {
    __weak typeof(self) wself = self;
    
    self.icon = [[UIImageView alloc] init];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = iconWidth/2;
    _icon.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_icon];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_descLabel];
    
    self.sourceLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_sourceLabel];
    
    self.joinBtn = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero];
    [self addSubview:_joinBtn];
}

- (void)initConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(11);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(iconWidth);
    }];
    
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(24);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.joinBtn.mas_left).offset(-10);
        make.height.mas_equalTo(21);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(1);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(14);
    }];
    
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(14);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)followStateChanged:(NSNotification *)notification {
    if(isEmptyString(self.model.socialGroupId)){
        return;
    }
    
    BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
    NSString *groupId = notification.userInfo[@"social_group_id"];
    
    if([groupId isEqualToString:self.model.socialGroupId] && followed){
        if(self.delegate && [self.delegate respondsToSelector:@selector(joinIn:cell:)]){
            [self.delegate joinIn:self.model cell:self];
        }
    }
}

@end
