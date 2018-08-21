//
//  TTProfileFillFrontView.m
//  Article
//
//  Created by jinqiushi on 2017/10/27.
//

#import "TTProfileFillFrontView.h"
#import <TTAccountBusiness.h>
#import "UITextField+TTBytesLimit.h"
#import "TTProfileFillManager.h"
#import "TTImagePickerController.h"
#import "UIView+TTImagePickerViewController.h"
#import "TTImageCropperViewController.h"
#import "NSString+TTLength.h"
#import <Lottie/Lottie.h>
#import "NSString+UGCUtils.h"
#import <NSObject+FBKVOController.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <SDWebImage/UIView+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <TTThemeManager.h>
#import "TTKitchenHeader.h"
#import "TTDeviceHelper.h"
#import <SDWebImage/UIView+WebCache.h>//TODO
#import <SDWebImage/UIImageView+WebCache.h>
#import <BDWebImage/SDWebImageAdapter.h>


extern NSString *const kTTUserEditableInfoKey;
extern NSString *const kTTEditUserInfoDidFinishNotificationName;

typedef NS_ENUM(NSUInteger, TextFieldBecomeFirstResponderFrom)
{
    TextFieldBecomeFirstResponderFromTap = 0,
    TextFieldBecomeFirstResponderFromPhotoPicker = 1,
};

@interface TTProfileFillFrontView ()<UITextFieldDelegate, TTImagePickerControllerDelegate, TTImageCropperDelegate>

@property (nonatomic, strong) SSThemedView *separatorLineView;

@property (nonatomic, strong) LOTAnimationView *iconAnimationView;

@property (nonatomic, strong) SSThemedImageView *indicateNameView;

@property (nonatomic, strong) SSThemedLabel *indicateAvatarLabel;

@property (nonatomic, assign) BOOL iconViewAvatarChanged;

@property (nonatomic, assign) BOOL userNameChanged;

@property (nonatomic, assign) BOOL hasShownIndicateNameAnimation;

@property (nonatomic, assign) TextFieldBecomeFirstResponderFrom textFieldAwakeFrom;

@property (nonatomic, copy) NSString *originalName;

@end

@implementation TTProfileFillFrontView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initActions];
    }
    return self;
}

- (void)initActions
{
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.topPointerView];
    
    [self addSubview:self.bottomPointerView];
    
    [self addSubview:self.backgroundView];
    
    [self.backgroundView addSubview:self.titleLabel];
    
    [self.backgroundView addSubview:self.iconImageView];
    
    [self.backgroundView addSubview:self.iconAnimationView];
    
    [self.backgroundView addSubview:self.indicateNameView];
    
    [self.backgroundView addSubview:self.nameTextField];
    
    [self.backgroundView addSubview:self.separatorLineView];
    
    [self.backgroundView addSubview:self.indicateCommonLabel];
    
    [self.backgroundView addSubview:self.indicateAlertLabel];
    
    [self.backgroundView addSubview:self.saveButton];
    
    [self.backgroundView addSubview:self.closeButton];
    
    [self.backgroundView addSubview:self.indicateAvatarLabel];
    
    [self updateIndicateText];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUITextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:self.nameTextField];

    [self.KVOController observe:self keyPath:@"userNameChanged" options:NSKeyValueObservingOptionNew action:@selector(saveStatusKVO)];
    [self.KVOController observe:self keyPath:@"iconViewAvatarChanged" options:NSKeyValueObservingOptionNew action:@selector(saveStatusKVO)];
}

