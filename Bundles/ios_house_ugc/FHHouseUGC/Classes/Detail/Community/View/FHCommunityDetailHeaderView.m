//
// Created by zhulijun on 2019-06-12.
//

#import <Masonry/View+MASAdditions.h>
#import "FHCommunityDetailHeaderView.h"
#import "UIColor+Theme.h"
#import "UILabel+House.h"
#import "WDDefines.h"
#import "IMConsDefine.h"
#import "FHUGCFollowButton.h"
#import "SSViewBase.h"
#import "TTDeviceHelper.h"
#import "FHCommunityDetailMJRefreshHeader.h"
#import <UIFont+House.h>
#import "TTRoute.h"

@interface FHCommunityDetailHeaderView ()

@property(nonatomic, strong) UIView *infoContainer;
@property(nonatomic, strong) UIView *operationBannerContainer;
@property(nonatomic, strong) UIView *publicationsDetailView;
@end

@implementation FHCommunityDetailHeaderView

-(UILabel *)publicationsDetailViewTitleLabel {
    if(!_publicationsDetailViewTitleLabel) {
        _publicationsDetailViewTitleLabel = [UILabel new];
        _publicationsDetailViewTitleLabel.textColor = [UIColor themeGray1];
        _publicationsDetailViewTitleLabel.font = [UIFont themeFontRegular:12];
    }
    return _publicationsDetailViewTitleLabel;
}

- (UIButton *)publicationsDetailView {
    if(!_publicationsDetailView) {
        _publicationsDetailView = [UIView new];
        _publicationsDetailView.clipsToBounds = YES;
        
        // 左边垂直分割线
        UIView *vSepLine = [UIView new];
        vSepLine.backgroundColor = [UIColor themeGray6];
        [_publicationsDetailView addSubview:vSepLine];
        
        // 点击查看按钮
        [_publicationsDetailView addSubview:self.publicationsDetailViewTitleLabel];
        
        // 右箭头
        UIImageView *arrowImageView = [UIImageView new];
        arrowImageView.image = [UIImage imageNamed:@"fh_ugc_community_detail_header_right_arrow"];
        [_publicationsDetailView addSubview:arrowImageView];
        
        
        [vSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self.publicationsDetailView);
            make.width.mas_equalTo(0.5);
        }];
        
        [self.publicationsDetailViewTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(vSepLine).offset(10);
            make.top.bottom.equalTo(vSepLine);
            make.right.equalTo(arrowImageView.mas_left);
        }];
        
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.publicationsDetailViewTitleLabel);
            make.width.height.mas_equalTo(14);
            make.right.equalTo(self.publicationsDetailView);
            make.left.equalTo(self.publicationsDetailViewTitleLabel.mas_right);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPublicationsDetail:)];
        [_publicationsDetailView addGestureRecognizer:tap];
    }
    
    return _publicationsDetailView;
}

- (UIView *)operationBannerContainer {
    if(!_operationBannerContainer) {
        _operationBannerContainer = [UIView new];
        _operationBannerContainer.backgroundColor = [UIColor themeGray7];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoOperationDetail:)];
        [_operationBannerContainer addGestureRecognizer:tap];
        
        [_operationBannerContainer addSubview:self.operationBannerImageView];
        [self.operationBannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.operationBannerContainer).offset(20);
            make.right.equalTo(self.operationBannerContainer).offset(-20);
            make.top.equalTo(self.operationBannerContainer).offset(5);
            make.bottom.equalTo(self.operationBannerContainer);
        }];
    }
    return _operationBannerContainer;
}

