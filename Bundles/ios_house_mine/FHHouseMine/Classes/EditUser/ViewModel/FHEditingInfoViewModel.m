//
//  FHEditingInfoViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/22.
//

#import "FHEditingInfoViewModel.h"
#import "NSString+TTLength.h"
#import "NSStringAdditions.h"
#import "ToastManager.h"
#import "TTIndicatorView.h"
#import "TTAccount+NetworkTasks.h"
#import "TTReachability.h"
#import "TTBaseMacro.h"
#import "TTAccountBusiness.h"

@interface FHEditingInfoViewModel()<UITextFieldDelegate>

@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, weak) FHEditingInfoController *viewController;

@end

@implementation FHEditingInfoViewModel

- (instancetype)initWithTextField:(UITextField *)textField controller:(FHEditingInfoController *)viewController {
    self = [super init];
    if (self) {
        self.textField = textField;
        textField.delegate = self;
        
        self.viewController = viewController;
    }
    return self;
}

- (void)viewWillAppear {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)save {
    if (self.type == FHEditingInfoTypeUserName) {
        // 修改用户名
        NSString *name = [self.textField.text trimmed];
        if([name isEqualToString:self.userInfo.name]) {
            // 当用户修改自己的昵称名，新昵称名与原昵称名相同时，显示“与原来昵称相同”
//            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"与原来昵称相同", nil) indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            [[ToastManager manager] showToast:@"与原来昵称相同"];
        } else {
            
            NSUInteger tt_byteLength = [name tt_lengthOfBytes];
            if(tt_byteLength < 2*2 || tt_byteLength > 20*2) {
//                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"昵称长度请控制在2-20个汉字", nil) indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                [[ToastManager manager] showToast:@"昵称长度请控制在2-20个汉字"];
            } else {
                // 上传
                [self uploadUserAuditContent:name forName:YES];
            }
        }
    } else if (self.type == FHEditingInfoTypeUserDesc){
        // 修改签名（介绍）
        NSString *desp = self.textField.text;
        NSUInteger tt_byteLength = [desp tt_lengthOfBytes];
        if([desp isEqualToString:self.userInfo.userDescription]) {
//            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"与原来介绍相同", nil) indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            [[ToastManager manager] showToast:@"与原来介绍相同"];
        } else if(tt_byteLength > 30*2) {
//            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"介绍长度请控制在0-30个汉字", nil) indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            [[ToastManager manager] showToast:@"介绍长度请控制在0-30个汉字"];
        } else {
            if (tt_byteLength == 0) {
                desp = @"  ";
            }

            // 上传
            [self uploadUserAuditContent:desp forName:NO];
        }
    }
}

/**
 *  更新用户名还是描述
 *
 *  @param nameOrDesp name or desp
 */
- (void)uploadUserAuditContent:(NSString *)content forName:(BOOL)nameOrDesp {
    if (isEmptyString(content))return;
    
    if (![TTReachability isNetworkConnected]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力，请稍后重试", nil) indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    __weak typeof(self) wself = self;
    
    void (^didCompletedBlock)(TTAccountUserEntity *, NSError *) = ^(TTAccountUserEntity *userEntity, NSError *error) {
        __strong typeof(wself) sself = wself;
        
        if (error) {
            // 名字重复的问题等错误信息，由服务端返回
            NSString *hint = [error.userInfo objectForKey:@"description"];
            if (isEmptyString(hint)) hint = [error.userInfo objectForKey:TTAccountErrMsgKey];
            if (isEmptyString(hint)) hint = NSLocalizedString(@"修改失败，请稍后重试", nil);

//            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            [[ToastManager manager] showToast:hint];
        } else {
            TTAccountUserEntity* user = [[TTAccount sharedAccount] user];
            if (user != nil) {
                user.name = userEntity.name;
                user.screenName = userEntity.screenName;
                user.userDescription = userEntity.userDescription;
                [[TTAccount sharedAccount] setUser:user];
            }

            NSString *username = [userEntity.auditInfoSet username];
            NSString *userDesp = [userEntity.auditInfoSet userDescription];
            if (!isEmptyString(username) && nameOrDesp) {
                sself.userInfo.name = username;
            }
            if (!isEmptyString(userDesp) && !nameOrDesp) {
                sself.userInfo.userDescription = userDesp;
            }

//            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"修改成功", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            [[ToastManager manager] showToast:@"修改成功"];
            
            // 使用新的数据刷新
            [sself.viewController.navigationController popViewControllerAnimated:YES];
            if(sself.viewController.delegate && [sself.viewController.delegate respondsToSelector:@selector(reloadData)]){
                [sself.viewController.delegate reloadData];
            }
        }
    };
    
    NSDictionary *params = @{(nameOrDesp ? TTAccountUserNameKey : TTAccountUserDescriptionKey) : content};
    
    [TTAccount updateUserProfileWithDict:params completion:^(TTAccountUserEntity *userEntity, NSError * _Nullable error) {
        if (!error) {
            if (didCompletedBlock) didCompletedBlock(userEntity, nil);
        } else {
            if (didCompletedBlock) didCompletedBlock(nil, error);
        }
    }];
}

#pragma mark - 键盘通知

- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    if(_isHideKeyBoard){
        return;
    }
}

@end