- (void)saveStatusKVO
{
    if (self.userNameChanged || self.iconViewAvatarChanged) {
        [self.saveButton setEnabled:YES];
    } else {
        [self.saveButton setEnabled:NO];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)actionsAfterShow
{
    if(isEmptyString(self.iconImageView.sda_imageURL.absoluteString) ) {
        //没有自定义头像
        [self startCameraAnimation];
    } else if (isEmptyString(self.nameTextField.text)) {
        [self checkAnddoIndicateNameAnimation];
    }
}

- (void)startCameraAnimation
{
    self.iconImageView.hidden = YES;
    self.iconAnimationView.hidden = NO;
    [self.iconAnimationView play];
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    [self.iconImageView sda_setImageWithURL:[NSURL URLWithString:avatarUrl] ];
    self.iconImageView.hidden = NO;
    self.iconAnimationView.hidden = YES;
    self.indicateAvatarLabel.hidden = YES;
}

- (void)setUserName:(NSString *)userName
{
    self.nameTextField.text = userName;
    [self updateIndicateText];
    self.originalName = userName;
}

#pragma mark - Actions

- (void)setIndicateText:(NSString *)text isAlert:(BOOL)isAlert
{
    if (isAlert) {
        self.indicateAlertLabel.hidden = NO;
        self.indicateCommonLabel.hidden = YES;
        self.indicateAlertLabel.text = text;
    } else {
        self.indicateCommonLabel.hidden = NO;
        self.indicateAlertLabel.hidden = YES;
        self.indicateCommonLabel.text = text;
    }
}

- (void)updateIndicateText
{
    NSInteger textLength = ([self.nameTextField bytesWithoutUndeterminedForNotEnglishLanguage]+1)/2;//备注，又改成向上取整了,在这种计算方式下，3个英文字符显示: 支持。。2/10
    NSString *tips = [[TTProfileFillManager manager].profileModel.tips length] ? [TTProfileFillManager manager].profileModel.tips : @"支持中英文、数字";
    NSString *str = [NSString stringWithFormat:@"%@ %ld/10",tips,(long)textLength];
    [self setIndicateText:str isAlert:NO];
}

- (void)iconTaped:(id)sender
{
    [self.viewController.view endEditing:YES];
    [self.iconAnimationView stop];
    [self showImagePicker];
}

- (void)showImagePicker
{
    TTImagePickerController *imgPick = [[TTImagePickerController alloc] initWithDelegate:self];
    imgPick.maxImagesCount = 1;
    [imgPick presentOn:self.ttImagePickerViewController];
}

- (void)checkAnddoIndicateNameAnimation
{
    if (isEmptyString(self.nameTextField.text) && self.hasShownIndicateNameAnimation == NO) {
        CGRect frame = self.indicateNameView.frame;
        self.indicateNameView.layer.anchorPoint = CGPointMake(0, 0.5);
        self.indicateNameView.frame = frame;
        self.indicateNameView.hidden = NO;
        if (@available(iOS 9.0, *)){
            CASpringAnimation *scaleSpringAnimation = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
            scaleSpringAnimation.fromValue = @0;
            scaleSpringAnimation.toValue = @1;
            scaleSpringAnimation.damping = 20;
            scaleSpringAnimation.stiffness = 240;
            scaleSpringAnimation.duration = scaleSpringAnimation.settlingDuration;
            [self.indicateNameView.layer addAnimation:scaleSpringAnimation forKey:scaleSpringAnimation.keyPath];
            self.hasShownIndicateNameAnimation = YES;
        }else{
            self.indicateNameView.transform = CGAffineTransformMakeScale(0.0, 0.0);
            [UIView animateWithDuration:0.5 animations:^{
                self.indicateNameView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                self.hasShownIndicateNameAnimation = YES;
            }];
        }
    }
}

- (void)closeButtonTapped:(id)sender
{
    [TTTrackerWrapper eventV3:@"profile_modify_close" params:@{@"refer":@"comment_list",@"demand_id":@100379}];
    if (self.profileFillViewController) {
        [self.profileFillViewController closeAction:YES];
    }
}

- (void)backgroundViewTaped:(id)sender
{
    [self.nameTextField resignFirstResponder];
}

- (void)saveButtonTapped:(id)sender
{
    if ((isEmptyString(self.nameTextField.text) || !self.userNameChanged) && !self.iconViewAvatarChanged) {
        //啥也没改，直接关了
        [TTTrackerWrapper eventV3:@"profile_modify_save" params:@{@"refer":@"comment_list",@"profile_item":@"none",@"demand_id":@100379}];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"已保存" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        if (self.profileFillViewController) {
            [self.profileFillViewController closeAction:YES];
        }
    } else {
        //其他情况都需要网络交互
        //在这处理埋点，然后统一处理提示
        if (!isEmptyString(self.nameTextField.text) && self.userNameChanged && self.iconViewAvatarChanged) {
            //都改
            [TTTrackerWrapper eventV3:@"profile_modify_save" params:@{@"refer":@"comment_list",@"profile_item":@"nickname_avatar",@"demand_id":@100379}];
        } else if ((isEmptyString(self.nameTextField.text) || !self.userNameChanged) && self.iconViewAvatarChanged) {
            //只改头像
            [TTTrackerWrapper eventV3:@"profile_modify_save" params:@{@"refer":@"comment_list",@"profile_item":@"avatar",@"demand_id":@100379}];
        } else if (!isEmptyString(self.nameTextField.text) && self.userNameChanged  && !self.iconViewAvatarChanged) {
            //只改名字
            [TTTrackerWrapper eventV3:@"profile_modify_save" params:@{@"refer":@"comment_list",@"profile_item":@"nickname",@"demand_id":@100379}];
        }
        [self endEditing:YES];
        
        if (!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            return;
        }
        
        TTIndicatorView *indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:@"正在上传" indicatorImage:nil dismissHandler:nil];
        indicatorView.autoDismiss = NO;
        [indicatorView showFromParentView:self];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        if (!isEmptyString(self.nameTextField.text) && self.userNameChanged) {
            [[TTProfileFillManager manager] presetUserName:self.nameTextField.text];
        }
        [[TTProfileFillManager manager] confirmUserIconAndNameCompletion:^(TTAccountUserEntity *aModel, NSError *error) {
            [[UIApplication sharedApplication]endIgnoringInteractionEvents];
            [indicatorView dismissFromParentView];
            
            if (!error) {
                //成功情况埋点
                if (!isEmptyString(self.nameTextField.text) && self.userNameChanged && self.iconViewAvatarChanged) {
                    //都改
                    [TTTrackerWrapper eventV3:@"profile_complete" params:@{@"refer":@"comment_list",@"profile_item":@"nickname_avatar",@"info":@"success",@"demand_id":@100379}];
                } else if ((isEmptyString(self.nameTextField.text) || !self.userNameChanged) && self.iconViewAvatarChanged) {
                    //只改头像
                    [TTTrackerWrapper eventV3:@"profile_complete" params:@{@"refer":@"comment_list",@"profile_item":@"avatar",@"info":@"success",@"demand_id":@100379}];
                } else if (!isEmptyString(self.nameTextField.text) && self.userNameChanged  && !self.iconViewAvatarChanged) {
                    //只改名字
                    [TTTrackerWrapper eventV3:@"profile_complete" params:@{@"refer":@"comment_list",@"profile_item":@"nickname",@"info":@"success",@"demand_id":@100379}];
                }
                
                //成功情况，收起面板并弹出成功toast
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"已保存" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                if (self.profileFillViewController) {
                    [self.profileFillViewController closeAction:YES];
                }
                //Notification
                NSDictionary *userInfoDict = [[TTAccountManager currentUser].auditInfoSet toOriginalDictionary];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:userInfoDict forKey:kTTUserEditableInfoKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTEditUserInfoDidFinishNotificationName object:self userInfo:userInfo];
                
            } else {
                
                //失败情况，本页面给提示，不收起面板
                NSString *hint = [error.userInfo objectForKey:@"description"];
                if (isEmptyString(hint)) {
                    //toast提示
                    hint = NSLocalizedString(@"修改失败，请稍后重试", nil);
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                } else {
                    [self setIndicateText:hint isAlert:YES];
                }
                
                //失败情况埋点
                if (!isEmptyString(self.nameTextField.text) && self.userNameChanged && self.iconViewAvatarChanged) {
                    //都改
                    [TTTrackerWrapper eventV3:@"profile_complete" params:@{@"refer":@"comment_list",@"profile_item":@"nickname_avatar",@"info":hint,@"demand_id":@100379}];
                } else if ((isEmptyString(self.nameTextField.text) || !self.userNameChanged) && self.iconViewAvatarChanged) {
                    //只改头像
                    [TTTrackerWrapper eventV3:@"profile_complete" params:@{@"refer":@"comment_list",@"profile_item":@"avatar",@"info":hint,@"demand_id":@100379}];
                } else if (!isEmptyString(self.nameTextField.text) && self.userNameChanged  && !self.iconViewAvatarChanged) {
                    //只改名字
                    [TTTrackerWrapper eventV3:@"profile_complete" params:@{@"refer":@"comment_list",@"profile_item":@"nickname",@"info":hint,@"demand_id":@100379}];
                }
            }
        }];
    }
    
}

