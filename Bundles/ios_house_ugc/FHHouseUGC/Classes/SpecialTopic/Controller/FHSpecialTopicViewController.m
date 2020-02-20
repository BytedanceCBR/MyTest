//
//  FHSpecialTopicViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/20.
//

#import "FHSpecialTopicViewController.h"
#import "FHSpecialTopicViewModel.h"
#import "UIViewController+Track.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUGCShareManager.h"
#import "TTBaseMacro.h"
#import "FHUGCFollowButton.h"
#import "UILabel+House.h"
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIImage+FIconFont.h"

@interface FHSpecialTopicViewController ()<TTUIViewControllerTrackProtocol>
@property (nonatomic, strong) FHSpecialTopicViewModel *viewModel;
@property (nonatomic, strong) UIImage *shareWhiteImage;
@property (nonatomic, strong) UIButton *shareButton;// 分享

@end

@implementation FHSpecialTopicViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttTrackStayEnable = YES;
        self.communityId = paramObj.allParams[@"community_id"];
        self.tabName = paramObj.allParams[@"tab_name"];
        // 取链接中的埋点数据
        NSDictionary *params = paramObj.allParams;
        NSString *enter_from = params[@"enter_from"];
        if (enter_from.length > 0) {
            self.tracerDict[@"enter_from"] = enter_from;
        }
        NSString *enter_type = params[@"enter_type"];
        if (enter_type.length > 0) {
            self.tracerDict[@"enter_type"] = enter_type;
        }
        NSString *element_from = params[@"element_from"];
        if (element_from.length > 0) {
            self.tracerDict[@"element_from"] = element_from;
        }
        NSString *group_id = params[@"group_id"];
        if (group_id.length > 0) {
            self.tracerDict[@"group_id"] = group_id;
        }
        self.tracerDict[@"page_type"] = [self pageType];
        
        NSString *log_pb_str = params[@"log_pb"];
        if ([log_pb_str isKindOfClass:[NSString class]] && log_pb_str.length > 0) {
            NSData *jsonData = [log_pb_str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err = nil;
            NSDictionary *dic = nil;
            @try {
                dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:NSJSONReadingMutableContainers
                                                        error:&err];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            if (!err && [dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
                self.tracerDict[@"log_pb"] = dic;
            }
        }
        //logPb 增加social_group_id
        NSDictionary *temp_log_pb = self.tracerDict[@"log_pb"];
        if (self.communityId.length > 0) {
            NSMutableDictionary *mutLogPb = [NSMutableDictionary new];
            if ([temp_log_pb isKindOfClass:[NSDictionary class]]) {
                [mutLogPb addEntriesFromDictionary:temp_log_pb];
            }
            mutLogPb[@"social_group_id"] = self.communityId;
            self.tracerDict[@"log_pb"] = mutLogPb;
        }
    }
    return self;
}

// 重载方法
- (BOOL)isOpenUrlParamsSame:(NSDictionary *)queryParams {
    /*
    if (queryParams.count > 0) {
        NSString *queryId = queryParams[@"community_id"];
        NSString *queryIdStr = [NSString stringWithFormat:@"%@",queryId];
        NSString *currentIdStr = [NSString stringWithFormat:@"%@",self.communityId];
        if (queryIdStr.length > 0 && [queryIdStr isEqualToString:currentIdStr]) {
            return YES;
        }
    }
     */
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initNavBar];
    [self initView];
    [self initConstrains];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.viewModel viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear];
    [self.viewModel addStayPageLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)initNavBar {
    [self setupDefaultNavBar:NO];
    
    self.rightBtn = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero];
    self.rightBtn.backgroundColor = [UIColor themeWhite];
    self.rightBtn.groupId = self.communityId;
    self.rightBtn.hidden = YES;
    self.rightBtn.tracerDic = [self followButtonTraceDict];
    WeakSelf;
    self.rightBtn.followedSuccess = ^(BOOL isSuccess, BOOL isFollow) {
        StrongSelf;
        if(isSuccess) {
            [self.viewModel refreshBasicInfo];
        }
    };
    
    self.titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor themeGray1];
    
    self.subTitleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:10];
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.textColor = [UIColor themeGray3];
    
    self.titleContainer = [[UIView alloc] init];
    [self.titleContainer addSubview:self.titleLabel];
    [self.titleContainer addSubview:self.subTitleLabel];
    [self.customNavBarView addSubview:self.titleContainer];
    [self.customNavBarView addSubview:self.rightBtn];
    // 分享按钮
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setBackgroundImage:self.shareWhiteImage forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:self.shareWhiteImage forState:UIControlStateHighlighted];
    [self.shareButton addTarget:self  action:@selector(shareButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.customNavBarView addSubview:_shareButton];
    //设置导航条透明
    [self setNavBar:NO];
}

