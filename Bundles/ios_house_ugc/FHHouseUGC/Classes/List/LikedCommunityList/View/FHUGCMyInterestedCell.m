//
//  FHUGCMyInterestedSimpleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/14.
//

#import "FHUGCMyInterestedCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import <UIImageView+BDWebImage.h>
#import "TTDeviceHelper.h"
#import "FHUGCMyInterestModel.h"
#import "FHUGCFollowButton.h"
#import "FHUGCConfig.h"
#import "TTUGCAttributedLabel.h"
#import "FHUGCCellHelper.h"

#define iconWidth 50
#define maxLines 2

@interface FHUGCMyInterestedCell ()

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UILabel *sourceLabel;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) FHUGCFollowButton *joinBtn;
@property(nonatomic, strong) UIView *bottomSepLine1;
@property(nonatomic, strong) UIView *bottomSepLine2;

@property(nonatomic, strong) TTUGCAttributedLabel *postDescLabel;
@property(nonatomic, strong) UIImageView *postIcon;
@property(nonatomic, strong) UIImageView *locationIcon;

@end

@implementation FHUGCMyInterestedCell

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socialGroupDataChange:) name:@"kFHUGCSicialGroupDataChangeKey" object:nil];
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

- (void)socialGroupDataChange:(NSNotification *)notification {
    if (notification) {
        FHUGCMyInterestDataRecommendSocialGroupsModel *tempModel = self.currentData;
        if (tempModel && [tempModel isKindOfClass:[FHUGCMyInterestDataRecommendSocialGroupsModel class]]) {
            NSString *socialGroupId = tempModel.socialGroup.socialGroupId;
            FHUGCScialGroupDataModel *model = [[FHUGCConfig sharedInstance] socialGroupData:socialGroupId];
            if (model && (![model.countText isEqualToString:tempModel.socialGroup.countText] || ![model.hasFollow isEqualToString:tempModel.socialGroup.hasFollow])) {
                tempModel.socialGroup.contentCount = model.contentCount;
                tempModel.socialGroup.countText = model.countText;
                tempModel.socialGroup.hasFollow = model.hasFollow;
                tempModel.socialGroup.followerCount = model.followerCount;
                
                [self refreshWithData:tempModel];
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
        _postDescLabel.text = model.threadInfo.content;
        //内容
        if(isEmptyString(model.threadInfo.content)){
            self.postDescLabel.hidden = YES;
        }else{
            self.postDescLabel.hidden = NO;
            //内容
            [FHUGCCellHelper setRichContent:_postDescLabel content:model.threadInfo.content font:[UIFont themeFontRegular:14] numberOfLines:maxLines];
        }
        [self.icon bd_setImageWithURL:[NSURL URLWithString:model.socialGroup.avatar] placeholder:nil];
        self.joinBtn.groupId = model.socialGroup.socialGroupId;
        self.joinBtn.followed = [model.socialGroup.hasFollow boolValue];
        self.joinBtn.tracerDic = self.tracerDic;
        [self updateImageConstraints:model];
    }
}

- (void)updateImageConstraints:(FHUGCMyInterestDataRecommendSocialGroupsModel *)model {
    if(model.threadInfo.images.count > 0){
        FHUGCMyInterestDataRecommendSocialGroupsThreadInfoImagesModel *imageModel = [model.threadInfo.images firstObject];
        [self.postIcon bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
        
        self.postIcon.hidden = NO;
        [self.postDescLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.postIcon);
            make.left.mas_equalTo(self.containerView).offset(10);
            make.right.mas_equalTo(self.postIcon.mas_left).offset(-10);
            make.height.mas_equalTo(40);
        }];
        
        [self.bottomSepLine2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.postIcon.mas_bottom).offset(10);
            make.left.mas_equalTo(self.containerView).offset(10);
            make.right.mas_equalTo(self.containerView).offset(-10);
            make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
        }];
    }else{
        //当没有图片时
        self.postIcon.hidden = YES;
        [self.postDescLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomSepLine1.mas_bottom).offset(15);
            make.left.mas_equalTo(self.containerView).offset(10);
            make.right.mas_equalTo(self.containerView).offset(-25);
        }];
        
        [self.bottomSepLine2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.postDescLabel.mas_bottom).offset(15);
            make.left.mas_equalTo(self.containerView).offset(10);
            make.right.mas_equalTo(self.containerView).offset(-10);
            make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
        }];
        
    }

}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor themeGray7];
    
    self.containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.layer.masksToBounds = YES;
    _containerView.layer.cornerRadius = 4;
    [self.contentView addSubview:_containerView];
    
    self.icon = [[UIImageView alloc] init];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = 4;
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.layer.borderWidth = 0.5;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
    [self.containerView addSubview:_icon];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    [self.containerView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    [self.containerView addSubview:_descLabel];
    
    self.sourceLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    [self.containerView addSubview:_sourceLabel];
    
    self.joinBtn = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_joinBtn];
    
    self.bottomSepLine1 = [[UIView alloc] init];
    _bottomSepLine1.backgroundColor = [UIColor themeGray6];
    [self.containerView addSubview:_bottomSepLine1];
    
    self.bottomSepLine2 = [[UIView alloc] init];
    _bottomSepLine2.backgroundColor = [UIColor themeGray6];
    [self.containerView addSubview:_bottomSepLine2];
    
//    self.postDescLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    self.postDescLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    [self.containerView addSubview:_postDescLabel];
    
    self.postIcon = [[UIImageView alloc] init];
    _postIcon.contentMode = UIViewContentModeScaleAspectFill;
    _postIcon.layer.masksToBounds = YES;
    _postIcon.layer.cornerRadius = 4;
    _postIcon.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_postIcon];
    
    self.locationIcon = [[UIImageView alloc] init];
    _locationIcon.image = [UIImage imageNamed:@"fh_ugc_location"];
    [self.containerView addSubview:_locationIcon];
}

- (void)initConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(10);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.width.height.mas_equalTo(iconWidth);
    }];
    
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.icon);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(24);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(14);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.joinBtn.mas_left).offset(-10);
        make.height.mas_equalTo(21);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(17);
    }];
    
    [self.bottomSepLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.postIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomSepLine1.mas_bottom).offset(10);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.postDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.postIcon);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.right.mas_equalTo(self.postIcon.mas_left).offset(-10);
        make.height.mas_equalTo(40);
    }];
    
    [self.bottomSepLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postIcon.mas_bottom).offset(10);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.locationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.sourceLabel);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.width.height.mas_equalTo(8);
    }];

    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomSepLine2.mas_bottom).offset(10);
        make.left.mas_equalTo(self.locationIcon.mas_right).offset(4);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.height.mas_equalTo(17);
        make.bottom.mas_equalTo(self.containerView).offset(-10);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)joinIn {
    
}

@end
