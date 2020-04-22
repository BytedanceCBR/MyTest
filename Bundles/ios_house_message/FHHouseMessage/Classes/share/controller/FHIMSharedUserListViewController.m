//
//  FHIMSharedUserListViewController.m
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import "FHIMSharedUserListViewController.h"
#import "FHIMShareUserListViewModel.h"
#import "FHIMShareUserCell.h"
#import "FHIMShareAlertView.h"
#import "FHIMHouseShareView.h"
#import "IMManager.h"
#import "IChatService.h"
#import "TTRoute.h"
#import "Masonry.h"
#import "ReactiveObjC.h"
#import <BDWebImage/BDWebImage.h>
#import "FHChatUserInfo.h"
#import "FHUserTracker.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import <FHHouseBase/FHBaseTableView.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHHouseBase/FHHouseType.h>

@interface FHIMSharedUserListViewController () <TTRouteInitializeProtocol, FHIMShareUserListViewModelDelegate, FHIMShareAlertViewDelegate, IMChatStateObserver>
{
    NSDictionary* _queryParams;
    FHChatUserInfo* _target;
    NSUInteger _rowIndex;
    NSTimeInterval _lastModify;
    NSInteger _houseType;
}
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) FHIMShareUserListViewModel* listViewModel;
@property (nonatomic, strong) FHIMShareAlertView* alertView;
@end

@implementation FHIMSharedUserListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _lastModify = 0;
        _rowIndex = NSUIntegerMax;
        self.listViewModel = [[FHIMShareUserListViewModel alloc] init];
        _listViewModel.delegate = self;
        self.tableView = [[FHBaseTableView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;

        if (@available(iOS 7.0, *)) {
            self.tableView.estimatedSectionFooterHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
            self.tableView.estimatedRowHeight = 0;
        } else {
            // Fallback on earlier versions
        }

        _queryParams = [paramObj queryParams];
        NSNumber* houseTypeObj = _queryParams[@"houseType"];
        if (houseTypeObj != nil) {
            _houseType = [houseTypeObj integerValue];
        } else {
            _houseType = 0;
        }

        self.tableView.sectionFooterHeight = 0;
        self.tableView.sectionHeaderHeight = 0;
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);

        [_tableView registerClass:[FHIMShareUserCell class] forCellReuseIdentifier:@"item"];
        [_listViewModel loadTargetUsers];
    }
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"fh_chat_opened" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        NSMutableArray* cls = [self.navigationController.viewControllers mutableCopy];
        [cls removeObject:self];
        self.navigationController.viewControllers = cls;
    }];

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KUSER_UPDATE_NOTIFICATION object:nil] throttle:2] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        [self conversationUpdated:nil];
    }];
    [[IMManager shareInstance] addChatStateObverver:self];
    return self;
}

-(void)initNavBar {
    [self setupDefaultNavBar:NO];
    //    self.customNavBarView.leftBtn.hidden = [self leftActionHidden];
    self.customNavBarView.title.text = @"选择经纪人";
    UIImage *img = ICON_FONT_IMG(12, @"\U0000e673", nil);
    [self.customNavBarView.leftBtn setBackgroundImage:img forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:img forState:UIControlStateHighlighted];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavBar];
    // Do any additional setup after loading the view.
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
    }];
    _tableView.delegate = _listViewModel;
    _tableView.dataSource = _listViewModel;

    [self addDefaultEmptyViewFullScreen];
    @weakify(self);
    [[RACObserve(_listViewModel, chatUsers) filter:^BOOL(NSArray*  _Nullable value) {
        return [value count] != 0;
    }] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.tableView.hidden = NO;
        self.emptyView.hidden = YES;
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 100, 100) animated:NO];
        });
    }];
    [[RACObserve(_listViewModel, chatUsers) filter:^BOOL(NSArray*  _Nullable value) {
        return [value count] == 0;
    }] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.emptyView.hidden = NO;
        self.emptyView.retryButton.hidden = YES;

        [self.emptyView showEmptyWithTip:@"暂无联系过的经纪人" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        self.tableView.hidden = YES;
    }];
}

