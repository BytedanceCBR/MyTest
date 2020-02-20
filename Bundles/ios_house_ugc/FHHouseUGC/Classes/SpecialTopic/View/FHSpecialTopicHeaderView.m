//
//  FHSpecialTopicHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/20.
//

#import <Masonry/View+MASAdditions.h>
#import "FHSpecialTopicHeaderView.h"
#import "UIColor+Theme.h"
#import "UILabel+House.h"
#import "WDDefines.h"
#import "IMConsDefine.h"
#import "FHUGCFollowButton.h"
#import "SSViewBase.h"
#import "TTDeviceHelper.h"
#import "UIFont+House.h"
#import "TTRoute.h"
#import "FHUGCScialGroupModel.h"
#import "UIViewAdditions.h"

@interface FHSpecialTopicHeaderView ()

@property (nonatomic, strong) UIView *infoContainer;
@property (nonatomic, strong) UIView *userCountTapView;
@property (nonatomic, assign) CGFloat preOffset;

@end

@implementation FHSpecialTopicHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initVars];
        [self initView];
        [self initConstraints];
    }
    return self;
}

- (void)initVars {
   
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
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 3.5, 0.5, 10)];
    sepLine.backgroundColor = [UIColor whiteColor];
    self.userCountSepLine = sepLine;
    
    self.userCountLabel = [UILabel new];
    self.userCountLabel.font = [UIFont themeFontRegular:12];
    self.userCountLabel.textColor = [UIColor themeWhite];
    self.userCountLabel.numberOfLines = 1;
    self.userCountLabel.text = @"0个成员";
    
    self.userCountRightArrow = [UIImageView new];
    self.userCountRightArrow.image = [UIImage imageNamed:@"fh_ugc_community_right_2"];
    
    [self.labelContainer addSubview:self.nameLabel];
    [self.labelContainer addSubview:self.subtitleLabel];
    
    [self.labelContainer addSubview:self.userCountLabel];
    [self.labelContainer addSubview:self.userCountSepLine];
    [self.labelContainer addSubview:self.userCountRightArrow];
    
    self.userCountTapView = [[UIView alloc] init];
    self.userCountTapView.backgroundColor = [UIColor clearColor];
    [self.labelContainer addSubview:self.userCountTapView];
    
    [self.infoContainer addSubview:self.avatar];
    [self.infoContainer addSubview:self.labelContainer];
    
    self.refreshHeader = [[FHCommunityDetailRefreshHeader alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 20)];
    _refreshHeader.alpha = 0;
    [self.viewController.view addSubview:_refreshHeader];
    
    
    /** 背景图 **/
    [self addSubview:self.topBack];
    /** 信息区 **/
    [self addSubview:self.infoContainer];
    
    [self addSubview:self.refreshHeader];
    
    self.userCountShowen = NO;
}

- (void)setUserCountShowen:(BOOL)userCountShowen {
    _userCountShowen = userCountShowen;
    self.userCountSepLine.hidden = !userCountShowen;
    self.userCountLabel.hidden = !userCountShowen;
    self.userCountRightArrow.hidden = !userCountShowen;
    self.userCountTapView.hidden = !userCountShowen;
}

- (void)initConstraints {
    [self.refreshHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self.infoContainer.mas_top);
        make.height.mas_equalTo(20);
    }];
    
    [self.infoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self.topBack.mas_bottom).offset(-15);
        make.height.mas_equalTo(50);
    }];

    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.infoContainer);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.labelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatar.mas_right).offset(8);
        make.right.equalTo(self.infoContainer).offset(-8);
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
    
    [self.userCountSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.subtitleLabel);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(0.5);
        make.left.mas_equalTo(self.subtitleLabel.mas_right).offset(5);
    }];
    
    [self.userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.subtitleLabel);
        make.height.mas_equalTo(17);
        make.left.mas_equalTo(self.userCountSepLine.mas_right).offset(5);
    }];
    
    [self.userCountRightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.subtitleLabel);
        make.height.width.mas_equalTo(14);
        make.left.mas_equalTo(self.userCountLabel.mas_right).offset(0);
        make.right.mas_lessThanOrEqualTo(self.labelContainer);
    }];
     
     [self.userCountTapView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.mas_equalTo(self.subtitleLabel);
         make.left.mas_equalTo(self.userCountSepLine.mas_left);
         make.right.mas_equalTo(self.userCountRightArrow.mas_right);
         make.height.mas_equalTo(22);
     }];
}

- (void)updateWhenScrolledWithContentOffset:(CGFloat)offset isScrollTop:(BOOL)isScrollTop scrollView:(UIScrollView *)scrollView {
    if (offset < 0) {
        CGFloat height = self.headerBackHeight - offset;
        self.topBack.frame = CGRectMake(0, offset, SCREEN_WIDTH, height);
    } else {
        self.topBack.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight);
    }
    //控制刷新状态
    if(offset <= 0 && self.refreshHeader.state != MJRefreshStateRefreshing){
        CGFloat distance = fabs(offset) > 20 ? 20 : fabs(offset);
        self.refreshHeader.alpha = distance / 20;
    }

    if(offset <= -50){
        if(self.refreshHeader.state != MJRefreshStatePulling && self.refreshHeader.state != MJRefreshStateRefreshing){
            self.refreshHeader.state = MJRefreshStatePulling;
        }
    }else{
        if(self.refreshHeader.state != MJRefreshStateIdle && self.refreshHeader.state != MJRefreshStateRefreshing){
            self.refreshHeader.state = MJRefreshStateIdle;
        }
    }
    
    _preOffset = offset;
}

+ (CGFloat)viewHeight {
    CGFloat headerBackNormalHeight = 144;
    CGFloat headerBackXSeriesHeight = headerBackNormalHeight + 24; //刘海平多出24
    CGFloat height = [TTDeviceHelper isIPhoneXSeries] ? headerBackXSeriesHeight : headerBackNormalHeight;
    return height;
}

@end
