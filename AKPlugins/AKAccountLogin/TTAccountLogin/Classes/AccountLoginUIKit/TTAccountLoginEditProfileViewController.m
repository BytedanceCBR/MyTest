//
//  TTAccountLoginEditProfileViewController.m
//  TTAccountLogin
//
//  Created by huic on 16/3/8.
//
//

#import "TTAccountLoginEditProfileViewController.h"
#import <TTNavigationController.h>
#import <TTIndicatorView.h>
#import <UIViewAdditions.h>
#import <NSStringAdditions.h>
#import <TTDeviceUIUtils.h>
#import <UIImage+TTThemeExtension.h>
#import <Masonry.h>
#import "TTAccountAlertView.h"



#define kTTAccountLoginUpdateAvatarActionSheetTag 10012


@interface TTAccountLoginEditProfileViewController ()
<
UIActionSheetDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>
@property (nonatomic, strong) TTAlphaThemedButton *changeHeadButton;
@property (nonatomic, strong) SSThemedButton *skipButton;
@property (nonatomic, strong) SSThemedLabel  *passwordChangeHitLabel;
@end

@implementation TTAccountLoginEditProfileViewController

@synthesize source = _source;

- (instancetype)initWithSource:(NSString *)source
{
    if (self = [super init]) {
        _source = source;
        
        if ([TTNavigationController refactorNaviEnabled] && [TTDeviceHelper isPadDevice]) {
            self.ttNeedHideBottomLine = YES;
            self.ttNeedTopExpand = NO;
            self.ttNaviTranslucent = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)source
{
    if (isEmptyString(_source)) {
        _source = @"other";
    }
    return _source;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 在账号个人设置页中，获取PV
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"profile_settings_show" dict:@{@"source":self.source}];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [TTTrackerWrapper eventV3:@"login_profile_settings_show" params:extraDict isDoubleSending:YES];
    
    [self initSubviews];
    
    self.ttNaviTranslucent = YES;
}

#pragma mark - init

- (void)initSubviews
{
    //复用Base类
    self.platformLoginView.hidden = YES;
    self.captchaInput.hidden = YES;
    
    self.mobileInput.field.textAlignment = NSTextAlignmentCenter;
    self.mobileInput.field.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.mobileInput.field.keyboardType = UIKeyboardTypeDefault;
    self.mobileInput.field.placeholder = NSLocalizedString(@"请输入用户名", nil);
    
    [self.registerButton setTitle:NSLocalizedString(@"完成", nil)
                         forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.navigationItem.rightBarButtonItem = self.closeItem;
    
    
    //顶部新增更换头像按钮
    [self.view addSubview:self.changeHeadButton];
    
    //中部新增跳过按钮
    [self.view addSubview:self.skipButton];
    
    self.passwordChangeHitLabel = [[SSThemedLabel alloc] init];
    self.passwordChangeHitLabel.textColorThemeKey = kColorText3;
    self.passwordChangeHitLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
    self.passwordChangeHitLabel.text = NSLocalizedString(@"修改密码： <我>-<设置>-<账号管理>", nil);
    [self.view addSubview:self.passwordChangeHitLabel];
    
    [self.passwordChangeHitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.skipButton.mas_bottom).with.offset([TTDeviceUIUtils tt_padding:56.f]);
    }];
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 为了适配小屏幕手机(4, 4s)
    CGFloat extraNegHeight = ([TTDeviceHelper is480Screen] ? - 10 : 0);
    
    // 上方信息区域高度占全局1:4.688
    self.upInfoContainerView.frame = self.view.bounds;
    self.upInfoContainerView.height = MAX(floor(self.view.height * kTTAccountLoginUpInfoHeightRatioInView) + extraNegHeight, kTTAccountLoginUpInfoHeight + 44);
    
    //上传头像按钮布局
    _changeHeadButton.size = CGSizeMake(kTTAccountLoginUpInfoHeight, kTTAccountLoginUpInfoHeight);
    _changeHeadButton.layer.cornerRadius = kTTAccountLoginUpInfoHeight / 2;
    _changeHeadButton.centerX = self.view.width/2;
    _changeHeadButton.bottom = self.upInfoContainerView.bottom;
    
    // 中部布局
    self.mobileInput.size = CGSizeMake(self.view.width - kTTAccountLoginInputFieldLeftMargin - kTTAccountLoginInputFieldRightMargin, kTTAccountLoginInputFieldHeight);
    self.mobileInput.top = floor(self.upInfoContainerView.bottom + self.upInfoContainerView.height * 0.35) + ((self.upInfoContainerView.height * 0.35 +extraNegHeight > 10) ? extraNegHeight : 0);
    self.mobileInput.left = kTTAccountLoginInputFieldLeftMargin;
    
    // "完成"登录按钮
    self.registerButton.size = CGSizeMake(self.view.width - kTTAccountLoginInputFieldLeftMargin - kTTAccountLoginInputFieldRightMargin, kTTAccountLoginInputFieldHeight);
    self.registerButton.top = self.mobileInput.bottom + kTTAccountLoginInputFieldVerticalMargin;
    self.registerButton.left = kTTAccountLoginInputFieldLeftMargin;
    
    //"跳过"按钮布局
    [_skipButton sizeToFit];
    _skipButton.centerX = self.view.width/2;
    _skipButton.top = self.registerButton.bottom + kTTAccountLoginLoginLabelVerticalMargin;
}

