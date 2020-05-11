//
//  FHAccountBindingViewModel.m
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import "FHAccountBindingViewModel.h"
#import "FHAccountBindingViewController.h"
#import "FHThirdAccountsHeaderView.h"
#import "TTAccountManager.h"
#import "TTAccount+PlatformAuthLogin.h"
#import "FHDouYinBindingCell.h"
#import "FHPhoneBindingCell.h"
#import "ToastManager.h"
#import "FHMineAPI.h"
#import "FHUserTracker.h"
#import "TTUIResponderHelper.h"
#import "FHLoginDefine.h"

typedef NS_ENUM(NSUInteger, FHAccountBindingSectionType) {
    kFHAccountBindingSectionTypeNone,
    kFHAccountBindingSectionTypeBindingInfo,      // 绑定修改（手机号、密码等）
    kFHAccountBindingSectionTypeThirdAccounts,    // 关联帐号
};

typedef NS_ENUM(NSUInteger, FHAccountBindingCellType) {
    kFHAccountBindingCellTypeNone,
    kFHAccountBindingCellTypeBindingPhone,        //绑定的手机号
    kFHAccountBindingCellTypeBindingDouYin,       //抖音一键登录
};

typedef NS_ENUM(NSUInteger, FHAccountBindingOperationWordType) {
    FHAccountBindingOperationWordOther     = 0,      //
    FHAccountBindingOperationCancel        = 1,      // 取消绑定
    FHAccountBindingOperationAlreadyHave   = 2,      // 已经被绑定，绑定失败
    FHAccountBindingOperationWillLose      = 3,      // 解绑后无法找回该账户
};

@interface FHAccountBindingViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation FHAccountBindingViewModel

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        [self registerCellClasses];
        
    }
    return self;
}

- (void)registerCellClasses {
    [self.tableView registerClass:[FHDouYinBindingCell class] forCellReuseIdentifier:@"kFHAccountBindingCellTypeBindingDouYin"];
    [self.tableView registerClass:[FHPhoneBindingCell class] forCellReuseIdentifier:@"kFHAccountBindingCellTypeBindingPhone"];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 2 && indexPath.row < 1) {
        switch ([self cellTypeOfIndexPath:indexPath]) {
            case kFHAccountBindingCellTypeBindingPhone:{
                FHPhoneBindingCell *cell = (FHPhoneBindingCell *)[tableView dequeueReusableCellWithIdentifier:@"kFHAccountBindingCellTypeBindingPhone"];
                cell.contentLabel.text = [self mobilePhoneNumber];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            case kFHAccountBindingCellTypeBindingDouYin:{
                FHDouYinBindingCell *cell = (FHDouYinBindingCell *)[tableView dequeueReusableCellWithIdentifier:@"kFHAccountBindingCellTypeBindingDouYin"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                __weak typeof(self) wSelf = self;
                cell.douYinBinding = ^(UISwitch * sender) {
                    [wSelf thirdPartyBindLog:!sender.isOn];
                    if (sender.isOn) {
                        [wSelf bindingAccountDouYin:sender cancel:NO];
                    } else {
                        [wSelf handleItemselected:sender withType:FHAccountBindingOperationCancel withError:nil];
                    }
                };
                [cell.switchButton setOn:[self hadDouYinAccount]];
                return cell;
            }
                break;
            default:
                break;
        }
    }
    return [[UITableViewCell alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch ([self sectionTypeOfIndex:section]) {
            case kFHAccountBindingSectionTypeBindingInfo:{
                return 6.0;
                break;
            }
            case kFHAccountBindingSectionTypeThirdAccounts:{
                return 44.0;
                break;
            }
            default:{
                return 0.01;
            }
                break;
        }
        return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *aView = nil;
    switch ([self sectionTypeOfIndex:section]) {
        case kFHAccountBindingSectionTypeBindingInfo:{
            UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 6.0)];
            aView = sectionHeaderView;
            break;
        }
        case kFHAccountBindingSectionTypeThirdAccounts:{
            FHThirdAccountsHeaderView *sectionHeaderView = [[FHThirdAccountsHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44.0)];
            aView = sectionHeaderView;
            break;
        }
        default:{
            aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.01)];
        }
            break;
    }
    aView.backgroundColor = [UIColor clearColor];
    return aView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 0.01)];
    return view;
}

