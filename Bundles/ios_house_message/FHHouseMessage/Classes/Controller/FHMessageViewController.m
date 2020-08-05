//
//  FHMessageViewController.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHMessageViewController.h"
#import "Masonry.h"
#import "UIViewController+NavbarItem.h"
#import "UIColor+Theme.h"
#import "TTReachability.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIViewController+Track.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "TTRoute.h"
#import "ChatMsg.h"
#import "IMManager.h"
#import <TTReachability/TTReachability.h>
#import "FHBubbleTipManager.h"
#import "ReactiveObjC.h"
#import "UIView+House.h"
#import <FHCHousePush/FHPushMessageTipView.h>
#import <FHCHousePush/FHPushAuthorizeManager.h>
#import <FHCHousePush/FHPushAuthorizeHelper.h>
#import <FHCHousePush/FHPushMessageTipView.h>
#import <FHHouseBase/FHBaseTableView.h>
#import <FHMessageNotificationManager.h>
#import "FHEnvContext.h"
#import <FHPopupViewCenter/FHPopupViewManager.h>
#import "FHMessageEditHelp.h"

@interface FHMessageViewController ()

@property(nonatomic, strong) FHPushMessageTipView *pushTipView;
@property (nonatomic, copy)     NSString       *enter_from;// 外部传入
@property(nonatomic , assign) BOOL hasEnterCategory;

@end

@implementation FHMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _hasEnterCategory = NO;
    [FHMessageEditHelp shared].isCanReloadData = YES;
    // Do any additional setup after loading the view.
    self.showenRetryButton = YES;
    self.ttTrackStayEnable = YES;
    self.enter_from = self.tracerDict[UT_ENTER_FROM];
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.emptyView hideEmptyView];
    [self startLoadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.fatherVC refreshConversationList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self tt_resetStayTime];
}

- (void)userInfoReload {
    [self.viewModel reloadData];
}

- (BOOL)leftActionHidden {
    return YES;
}

- (void)initView {

    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    _tableView = [[FHBaseTableView alloc] init];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0 , *)) {
          _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
      }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01f)];
    _tableView.tableHeaderView = headerView;

    [self.containerView addSubview:_tableView];
    [self addDefaultEmptyViewFullScreen];
    __weak typeof(self)wself = self;
    self.emptyView.loginBlock = ^{
        [wself login];
    };
}

- (void)login {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[TRACER_KEY] = @{
        @"enter_from": [self getPageType],
        @"enter_method": @"click_login",
    };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL* url = [NSURL URLWithString:@"snssdk1370://flogin"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)initConstraints {

    CGFloat bottom = [self getBottomMargin];
    if (@available(iOS 11.0 , *)) {
        if([self isAlignToSafeBottom]){
            bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
        }
    }
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 13.0, *)) {
            make.top.mas_equalTo(self.view).offset(44.f + [UIApplication sharedApplication].keyWindow.safeAreaInsets.top);
        } else if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view).offset(44.f + self.view.tt_safeAreaInsets.top);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pushTipView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.containerView);
    }];
}

- (CGFloat)getBottomMargin {
    return [self.fatherVC getBottomMargin];
}

- (void)initViewModel {
    _viewModel = [[FHMessageViewModel alloc] initWithTableView:_tableView controller:self];
    [_viewModel setPageType:[self getPageType]];
    if (self.enter_from.length > 0) {
        [_viewModel setEnterFrom:self.enter_from];
    }
}

- (void)addEnterCategoryLogWithType:(NSString *)enterType {
//    if (_hasEnterCategory) {
//        return;
//    }
//    _hasEnterCategory = YES;
    NSDictionary *params = @{
            @"category_name": [self getPageTypeWithDataType],
            @"enter_from": @"message",
            @"enter_type": enterType
    };
    [FHUserTracker writeEvent:@"enter_category" params:params];
}

- (NSString *)getPageType {
    return [self.fatherVC getPageType];
}

- (NSString *)getPageTypeWithDataType {
    if (self.dataType == FHMessageRequestDataTypeIM) {
        return @"message_weiliao";
    } else if (self.dataType == FHMessageRequestDataTypeSystem) {
        return @"message_notice";
    }
    return @"message_list";
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return self.fatherVC.dataList.count == 0 ? NO : YES; //默认会显示空
}

- (BOOL) isAlignToSafeBottom {
    return [self.fatherVC isAlignToSafeBottom];
}
@end
