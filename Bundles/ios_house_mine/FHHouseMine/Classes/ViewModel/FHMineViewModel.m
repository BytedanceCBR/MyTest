//
//  FHMineViewModel.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineViewModel.h"
#import "TTHttpTask.h"
#import "TTRoute.h"
#import "FHMineBaseCell.h"
#import "FHMineMutiItemCell.h"
#import "FHMineAPI.h"
#import "FHHouseType.h"
#import "TTAccount.h"
#import "TTAccountManager.h"
#import "ToastManager.h"
#import "FHUserTracker.h"
#import "TTReachability.h"
#import "FHMineConfigModel.h"
#import "FHMineMutiItemCell.h"
#import "FHCommuteManager.h"
#import "FHEnvContext.h"
#import "FHUtils.h"

#define mutiItemCellId @"mutiItemCellId"

@interface FHMineViewModel()<UITableViewDelegate,UITableViewDataSource,FHMineMutiItemCellDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMineViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSDictionary *focusItemDic;
@property(nonatomic, assign) BOOL hasLogin;
@property(nonatomic, strong) FHMineMutiItemCell *focusCell;
@property(nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic, strong) FHMineConfigModel *configModel;

@end

@implementation FHMineViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMineViewController *)viewController {
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        _isFirstLoad = YES;
        
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.viewController = viewController;
        
        [self.tableView registerClass:NSClassFromString(@"FHMineMutiItemCell") forCellReuseIdentifier:mutiItemCellId];
        //        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)dealloc {
    //    [TTAccount removeMulticastDelegate:self];
}

- (void)requestData {
    __weak typeof(self) wself = self;
    [FHMineAPI requestFocusInfoWithCompletion:^(NSDictionary * _Nonnull response, NSError * _Nonnull error) {
        if (error) {
            //TODO: show handle error
            [wself.tableView reloadData];
            return;
        }
        
        if(response.count == 4){
            self.focusItemDic = response;
            
            if(self.focusCell){
                [self.focusCell setItemTitlesWithItemDic:self.focusItemDic];
            }
        }
    }];
}

- (void)requestMineConfig {
    __weak typeof(self) wself = self;
    
    if(self.isFirstLoad){
        [self.viewController startLoading];
    }
    
    [FHMineAPI requestMineConfigWithClassName:@"FHMineConfigModel" completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        if(wself.isFirstLoad){
            [wself.viewController endLoading];
        }
        
        wself.isFirstLoad = NO;
        
        if (error) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            wself.viewController.showenRetryButton = YES;
            wself.tableView.bounces = NO;
            return;
        }
        
        wself.tableView.bounces = YES;
        [wself.viewController.emptyView hideEmptyView];
        
        FHMineConfigModel *configModel = (FHMineConfigModel *)model;
        wself.configModel = configModel;
        if(configModel){
            wself.dataList = configModel.data.iconOpData;
            [wself.tableView reloadData];
            [wself updateHomePageEntrance:configModel.data.homePage];
        }
    }];
}

- (void)updateHomePageEntrance:(FHMineConfigDataHomePageModel *)model {
    [self.viewController.headerView sethomePageWithModel:model];
}