#pragma mark - data helper

-(void)loadData {
    if (!_sections) {
        _sections = [NSMutableArray array];
    }
    [self.sections removeAllObjects];
    [self.sections addObjectsFromArray:@[
        @(kFHAccountBindingSectionTypeBindingInfo),
        @(kFHAccountBindingSectionTypeThirdAccounts)
    ]
    ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (FHAccountBindingSectionType)sectionTypeOfIndex:(NSUInteger)section {
    if (section >= [self.sections count]) return kFHAccountBindingSectionTypeNone;
    return [[self.sections objectAtIndex:section] unsignedIntegerValue];
}

- (FHAccountBindingCellType)cellTypeOfIndexPath:(NSIndexPath *)indexPath {
    FHAccountBindingCellType cellType = kFHAccountBindingCellTypeNone;
    switch ([self sectionTypeOfIndex:indexPath.section]) {
        case kFHAccountBindingSectionTypeBindingInfo:
            if (indexPath.row == 0) {
                cellType = kFHAccountBindingCellTypeBindingPhone;
            }
            break;
        case kFHAccountBindingSectionTypeThirdAccounts:
            if (indexPath.row == 0) {
                cellType = kFHAccountBindingCellTypeBindingDouYin;
            }
            break;
        default:
            break;
    }
    return cellType;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (section >= [self.sections count]) {
        return 0;
    }
    NSUInteger numberOfRows = 0;
    switch ([self sectionTypeOfIndex:section]) {
        case kFHAccountBindingSectionTypeBindingInfo:
            numberOfRows = 1;
            break;
        case kFHAccountBindingSectionTypeThirdAccounts:
            numberOfRows = 1;
            break;
        default:
            break;
    }
    return numberOfRows;
}

#pragma mark - TTAccount
- (NSString *)mobilePhoneNumber {
    NSString *mobile = [[TTAccount sharedAccount] user].mobile;
    NSRange range = [mobile rangeOfString:@"****"];
    if (mobile.length != 11) {
        return @"电话号码异常";
    }
    if (mobile.length == 11 && range.location == NSNotFound) {
        NSString *nowMobile = [NSString stringWithFormat:@"%@****%@",[mobile substringToIndex:3],[mobile substringFromIndex:7]];
        mobile = nowMobile;
    }
    return mobile;
}

- (BOOL)hadDouYinAccount {
    NSArray<TTAccountPlatformEntity *> *connects = [[TTAccount sharedAccount] user].connects;
    for (TTAccountPlatformEntity *ent in connects) {
        if ([ent.platform isEqualToString:@"aweme_v2" ]) {
            return YES;
        }
    }
    return NO;
}

- (void)bindingAccountDouYin:(UISwitch *)sender cancel:(BOOL)cancel { //绑定与解绑逻辑
    __weak typeof(self) wSelf = self;
    if (cancel) {
        [TTAccount requestLogoutForPlatform:TTAccountAuthTypeDouyin completion:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(wSelf) strongSelf = wSelf;
            if (error) {
                [strongSelf handleCancelBindingResult:error sender:sender];
                
            } else {
                [strongSelf handleCancelBindingResult:error sender:sender];
            }
        }];
    } else {
        [TTAccount requestBindV2ForPlatform:TTAccountAuthTypeDouyin inCustomWebView:NO willBind:^(NSString * _Nonnull Bindinfo){
            
        } completion:^(BOOL success, NSError *error) {
            __strong typeof(wSelf) strongSelf = wSelf;
            if (error) {
                [strongSelf handleBindingResult:error sender:sender];
            } else {
                [strongSelf handleBindingResult:error sender:sender];
            }
        }];
    }
};


#pragma mark - Remind

- (void)handleItemselected:(UISwitch *)sender withType:(FHAccountBindingOperationWordType)type withError:(NSError *)error {
    __weak typeof(self) wSelf = self;
    if (type == FHAccountBindingOperationCancel) {
        [self thirdPartyBindTipsLog:!sender.isOn statusInfo:@"操作确认" popType:@"解绑弹窗"];
        [self showAlert:@"解除绑定？" message:nil cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            [sender setOn:!sender.isOn animated:YES];
        } confirmBlock:^{
            [wSelf bindingAccountDouYin:sender cancel:YES];
        }];
//    } else if (type == FHAccountBindingOperationAlreadyHave) {
//        [self showAlert:@"绑定失败" message:@"绑定失败，此抖音账号已绑定到账号『 』" cancelTitle:@"取消" confirmTitle:@"解绑原账号" cancelBlock:^{
//            [sender setOn:!sender.isOn animated:YES];
//        } confirmBlock:^{
//
//        }];
//    } else if (type == FHAccountBindingOperationWillLose) {
//        [self showAlert:@"解绑后将无法用此抖音号登录『 』，也可能无法再次找回该账户，确认操作？" message:nil cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
//            [sender setOn:!sender.isOn animated:YES];
//        } confirmBlock:^{
//
//        }];
    }
}

