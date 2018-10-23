//
//  TTEditUserProfileViewController.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditUserProfileViewController.h"
#import "SSNavigationBar.h"

#import "TTEditUserProfileViewModel.h"
#import "TTEditUGCProfileViewModel.h"
#import "TTEditPGCProfileViewModel.h"
#import <TTAccountBusiness.h>
#import "SSMyUserModel.h"

#import <TTAlphaThemedButton.h>
#import <UIButton+TTAdditions.h>
#import <TTUIResponderHelper.h>

#import "TTEditUserProfileViewModel+Network.h"



/**
 *  编辑资料完成后，向h5或rn页面发送通知
 *  userInfo: {@"user_info": ***}
 */
NSString *const kTTEditUserInfoDidFinishNotificationName = @"kTTEditUserInfoDidFinishNotificationName";
NSString *const kTTUserEditableInfoKey = @"user_info";

@interface TTEditUserProfileViewController ()
@property (nonatomic, strong) TTEditUserProfileViewModel *profileViewModal;
@end

@implementation TTEditUserProfileViewController
- (instancetype)init {
    if ((self = [super initWithRouteParamObj:nil])) {
        _userType = [TTAccountManager accountUserType];
    }
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _userType = [TTAccountManager accountUserType];
    }
    return self;
}

- (instancetype)initWithUserType:(TTAccountUserType)userType {
    if ((self = [self init])) {
        _userType = userType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup views
    [self setupContainerView];
    
    // setup navigationBar
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"编辑资料",nil)];
    TTAlphaThemedButton *backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.enableHighlightAnim = YES;
    backButton.imageName = @"lefterbackicon_titlebar";
    backButton.frame = CGRectMake(0, 0, 24, 24);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -17, 0, 0);
    backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [backButton addTarget:self action:@selector(editProfileViewControllerDidTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    if (_userType == TTAccountUserTypePGC) {
        // 不可保存时按钮文字颜色为kColorText9，可保存时kColorText1
        TTAlphaThemedButton *saveButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        saveButton.enableHighlightAnim = YES;
        saveButton.backgroundColor = [UIColor clearColor];
        saveButton.titleLabel.font = [UIFont systemFontOfSize:32.f/2];
        saveButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        saveButton.titleColorThemeKey = kColorText1;
        saveButton.disabledTitleColorThemeKey = kColorText9;
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton sizeToFit];
        saveButton.height = 44.f;
        [saveButton addTarget:self action:@selector(didTapSavePGCInfoButton:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
        
        [self updateSaveButtonStatus];
    }
    
    // initialize loadData
    [self.profileViewModal reloadViewModel];
    [self loadRequest];
    
}

- (void)setupContainerView {
    [self.view addSubview:self.profileView];
    CGFloat top = [self navigationBarHeight];
    self.profileView.frame = CGRectMake(0, top, self.view.width, self.view.height - top);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.profileView willAppear];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.profileView willDisappear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.profileView didAppear];
    
    if (_delegate && [_delegate respondsToSelector:@selector(hideDescriptionCellInEditUserProfileController:)]) {
        if ([_delegate hideDescriptionCellInEditUserProfileController:self]) {
            
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.profileView didDisappear];
}

#pragma safeAreaInset
- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    CGFloat top = [self navigationBarHeight];
    self.profileView.frame = CGRectMake(0, top, self.view.width, self.view.height - top);
}

#pragma mark - update save button status

- (void)updateSaveButtonStatus {
    TTAlphaThemedButton *saveButton = self.navigationItem.rightBarButtonItem.customView;
    if ([saveButton isKindOfClass:[TTAlphaThemedButton class]]) {
        BOOL isModified = [self.profileViewModal hasModifiedUserAuditInfo];
        saveButton.enabled = isModified;
    }
}

#pragma mark - network

- (void)loadRequest {
    if ([TTAccountManager isLogin]) {
        __weak typeof(self) wself = self;
        
        [TTAccount getUserAuditInfoIgnoreDispatchWithCompletion:^(TTAccountUserEntity *userEntity, NSError *error) {
            __weak typeof(wself) sself = wself;
            if (!error) {
                TTAccountUserAuditSet *newAuditInfo = [userEntity.auditInfoSet copy];
                sself.profileViewModal.editableAuditInfo.isAuditing  = [newAuditInfo isAuditing];
                sself.profileViewModal.editableAuditInfo.editEnabled = [newAuditInfo modifyUserInfoEnabled];
                sself.profileViewModal.editableAuditInfo.name        = [newAuditInfo username];
                sself.profileViewModal.editableAuditInfo.avatarURL  = [newAuditInfo userAvatarURLString];
                sself.profileViewModal.editableAuditInfo.userDescription = [newAuditInfo userDescription];
                
                //改版个人主页之后新增
                sself.profileViewModal.editableAuditInfo.gender = [TTAccountManager currentUser].gender;
                sself.profileViewModal.editableAuditInfo.birthday = [TTAccountManager currentUser].birthday;
                sself.profileViewModal.editableAuditInfo.area = [TTAccountManager currentUser].area;
                
                [sself.profileViewModal reloadViewModel];
            }
        }];
    }
}