- (void)showInfo {
    if([TTAccount sharedAccount].isLogin){
        NSDictionary *fhSettings = [self fhSettings];
        NSInteger state = [fhSettings tt_integerValueForKey:@"f_is_show_profile_edit_entry"];
        if(state == 1){
            [[ToastManager manager] showToast:@"个人资料功能升级中，敬请期待"];
        }else if(state == 2){
            NSString *goDetailTrackDic = @{
                @"enter_from":@"minetab",
                @"page_type":@"personal_info"
            };
            TRACK_EVENT(@"go_detail", goDetailTrackDic);
            NSString *clickTrackDic = @{
                @"click_type":@"edit_info",
                @"page_type":@"minetab"
            };
            TRACK_EVENT(@"click_minetab", clickTrackDic);
            
            NSURL* url = [NSURL URLWithString:@"sslocal://editUserProfile"];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        }
    }else{
        NSString *clickTrackDic = @{
            @"click_type":@"login",
            @"page_type":@"minetab"
        };
        TRACK_EVENT(@"click_minetab", clickTrackDic);
        
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"isCheckUGCADUser"] = @(1);
        dict[TRACER_KEY] = @{
            @"enter_from": @"minetab",
            @"enter_method": @"click_mine",
            @"enter_type": @"login",
            @"trigger": @"user"
        };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL* url = [NSURL URLWithString:@"snssdk1370://flogin"];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)updateHeaderView {
    if ([FHEnvContext canShowLoginTip]) {
        TTAccountUserEntity *userInfo = [TTAccount sharedAccount].user;
        if (userInfo) {
            NSString *avatar = [TTAccountManager avatarURLString];
            [self.viewController.headerView updateAvatar:avatar];
            NSString *name = [TTAccountManager userName];
            NSDictionary *fhSettings = [self fhSettings];
            NSInteger state = [fhSettings tt_integerValueForKey:@"f_is_show_profile_edit_entry"];
            [self.viewController.headerView setUserInfoState:state];
            self.viewController.headerView.userNameLabel.text = name?:@"";
            self.viewController.headerView.descLabel.text = @"查看并编辑个人信息";
            if(state != 0){
                self.viewController.headerView.editIcon.hidden = NO;
            }
            _hasLogin = YES;
            [self.viewController.headerView sethomePageWithModel:self.configModel.data.homePage];
            [self.viewController.headerView setDeaultShowTypeByLogin:YES];
        }else {
            [self.viewController.headerView setDeaultShowTypeByLogin:NO];
            _hasLogin = NO;
        }
    }else {
        NSString *avatar = [TTAccountManager avatarURLString];
        [self.viewController.headerView updateAvatar:avatar];
        NSString *name = [TTAccountManager userName];
        TTAccountUserEntity *userInfo = [TTAccount sharedAccount].user;
        NSDictionary *fhSettings = [self fhSettings];
        NSInteger state = [fhSettings tt_integerValueForKey:@"f_is_show_profile_edit_entry"];
        
        [self.viewController.headerView setUserInfoState:state];
        
        if (userInfo != nil) {
            self.viewController.headerView.userNameLabel.text = name?:@"";
            self.viewController.headerView.descLabel.text = @"查看并编辑个人信息";
            if(state != 0){
                self.viewController.headerView.editIcon.hidden = NO;
            }
            _hasLogin = YES;
        } else {
            self.viewController.headerView.userNameLabel.text = @"登录/注册";
            self.viewController.headerView.descLabel.text = @"关注房源永不丢失";
            self.viewController.headerView.editIcon.hidden = YES;
            _hasLogin = NO;
        }
        [self.viewController.headerView sethomePageWithModel:self.configModel.data.homePage];
    }
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (void)goToFeedback:(FHMineConfigDataIconOpDataMyIconItemsModel *)model {
    NSString *goDetailTrackDic = @{
        @"enter_from":@"minetab",
        @"page_type":@"feedback",
    };
    TRACK_EVENT(@"go_detail", goDetailTrackDic);
    NSString *clickTrackDic = @{
        @"click_type":@"feedback",
        @"page_type":@"minetab",
    };
    TRACK_EVENT(@"click_minetab", clickTrackDic);
    
    NSURL* url = [NSURL URLWithString:model.openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}


- (void)goToSystemSetting {
    NSString *goDetailTrackDic = @{
        @"enter_from":@"minetab",
        @"page_type":@"setting",
    };
    TRACK_EVENT(@"go_detail", goDetailTrackDic);
    NSString *clickTrackDic = @{
        @"click_type":@"setting",
        @"page_type":@"minetab",
    };
    TRACK_EVENT(@"click_minetab", clickTrackDic);
    
    NSURL* url = [NSURL URLWithString:@"sslocal://more"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

- (void)callPhone {
    NSString *phoneUrl = [NSString stringWithFormat:@"telprompt://%@",@"400-6124-360"];
    NSURL *url = [NSURL URLWithString:phoneUrl];
    [[UIApplication sharedApplication]openURL:url];
}

- (void)updateFocusTitles {
    if(self.focusCell){
        [self.focusCell updateFocusTitles];
    }
}

#pragma mark - FHMineMutiItemCellDelegate

- (void)didItemClick:(FHMineConfigDataIconOpDataMyIconItemsModel *)model {
     if ([TTReachability isNetworkConnected]) {
         [self addCLickIconLog:model];
         FHMineItemType type = [model.id integerValue];
         if(type == FHMineItemTypeSugSubscribe || type == FHMineItemTypeFeedback){
             [self jumpWithMoreAction:model];
         }else if ([model.openUrl containsString:@"://commute_list"]){
             NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
             if (model.reportParams) {
                 [tracer addEntriesFromDictionary:model.reportParams];
             }
             tracer[@"enter_type"] = @"click";
             //通勤找房
             [[FHCommuteManager sharedInstance] tryEnterCommutePage:model.openUrl logParam:tracer];
         }else if([model.openUrl containsString:@"house_encyclopedia"]){
            NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
            [tracer setValue:@"minetab_tools" forKey:@"origin_from"];
             TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:tracer];
             NSURL* url = [NSURL URLWithString:model.openUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
         }else
         {
             //埋点
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
             NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
             if (model.reportParams) {
                 [tracer addEntriesFromDictionary:model.reportParams];
             }
             tracer[@"enter_type"] = @"click";
             dict[@"tracer"] = tracer;
             
             TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
             
             NSURL* url = [NSURL URLWithString:model.openUrl];
             if(model.openUrl && [model.openUrl containsString:@"slocal://myFocus"] && [FHUtils getSettingEnableBooleanForKey:@"f_login_before_house_subscribe"] && ![TTAccountManager isLogin]){
                 NSString *clickTrackDic = @{
                         @"click_type":@"login",
                         @"page_type":@"minetab"
                     };
                 TRACK_EVENT(@"click_minetab", clickTrackDic);
                                  
                 NSMutableDictionary *params = [NSMutableDictionary dictionary];
                NSString *page_type = @"minetab";
                [params setObject:page_type forKey:@"enter_from"];
                [params setObject:@"click_favorite" forKey:@"enter_type"];
                [params setObject:@"click_favorite" forKey:@"enter_method"];
                [params setObject:@"user" forKey:@"trigger"];
                // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
                [params setObject:@(YES) forKey:@"need_pop_vc"];
                 
                 __weak typeof(self) wSelf = self;
                  [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                      if (type == TTAccountAlertCompletionEventTypeDone) {
                          // 登录成功
                          if ([TTAccountManager isLogin]) {
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                   [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
                               });
                          }else{
                              [[ToastManager manager] showToast:@"需要先登录才能进行操作哦"];
                          }
                      }
                  }];
//                 TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//
//                 NSURL* url = [NSURL URLWithString:@"snssdk1370://flogin"];
//                 [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
             }else{
                 [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
             }
         }
     }else{
         [[ToastManager manager] showToast:@"网络异常"];
     }
}

- (void)jumpWithMoreAction:(FHMineConfigDataIconOpDataMyIconItemsModel *)model {
    FHMineItemType type = [model.id integerValue];
    switch (type) {
        case FHMineItemTypeSugSubscribe:
            [self goToSugSubscribeList:model];
            break;
        case FHMineItemTypeFeedback:
            [self goToFeedback:model];
            break;
        default:
            break;
    }
}

- (void)goToSugSubscribeList:(FHMineConfigDataIconOpDataMyIconItemsModel *)model {
    NSHashTable *subscribeDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [subscribeDelegateTable addObject:self];
    //埋点
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"tracer"] = model.reportParams;
    dict[@"title"] = @"我订阅的搜索";
    dict[@"subscribe_delegate"] = subscribeDelegateTable;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:model.openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

// 搜索订阅组合列表页cell点击：FHSugSubscribeListViewController
- (void)cellSubscribeItemClick:(FHSugSubscribeDataDataItemsModel *)model {
    NSString *enter_from = @"old_subscribe_list";
    NSString *element_from = @"be_null";
    [self jumpCategoryListVCFromSubscribeItem:model enterFrom:enter_from elementFrom:element_from];
}

- (void)jumpCategoryListVCFromSubscribeItem:(FHSugSubscribeDataDataItemsModel *)model enterFrom:(NSString *)enter_from elementFrom:(NSString *)element_from {
    NSString *jumpUrl = model.openUrl;
    if (jumpUrl.length > 0) {
        NSString *queryType = @"subscribe"; // 订阅搜索
        NSString *pageType = @"";
        // 特殊埋点需求，此处enter_query和search_query都埋:be_null
        NSDictionary *houseSearchParams = @{
            @"enter_query":@"be_null",
            @"search_query":@"be_null",
            @"page_type":pageType.length > 0 ? pageType : @"be_null",
            @"query_type":queryType
        };
        NSMutableDictionary *infos = [NSMutableDictionary new];
        infos[@"houseSearch"] = houseSearchParams;
        
        NSMutableDictionary *tracer = [NSMutableDictionary new];
        tracer[@"enter_type"] = @"click";
        tracer[@"element_from"] = element_from.length > 0 ? element_from : @"be_null";
        tracer[@"enter_from"] = enter_from.length > 0 ? enter_from : @"be_null";
        infos[@"tracer"] = tracer;
        
        // 参数都在jumpUrl中
        [self jumpToCategoryListVCByUrl:jumpUrl queryText:nil placeholder:nil infoDict:infos];
    }
}

- (void)jumpToCategoryListVCByUrl:(NSString *)jumpUrl queryText:(NSString *)queryText placeholder:(NSString *)placeholder infoDict:(NSDictionary *)infos {
    NSString *openUrl = jumpUrl;
    if (openUrl.length <= 0) {
        openUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%ld&full_text=%@&placeholder=%@",FHHouseTypeSecondHandHouse,queryText,placeholder];
    }
    // 不需要回传sug数据，以及自己控制页面跳转和移除逻辑
    NSMutableDictionary *tempInfos = [NSMutableDictionary dictionaryWithDictionary:infos];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:tempInfos];
    
    NSURL *url = [NSURL URLWithString:openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHMineConfigDataIconOpDataModel *dataModel = _dataList[indexPath.row];
    
    FHMineBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:mutiItemCellId];
    
    [cell updateCell:dataModel isFirst:indexPath.row == 0];
    
    if([cell isKindOfClass:[FHMineMutiItemCell class]]){
        FHMineMutiItemCell *mutiItemCell = (FHMineMutiItemCell *)cell;
        mutiItemCell.delegate = self;
        if([dataModel.myIconId integerValue] == FHMineModuleTypeHouseFocus){
            self.focusCell = mutiItemCell;
            if(self.focusItemDic.count == 4){
                [mutiItemCell setItemTitlesWithItemDic:self.focusItemDic];
            }
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewController refreshContentOffset:scrollView.contentOffset];
}

- (void)addCLickIconLog:(FHMineConfigDataIconOpDataMyIconItemsModel *)model
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"log_pb"] = model.logPb ?: @"be_null";
    param[@"page_type"] = @"minetab";
    [FHUserTracker writeEvent:@"click_icon" params:param];
}

@end
