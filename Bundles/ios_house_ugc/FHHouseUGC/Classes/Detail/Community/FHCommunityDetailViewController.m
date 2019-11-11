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

@interface FHCommunityDetailViewController ()<TTUIViewControllerTrackProtocol>
@property(nonatomic, strong) FHCommunityDetailViewModel *viewModel;
@property (nonatomic, strong)   UIImage       *shareWhiteImage;
@property (nonatomic, strong)   UIButton       *shareButton;// 分享
@end

@implementation FHCommunityDetailViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttTrackStayEnable = YES;
        self.communityId = paramObj.allParams[@"community_id"];
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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
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

- (void)initView {
    [self setupDefaultNavBar:NO];
    // 分享按钮
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setBackgroundImage:self.shareWhiteImage forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:self.shareWhiteImage forState:UIControlStateHighlighted];
    [self.shareButton addTarget:self  action:@selector(shareButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.customNavBarView addSubview:_shareButton];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-10);
    }];
    [self setNavBar:NO];
    [self addDefaultEmptyViewFullScreen];
}

- (void)setNavBar:(BOOL)showJoinButton {
    if (showJoinButton) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.shareButton.hidden = YES;
        [self.customNavBarView setNaviBarTransparent:NO];
    } else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
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

@end
