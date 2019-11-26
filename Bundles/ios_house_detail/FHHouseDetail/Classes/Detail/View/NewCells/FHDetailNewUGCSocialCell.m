//
//  FHDetailNewUGCSocialCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/11/25.
//

#import "FHDetailNewUGCSocialCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "UILabel+House.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import <TTSandBoxHelper.h>
#import "FHHouseNewsSocialModel.h"

@interface FHDetailNewUGCSocialCell()

@property (nonatomic, strong)   UIControl       *bgControl; // 底部按钮
@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   UILabel       *descLabel;
@property (nonatomic, strong)   UIImageView       *iconImageView;
@property (nonatomic, strong)   UILabel       *contentLabel;
@property (nonatomic, strong)   UIImageView       *rightArrowIcon;

@end

@implementation FHDetailNewUGCSocialCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHHouseNewsSocialModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHHouseNewsSocialModel *socialInfo = (FHHouseNewsSocialModel *)data;
    if (socialInfo) {
        self.titleLabel.text = socialInfo.socialGroupInfo.socialGroupName;
        NSString *descStr = socialInfo.socialGroupInfo.countText;// 帖子数
        if (descStr.length > 0) {
            descStr = [NSString stringWithFormat:@"%@ | %@人关注",descStr,socialInfo.socialGroupInfo.followerCount];
        }
        self.descLabel.text = descStr;
        if (socialInfo.socialActiveInfo && [socialInfo.socialActiveInfo isKindOfClass:[NSArray class]]) {
            if (socialInfo.socialActiveInfo.count > 0) {
                FHDetailCommunityEntryActiveInfoModel *model = socialInfo.socialActiveInfo[0];
                [self.iconImageView bd_setImageWithURL:[NSURL URLWithString:model.activeUserAvatar] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
                self.contentLabel.text = model.suggestInfo;
            } else {
                self.contentLabel.text = @"";
                self.iconImageView.image = [UIImage imageNamed:@"detail_default_avatar"];
            }
        } else {
            self.contentLabel.text = @"";
            self.iconImageView.image = [UIImage imageNamed:@"detail_default_avatar"];
        }
    }
  
    [self layoutIfNeeded];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor themeWhite];
    self.bgControl = [[UIControl alloc] initWithFrame:CGRectZero];
    self.bgControl.backgroundColor = [UIColor themeWhite];
    [self.contentView addSubview:self.bgControl];
    [self.bgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(119);
    }];
    
    [self.bgControl addTarget:self action:@selector(cellClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:18];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.font = [UIFont themeFontMedium:18];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 1;
    [self.contentView addSubview:_titleLabel];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(26);
    }];
    
    _descLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _descLabel.textColor = [UIColor themeGray3];
    _descLabel.textAlignment = NSTextAlignmentLeft;
    _descLabel.numberOfLines = 1;
    [self.contentView addSubview:_descLabel];
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.right.mas_equalTo(self.contentView).offset(-45);
        make.height.mas_equalTo(17);
    }];
    
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.layer.cornerRadius = 14;
    _iconImageView.clipsToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(28);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(8);
    }];
    
    _contentLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _contentLabel.textColor = [UIColor themeGray1];
    _contentLabel.textAlignment = NSTextAlignmentLeft;
    _contentLabel.numberOfLines = 1;
    [self.contentView addSubview:_contentLabel];
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(8);
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.mas_equalTo(self.contentView).offset(-45);
        make.height.mas_equalTo(22);
    }];
    
    _rightArrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
    [self.contentView addSubview:self.rightArrowIcon];
    [self.rightArrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.height.mas_equalTo(20);
    }];
}

// 跳转圈子
- (void)cellClicked:(UIControl *)controll {
    // add by zyk 记得埋点
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
    if (self.currentData) {
        FHHouseNewsSocialModel *socialInfo = (FHHouseNewsSocialModel *)self.currentData;
        if (socialInfo.socialGroupInfo && socialInfo.socialGroupInfo.socialGroupId.length > 0) {
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"community_id"] = socialInfo.socialGroupInfo.socialGroupId;
            dict[@"tracer"] = tracerDic;
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            // 跳转到圈子详情页
            NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
        }
    }
}

// add by zyk
- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"ugc_social_info";
}

@end
