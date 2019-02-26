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
#import "FHMineFocusCell.h"
#import "FHMineAPI.h"
#import "FHHouseType.h"
#import "TTAccount.h"
#import "TTAccountManager.h"
#import "ToastManager.h"
#import "FHUserTracker.h"
#import "TTReachability.h"

@interface FHMineViewModel()<UITableViewDelegate,UITableViewDataSource,FHMineFocusCellDelegate>

@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) NSArray *defaultList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMineViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *focusItemTitles;
@property (nonatomic , assign) BOOL hasLogin;

@end

@implementation FHMineViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMineViewController *)viewController
{
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        _focusItemTitles = [[NSMutableArray alloc] init];
        
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.viewController = viewController;
        
        [self initDefaultData];
    }
    return self;
}

- (void)initDefaultData {
    self.defaultList = @[
                         @{
                             @"name":@"我的关注",
                             @"cellId":@"focusCellId",
                             @"cellClassName":@"FHMineFocusCell"
                             },
                         @{
                             @"name":@"我的收藏",
                             @"url":@"snssdk1370://favorite?stay_id=favorite",
                             @"cellId":@"settingCellId",
                             @"cellClassName":@"FHMineSettingCell"
                             },
                         @{
                             @"name":@"用户反馈",
                             @"url":@"snssdk1370://feedback",
                             @"cellId":@"settingCellId",
                             @"cellClassName":@"FHMineSettingCell",
                             @"click_minetab":@{
                                        @"click_type":@"feedback",
                                        @"page_type":@"minetab",
                                     },
                             @"go_detail":@{
                                     @"enter_from":@"minetab",
                                     @"page_type":@"feedback",
                                     },
                             },
                         @{
                             @"name":@"系统设置",
                             @"url":@"snssdk1370://more",
                             @"cellId":@"settingCellId",
                             @"cellClassName":@"FHMineSettingCell",
                             @"click_minetab":@{
                                     @"click_type":@"setting",
                                     @"page_type":@"minetab",
                                     },
                             @"go_detail":@{
                                     @"enter_from":@"minetab",
                                     @"page_type":@"setting",
                                     },
                             },
                         ];
    [self.dataList addObjectsFromArray:self.defaultList];
    
    for (NSDictionary *dic in self.defaultList) {
        NSString *cellId = dic[@"cellId"];
        NSString *cellClassName = dic[@"cellClassName"];
        [self.tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:cellId];
    }
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
            [self.focusItemTitles removeAllObjects];
            NSArray *typeArray = @[@(FHHouseTypeSecondHandHouse),@(FHHouseTypeRentHouse),@(FHHouseTypeNewHouse),@(FHHouseTypeNeighborhood)];
            NSArray *nameArray = @[@"二手房",@"租房",@"新房",@"小区"];
            
            for (NSInteger i = 0; i < typeArray.count; i++) {
                NSInteger type = [typeArray[i] integerValue];
                NSInteger count = [response[@(type)] integerValue];
                NSString *title = [self getFocusItemTitle:nameArray[i] count:count];
                [self.focusItemTitles addObject:title];
            }
            
            [wself.tableView reloadData];
        }
    }];
}

- (void)showInfo
{
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
            
            NSURL* url = [NSURL URLWithString:@"snssdk1370://editUserProfile"];
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
    
    if (userInfo != nil) {
        self.viewController.headerView.userNameLabel.text = name?:@"";
        self.viewController.headerView.descLabel.text = @"查看并编辑个人资料";
        self.viewController.headerView.editIcon.hidden = NO;
        _hasLogin = YES;
    } else {
        self.viewController.headerView.userNameLabel.text = @"登录";
        self.viewController.headerView.descLabel.text = @"登录后，关注房源永不丢失";
        self.viewController.headerView.editIcon.hidden = YES;
        _hasLogin = NO;
    }
    
    NSDictionary *fhSettings = [self fhSettings];
    NSInteger state = [fhSettings tt_integerValueForKey:@"f_is_show_profile_edit_entry"];
    [self.viewController.headerView setUserInfoState:state hasLogin:_hasLogin];
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

#pragma mark - FHMineFocusCellDelegate

- (void)goToFocusDetail:(FHHouseType)type {
    if ([TTReachability isNetworkConnected]) {
        NSURL* url = [NSURL URLWithString:@"snssdk1370://myFavorite"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"type"] = @(type);
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    } else {
        [[ToastManager manager] showToast:@"网络异常"];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = _dataList[indexPath.row][@"cellId"];
    FHMineBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    [cell updateCell:_dataList[indexPath.row]];
    
    if([cell isKindOfClass:[FHMineFocusCell class]]){
        FHMineFocusCell *focusCell = (FHMineFocusCell *)cell;
        focusCell.delegate = self;
        if(self.focusItemTitles.count == 4){
            [focusCell setItemTitles:self.focusItemTitles];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellClassName = _dataList[indexPath.row][@"cellClassName"];
    if([cellClassName isEqualToString:@"FHMineFocusCell"]){
        return UITableViewAutomaticDimension;
    }
    return 50.0f;
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

@end