- (UIImageView *)operationBannerImageView {
    if(!_operationBannerImageView) {
        _operationBannerImageView = [UIImageView new];
        _operationBannerImageView.backgroundColor = [UIColor themeGray6];
    }
    return _operationBannerImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self initConstraints];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor themeGray7];

    /** 头部背景图 **/
    CGFloat headerBackNormalHeight = 144;
    CGFloat headerBackXSeriesHeight = headerBackNormalHeight + 24; //刘海平多出24
    self.headerBackHeight = [TTDeviceHelper isIPhoneXSeries] ? headerBackXSeriesHeight : headerBackNormalHeight;
    self.topBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight)];
    self.topBack.clipsToBounds = YES;
    self.topBack.contentMode = UIViewContentModeScaleAspectFill;
    
    /** 头部信息区 **/
    self.infoContainer = [[UIView alloc] init];
    /* 左边头像 */
    self.avatar = [UIImageView new];
    self.avatar.backgroundColor = [UIColor themeGray7];
    self.avatar.clipsToBounds = YES;
    self.avatar.layer.cornerRadius = 4;

    /* 中间标签区 */
    self.labelContainer = [[UIView alloc] init];
    // 主标题标签
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont themeFontMedium:16];
    self.nameLabel.textColor = [UIColor themeWhite];
    self.nameLabel.numberOfLines = 1;
    // 副标题标签
    self.subtitleLabel = [UILabel new];
    self.subtitleLabel.font = [UIFont themeFontRegular:12];
    self.subtitleLabel.textColor = [UIColor themeWhite];
    self.subtitleLabel.numberOfLines = 1;
    
    // 用户关注count相关
    self.userCountBgView = [UIView new];
    self.userCountBgView.backgroundColor = [UIColor clearColor];
    [self.labelContainer addSubview:self.userCountBgView];
    
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 3.5, 0.5, 10)];
    sepLine.backgroundColor = [UIColor whiteColor];
    [self.userCountBgView addSubview:sepLine];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoSocialFollowUserList:)];
    [self.userCountBgView addGestureRecognizer:tap];
    
    self.userCountLabel = [UILabel new];
    self.userCountLabel.font = [UIFont themeFontRegular:12];
    self.userCountLabel.textColor = [UIColor themeWhite];
    self.userCountLabel.numberOfLines = 1;
    self.userCountLabel.text = @"xxx个成员";
    [self.userCountBgView addSubview:self.userCountLabel];
    
    self.userCountRightArrow = [UIImageView new];
    self.userCountRightArrow.image = [UIImage imageNamed:@"fh_ugc_community_right_2"];
    [self.userCountBgView addSubview:self.userCountRightArrow];
    
    [self.labelContainer addSubview:self.nameLabel];
    [self.labelContainer addSubview:self.subtitleLabel];
    
    /* 右边关注按钮 */
    self.followButton = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero style:FHUGCFollowButtonStyleNoBorder];
    self.followButton.followedBackgroundColor = [[UIColor themeWhite] colorWithAlphaComponent:0.4];
    self.followButton.followedTextColor = [UIColor themeWhite];
    self.followButton.followed = NO;
    
    
    [self.infoContainer addSubview:self.avatar];
    [self.infoContainer addSubview:self.labelContainer];
    [self.infoContainer addSubview:self.followButton];
    

    /** 下方公告区 **/
    self.publicationsContainer = [[UIView alloc] init];
    self.publicationsContainer.clipsToBounds = YES;
    self.publicationsContainer.backgroundColor = [UIColor themeWhite];
    // 公告内容
    self.publicationsContentLabel = [UILabel new];
    self.publicationsContentLabel.font = [UIFont themeFontRegular:12];
    self.publicationsContentLabel.textColor = [UIColor themeGray1];
    self.publicationsContentLabel.numberOfLines = PublicationsContentLabel_numberOfLines;
    [self.publicationsContentLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.publicationsContainer addSubview:self.publicationsContentLabel];
    [self.publicationsContainer addSubview:self.publicationsDetailView]; // 公告点击查看按钮
    
    
    /** 背景图 **/
    [self addSubview:self.topBack];
    /** 信息区 **/
    [self addSubview:self.infoContainer];
    /** 公告区 **/
    [self addSubview:self.publicationsContainer];
    /** 运营位  **/
    [self addSubview:self.operationBannerContainer];
}