- (NSString *)placeHolderString
{
    NSString *origStr = [TTAccountManager userName];
    return [origStr ellipsisStringWithFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17.0]] constraintsWidth:self.backgroundView.width - 2 *[TTDeviceUIUtils tt_newPadding:25.0+64.0+10.0]];
}

#pragma mark - TTImagePickerControllerDelegate

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAssetModel *> *)assets
{
    UIImage *image = [photos lastObject];
    [self cropImageAction:image];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info
{
    [self cropImageAction:photo];
}
- (void)cropImageAction:(UIImage *)photo
{
    TTImageCropperViewController *imgCropperVC = [[TTImageCropperViewController alloc] initWithImage:photo cropFrame:CGRectMake(0,([UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width)/2.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width) limitScaleRatio:3.0];
    imgCropperVC.delegate = self;
    [self.viewController presentViewController:imgCropperVC animated:YES completion:^{
        // TO DO
    }];
}

#pragma mark - TTImageCropperDelegate
- (void)imageCropper:(TTImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [cropperViewController dismissViewControllerAnimated:YES
                                              completion:^{
                                                  [self checkAnddoIndicateNameAnimation];
                                              }];
    
    self.iconImageView.image = editedImage;
    self.iconImageView.hidden = NO;
    self.iconAnimationView.hidden = YES;
    self.indicateAvatarLabel.hidden = YES;
    self.iconViewAvatarChanged = YES;
    
    if (![[self.iconImageView.layer sublayers] count]) {
        CALayer *fivePercentMask = [[CALayer alloc] init];
        fivePercentMask.frame = self.iconImageView.layer.bounds;
        fivePercentMask.cornerRadius = self.iconImageView.layer.cornerRadius;
        fivePercentMask.masksToBounds = YES;
        fivePercentMask.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05].CGColor;
        [self.iconImageView.layer addSublayer:fivePercentMask];
    }
    //焦点移到输入框
    if ([self.nameTextField.text length] == 0) {
        self.textFieldAwakeFrom = TextFieldBecomeFirstResponderFromPhotoPicker;
        [self.nameTextField becomeFirstResponder];
    }
    //直接先上传头像
    [[TTProfileFillManager manager] uploadUserIcon:editedImage completion:nil];
}

- (void)imageCropperDidCancel:(TTImageCropperViewController *)cropperViewController
{
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.textFieldAwakeFrom == TextFieldBecomeFirstResponderFromTap) {
        //点过来的，清除placeholder，消失黑色指示框
        if([TTDeviceHelper OSVersionNumber] < 9.0) {
            //对于iOS8.1系统的光标靠左问题。采用placeholder为一个空格的trick方法
            self.nameTextField.placeholder = @" ";
        } else {
            self.nameTextField.placeholder = @"";
        }
        self.indicateNameView.hidden = YES;
    } else if (self.textFieldAwakeFrom == TextFieldBecomeFirstResponderFromPhotoPicker){
        //选完头像过来的，保留placeholder，不处理黑色指示框
        self.nameTextField.placeholder = [self placeHolderString];
        //fromTap是默认状态，把这个字段设会默认的fromeTap
        self.textFieldAwakeFrom = TextFieldBecomeFirstResponderFromTap;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.nameTextField.placeholder = [self placeHolderString];
    if (isEmptyString(self.nameTextField.text)
        && !isEmptyString(self.originalName)) {
        //如果是之前有名字的，在这个页面删光了名字，但是点了出去失去焦点，自动恢复原来的名字
        [self setUserName:self.originalName];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextField resignFirstResponder];
    return YES;
}

- (void)handleUITextFieldTextDidChangeNotification:(id)sender
{
    [self updateIndicateText];
    self.indicateNameView.hidden = YES;
    self.userNameChanged = YES;
    if([TTDeviceHelper OSVersionNumber] < 9.0) {
        //对于iOS8.1系统的光标靠左问题。采用placeholder为一个空格的trick方法
        self.nameTextField.placeholder = @" ";
    } else {
        self.nameTextField.placeholder = @"";
    }
    if ([self.nameTextField.text length] == 0) {
        self.userNameChanged = NO;
    }
}

#pragma mark - Getter

- (SSThemedImageView *)topPointerView
{
    if (!_topPointerView) {
        _topPointerView = [[SSThemedImageView alloc] init];
        _topPointerView.imageName = @"profile_fill_arrow_down_guide";
        _topPointerView.top = 0;
        _topPointerView.width = [TTDeviceUIUtils tt_newPadding:17.0];
        _topPointerView.height = [TTDeviceUIUtils tt_newPadding:7.0];
        _topPointerView.left = [TTDeviceUIUtils tt_newPadding:16.0];
        _topPointerView.hidden = YES;
    }
    return _topPointerView;
}

- (SSThemedImageView *)bottomPointerView
{
    if (!_bottomPointerView) {
        _bottomPointerView = [[SSThemedImageView alloc] init];
        _bottomPointerView.imageName = @"profile_fill_arrow_down_guide";
        _bottomPointerView.top = [TTDeviceUIUtils tt_newPadding:283.0+7.0];
        _bottomPointerView.width = [TTDeviceUIUtils tt_newPadding:17.0];
        _bottomPointerView.height = [TTDeviceUIUtils tt_newPadding:7.0];
        _bottomPointerView.left = [TTDeviceUIUtils tt_newPadding:16.0];
        _bottomPointerView.hidden = YES;
        _bottomPointerView.transform = CGAffineTransformMakeScale(1.0, -1.0);
    }
    return _bottomPointerView;
}

- (SSThemedView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, [TTDeviceUIUtils tt_newPadding:7.0], self.width, [TTDeviceUIUtils tt_newPadding:283.0])];
        _backgroundView.backgroundColorThemeKey = kColorBackground4;
        _backgroundView.layer.cornerRadius = 6.0;
        UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTaped:)];
        [_backgroundView addGestureRecognizer:backgroundTap];
    }
    return _backgroundView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, [TTDeviceUIUtils tt_newPadding:28.0], self.backgroundView.width, [TTDeviceUIUtils tt_newPadding:17.0])];
        _titleLabel.text = [[TTProfileFillManager manager].profileModel.title length] ? [TTProfileFillManager manager].profileModel.title:@"完善资料可获更多点赞";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17.0]];
    }
    return _titleLabel;
}

