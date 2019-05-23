//
//  FHMineViewModel.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineViewModel.h"
#import <TTHttpTask.h>
#import <TTRoute.h>
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

#define mutiItemCellId @"mutiItemCellId"

@interface FHMineViewModel()<UITableViewDelegate,UITableViewDataSource,FHMineFocusCellDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMineViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *focusItemTitles;
@property(nonatomic , assign) BOOL hasLogin;
@property(nonatomic , strong) FHMineMutiItemCell *focusCell;
@property(nonatomic, assign) BOOL isFirstLoad;

@end

@implementation FHMineViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMineViewController *)viewController
{
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        _focusItemTitles = [[NSMutableArray alloc] init];
        _isFirstLoad = YES;
        
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.viewController = viewController;
        
        [self.tableView registerClass:NSClassFromString(@"FHMineMutiItemCell") forCellReuseIdentifier:mutiItemCellId];
        
//        [self initDefaultData];
    }
    return self;
}

//- (void)initDefaultData {
//    self.defaultList = @[
//                         @{
//                             @"name":@"",
//                             @"cellId":@"focusCellId",
//                             @"cellClassName":@"FHMineMutiItemCell"
//                             },
//                         @{
//                             @"name":@"我的收藏",
//                             @"url":@"snssdk1370://favorite?stay_id=favorite",
//                             @"cellId":@"settingCellId",
//                             @"cellClassName":@"FHMineSettingCell"
//                             },
//                         @{
//                             @"name":@"用户反馈",
//                             @"url":@"snssdk1370://feedback",
//                             @"cellId":@"settingCellId",
//                             @"cellClassName":@"FHMineSettingCell",
//                             @"click_minetab":@{
//                                        @"click_type":@"feedback",
//                                        @"page_type":@"minetab",
//                                     },
//                             @"go_detail":@{
//                                     @"enter_from":@"minetab",
//                                     @"page_type":@"feedback",
//                                     },
//                             },
//                         @{
//                             @"name":@"系统设置",
//                             @"url":@"snssdk1370://more",
//                             @"cellId":@"settingCellId",
//                             @"cellClassName":@"FHMineSettingCell",
//                             @"click_minetab":@{
//                                     @"click_type":@"setting",
//                                     @"page_type":@"minetab",
//                                     },
//                             @"go_detail":@{
//                                     @"enter_from":@"minetab",
//                                     @"page_type":@"setting",
//                                     },
//                             },
////                         @{
////                             @"name":@"视频测试",
////                             @"url":@"snssdk1370://video_test",
////                             @"cellId":@"settingCellId",
////                             @"cellClassName":@"FHMineSettingCell",
////                             },
//                         ];
//    [self.dataList addObjectsFromArray:self.defaultList];
//    
//    for (NSDictionary *dic in self.defaultList) {
//        NSString *cellId = dic[@"cellId"];
//        NSString *cellClassName = dic[@"cellClassName"];
//        [self.tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:cellId];
//    }
//}

