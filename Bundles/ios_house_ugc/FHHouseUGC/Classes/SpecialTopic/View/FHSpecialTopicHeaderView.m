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
@property (nonatomic, strong) UIImageView *topBgView;

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
    self.headerBackHeight = self.frame.size.height;
    self.topBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight)];
    self.topBack.clipsToBounds = YES;
    self.topBack.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.topBack];
    
    self.topBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight)];
    _topBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addSubview:_topBgView];
    
//    fh_ugc_black_bg
    
    /** 头部信息区 **/
//    self.infoContainer = [[UIView alloc] init];
    /* 左边头像 */
//    self.avatar = [UIImageView new];
//    self.avatar.backgroundColor = [UIColor themeGray7];
//    self.avatar.clipsToBounds = YES;
//    self.avatar.layer.cornerRadius = 4;

    /* 中间标签区 */
//    self.labelContainer = [[UIView alloc] init];
    // 主标题标签
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, self.frame.size.height - 73, self.frame.size.width - 48, 29)];
    self.nameLabel.font = [UIFont themeFontSemibold:21];
    self.nameLabel.textColor = [UIColor themeWhite];
    self.nameLabel.numberOfLines = 1;
    // 副标题标签
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.frame.size.height - 36, self.frame.size.width - 30, 21)];
    self.subtitleLabel.font = [UIFont themeFontRegular:15];
    self.subtitleLabel.textColor = [UIColor themeWhite];
    self.subtitleLabel.numberOfLines = 1;
    
    // 用户关注count相关
//    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 3.5, 0.5, 10)];
//    sepLine.backgroundColor = [UIColor whiteColor];
//    self.userCountSepLine = sepLine;
    
//    self.userCountLabel = [UILabel new];
//    self.userCountLabel.font = [UIFont themeFontRegular:12];
//    self.userCountLabel.textColor = [UIColor themeWhite];
//    self.userCountLabel.numberOfLines = 1;
//    self.userCountLabel.text = @"0个成员";
    
//    self.userCountRightArrow = [UIImageView new];
//    self.userCountRightArrow.image = [UIImage imageNamed:@"fh_ugc_community_right_2"];
    
//    [self.labelContainer addSubview:self.nameLabel];
//    [self.labelContainer addSubview:self.subtitleLabel];
//
//    [self.labelContainer addSubview:self.userCountLabel];
//    [self.labelContainer addSubview:self.userCountSepLine];
//    [self.labelContainer addSubview:self.userCountRightArrow];
//
//    self.userCountTapView = [[UIView alloc] init];
//    self.userCountTapView.backgroundColor = [UIColor clearColor];
//    [self.labelContainer addSubview:self.userCountTapView];
    
//    [self.infoContainer addSubview:self.avatar];
//    [self.infoContainer addSubview:self.labelContainer];
    
    self.refreshHeader = [[FHCommunityDetailRefreshHeader alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 20)];
    _refreshHeader.alpha = 0;
    [self.viewController.view addSubview:_refreshHeader];
    /** 信息区 **/
//    [self addSubview:self.infoContainer];
    
    [self addSubview:self.refreshHeader];
    
    [self addSubview:self.nameLabel];
    
    [self addSubview:self.subtitleLabel];
}

- (void)initConstraints {
    [self.refreshHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.top.mas_equalTo(self).offset(50);
        make.height.mas_equalTo(20);
    }];

//    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self).offset(24);
//        make.right.mas_equalTo(self).offset(-24);
//        make.bottom.mas_equalTo(self.subtitleLabel.mas_top).offset(-8);
//        make.height.mas_equalTo(29);
//    }];
//
//    self.subtitleLabel.bottom = self.bottom - 15;
//    self.subtitleLabel.left = self.left + 15;
//    self.subtitleLabel.right = self.right - 15;
//    self.subtitleLabel.height = 21;
    

//    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self).offset(15);
//        make.right.mas_equalTo(self).offset(-15);
//        make.bottom.mas_equalTo(self.topBack.mas_bottom).offset(-15);
//        make.height.mas_equalTo(self).offset(21);
//    }];
    
    
    
    
}

- (void)updateWhenScrolledWithContentOffset:(CGFloat)offset isScrollTop:(BOOL)isScrollTop scrollView:(UIScrollView *)scrollView {
    if (offset < 0) {
        CGFloat height = self.headerBackHeight - offset;
        self.topBack.frame = CGRectMake(0, offset, SCREEN_WIDTH, height);
        self.topBgView.frame = CGRectMake(0, offset, SCREEN_WIDTH, height);
    } else {
        self.topBack.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight);
        self.topBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight);
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

@end
