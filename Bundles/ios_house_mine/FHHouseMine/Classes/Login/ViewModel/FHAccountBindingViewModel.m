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
#import "TTUIResponderHelper.h"

typedef NS_ENUM(NSUInteger, FHSectionType) {
    kFHSectionTypeNone,
    kFHSectionTypeBindingInfo,      // 绑定修改（手机号、密码等）
    kFHSectionTypeThirdAccounts,    // 关联帐号
};

typedef NS_ENUM(NSUInteger, FHCellType) {
    kFHCellTypeNone,
    kFHCellTypeBindingPhone,        //绑定的手机号
    kFHCellTypeBindingDouYin,       //抖音一键登录
};

typedef NS_ENUM(NSUInteger, FHAccountBindingOperationWordType) {
    FHAccountBindingOperationWordOther     = 0,      //
    FHAccountBindingOperationCancel        = 1,      // 取消绑定
    FHAccountBindingOperationFailure       = 2,      // 绑定失败
    FHAccountBindingOperationUnableFound   = 3,      // 解绑后无法找回该账户
};

@interface FHAccountBindingViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) FHAccountBindingViewController *viewController;

@end

@implementation FHAccountBindingViewModel

- (instancetype)initWithTableView:(UITableView *)tableView viewController:(FHAccountBindingViewController *)viewController {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        self.viewController = viewController;
        [self registerCellClasses];
        
    }
    return self;
}

- (void)registerCellClasses {
    [self.tableView registerClass:[FHDouYinBindingCell class] forCellReuseIdentifier:@"kFHCellTypeBindingDouYin"];
    [self.tableView registerClass:[FHPhoneBindingCell class] forCellReuseIdentifier:@"kFHCellTypeBindingPhone"];
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
            case kFHCellTypeBindingPhone:{
                FHPhoneBindingCell *cell = (FHPhoneBindingCell *)[tableView dequeueReusableCellWithIdentifier:@"kFHCellTypeBindingPhone"];
                cell.contentLabel.text = [self mobilePhoneNumber];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            case kFHCellTypeBindingDouYin:{
                FHDouYinBindingCell *cell = (FHDouYinBindingCell *)[tableView dequeueReusableCellWithIdentifier:@"kFHCellTypeBindingDouYin"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                __weak typeof(self) wSelf = self;
                cell.DouYinBinding = ^(UISwitch * sender) {
                    [wSelf bindingDouYinAccount:sender];
                };
                cell.DouYinUnbinding = ^(UISwitch * sender){
                    [wSelf handleItemselected:sender withType:FHAccountBindingOperationCancel];
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
            case kFHSectionTypeBindingInfo:{
                return 6.0;
                break;
            }
            case kFHSectionTypeThirdAccounts:{
                return 42.0;
                break;
            }
            default:{
                return 0.0;
            }
                break;
        }
        return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *aView = nil;
    switch ([self sectionTypeOfIndex:section]) {
        case kFHSectionTypeBindingInfo:{
            UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 6.0)];
            aView = sectionHeaderView;
            break;
        }
        case kFHSectionTypeThirdAccounts:{
            FHThirdAccountsHeaderView *sectionHeaderView = [[FHThirdAccountsHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 42.0)];
            aView = sectionHeaderView;
            break;
        }
        default:{
            aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.0)];
        }
            break;
    }
    aView.backgroundColor = [UIColor clearColor];
    return aView;
}

#pragma mark - private methods

-(void)initData {
    if (!_sections) {
        _sections = [NSMutableArray array];
    }
    [self.sections removeAllObjects];
    [self.sections addObjectsFromArray:@[
        @(kFHSectionTypeBindingInfo),
        @(kFHSectionTypeThirdAccounts)
    ]
    ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (FHSectionType)sectionTypeOfIndex:(NSUInteger)section {
    if (section >= [self.sections count]) return kFHSectionTypeNone;
    return [[self.sections objectAtIndex:section] unsignedIntegerValue];
}

- (FHCellType)cellTypeOfIndexPath:(NSIndexPath *)indexPath {
    FHCellType cellType = kFHCellTypeNone;
    switch ([self sectionTypeOfIndex:indexPath.section]) {
        case kFHSectionTypeBindingInfo:
            if (indexPath.row == 0) {
                cellType = kFHCellTypeBindingPhone;
            }
            break;
        case kFHSectionTypeThirdAccounts:
            if (indexPath.row == 0) {
                cellType = kFHCellTypeBindingDouYin;
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
        case kFHSectionTypeBindingInfo:
            numberOfRows = 1;
            break;
        case kFHSectionTypeThirdAccounts:
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

- (void)bindingDouYinAccount:(UISwitch *)sender { //绑定逻辑
    __weak typeof(self) wSelf = self;
    [TTAccount requestBindV2ForPlatform:TTAccountAuthTypeDouyin inCustomWebView:NO willBind:^(NSString * _Nonnull Bindinfo){
        NSLog(@"luowentao Bindinfo:%@",Bindinfo);
    } completion:^(BOOL success, NSError *error) {
        __strong typeof(wSelf) strongSelf = wSelf;
        NSLog(@"luowentao success = %d error = %@",success,error);
        if (error) {
            [strongSelf handleBindingResult:error];
            [sender setOn:!sender.isOn animated:YES];
        } else {
            [strongSelf handleBindingResult:error];
        }
    }];
};

- (void)cancelBindingDouYinAccount:(UISwitch *)sender { //解绑逻辑
    __weak typeof(self) wSelf = self;
    
    [TTAccount requestLogoutForPlatform:TTAccountAuthTypeDouyin completion:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"luowentao success = %d error = %@",success,error);
        __strong typeof(wSelf) strongSelf = wSelf;
        if (error) {
            [strongSelf handleCancelBindingResult:error];
            [sender setOn:!sender.isOn animated:YES];
        } else {
            [strongSelf handleCancelBindingResult:error];
        }
    }];
}

#pragma mark - Remind


- (void)handleItemselected:(UISwitch *)sender withType:(FHAccountBindingOperationWordType)type {
    __weak typeof(self) wself = self;
    if (type == FHAccountBindingOperationCancel) {
        [self showAlert:@"解除绑定" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
            [sender setOn:!sender.isOn animated:YES];
        } confirmBlock:^{
            [wself cancelBindingDouYinAccount:sender];
        }];
    }
}


- (void)showAlert:(NSString *)title cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle cancelBlock:(void(^)())cancelBlock confirmBlock:(void(^)())confirmBlock {
    __weak typeof(self) wself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleCancel
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
- (void)handleBindingResult:(NSError *)error {
    if (!error) {
        [[ToastManager manager] showToast:@"绑定成功"];
    } else {
        if (error.code == 1041) {
            [[ToastManager manager] showToast:@"已经绑定了某个账号"];
        } else {
            NSString *errorMessage = @"啊哦，服务器开小差了";
            errorMessage = [FHMineAPI errorMessageByErrorCode:error];
            [[ToastManager manager] showToast:errorMessage];
        }
    }
}

- (void)handleCancelBindingResult:(NSError *)error {
    if (!error) {
        [[ToastManager manager] showToast:@"解绑成功"];
    } else {
        NSString *errorMessage = @"啊哦，服务器开小差了";
        errorMessage = [FHMineAPI errorMessageByErrorCode:error];
        [[ToastManager manager] showToast:errorMessage];
    }
}

@end