- (SSThemedImageView *)iconImageView
{
    if (!_iconImageView) {
        CGFloat iconSize = [TTDeviceUIUtils tt_newPadding:80.0];
        _iconImageView = [[SSThemedImageView alloc]initWithFrame:CGRectMake(0, [TTDeviceUIUtils tt_newPadding:69.0],iconSize , iconSize)];
        _iconImageView.centerX = self.backgroundView.width/2.0;
        _iconImageView.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:40.0];
        _iconImageView.contentMode =  UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.userInteractionEnabled = YES;
        //增加iconImageView的操作代码
        UITapGestureRecognizer *iconTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTaped:)];
        [_iconImageView addGestureRecognizer:iconTapGesture];
    }
    return _iconImageView;
}

- (SSThemedTextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [[SSThemedTextField alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:20.0], [TTDeviceUIUtils tt_newPadding:169.0], self.backgroundView.width - 2 * [TTDeviceUIUtils tt_newPadding:20.0], [TTDeviceUIUtils tt_newPadding:18.0])];
        _nameTextField.placeholder = [self placeHolderString];
        _nameTextField.textAlignment = NSTextAlignmentCenter;
        _nameTextField.placeholderColorThemeKey = kColorText3;
        _nameTextField.textColorThemeKey = kColorText1;
        _nameTextField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17.0]];
        _nameTextField.delegate = self;
        _nameTextField.returnKeyType = UIReturnKeyDone;
        self.textFieldAwakeFrom = TextFieldBecomeFirstResponderFromTap;
        [_nameTextField limitTextLength:20];
    }
    return _nameTextField;
}

