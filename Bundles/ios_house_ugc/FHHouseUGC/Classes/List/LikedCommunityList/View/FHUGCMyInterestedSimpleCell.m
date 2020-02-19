//
//  FHUGCMyInterestedSimpleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/14.
//

#import "FHUGCMyInterestedSimpleCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"
#import "TTDeviceHelper.h"
#import "FHUGCFollowButton.h"
#import "FHUGCMyInterestModel.h"
#import "FHUGCConfig.h"

#define iconWidth 48

@interface FHUGCMyInterestedSimpleCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UILabel *sourceLabel;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) FHUGCFollowButton *joinBtn;
@property(nonatomic, strong) UIView *bottomLine;

@end

@implementation FHUGCMyInterestedSimpleCell

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 关注状态改变
- (void)followStateChanged:(NSNotification *)notification {
    if (notification) {
        FHUGCMyInterestDataRecommendSocialGroupsModel *model = (FHUGCMyInterestDataRecommendSocialGroupsModel *)self.currentData;
        NSDictionary *userInfo = notification.userInfo;
        BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
        NSString *groupId = notification.userInfo[@"social_group_id"];
        NSString *currentGroupId = model.socialGroup.socialGroupId;
        if(groupId.length > 0 && currentGroupId.length > 0) {
            if ([groupId isEqualToString:currentGroupId]) {
                if (self.currentData) {
                    // 替换关注人数 AA关注BB热帖 替换：AA
                    [[FHUGCConfig sharedInstance] updateScialGroupDataModel:model.socialGroup byFollowed:followed];
                    [self refreshWithData:self.currentData];
                }
            }
        }
    }
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHUGCMyInterestDataRecommendSocialGroupsModel class]]){
        self.currentData = data;
        FHUGCMyInterestDataRecommendSocialGroupsModel *model = (FHUGCMyInterestDataRecommendSocialGroupsModel *)data;
        _titleLabel.text = model.socialGroup.socialGroupName;
        _descLabel.text = model.socialGroup.countText;
        _sourceLabel.text = model.socialGroup.suggestReason;
        [self.icon bd_setImageWithURL:[NSURL URLWithString:model.socialGroup.avatar] placeholder:nil];
        self.joinBtn.groupId = model.socialGroup.socialGroupId;
        self.joinBtn.followed = [model.socialGroup.hasFollow boolValue];
        self.joinBtn.tracerDic = self.tracerDic;
    }
}

- (void)initViews {
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
    [self.contentView addSubview:_joinBtn];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_bottomLine];
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
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sourceLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
