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
    self.backgroundColor = [UIColor whiteColor];

    /** 头部背景图 **/
    self.headerBackHeight = self.frame.size.height;
    self.topBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight)];
    self.topBack.clipsToBounds = YES;
    self.topBack.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.topBack];
    
    self.topBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight)];
    _topBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    _topBgView.hidden = YES;
    [self addSubview:_topBgView];
    // 主标题标签
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, self.frame.size.height - 73, self.frame.size.width - 48, 29)];
    self.nameLabel.font = [UIFont themeFontSemibold:21];
    self.nameLabel.textColor = [UIColor themeWhite];
    self.nameLabel.numberOfLines = 3;
    // 副标题标签
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.frame.size.height - 36, self.frame.size.width - 30, 21)];
    self.subtitleLabel.font = [UIFont themeFontRegular:15];
    self.subtitleLabel.textColor = [UIColor themeWhite];
    self.subtitleLabel.numberOfLines = 2;
    
    self.refreshHeader = [[FHCommunityDetailRefreshHeader alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 20)];
    _refreshHeader.alpha = 0;
    [self.viewController.view addSubview:_refreshHeader];
    
    [self addSubview:self.refreshHeader];
    
    [self addSubview:self.nameLabel];
    
    [self addSubview:self.subtitleLabel];
}

- (void)initConstraints {
    [self.refreshHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.top.mas_equalTo(self).offset(70);
        make.height.mas_equalTo(20);
    }];
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