- (SSThemedView *)separatorLineView
{
    if (!_separatorLineView) {
        _separatorLineView = [[SSThemedView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:20.0], [TTDeviceUIUtils tt_newPadding:198.0], self.backgroundView.width - 2* [TTDeviceUIUtils tt_newPadding:20.0], 1.0)];
        _separatorLineView.backgroundColorThemeKey = kColorLine7;
    }
    return _separatorLineView;
}

- (SSThemedLabel *)indicateCommonLabel
{
    if (!_indicateCommonLabel) {
        _indicateCommonLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, [TTDeviceUIUtils tt_newPadding:203.0], self.backgroundView.width, [TTDeviceUIUtils tt_newPadding:12.0])];
        _indicateCommonLabel.text = @"";
        _indicateCommonLabel.textColorThemeKey = kColorText3;
        _indicateCommonLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.0]];
        _indicateCommonLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _indicateCommonLabel;
}

- (SSThemedLabel *)indicateAlertLabel
{
    if (!_indicateAlertLabel) {
        _indicateAlertLabel = [[SSThemedLabel alloc] initWithFrame:self.indicateCommonLabel.frame];
        _indicateAlertLabel.text = @"";
        _indicateAlertLabel.textColorThemeKey = kColorText4;
        _indicateAlertLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.0]];
        _indicateAlertLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _indicateAlertLabel;
}

