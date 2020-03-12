//
//  FHDetailNewUGCSocialCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/11/25.
//

#import "FHDetailNewUGCSocialCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "UILabel+House.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "TTSandBoxHelper.h"
#import "FHHouseNewsSocialModel.h"
#import "TTUGCEmojiParser.h"

@interface FHDetailNewUGCSocialCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIControl       *bgControl; // 底部按钮
@property (nonatomic, strong)   UILabel       *titleLabel;
@property (nonatomic, strong)   UILabel       *descLabel;
@property (nonatomic, strong)   UIImageView       *iconImageView;
@property (nonatomic, strong)   TTUGCAttributedLabel       *contentLabel;
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

// 去除空格和换行
- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHDetailNewUGCSocialCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHDetailNewUGCSocialCellModel *cellModel = (FHDetailNewUGCSocialCellModel *)data;
    FHHouseNewsSocialModel *socialInfo = cellModel.socialInfo;
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
                NSString *textStr = model.suggestInfo;
                textStr = [self removeSpaceAndNewline:textStr];
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:[TTUGCEmojiParser parseInCoreTextContext:textStr fontSize:16]];
                NSMutableDictionary *typeAttributes = @{}.mutableCopy;
                [typeAttributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
                [typeAttributes setValue:[UIFont themeFontRegular:16] forKey:NSFontAttributeName];
                if (attrStr.length > 0) {
                    [attrStr addAttributes:typeAttributes range:NSMakeRange(0, attrStr.length)];
                }
                [self.contentLabel setText:attrStr];
            } else {
                [self.contentLabel setText:@""];
                self.iconImageView.image = [UIImage imageNamed:@"detail_default_avatar"];
            }
        } else {
            [self.contentLabel setText:@""];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellData:) name:@"kFHDetailNewUGCSocialCellNotiKey" object:nil];
    }
    return self;
}

// 刷新Cell
- (void)updateCellData:(NSNotification *)noti {
    if (noti) {
        NSString *social_group_id = noti.userInfo[@"social_group_id"];
        if (self.currentData && social_group_id && [social_group_id isKindOfClass:[NSString class]]) {
            FHDetailNewUGCSocialCellModel *cellModel = (FHDetailNewUGCSocialCellModel *)self.currentData;
            FHHouseNewsSocialModel *socialInfo = cellModel.socialInfo;
            if ([socialInfo.socialGroupInfo.socialGroupId isEqualToString:social_group_id]) {
                [self refreshWithData:self.currentData];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setupUI {
    
    self.backgroundColor = [UIColor themeWhite];
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.layer.cornerRadius = 10;
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    self.bgControl = [[UIControl alloc] initWithFrame:CGRectZero];
    self.bgControl.backgroundColor = [UIColor themeWhite];
    [self.containerView addSubview:self.bgControl];
    [self.bgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
        make.height.mas_equalTo(119);
    }];
    
    [self.bgControl addTarget:self action:@selector(cellClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:18];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.font = [UIFont themeFontMedium:18];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 1;
    [self.containerView addSubview:_titleLabel];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.containerView).offset(15);
        make.right.mas_equalTo(self.containerView).offset(-15);
        make.height.mas_equalTo(26);
    }];
    
    _descLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _descLabel.textColor = [UIColor themeGray3];
    _descLabel.textAlignment = NSTextAlignmentLeft;
    _descLabel.numberOfLines = 1;
    [self.containerView addSubview:_descLabel];
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).offset(15);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.right.mas_equalTo(self.containerView).offset(-45);
        make.height.mas_equalTo(17);
    }];
    
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.layer.cornerRadius = 14;
    _iconImageView.clipsToBounds = YES;
    [self.containerView addSubview:_iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).offset(15);
        make.width.height.mas_equalTo(28);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(8);
    }];
    
    _contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.font = [UIFont themeFontRegular:16];
    _contentLabel.textColor = [UIColor themeGray1];
    _contentLabel.textAlignment = NSTextAlignmentLeft;
    _contentLabel.numberOfLines = 1;
    [self.containerView addSubview:_contentLabel];
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).offset(8);
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.mas_equalTo(self.containerView).offset(-45);
        make.height.mas_equalTo(22);
    }];
    
    _rightArrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
    [self.containerView addSubview:self.rightArrowIcon];
    [self.rightArrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.containerView);
        make.right.mas_equalTo(self.containerView).offset(-15);
        make.width.height.mas_equalTo(20);
    }];
}

// 跳转圈子
- (void)cellClicked:(UIControl *)controll {
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    if (self.currentData) {
        FHDetailNewUGCSocialCellModel *cellModel = (FHDetailNewUGCSocialCellModel *)self.currentData;
        FHHouseNewsSocialModel *socialInfo = cellModel.socialInfo;
        if (socialInfo.socialGroupInfo && socialInfo.socialGroupInfo.socialGroupId.length > 0) {
            self.baseViewModel.contactViewModel.needRefetchSocialGroupData = YES;
            NSDictionary *log_pb = tracerDic[@"log_pb"];
            NSString *group_id = nil;
            if (log_pb && [log_pb isKindOfClass:[NSDictionary class]]) {
                group_id = log_pb[@"group_id"];
            }
            tracerDic[@"log_pb"] = socialInfo.socialGroupInfo.logPb ? socialInfo.socialGroupInfo.logPb : @"be_null";
            NSString *page_type = tracerDic[@"page_type"];
            tracerDic[@"enter_from"] = page_type ?: @"be_null";
            tracerDic[@"enter_type"] = @"click";
            tracerDic[@"group_id"] = group_id ?: @"be_null";
            tracerDic[@"element_from"] = @"community_group";
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

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"community_group";
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}


@end

@implementation FHDetailNewUGCSocialCellModel



@end
