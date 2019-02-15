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
//#import "FHUserTracker.h"

@interface FHMineViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) NSArray *defaultList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMineViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray<FHMineFavoriteItemView *> *focusItems;
@property (nonatomic , assign) BOOL hasLogin;

@end

@implementation FHMineViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMineViewController *)viewController
{
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        _focusItems = [[NSMutableArray alloc] init];
        
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
                             @"url":@"snssdk1370://favorite",
                             @"cellId":@"settingCellId",
                             @"cellClassName":@"FHMineSettingCell"
                             },
                         @{
                             @"name":@"用户反馈",
                             @"url":@"snssdk1370://feedback",
                             @"cellId":@"settingCellId",
                             @"cellClassName":@"FHMineSettingCell"
                             },
                         @{
                             @"name":@"系统设置",
                             @"url":@"snssdk1370://more",
                             @"cellId":@"settingCellId",
                             @"cellClassName":@"FHMineSettingCell"
                             },
                         ];
    [self.dataList addObjectsFromArray:self.defaultList];
    
    for (NSDictionary *dic in self.defaultList) {
//        FHBMineDataServiceListModel *model = [[FHBMineDataServiceListModel alloc] init];
//        model.name = dic[@"name"];
//        model.url = dic[@"url"];
//        [self.dataList addObject:model];
        
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
            [self.focusItems removeAllObjects];
            NSArray *typeArray = @[@(FHHouseTypeSecondHandHouse),@(FHHouseTypeRentHouse),@(FHHouseTypeNewHouse),@(FHHouseTypeNeighborhood)];
            NSArray *nameArray = @[@"二手房",@"租房",@"新房",@"小区"];
            NSArray *imageNameArray = @[@"icon-ershoufang",@"icon-zufang",@"icon-xinfang",@"icon-xiaoqu"];
            
            for (NSInteger i = 0; i < typeArray.count; i++) {
                NSInteger type = [typeArray[i] integerValue];
                NSInteger count = [response[@(type)] integerValue];
                NSString *title = [self getFocusItemTitle:nameArray[i] count:count];
                FHMineFavoriteItemView *view = [[FHMineFavoriteItemView alloc] initWithName:title imageName:imageNameArray[i]];
                view.focusClickBlock = ^{
                    [wself goToFocusDetail:type];
                };
                [self.focusItems addObject:view];
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
            NSURL* url = [NSURL URLWithString:@"snssdk1370://editUserProfile"];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        }
    }else{
        NSURL* url = [NSURL URLWithString:@"snssdk1370://flogin"];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
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

- (void)goToFocusDetail:(NSInteger)type {
    NSURL* url = [NSURL URLWithString:@"snssdk1370://myFavorite"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = @(type);
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
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
        [focusCell setItems:self.focusItems];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellClassName = _dataList[indexPath.row][@"cellClassName"];
    
    if([cellClassName isEqualToString:@"FHMineFocusCell"]){
        return UITableViewAutomaticDimension;
    }
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSDictionary *dic = _dataList[indexPath.row];
    NSString *urlStr = dic[@"url"];
    if(urlStr){
        NSURL* url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
    }

//    [self addEnterDetailLog:model];
}

//-(void)addEnterDetailLog:(FHBMineDataServiceListModel *)model
//{
//    /*
//     1. event_type：house_app2b
//     2. page_type：(详情页类型：用户反馈：feedback，系统设置：setting，编辑资料：personal_info)
//     3. enter_from：(详情页入口：我的tab：minetab]
//     */
//    
//    
//    NSMutableDictionary *param = [NSMutableDictionary new];
//    
//    param[UT_ENTER_FROM] = UT_OF_MINE;
//    NSURL *url = [NSURL URLWithString:model.url];
//    if(url.host){
//        param[UT_PAGE_TYPE] = url.host;
//    }
//    
//    TRACK_EVENT(UT_GO_DETAIL,param);
//}
//
//-(void)addEnterUserProfileLog
//{
//    NSMutableDictionary *param = [NSMutableDictionary new];
//    
//    param[UT_ENTER_FROM] = UT_OF_MINE;
//    param[UT_PAGE_TYPE] = @"personal_info";
//    
//    TRACK_EVENT(UT_GO_DETAIL,param);
//}

@end