- (void)showAlert:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle cancelBlock:(void(^)())cancelBlock confirmBlock:(void(^)())confirmBlock {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             // 点击取消按钮，调用此block
                                                             if(cancelBlock){
                                                                 cancelBlock();
                                                             }
                                                         }];
    [alert addAction:cancelAction];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:confirmTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              // 点击按钮，调用此block
                                                              if(confirmBlock){
                                                                  confirmBlock();
                                                              }
                                                          }];
    [alert addAction:defaultAction];
    [[TTUIResponderHelper visibleTopViewController] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Handing
- (void)handleBindingResult:(NSError *)error sender:(UISwitch *)sender {
    if (!error) {
        [self thirdPartyBindTipsLog:!sender.isOn statusInfo:@"绑定成功" popType:@"绑定弹窗"];
        [[ToastManager manager] showToast:@"绑定成功"];
    } else {
        [self thirdPartyBindTipsLog:!sender.isOn statusInfo:@"绑定失败" popType:@"绑定弹窗"];
        NSString *errorMessage = nil;
        if (error.code == 6) {
            errorMessage = @"服务异常";
        } else if (error.code == 999) {
            errorMessage = @"服务器出了点小意外，努力修复中";
        } else {
            errorMessage = [FHMineAPI errorMessageByErrorCode:error];
        }
        if (errorMessage.length == 0) {
            errorMessage = @"啊哦，服务器开小差了";
        }
        [[ToastManager manager] showToast:errorMessage];
        [sender setOn:!sender.isOn animated:YES];
    }
}

- (void)handleCancelBindingResult:(NSError *)error sender:(UISwitch *)sender {
    if (!error) {
        [self thirdPartyBindTipsLog:!sender.isOn statusInfo:@"解绑成功" popType:@"解绑弹窗"];
        [[ToastManager manager] showToast:@"解绑成功"];
    } else {
        [self thirdPartyBindTipsLog:!sender.isOn statusInfo:@"解绑失败" popType:@"解绑弹窗"];
        NSString *errorMessage = nil;
        if (error.code == 6) {
            errorMessage = @"服务异常";
        } else if (error.code == 999) {
            errorMessage = @"服务器出了点小意外，努力修复中";
        } else if (error.code == 1038) {
            errorMessage = @"该三方帐号是当前帐号的唯一登录方式，暂不支持解绑操作";
        } else {
            errorMessage = [FHMineAPI errorMessageByErrorCode:error];
        }
        if (errorMessage.length == 0) {
            errorMessage = @"啊哦，服务器开小差了";
        }
        [[ToastManager manager] showToast:errorMessage];
        [sender setOn:!sender.isOn animated:YES];
    }
}
#pragma mark - Log
- (void)thirdPartyBindLog :(BOOL)isOn {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"status"] = isOn ? @"on":@"off";
    tracerDict[@"event_page"] = @"account_safe";
    tracerDict[@"event_type"] = @"click";
    tracerDict[@"event_belong"] = @"account";
    tracerDict[@"platform"] = @"aweme";
    tracerDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"third_party_bind", tracerDict);
}

- (void)thirdPartyBindTipsLog :(BOOL)isOn statusInfo:(NSString *)info popType:(NSString *)type {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"status"] = isOn ? @"on":@"off";
    tracerDict[@"event_page"] = @"account_safe";
    tracerDict[@"event_type"] = @"show";
    tracerDict[@"event_belong"] = @"account";
    tracerDict[@"show_type"] = @"toast";
    tracerDict[@"platform"] = @"aweme";
    tracerDict[@"popup_type"] = type;
    tracerDict[@"status_info"] = info;
    tracerDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"third_party_bind_tips", tracerDict);
}
@end
