//
//  ArticleMobileSettingViewController.m
//  Article
//
//  Created by SunJiangting on 14-7-11.
//
//

#import "ArticleMobileSettingViewController.h"
#import <TTNavigationController.h>
#import <TTThemedAlertController.h>
#import <TTDeviceHelper.h>
#import <TTUIResponderHelper.h>
#import <TTAccountBusiness.h>
#import "TTTrackerWrapper.h"


@interface ArticleMobileSettingViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
}

@property(nonatomic, strong) SSThemedButton     *avatarButton;
@property(nonatomic, strong) SSThemedTextField  *nameField;
@property(nonatomic, strong) SSThemedImageView  *avatarImageView;
@property(nonatomic, strong) SSThemedButton * completeButton;
@property(nonatomic, strong) SSThemedLabel * avatarLabel;

@end

@implementation ArticleMobileSettingViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.state = ArticleLoginStateMobileRegister;
    
    self.navigationBar.title = NSLocalizedString(@"设置个人信息", nil);
    self.navigationBar.leftBarView = nil;
    
    self.automaticallyAdjustKeyboardOffset = YES;
    self.maximumHeightOfContent = 230;
    
    self.navigationBar.rightBarView =
    [SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:NSLocalizedString(@"跳过", nil) target:self action:@selector(skipSettingActionFired:)];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"设置个人信息", nil)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.navigationBar.rightBarView];
    
    CGFloat width = [ArticleMobileSettingViewController widthOfAvatarButton];
    self.avatarButton = [[SSThemedButton alloc] init];
    self.avatarButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.avatarButton addTarget:self action:@selector(chooseAvatarActionFired:) forControlEvents:UIControlEventTouchUpInside];
    self.avatarButton.layer.cornerRadius = width / 2;
    self.avatarButton.layer.masksToBounds = YES;
    self.avatarButton.backgroundColorThemeKey = kColorBackground4;
    self.avatarButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
    self.avatarButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.avatarButton.borderColorThemeKey = kColorLine1;
    self.avatarButton.highlightedBorderColorThemeKey = kColorLine1Highlighted;
    [self.containerView addSubview:self.avatarButton];
    
    self.avatarImageView = [[SSThemedImageView alloc] init];
    self.avatarImageView.imageName = @"camera_cellphone_setup";
    self.avatarImageView.autoresizingMask = self.avatarButton.autoresizingMask;
    self.avatarImageView.userInteractionEnabled = NO;
    //self.avatarImageView.layer.cornerRadius = 44;
    //self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor clearColor];
    [self.avatarButton addSubview:self.avatarImageView];
    [self.avatarImageView sizeToFit];
    
    self.avatarLabel = [[SSThemedLabel alloc] init];
    self.avatarLabel.text = @"上传头像";
    self.avatarLabel.font = [UIFont systemFontOfSize:[ArticleMobileSettingViewController fontSizeOfAvatarLabel]];
    self.avatarLabel.textColorThemeKey = kColorText3;
    self.avatarLabel.backgroundColor = [UIColor clearColor];
    [self.avatarButton addSubview:self.avatarLabel];
    [self.avatarLabel sizeToFit];
    
    
    self.nameField = [[SSThemedTextField alloc] init];
    self.nameField.keyboardType = UIKeyboardTypeDefault;
    self.nameField.returnKeyType = UIReturnKeyNext;
    self.nameField.placeholder = NSLocalizedString(@"请输入用户名", nil);
    self.nameField.font = [UIFont systemFontOfSize:[ArticleMobileSettingViewController fontSizeOfInputFiled]];
    self.nameField.placeholderColorThemeKey = kColorText3;
    self.nameField.textColorThemeKey = kColorText1;
    self.nameField.textAlignment = NSTextAlignmentCenter;
    [self.inputContainerView addSubview:self.nameField];
    
    self.completeButton = [self mobileButtonWithTitle:@"完 成" target:self action:@selector(completeSettingActionFired:)];
    [self.containerView addSubview:self.completeButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat width = [ArticleMobileSettingViewController widthOfAvatarButton];
    self.inputContainerView.frame = CGRectMake(0, (self.avatarButton.bottom) + 30, (self.containerView.width), [ArticleMobileSettingViewController heightOfInputField]);
    
    self.avatarButton.frame = CGRectMake(((self.containerView.width) - width) / 2, 30, width, width);
    self.avatarImageView.centerX = (self.avatarButton.width) / 2;
    self.avatarLabel.centerX = (self.avatarButton.width) / 2;
    CGFloat y = ((self.avatarButton.height) - (self.avatarImageView.height) - 8 - (self.avatarLabel.height)) / 2;
    self.avatarImageView.top = y;
    self.avatarLabel.top = (self.avatarImageView.bottom) + 8;
    self.nameField.frame = CGRectMake(10, 0, (self.inputContainerView.width) - 10, (self.inputContainerView.height));
    self.completeButton.origin = CGPointMake(0, (self.inputContainerView.bottom) + 20);
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.ttDisableDragBack = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.ttDisableDragBack = NO;
    [self.nameField becomeFirstResponder];
}

