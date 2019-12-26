//
//  FHCommunityDetailViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHCommunityDetailViewController.h"
#import "FHCommunityDetailViewModel.h"
#import "UIViewController+Track.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUGCShareManager.h"
#import "TTBaseMacro.h"
#import "FHUGCFollowButton.h"
#import <UILabel+House.h>
#import <TTDeviceHelper.h>
#import "FHUGCPostMenuView.h"
#import "FHCommonDefines.h"
#import "FHUserTracker.h"
#import <UIViewController+NavigationBarStyle.h>
#import <UIImage+FIconFont.h>

@interface FHCommunityDetailViewController ()<TTUIViewControllerTrackProtocol, FHUGCPostMenuViewDelegate>
@property (nonatomic, strong) FHCommunityDetailViewModel *viewModel;
@property (nonatomic, strong) UIImage *shareWhiteImage;
@property (nonatomic, strong) UIButton *shareButton;// 分享
@property (nonatomic, strong) FHUGCPostMenuView *publishMenuView;

@end

@implementation FHCommunityDetailViewController

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
    [self initPublishBtn];
    if(self.communityId){
        [self initGroupChatBtn];
        [self initBageView];
    }
    [self addDefaultEmptyViewFullScreen];
}

- (void)initHeaderView {
    CGFloat headerBackNormalHeight = 144;
    CGFloat headerBackXSeriesHeight = headerBackNormalHeight + 24; //刘海平多出24
    CGFloat height = [TTDeviceHelper isIPhoneXSeries] ? headerBackXSeriesHeight : headerBackNormalHeight + 40;
    
    self.headerView = [[FHCommunityDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    self.headerView.followButton.groupId = self.communityId;
    self.headerView.followButton.tracerDic = [self followButtonTraceDict];
    WeakSelf;
    self.headerView.followButton.followedSuccess = ^(BOOL isSuccess, BOOL isFollow) {
        StrongSelf;
        if(isSuccess) {
            [self.viewModel refreshBasicInfo];
        }
    };
    self.headerView.gotoSocialFollowUserListBlk = ^{
        StrongSelf;
        [self.viewModel gotoSocialFollowUserList];
    };
    
    //随机一张背景图
    NSInteger randomImageIndex = [self.communityId integerValue] % 4;
    randomImageIndex = randomImageIndex < 0 ? 0 : randomImageIndex;
    NSString *imageName = [NSString stringWithFormat:@"fh_ugc_community_detail_header_back%d", randomImageIndex];
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

- (void)initPublishBtn {
    self.publishBtn = [[UIButton alloc] init];
    [_publishBtn setImage:[UIImage imageNamed:@"fh_ugc_publish"] forState:UIControlStateNormal];
    [_publishBtn addTarget:self action:@selector(goToPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
}

- (void)initGroupChatBtn {
    self.groupChatBtn = [[UIButton alloc] init];
    [_groupChatBtn setImage:[UIImage imageNamed:@"fh_ugc_group_chat_tip"] forState:UIControlStateNormal];
    [_groupChatBtn setImage:[UIImage imageNamed:@"fh_ugc_group_chat_tip"] forState:UIControlStateDisabled];
    [_groupChatBtn addTarget:self action:@selector(gotoGroupChat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_groupChatBtn];
    [_groupChatBtn setHidden:YES];
}

- (void)initBageView {
    self.bageView = [[TTBadgeNumberView alloc] init];
    _bageView.badgeNumber = [[NSNumber numberWithInt:0] integerValue];
    [self.view addSubview:_bageView];
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
    
    CGFloat publishBtnBottomHeight;
    if ([TTDeviceHelper isIPhoneXSeries]) {
        publishBtnBottomHeight = 44;
    }else{
        publishBtnBottomHeight = 10;
    }
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-publishBtnBottomHeight);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.height.mas_equalTo(64);
    }];
    
    [self.groupChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-publishBtnBottomHeight - 64);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.height.mas_equalTo(64);
    }];
    
    [self.bageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.groupChatBtn).offset(5);
        make.right.mas_equalTo(self.self.groupChatBtn).offset(-5);
        make.height.mas_equalTo(15);
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
    self.viewModel = [[FHCommunityDetailViewModel alloc] initWithController:self tracerDict:self.tracerDict];
    self.viewModel.shareButton = self.shareButton;
    [self.viewModel addGoDetailLog];
    [self.viewModel addPublicationsShowLog];
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

//发布按钮点击
- (void)goToPublish {
    
    [self showPublishMenu];

}
- (FHUGCPostMenuView *)publishMenuView {
    
    if(!_publishMenuView) {
        _publishMenuView = [[FHUGCPostMenuView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _publishMenuView.delegate = self;
    }
    return _publishMenuView;
}

- (void)showPublishMenu {
    [self.publishMenuView showForButton:self.publishBtn];
}

#pragma mark - FHUGCPostMenuViewDelegate

- (void)gotoPostPublish {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ELEMENT_TYPE] = @"feed_icon";
    params[UT_PAGE_TYPE] = self.tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
    TRACK_EVENT(@"click_options", params);
    
    [self.viewModel gotoPostThreadVC];
}

- (void)gotoVotePublish {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ELEMENT_TYPE] = @"vote_icon";
    params[UT_PAGE_TYPE] = self.tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
    TRACK_EVENT(@"click_options", params);
    
    [self.viewModel gotoVotePublish];
}

- (void)gotoWendaPublish {

    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ELEMENT_TYPE] = @"question_icon";
    params[UT_PAGE_TYPE] = self.tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
    TRACK_EVENT(@"click_options", params);
    
    [self.viewModel gotoWendaPublish];
}

- (void)postMenuViewWillShow {
    self.bageView.alpha = 0;
    self.groupChatBtn.alpha = 0.0f;
}

- (void)postMenuDidHide {
    self.bageView.alpha = 1;
    self.groupChatBtn.alpha = 1.0f;
}

//去到群聊
- (void)gotoGroupChat {
    [self.viewModel gotoGroupChat];
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
