//
//  FHEditUserViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/20.
//

#import "FHEditUserViewModel.h"
#import <TTHttpTask.h>
#import <TTRoute.h>
#import "FHEditUserBaseCell.h"
#import <TTAccountBusiness.h>
#import "FHEditableUserInfo.h"
#import "TTURLUtils.h"
#import "FHEnvContext.h"

@interface FHEditUserViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) NSArray *dataList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) FHEditableUserInfo *userInfo;
@property(nonatomic, weak) FHEditUserController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;

@end

@implementation FHEditUserViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHEditUserController *)viewController
{
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc] init];
    
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.viewController = viewController;
    }
    return self;
}

- (void)refreshData {
    self.dataList = @[
                      @[
                          @{
                              @"name":@"头像",
                              @"key":@"avatar",
                              @"cellId":@"imageCellId",
                              @"cellClassName":@"FHEditUserImageCell",
                              @"imageUrl":self.userInfo.avatarURL,
                              },
                          @{
                              @"name":@"昵称",
                              @"key":@"userName",
                              @"url":@"snssdk1370://favorite?stay_id=favorite",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":self.userInfo.name
                              },
                          @{
                              @"name":@"介绍",
                              @"key":@"userDesc",
                              @"url":@"snssdk1370://feedback",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":self.userInfo.userDescription
                              },
                          ],
                      @[
                          @{
                              @"name":@"注销账号",
                              @"key":@"unRegister",
                              @"cellId":@"textCellId",
                              @"cellClassName":@"FHEditUserTextCell",
                              @"content":@""
                              },
                          ]
                         ];
    
    for (NSArray *items in self.dataList) {
        for (NSDictionary *item in items) {
            NSString *cellId = item[@"cellId"];
            NSString *cellClassName = item[@"cellClassName"];
            [self.tableView registerClass:NSClassFromString(cellClassName) forCellReuseIdentifier:cellId];
        }
    }
}

- (void)loadRequest {
    if ([TTAccountManager isLogin]) {
        __weak typeof(self) wself = self;
        
        [TTAccount getUserAuditInfoIgnoreDispatchWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            __weak typeof(wself) sself = wself;
            if (!error) {
                TTAccountUserAuditSet *newAuditInfo = [userEntity.auditInfoSet copy];
                sself.userInfo.editEnabled = [newAuditInfo modifyUserInfoEnabled];
                sself.userInfo.name        = [newAuditInfo username];
                sself.userInfo.avatarURL  = [newAuditInfo userAvatarURLString];
                sself.userInfo.userDescription = [newAuditInfo userDescription];
                
                [sself reloadViewModel];
            }
        }];
    }
}

- (void)reloadViewModel {
    if (!_userInfo) {
        [self refreshUserInfo];
    }
    
    [self refreshData];
    [self.tableView reloadData];
}

- (void)refreshUserInfo {
    TTAccountUserAuditSet *newAuditInfo = [[TTAccountManager currentUser].auditInfoSet copy];
    TTAccountUserEntity* userInfo = [[TTAccount sharedAccount] user];
    if (!newAuditInfo && !userInfo) return;
    
    if (!_userInfo) {
        _userInfo = [[FHEditableUserInfo alloc] init];
    }
    
    _userInfo.editEnabled = YES;
    _userInfo.name        = [newAuditInfo username];
    _userInfo.avatarURL   = [newAuditInfo userAvatarURLString];
    _userInfo.userDescription = [newAuditInfo userDescription];
}

- (void)triggerLogoutUnRegister {
    NSDictionary *params = @{@"category":@"event_v3",@"page_type":@"minetab"};
    [FHEnvContext recordEvent:params andEventKey:@"account_cancellation"];
    
    
    NSString *unencodedString = @"http://m.haoduofangs.com/f100/inner/valuation/delcount/";
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)unencodedString,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@",encodedString];
    
    NSURL *url = [TTURLUtils URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.dataList[section];
    return [items count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = self.dataList[indexPath.section];
    NSString *cellId = items[indexPath.row][@"cellId"];
    FHEditUserBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    [cell updateCell:items[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 60.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section != 0){
        return 10.0f;
    }
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = nil;
    if(section != 0){
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10.0f)];
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray *items = self.dataList[indexPath.section];
    NSDictionary *dic = items[indexPath.row];
    
    NSString *urlStr = dic[@"url"];
    if(urlStr){
        NSURL* url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
    }else{
        [self doOtherAction:dic[@"key"]];
    }
}

- (void)doOtherAction:(NSString *)key {
    if([key isEqualToString:@"unRegister"]){
        [self triggerLogoutUnRegister];
    }else if([key isEqualToString:@"avatar"]){
        
    }
}

@end