#pragma mark - Actions

- (void)rightItemClicked
{
    //注册时点关闭按钮或跳过按钮
    [self showAlertViewIfNeed];
}

- (void)changeHeadButtonClicked:(id)sender
{
    //点击上传头像
    UIActionSheet *tSheet = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        tSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册上传", nil), nil];
    }
    else {
        tSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"从相册上传", nil), nil];
    }
    
    if (tSheet) {
        tSheet.delegate = self;
        tSheet.tag = kTTAccountLoginUpdateAvatarActionSheetTag;
        [tSheet showInView:self.view];
    }
}

- (void)registerButtonClicked:(id)sender
{
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"profile_settings_click_confirm" dict:@{@"source":self.source}];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [extraDict setValue:@"confirm" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_profile_settings_click" params:extraDict isDoubleSending:YES];
    
    NSString *name = self.mobileInput.field.text;
    name = [name trimmed];
    
    if ([name isEqualToString:[[TTAccount sharedAccount] user].name]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"与原来名称相同", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    else {
        NSUInteger length = 0;
        NSCharacterSet *nameLatinCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"];
        
        for (NSUInteger i = 0; i < [name length]; i++) {
            int a = [name characterAtIndex:i];
            NSString *str = [name substringWithRange:NSMakeRange(i, 1)];
            if([str rangeOfCharacterFromSet:nameLatinCharacterSet].location != NSNotFound ||
               (a >= 0x4e00 && a < 0x9fff) /*|| strlen([str UTF8String]) >= 3*/) {
                length ++;
            } else {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"用户名仅允许中文、英文、数字、\"_\"和减号", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                return;
            }
        }
        
        if(length < 2 || length > 20) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"用户名长度请控制在2-20字", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
        else {
            NSMutableDictionary *profileDict = [NSMutableDictionary dictionaryWithCapacity:1];
            [profileDict setValue:name forKey:TTAccountUserNameKey];
            
            [TTAccount updateUserProfileWithDict:profileDict completion:^(TTAccountUserEntity *userEntity, NSError *error) {
                [self responseDidUpdateUserInfoCompletionWithError:error];
            }];
        }
    }
}

- (void)skipButtonClicked:(id)sender
{
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"profile_settings_click_skip" dict:@{@"source":self.source}];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [extraDict setValue:@"skip" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_profile_settings_click" params:extraDict isDoubleSending:YES];
    
    [self showAlertViewIfNeed];
}

- (void)showAlertViewIfNeed
{
    TTAccountAlertView *alert = [[TTAccountAlertView alloc] initWithTitle:[NSString stringWithFormat:@"确认使用头条默认用户名\"%@\"?", [[TTAccount sharedAccount] user].name] message:nil cancelBtnTitle:@"使用" confirmBtnTitle:@"去修改" animated:YES tapCompletion:^(TTAccountAlertCompletionEventType type) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            
        } else if(type == TTAccountAlertCompletionEventTypeCancel) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alert show];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet.tag == kTTAccountLoginUpdateAvatarActionSheetTag) {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                switch (buttonIndex) {
                    case 0:
                    {
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                    }
                        break;
                    case 1:
                    {
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    }
                        break;
                    default:
                        break;
                }
            }
            else {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            UIImagePickerController *tController = [[UIImagePickerController alloc] init];
            tController.delegate = self;
            tController.sourceType = sourceType;
            tController.allowsEditing = YES;
            
            [self presentViewController:tController animated:YES completion:NULL];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    // iOS 9 的系统 bug，在 iPad 不能选取图片显示区域，系统自动给截了左上角区域；
    // workaround : iPad 暂时先取 `UIImagePickerControllerOriginalImage` (会导致图片挤压变形).
    
    NSString *imageType = UIImagePickerControllerEditedImage;
    if ([TTDeviceHelper isPadDevice] && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            imageType = UIImagePickerControllerOriginalImage;
        }
    }
    UIImage *tImage = [info objectForKey:imageType];
    
    if (tImage) {
        [TTAccount startUploadUserPhoto:tImage progress:nil completion:^(TTAccountUserEntity *userEntity, NSError *error) {
            [self responseDidUploadUserPhotoCompletionWithImage:tImage error:error];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - response for update user info

- (void)responseDidUpdateUserInfoCompletionWithError:(NSError *)error
{
    if (!error) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"修改成功", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        
        //注册时用户信息正确点完成
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSString *activityTip =
        [error.userInfo objectForKey:kTTAccountLoginErrorDisplayMessageKey];
        if (isEmptyString(activityTip)) {
            activityTip = NSLocalizedString(@"修改失败,请稍后重试", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:activityTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
}

- (void)responseDidUploadUserPhotoCompletionWithImage:(UIImage *)image
                                                error:(NSError *)error
{
    NSString *notify = nil;
    if (!error) {
        [self.changeHeadButton setImage:image forState:UIControlStateNormal];
        
        notify = NSLocalizedString(@"修改头像成功", nil);;
        if (notify) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:notify indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
    } else {
        notify = [[error userInfo] objectForKey:kTTAccountLoginErrorDisplayMessageKey];
        if (isEmptyString(notify)) notify = NSLocalizedString(@"修改头像失败,请稍后重试", nil);
        if (notify) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:notify indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
    }
}

#pragma mark - Helper

- (BOOL)isContentValid
{
    return YES;
}

- (void)showAutoDismissIndicatorWithText:(NSString *)text
{
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:text indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
}

- (int)nameCharacterLength:(NSString *)c
{
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

#pragma mark - Getter/Setter

- (TTAlphaThemedButton *)changeHeadButton
{
    if (!_changeHeadButton) {
        _changeHeadButton = [[TTAlphaThemedButton alloc] init];
        _changeHeadButton.size = CGSizeMake(kTTAccountLoginUpInfoHeight, kTTAccountLoginUpInfoHeight);
        _changeHeadButton.layer.cornerRadius = kTTAccountLoginUpInfoHeight / 2;
        _changeHeadButton.clipsToBounds = YES;
        _changeHeadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _changeHeadButton.imageName = @"head_sdk_login";
        [_changeHeadButton addTarget:self action:@selector(changeHeadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeHeadButton;
}

- (SSThemedButton *)skipButton
{
    if (!_skipButton) {
        _skipButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _skipButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_skipButton setTitle:NSLocalizedString(@"跳过", nil)
                     forState:UIControlStateNormal];
        _skipButton.titleLabel.font =
        [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _skipButton.titleColorThemeKey = kColorText1;
        _skipButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
        [_skipButton addTarget:self
                        action:@selector(skipButtonClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        [_skipButton sizeToFit];
    }
    return _skipButton;
}

@end