- (void)uploadPGCAuditInfo {
    if(!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力，请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    [self.profileViewModal uploadAllUserProfileInfoWithStartBlock:nil completion:^(TTAccountUserEntity *userEntity, NSError *error) {
        if (!error) {
            
            [self.profileViewModal refreshEditableUserInfo];
            
            [self popViewController];
            
        } else {
            NSString *hint = [error.userInfo objectForKey:@"description"];
            if (isEmptyString(hint)) hint = [error.userInfo objectForKey:TTAccountErrMsgKey];
            if (isEmptyString(hint)) hint = [error.userInfo objectForKey:@"hint"];
            if (isEmptyString(hint)) hint = NSLocalizedString(@"修改失败，请稍后重试", nil);
            
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
    }];
}

#pragma mark - events

- (void)popViewController {
    UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor:self];
    [navController popViewControllerAnimated:YES];
}

- (void)goBack:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(editUserProfileController:goBack:)]) {
        [_delegate editUserProfileController:self goBack:sender];
    } else {
        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
        [nav popViewControllerAnimated:YES];
    }
}

- (void)editProfileViewControllerDidTapBackButton:(id)sender {
    NSDictionary *userInfoDict = [[TTAccountManager currentUser].auditInfoSet toOriginalDictionary];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:userInfoDict forKey:kTTUserEditableInfoKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTEditUserInfoDidFinishNotificationName object:self userInfo:userInfo];
    
    if (_userType == TTAccountUserTypePGC &&
        [_profileViewModal isKindOfClass:[TTEditPGCProfileViewModel class]]) {
        TTEditPGCProfileViewModel *pgcViewModel = (TTEditPGCProfileViewModel *)_profileViewModal;
        if ([pgcViewModel hasModifiedUserAuditInfo]) {
            [self showSavingPGCInfoViewForBack:YES];
        } else {
            [self popViewController];
        }
    } else {
        [self popViewController];
    }
}

- (void)didTapSavePGCInfoButton:(id)sender {
    if (_userType == TTAccountUserTypePGC && [_profileViewModal isKindOfClass:[TTEditPGCProfileViewModel class]]) {
        TTEditPGCProfileViewModel *pgcViewModel = (TTEditPGCProfileViewModel *)_profileViewModal;
        if ([pgcViewModel hasModifiedUserAuditInfo]) {
            [self showSavingPGCInfoViewForBack:NO];
            
            wrapperTrackEvent(@"edit_profile", @"submit");
        }
    }
}

/**
 *  弹出是否保存PGC用户信息
 *
 *  @param backOrSave 区分是返回还是保存事件
 */
- (void)showSavingPGCInfoViewForBack:(BOOL)backOrSave {
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:NSLocalizedString(@"每个月只能修改一次，确认保\n存修改后的资料吗？", nil) preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        wrapperTrackEvent(@"pgc_profile_confirm", @"cancel");
        
        if (backOrSave) {
            [self popViewController];
        }
    }];
    [alert addActionWithTitle:NSLocalizedString(@"保存", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        wrapperTrackEvent(@"pgc_profile_confirm", @"confirm");
        
        [self uploadPGCAuditInfo];
    }];
    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
}

#pragma mark - lazied load of properties

- (TTEditUserProfileViewModel *)profileViewModal {
    if (!_profileViewModal) {
        switch (self.userType) {
            case TTAccountUserTypePGC: {
                _profileViewModal = [[TTEditPGCProfileViewModel alloc] initWithHostViewController:self];
                break;
            }
            case TTAccountUserTypeVisitor:
            case TTAccountUserTypeUGC: {
                _profileViewModal = [[TTEditUGCProfileViewModel alloc] initWithHostViewController:self];
                break;
            }
            default: {
                _profileViewModal = [[TTEditUserProfileViewModel alloc] initWithHostViewController:self];
                break;
            }
        }
    }
    return _profileViewModal;
}

- (TTEditUserProfileView *)profileView {
    return self.profileViewModal.profileView;
}
@end