- (void)initView {
    [self initHeaderView];
    [self initSegmentView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initHeaderView {
    CGFloat height = [FHSpecialTopicHeaderView viewHeight];
    
    self.headerView = [[FHSpecialTopicHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    
    //随机一张背景图
    NSInteger randomImageIndex = [self.communityId integerValue] % 4;
    randomImageIndex = randomImageIndex < 0 ? 0 : randomImageIndex;
    NSString *imageName = [NSString stringWithFormat:@"fh_ugc_community_detail_header_back%ld", (long)randomImageIndex];
    self.headerView.topBack.image = [UIImage imageNamed:imageName];
}

- (void)initSegmentView {
    self.segmentView = [[FHCommunityDetailSegmentView alloc] init];
    [_segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont, UIFont *__autoreleasing *selectedTitleFont) {
        *norColorKey = @"grey3"; //grey3
        *selColorKey = @"grey1";//grey1
        *titleFont = [UIFont themeFontRegular:16];
        *selectedTitleFont = [UIFont themeFontSemibold:16];
    }];
//    [_segmentView setUpUnderLineEffect:^(BOOL *isUnderLineDelayScroll, CGFloat *underLineH, NSString *__autoreleasing *underLineColorKey, BOOL *isUnderLineEqualTitleWidth) {
//        *isUnderLineDelayScroll = NO;
//        *underLineH = 2;
//        *underLineColorKey = @"akmain";
//        *isUnderLineEqualTitleWidth = YES;
//    }];
    _segmentView.backgroundColor = [UIColor clearColor];
    _segmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)initConstrains {
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.customNavBarView.leftBtn.mas_centerY);
        make.right.mas_equalTo(self.customNavBarView).offset(-18.0f);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(24);
    }];
    
    [self.titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.customNavBarView.leftBtn.mas_centerY);
        make.left.mas_equalTo(self.customNavBarView.leftBtn.mas_right).offset(10.0f);
        make.right.mas_equalTo(self.rightBtn.mas_left).offset(-10);
        make.height.mas_equalTo(34);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleContainer);
        make.centerX.mas_equalTo(self.customNavBarView);
        make.height.mas_equalTo(20);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.titleContainer);
        make.centerX.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(14);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)setNavBar:(BOOL)showJoinButton {
    if (showJoinButton) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.shareButton.hidden = YES;
        [self.customNavBarView setNaviBarTransparent:NO];
    } else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        self.shareButton.hidden = NO;
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}

- (void)initViewModel {
    self.viewModel = [[FHSpecialTopicViewModel alloc] initWithController:self tracerDict:self.tracerDict];
    self.viewModel.shareButton = self.shareButton;
    [self.viewModel addGoDetailLog];
    [self.viewModel addPublicationsShowLog];
    [self.viewModel updateNavBarWithAlpha:self.customNavBarView.bgView.alpha];
    [self.viewModel requestData:NO refreshFeed:NO showEmptyIfFailed:YES showToast:NO];
}

- (void)retryLoadData {
    [self.viewModel requestData:NO refreshFeed:YES showEmptyIfFailed:YES showToast:NO];
}

// 白色
- (UIImage *)shareWhiteImage
{
    if (!_shareWhiteImage) {
        _shareWhiteImage = ICON_FONT_IMG(24, @"\U0000e692", [UIColor whiteColor]); //detail_share_white
    }
    return _shareWhiteImage;
}

// 分享按钮点击
- (void)shareButtonClicked:(UIButton *)btn {
    if (self.viewModel.shareInfo && self.viewModel.shareTracerDict) {
        [[FHUGCShareManager sharedManager] shareActionWithInfo:self.viewModel.shareInfo tracerDic:self.viewModel.shareTracerDict];
    }
}

- (NSString *)pageType {
    return @"community_group_detail";
}

#pragma mark - 埋点

- (NSDictionary *)followButtonTraceDict {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"community_id"] = self.communityId;
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"click_position"] = @"join_like";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    return [params copy];
}

@end