-(void)selectShareTarget:(FHChatUserInfo*)target atRow:(NSUInteger)row {
    _target = target;
    _rowIndex = row;
    [self showShareAlert:target];
}

-(void)showShareAlert:(FHChatUserInfo*)info {
    self.alertView = [[FHIMShareAlertView alloc] init];
    _alertView.delegate = self;
    [_alertView.avator bd_setImageWithURL:[NSURL URLWithString:info.avatar]
                             placeholder:[UIImage imageNamed:@"chat_business_icon_c"]];
    _alertView.name.text = info.username;
    FHIMHouseShareView* houseView = _alertView.houseView;
    [houseView.houseImage bd_setImageWithURL:[NSURL URLWithString:_queryParams[@"house_cover"]]];
    houseView.titleLabel.text = _queryParams[@"house_title"];
    houseView.subTitleLabel.text = _queryParams[@"house_des"];
    houseView.totalPriceLabel.text = _queryParams[@"house_price"];
    houseView.pricePerSqmLabel.text = _queryParams[@"house_avg_price"];
    [_alertView showFrom:self.view];
    [self traceClickOption:@"realtor" atIndex:NSUIntegerMax];
}

-(void)traceClickOption:(NSString*)clickPosition atIndex:(NSUInteger)row {
    NSMutableDictionary* dict = [self.tracerDict mutableCopy];
    dict[@"click_position"] = clickPosition;
    dict[@"page_type"] = @"realotr_pick";
    dict[@"element_from"] = nil;
    dict[@"origin_from"] = nil;
    dict[@"impr_id"] = nil;
    dict[@"card_type"] = nil;
    dict[@"group_id"] = nil;
    dict[@"origin_search_id"] = nil;
    dict[@"search_id"] = nil;
    if (_rowIndex != NSUIntegerMax) {
        dict[@"rank"] = @(_rowIndex);
    } else {
        dict[@"rank"] = @"be_null";
    }
    [FHUserTracker writeEvent:@"click_options" params:dict];
}

-(void)onCancel {
    [self traceClickOption:@"cancel" atIndex:NSUIntegerMax];
}

-(void)onClickDone {
    [self traceClickOption:@"send" atIndex:NSUIntegerMax];

    IMConversation* conv = [[IMManager shareInstance].chatService conversationWithUserId:_target.userId];
    NSDictionary *syncParams = @{KLAST_HOUSE_ID_SYNC: @"0"};
    if([TTReachability isNetworkConnected]){
        [conv setSyncExtEntry:syncParams completion:^(id<TIMOConversationOperationResponse>  _Nullable response, NSError * _Nullable error) {
        }];

        NSMutableDictionary* dict = [_queryParams mutableCopy];
        NSMutableDictionary* theTracerDict = [self.tracerDict mutableCopy];
        theTracerDict[@"page_type"] = @"realotr_pick";
        theTracerDict[@"from"] = [self sourceByHouseType:_houseType];
        dict[@"tracer"] = theTracerDict;
        dict[@"target_user_id"] = _target.userId;
        dict[@"chat_title"] = _target.username;
        dict[@"from_im_share"] = @(1);
        dict[@"source"] = [self sourceByHouseType:_houseType];
        dict[@"from"] = [self sourceByHouseType:_houseType];
        TTRouteUserInfo* info = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://open_single_chat"] userInfo:info];
    } else {
        [[ToastManager manager] showToast:@"网络异常无法分享，轻稍后重试"];
    }

}

-(void)conversationUpdated:(NSString *)conversationIdentifier {
    NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();

    if (currentTime - _lastModify > 0.2) {
        _lastModify = currentTime;
        [_listViewModel loadTargetUsers];
    }
}

-(NSString*)sourceByHouseType:(NSInteger)houseType {
    switch (houseType) {
        case 3://租房
            return @"app_renthouse_share";//@"1.73";
        case 1://新房
            return @"app_court_share";//@"1.32";
        default://二手房
            return @"app_oldhouse_share";//@"1.14";
    }
}

@end