- (SSThemedButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [[SSThemedButton alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:93.0], [TTDeviceUIUtils tt_newPadding:227.0],self.backgroundView.width - 2*[TTDeviceUIUtils tt_newPadding:93.0], [TTDeviceUIUtils tt_newPadding:36.0])];
        _saveButton.titleColorThemeKey = kColorText12;
        _saveButton.disabledTitleColorThemeKey = kColorText12Disabled;
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.0]];
        NSString *title = [[TTProfileFillManager manager].profileModel.save length]?[TTProfileFillManager manager].profileModel.save:@"保存";
        [_saveButton setTitle:title forState:UIControlStateNormal];
        _saveButton.layer.cornerRadius = 4.0;
        _saveButton.clipsToBounds = YES;
        [_saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if ([[KitchenMgr getString:kKCUGCFollowButtonColorStyle] isEqualToString:@"red"]) {
            _saveButton.backgroundColorThemeKey = kColorBackground7;
            _saveButton.disabledBackgroundColorThemeKey = kColorBackground7Disabled;
        } else {
            _saveButton.backgroundColorThemeKey = kColorBackground8;
            _saveButton.disabledBackgroundColorThemeKey = kColorBackground8Disabled;
        }
        
        [_saveButton setEnabled:NO];

    }
    return _saveButton;
}

- (SSThemedButton *)closeButton
{
    if (!_closeButton) {
        CGFloat clsRDistance = [TTDeviceUIUtils tt_newPadding:12.0];
        CGFloat clsW = [TTDeviceUIUtils tt_newPadding:10.0];
        _closeButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(self.backgroundView.width - clsRDistance - clsW, clsRDistance, clsW, clsW)];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-[TTDeviceUIUtils tt_newPadding:12.0], -[TTDeviceUIUtils tt_newPadding:18.0], -[TTDeviceUIUtils tt_newPadding:18.0], -[TTDeviceUIUtils tt_newPadding:12.0]);
        _closeButton.backgroundImageName = @"profile_fill_close";
        [_closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (LOTAnimationView *)iconAnimationView
{
    if (!_iconAnimationView) {
        
        NSString *animationPath = [[NSBundle mainBundle] pathForResource:@"profileFill_photo_animation" ofType:@"json" inDirectory:@"UGCResource.bundle"];
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            animationPath = [[NSBundle mainBundle] pathForResource:@"profileFill_photo_animation_night" ofType:@"json" inDirectory:@"UGCResource.bundle"];
        }
        _iconAnimationView = [LOTAnimationView animationWithFilePath:animationPath];
        _iconAnimationView.frame = self.iconImageView.frame;
        _iconAnimationView.loopAnimation = YES;
        _iconAnimationView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *iconTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTaped:)];
        [_iconAnimationView addGestureRecognizer:iconTapGesture];
    }
    return _iconAnimationView;
}

- (SSThemedImageView *)indicateNameView
{
    if (!_indicateNameView) {
        _indicateNameView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(self.backgroundView.width - [TTDeviceUIUtils tt_newPadding:25.0+64.0], [TTDeviceUIUtils tt_newPadding:171.0], [TTDeviceUIUtils tt_newPadding:64.0], [TTDeviceUIUtils tt_newPadding:14.0])];
        _indicateNameView.imageName = @"profile_fill_username_bubble";
        SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:_indicateNameView.bounds];
        label.text = @"完善用户名";
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            label.contentInset = UIEdgeInsetsMake(0, 3, 0, -3);
        } else {
            label.contentInset = UIEdgeInsetsMake(0, 2, 0, -2);
        }
        label.textColorThemeKey = kColorText12;
        label.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10.0]];
        label.textAlignment = NSTextAlignmentCenter;
        [_indicateNameView addSubview:label];
        _indicateNameView.hidden = YES;
    }
    return _indicateNameView;
}

- (SSThemedLabel *)indicateAvatarLabel
{
    if (!_indicateAvatarLabel) {
        CGFloat width = [TTDeviceUIUtils tt_newPadding:52.0];
        CGFloat height = [TTDeviceUIUtils tt_newPadding:16.0];
        _indicateAvatarLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(self.backgroundView.width/2.0 - width/2.0, self.iconImageView.bottom - height, width, height)];
        _indicateAvatarLabel.text = @"完善头像";
        _indicateAvatarLabel.textColorThemeKey = kColorText12;
        _indicateAvatarLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10.0]];
        _indicateAvatarLabel.textAlignment = NSTextAlignmentCenter;
        _indicateAvatarLabel.backgroundColors = SSThemedColors(@"505050", @"707070");
        _indicateAvatarLabel.layer.cornerRadius = height/2.0;
        _indicateAvatarLabel.clipsToBounds = YES;
    }
    return _indicateAvatarLabel;
}
@end