- (void)initConstraints {
    
    [self.infoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self.topBack.mas_bottom).offset(-15);
    }];

    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.infoContainer);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.labelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.avatar);
        make.left.equalTo(self.avatar.mas_right).offset(8);
        make.right.equalTo(self.followButton.mas_left).offset(-8);
        make.top.equalTo(self.infoContainer).offset(3);
        make.bottom.equalTo(self.infoContainer).offset(-3);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.labelContainer);
    }];

    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.nameLabel).offset(5);
        make.left.bottom.equalTo(self.labelContainer);
    }];
    
    [self.userCountBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.subtitleLabel);
        make.height.mas_equalTo(17);
        make.left.mas_equalTo(self.subtitleLabel.mas_right).offset(5);
        make.right.mas_equalTo(self.labelContainer);
    }];
    
    [self.userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userCountBgView);
        make.height.mas_equalTo(17);
        make.left.mas_equalTo(self.userCountBgView.mas_left).offset(6);
    }];
    [self.userCountRightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userCountBgView);
        make.height.width.mas_equalTo(14);
        make.left.mas_equalTo(self.userCountLabel.mas_right).offset(0);
    }];

    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.avatar);
        make.right.equalTo(self.infoContainer);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(58);
    }];
    
    [self.publicationsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.topBack.mas_bottom);
    }];
    
    [self.publicationsContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.publicationsContainer).offset(10);
        make.left.equalTo(self.publicationsContainer).offset(20);
        make.right.equalTo(self.publicationsDetailView.mas_left).offset(-10);
        make.bottom.equalTo(self.publicationsContainer.mas_bottom).offset(-10);
    }];
    
    [self.publicationsDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
        make.left.equalTo(self.publicationsContentLabel.mas_right).offset(10);
        make.right.equalTo(self.publicationsContainer).offset(-15);
        make.top.bottom.equalTo(self.publicationsContentLabel);
    }];
     
     [self.operationBannerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.right.bottom.equalTo(self);
         make.top.equalTo(self.publicationsContainer.mas_bottom);
         make.height.mas_equalTo(0);
     }];

    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.topBack);
        make.bottom.equalTo(self.operationBannerContainer).offset(5);
    }];
}

- (void)updateWhenScrolledWithContentOffset:(CGPoint)contentOffset isScrollTop:(BOOL)isScrollTop {
    CGFloat offsetY = contentOffset.y;
    if (offsetY < 0) {
        CGFloat height = self.headerBackHeight - offsetY;
        self.topBack.frame = CGRectMake(0, offsetY, SCREEN_WIDTH, height);
    } else {
        self.topBack.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight);
    }
}

- (void)updateOperationInfo:(BOOL)isShow whRatio:(CGFloat)whRatio {
    // 运营位banner
    CGFloat width = SCREEN_WIDTH - 40;
    CGFloat height = isShow ? round(width / whRatio + 0.5) + 5 : 0;
    [self.operationBannerContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)updatePublicationsInfo:(BOOL)isShow hasDetailBtn:(BOOL)hasDetailBtn {
    
    if(isShow) {
        [self.publicationsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.topBack.mas_bottom);
        }];
    } else {
        [self.publicationsContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    [self.publicationsDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(hasDetailBtn ? 74 : 0);
    }];
    
    [self.publicationsContentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.publicationsDetailView.mas_left).offset(hasDetailBtn ? -10 : 0);
    }];
}

- (void)gotoPublicationsDetail: (UITapGestureRecognizer *)gesture {
    if(self.gotoPublicationsDetailBlock) {
        self.gotoPublicationsDetailBlock();
    }
}

// 小区圈关注列表
- (void)gotoSocialFollowUserList: (UITapGestureRecognizer *)gesture {
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    NSMutableDictionary *tracer = @{}.mutableCopy;
    [infoDict setValue:tracer forKey:@"tracer"];
    infoDict[@"title"] = @"XXX小区圈";
    infoDict[@"social_group_id"] = @"6703388162531524876";
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://ugc_follow_user_list"] userInfo:info];
}

-(void)gotoOperationDetail:(UITapGestureRecognizer *)tap {
    if(self.gotoOperationBlock) {
        self.gotoOperationBlock();
    }
}

-(BOOL)isPublicationsContentLabelLargerThanTwoLineWithoutDetailButtonShow {
    BOOL ret = NO;
    CGFloat leftPadding = 20;
    CGFloat rightPadding = 15;
    CGRect rect = [self.publicationsContentLabel textRectForBounds:CGRectMake(0, 0, SCREEN_WIDTH - leftPadding - rightPadding, CGFLOAT_MAX) limitedToNumberOfLines:0];
    ret = rect.size.height > (PublicationsContentLabel_numberOfLines * PublicationsContentLabel_lineHeight);
    return ret;
}
@end