- (void)chooseAvatarActionFired:(id)sender {
    UIActionSheet *tSheet = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        tSheet = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate:self
                                    cancelButtonTitle:NSLocalizedString(@"取消", nil)
                               destructiveButtonTitle:nil
                                    otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册上传", nil), nil];
    } else {
        tSheet = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate:self
                                    cancelButtonTitle:NSLocalizedString(@"取消", nil)
                               destructiveButtonTitle:nil
                                    otherButtonTitles:NSLocalizedString(@"从相册上传", nil), nil];
    }
    
    if (tSheet) {
        tSheet.delegate = self;
        [tSheet showInView:self.view];
    }
    wrapperTrackEvent(@"xiangping", @"account_avatar");
}

- (BOOL)isContentValid
{
    return (self.nameField.text.length > 0);
}

- (void)skipSettingActionFired:(id)sender
{
    /////// 友盟统计
    wrapperTrackEvent(@"login_register", @"finish_no_name");
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"系统为您自动分配了一个用户名", nil) message:[NSString stringWithFormat:@"%@", [TTAccountManager userName]] preferredType:TTThemedAlertControllerTypeAlert];
    
    [alert addActionWithTitle:NSLocalizedString(@"就用这个", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        /// 就用这个
        [self finishUserName];
        /////// 友盟统计
        wrapperTrackEvent(@"login_register", @"default_name");
    }];
    [alert addActionWithTitle:NSLocalizedString(@"修改一下", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        if (![self.nameField isFirstResponder]) {
            [self.nameField becomeFirstResponder];
        }
        /////// 友盟统计
        wrapperTrackEvent(@"login_register", @"amend_name");
    }];
    [alert showFrom:self animated:YES];
}

- (void)completeSettingActionFired:(id)sender {
    /// 修改昵称
    int length = 0;
    NSString *name = self.nameField.text;
    if (name.length == 0) {
        [self showAutoDismissIndicatorWithText:NSLocalizedString(@"请输入用户名", nil)];
        return;
    }
    for (int idx = 1; idx <= [name length]; idx++) {
        NSRange range = NSMakeRange(idx - 1, 1);
        NSString *str = [name substringWithRange:range];
        int tmpLength = [self nameCharacterLength:str];
        if (tmpLength == 0) {
            [self showAutoDismissIndicatorWithText:NSLocalizedString(@"用户名仅允许中文、英文、数字、\"_\"和减号", nil)];
            return;
        } else {
            length += tmpLength;
        }
    }
    
    if (length < 2 || length > 20) {
        [self showAutoDismissIndicatorWithText:NSLocalizedString(@"用户名长度请控制在2-20字", nil)];
    } else {
        [self showWaitingIndicator];
        
        NSMutableDictionary *profileDict = [NSMutableDictionary dictionary];
        [profileDict setValue:name forKey:TTAccountUserNameKey];
        [TTAccountManager startUpdateUserInfo:profileDict startBlock:nil completion:^(TTAccountUserEntity *userEntity, NSError *error) {
            [self respondsToAccountUserInfoChanged:error];
        }];
        
        self.navigationBar.userInteractionEnabled = NO;
    }
}