- (void)requestData {
    __weak typeof(self) wself = self;
    [FHMineAPI requestFocusInfoWithCompletion:^(NSDictionary * _Nonnull response, NSError * _Nonnull error) {
        if (error) {
            //TODO: show handle error
            [wself.tableView reloadData];
            return;
        }

        if(response.count == 4){
            [self.focusItemTitles removeAllObjects];
            NSArray *typeArray = @[@(FHHouseTypeSecondHandHouse),@(FHHouseTypeRentHouse),@(FHHouseTypeNewHouse),@(FHHouseTypeNeighborhood)];
            NSArray *nameArray = @[@"二手房",@"租房",@"新房",@"小区"];

            for (NSInteger i = 0; i < typeArray.count; i++) {
                NSInteger type = [typeArray[i] integerValue];
                NSInteger count = [response[@(type)] integerValue];
                NSString *title = [self getFocusItemTitle:nameArray[i] count:count];
                [self.focusItemTitles addObject:title];
            }
            
            if(self.focusCell && self.focusItemTitles.count == 4){
                [self.focusCell setItemTitles:self.focusItemTitles];
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
        
        if(self.isFirstLoad){
            [self.viewController endLoading];
        }
        
        wself.isFirstLoad = NO;
        
        if (error) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            wself.tableView.bounces = NO;
            return;
        }
        
        wself.tableView.bounces = YES;
        [wself.viewController.emptyView hideEmptyView];
        
        FHMineConfigModel *configModel = (FHMineConfigModel *)model;
        if(configModel){
            wself.dataList = configModel.data.iconOpData;
            [wself.tableView reloadData];
        }
    }];
}

- (void)showInfo
{
    if([TTAccount sharedAccount].isLogin){
        NSDictionary *fhSettings = [self fhSettings];
        NSInteger state = [fhSettings tt_integerValueForKey:@"f_is_show_profile_edit_entry"];
        //测试数据
        state = 2;
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
        dict[@"enter_from"] = @"minetab";
        dict[@"enter_type"] = @"login";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL* url = [NSURL URLWithString:@"snssdk1370://flogin"];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)updateHeaderView
{
    NSString *avatar = [TTAccountManager avatarURLString];
    [self.viewController.headerView updateAvatar:avatar];
    
    NSString *name = [TTAccountManager userName];
    TTAccountUserEntity *userInfo = [TTAccount sharedAccount].user;
    
    NSDictionary *fhSettings = [self fhSettings];
    NSInteger state = [fhSettings tt_integerValueForKey:@"f_is_show_profile_edit_entry"];
    //测试数据
    state = 2;
    [self.viewController.headerView setUserInfoState:state];
    
    if (userInfo != nil) {
        self.viewController.headerView.userNameLabel.text = name?:@"";
        self.viewController.headerView.descLabel.text = @"查看并编辑个人信息";
        self.viewController.headerView.editIcon.hidden = NO;
        _hasLogin = YES;
    } else {
        self.viewController.headerView.userNameLabel.text = @"登录/注册";
        self.viewController.headerView.descLabel.text = @"关注房源永不丢失";
        self.viewController.headerView.editIcon.hidden = YES;
        _hasLogin = NO;
    }
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (NSString *)getFocusItemTitle:(NSString *)name count:(NSInteger)count {
    if([TTAccount sharedAccount].isLogin){
        return [NSString stringWithFormat:@"%@ (%i)",name,count];
    }else{
        return [NSString stringWithFormat:@"%@ (*)",name];
    }
}

- (void)goToSystemSetting {
    NSURL* url = [NSURL URLWithString:@"sslocal://more"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

#pragma mark - FHMineFocusCellDelegate

- (void)didItemClick:(FHMineConfigDataIconOpDataMyIconItemsModel *)model {
     if ([TTReachability isNetworkConnected]) {
         //埋点
         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         dict[@"tracer"] = model.logPb;
         
         TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
         
         NSURL* url = [NSURL URLWithString:model.openUrl];
         [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
     }else{
         [[ToastManager manager] showToast:@"网络异常"];
     }
}

//- (void)goToFocusDetail:(FHHouseType)type {
//    if ([TTReachability isNetworkConnected]) {
//        NSURL* url = [NSURL URLWithString:@"snssdk1370://myFocus"];
//
//        NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
//        tracerDict[@"enter_from"] = @"minetab";
//        tracerDict[@"enter_type"] = @"click";
//        tracerDict[@"element_from"] = @"be_null";
//        tracerDict[@"origin_from"] = [self focusOriginFrom:type];
//
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[@"house_type"] = @(type);
//        dict[@"tracer"] = tracerDict;
//
//        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
//    } else {
//        [[ToastManager manager] showToast:@"网络异常"];
//    }
//}
//
//- (NSString *)focusOriginFrom:(FHHouseType)type {
//    NSString *originFrom = @"be_null";
//    switch (type) {
//        case FHHouseTypeNewHouse:
//            originFrom = @"minetab_new";
//            break;
//        case FHHouseTypeRentHouse:
//            originFrom = @"minetab_rent";
//            break;
//        case FHHouseTypeSecondHandHouse:
//            originFrom = @"minetab_old";
//            break;
//        case FHHouseTypeNeighborhood:
//            originFrom = @"minetab_neighborhood";
//            break;
//
//        default:
//            break;
//    }
//    return originFrom;
//}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHMineConfigDataIconOpDataModel *dataModel = _dataList[indexPath.row];
    
    FHMineBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:mutiItemCellId];
    
    [cell updateCell:dataModel isFirst:indexPath.row == 0];
    
    if([cell isKindOfClass:[FHMineMutiItemCell class]]){
        FHMineMutiItemCell *mutiItemCell = (FHMineMutiItemCell *)cell;
        mutiItemCell.delegate = self;
        if([dataModel.myIconId isEqualToString:@"0"]){
            self.focusCell = mutiItemCell;
            if(self.focusItemTitles.count == 4){
                [mutiItemCell setItemTitles:self.focusItemTitles];
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

    NSDictionary *dic = _dataList[indexPath.row];
    
    NSString *clickTrackDic = dic[@"click_minetab"];
    if(clickTrackDic){
        TRACK_EVENT(@"click_minetab", clickTrackDic);
    }
    
    NSString *goDetailTrackDic = dic[@"go_detail"];
    if(clickTrackDic){
        TRACK_EVENT(@"go_detail", goDetailTrackDic);
    }
    
    NSString *urlStr = dic[@"url"];
    if(urlStr){
        NSURL* url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewController refreshContentOffset:scrollView.contentOffset];
}



@end