#pragma mark - TTAccountMulticastProtocol

- (void)respondsToAccountUserInfoChanged:(NSError *)error
{
    self.navigationBar.userInteractionEnabled = YES;
    if (error) {
        [self dismissWaitingIndicatorWithError:error];
    } else {
        /// 修改成功
        [self finishUserName];
        /////// 友盟统计
        wrapperTrackEvent(@"login_register", @"register_finish");
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        /// 就用这个
        [self finishUserName];
        /////// 友盟统计
        wrapperTrackEvent(@"login_register", @"default_name");
    } else {
        if (![self.nameField isFirstResponder]) {
            [self.nameField becomeFirstResponder];
        }
        /////// 友盟统计
        wrapperTrackEvent(@"login_register", @"amend_name");
    }
}

- (void)finishUserName {
    [self backToMainViewControllerAnimated:YES completion:self.completion];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0: {
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                } break;
                case 1: {
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                } break;
                default:
                    break;
            }
        } else {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        UIImagePickerController *tController = [[UIImagePickerController alloc] init];
        tController.delegate = self;
        tController.sourceType = sourceType;
        tController.allowsEditing = YES;
        
        TTNavigationController *nav = (TTNavigationController *)[TTUIResponderHelper topViewControllerFor: self];
        if ([nav isKindOfClass:[UINavigationController class]]) {
            [nav presentViewController:tController animated:YES completion:NULL];
        } else {
            [nav.navigationController presentViewController:tController animated:YES completion:NULL];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *tImage = [info objectForKey:UIImagePickerControllerEditedImage];
    //self.avatarImageView.image = tImage;
    self.avatarImageView.hidden = YES;
    self.avatarLabel.hidden = YES;
    [self.avatarButton setBackgroundImage:tImage forState:UIControlStateNormal];
    if (tImage) {
        
        [TTAccountManager startUploadUserPhoto:tImage completion:^(TTAccountUserEntity *userEntity, NSError *error) {
            
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (int)nameCharacterLength:(NSString *)c {
    int length = 0;
    NSCharacterSet *nameLatinCharacterSet =
    [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"];
    if ([c rangeOfCharacterFromSet:nameLatinCharacterSet].location != NSNotFound) {
        length = 1;
    } else {
        NSData *data = [c dataUsingEncoding:NSUTF8StringEncoding];
        NSString *desc = [[data description] substringWithRange:NSMakeRange(1, data.description.length - 2)];
        if (([desc compare:@"e2ba80" options:NSCaseInsensitiveSearch] == NSOrderedDescending &&
             [desc compare:@"e2bfcf" options:NSCaseInsensitiveSearch] == NSOrderedAscending) ||
            ([desc compare:@"e38690" options:NSCaseInsensitiveSearch] == NSOrderedDescending &&
             [desc compare:@"e3869f" options:NSCaseInsensitiveSearch] == NSOrderedAscending) ||
            ([desc compare:@"e38780" options:NSCaseInsensitiveSearch] == NSOrderedDescending &&
             [desc compare:@"e387cf" options:NSCaseInsensitiveSearch] == NSOrderedAscending) ||
            ([desc compare:@"e39080" options:NSCaseInsensitiveSearch] == NSOrderedDescending &&
             [desc compare:@"e4b77f" options:NSCaseInsensitiveSearch] == NSOrderedAscending) ||
            ([desc compare:@"e4b880" options:NSCaseInsensitiveSearch] == NSOrderedDescending &&
             [desc compare:@"ea807f" options:NSCaseInsensitiveSearch] == NSOrderedAscending) ||
            ([desc compare:@"efa480" options:NSCaseInsensitiveSearch] == NSOrderedDescending &&
             [desc compare:@"efac7f" options:NSCaseInsensitiveSearch] == NSOrderedAscending)) {
                
                length = 1;
            }
    }
    return length;
}

+ (CGFloat)widthOfAvatarButton
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 100.f;
    } else {
        return 88.f;
    }
}

+ (CGFloat)fontSizeOfAvatarLabel
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 12.f;
    } else {
        return 10.f;
    }
}

@end
