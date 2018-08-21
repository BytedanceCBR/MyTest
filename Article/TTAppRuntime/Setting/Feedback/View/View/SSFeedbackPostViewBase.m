//
//  SSFeedbackPostViewBase.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-9.
//
//

#import "SSFeedbackPostViewBase.h"
#import "TTIndicatorView.h"
#import <QuartzCore/QuartzCore.h>
#import "SSImageUtil.h"
#import "SSPublishProgressView.h"
#import "SSFeedbackManager.h"
#import "UIImage+TTThemeExtension.h"

#import "TTDeviceHelper.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UITextView+TTAdditions.h"


#define kPhotoSourceSelectActionSheetTag 100
#define TipLabelFontSize 11.f
#define ContentViewLeftMargin 8.f
#define ContentViewRightMargin 8.f

#define ContactViewNoInputTip NSLocalizedString(@"QQ、邮箱或手机等联系方式", nil)

//#define imgSendButtonDefaultImgName @"upload_photo.png"
#define imgSendButtonDefaultImgName @"uploadpic_repost.png"
#define imgSendButtonPressImgName @"uploadpic_repost_press.png"

@interface SSFeedbackPostViewBase()

@property(nonatomic, retain)    SSPublishProgressView * submitProgressView;
@property(nonatomic, retain)    UIPopoverController *popover;
@property(nonatomic, retain)    SSThemedLabel * tipLabel;
@end

@implementation SSFeedbackPostViewBase
- (void)dealloc
{
    self.contactView = nil;
    self.inputTextView = nil;
    self.bgImgView = nil;
    self.tipLabel = nil;
    self.containerView = nil;
    self.imageButton = nil;
    self.submitProgressView = nil;
    self.popover = nil;
    
    self.contactField = nil;
    self.contactImageView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildView];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)buildView
{
    self.containerView = [[UIView alloc] initWithFrame:[self frameForContainerView]];
    _containerView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_containerView];
    
    self.bgImgView = [[UIImageView alloc] initWithImage:[self backgroundImge]];
    _bgImgView.frame = [self frameForBgImgView];
    _bgImgView.backgroundColor = [UIColor clearColor];
    [_containerView addSubview:_bgImgView];
    
    self.inputTextView = [[SSThemedTextView alloc] initWithFrame:[self frameForInputTextView]];
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.delegate = self;
    _inputTextView.font = [UIFont systemFontOfSize:15.f];
    _inputTextView.scrollsToTop = NO;
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        _inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    } else {
        _inputTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    }

    [_containerView addSubview:_inputTextView];
    
    self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _imageButton.layer.cornerRadius = 5.f;
    _imageButton.clipsToBounds = YES;
    _imageButton.backgroundColor = [UIColor clearColor];
    [_imageButton setImage:[UIImage themedImageNamed:imgSendButtonDefaultImgName] forState:UIControlStateNormal];
    [_imageButton addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_imageButton];
    
    self.contactView = [[UIView alloc] initWithFrame:CGRectZero];
    _contactView.backgroundColor = [UIColor clearColor];
    [_containerView addSubview:_contactView];
    
    self.contactImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _contactImageView.backgroundColor = [UIColor clearColor];
    //_contactImageView.contentStretch = CGRectMake(0.49, 0.49, 0.02, 0.02);
    [_contactView addSubview:_contactImageView];
    
    self.contactField = [[SSThemedTextField alloc] initWithFrame:CGRectZero];
    _contactField.backgroundColor = [UIColor clearColor];
    _contactField.font = [UIFont systemFontOfSize:15.f];
    _contactField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    NSString * defaultContact = [SSFeedbackManager defaultContactString];
    if (isEmptyString(defaultContact)) {
        defaultContact = ContactViewNoInputTip;
    }
    _contactField.placeholder = defaultContact;
    _contactField.placeholderColorThemeKey = kColorText3;
    [_contactView addSubview:_contactField];
    

    self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    [_tipLabel setText:NSLocalizedString(@"您的联系方式有助于我们沟通和解决问题，仅工作人员可见", nil)];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.font = [UIFont systemFontOfSize:TipLabelFontSize];
    _tipLabel.textColorThemeKey = kColorText3;
    [_containerView addSubview:_tipLabel];

    [self ssLayoutSubviews];
}


#pragma mark -- resource

- (UIImage *)backgroundImge
{
    UIImage * img = [UIImage themedImageNamed:@"inputbox_repost.png"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(4.f, 4.f, img.size.height - 5.f, img.size.width - 5.f)];
    return img;
}

#pragma mark -- calculate frame

- (CGRect)frameForContactField
{
    CGRect rect = [self frameForContactView];
    rect.origin.x = ContentViewLeftMargin + 10;
    rect.origin.y = 0;
    rect.size.width -= (ContentViewLeftMargin + ContentViewRightMargin + 20);
    return rect;
}

- (CGRect)frameForContactBgImgView
{
    CGRect rect = [self frameForContactView];
    rect.origin.x = ContentViewLeftMargin;
    rect.origin.y = 0;
    rect.size.width -= (ContentViewLeftMargin + ContentViewRightMargin);
    return rect;
}

- (CGRect)frameForTipLabel
{
    CGRect rect = CGRectZero;
    rect.origin.x = ContentViewLeftMargin;
    rect.origin.y = CGRectGetMaxY([self frameForContactView]) + 8;
    rect.size.width = CGRectGetWidth([self frameForContainerView]);
    rect.size.height = TipLabelFontSize + 5;
    return rect;
}

- (CGRect)frameForImageButton
{
    CGRect rect = CGRectZero;
    rect = CGRectMake(0, 0, 60, 60);
    rect.origin.y = CGRectGetMinY([self frameForBgImgView]) + 7;
    rect.origin.x = CGRectGetMaxX([self frameForBgImgView]) - rect.size.width - 7;
    return rect;
}

- (CGFloat)heightForContactView
{
    return 30.f;
}

- (CGRect)frameForContactView
{
    CGRect platformButtonViewsFrame = CGRectMake(0, CGRectGetMaxY([self frameForBgImgView]) + 8, CGRectGetWidth([self frameForContainerView]), [self heightForContactView]);
    return platformButtonViewsFrame;
}

- (CGRect)frameForContainerView
{
    CGRect rect = self.bounds;
    return rect;
}


- (CGRect)frameForInputTextView
{
    CGRect rect = CGRectZero;
    rect = [self frameForBgImgView];
    rect.size.width -= 60;
    rect.size.height = [self heightForInputTextView];
    return rect;
}

//iphone中，view的frame将依赖该view的frame
- (CGRect)frameForBgImgView
{
    CGRect rect = CGRectZero;
    rect = CGRectMake(ContentViewLeftMargin, ContentViewRightMargin, CGRectGetWidth(self.frame) - 16, [self heightForInputTextView]);
    return rect;
}

- (CGFloat)heightForInputTextView
{
    CGFloat height = ([TTDeviceHelper is568Screen] ? 182 : 94);
    return height;
}

#pragma mark -- layoutSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        [self ssLayoutSubviews];
    }
}

- (void)ssLayoutSubviews
{
    _submitProgressView.frame = self.bounds;
    _containerView.frame = [self frameForContainerView];
    _bgImgView.frame = [self frameForBgImgView];
    _inputTextView.frame = [self frameForInputTextView];
    _imageButton.frame = [self frameForImageButton];
    _tipLabel.frame = [self frameForTipLabel];
    _contactView.frame = [self frameForContactView];
    _contactImageView.frame = [self frameForContactBgImgView];
    _contactField.frame = [self frameForContactField];
}

- (void)setImageButtonImg:(UIImage *)img
{
    if (img == nil) {
        [_imageButton setImage:[UIImage themedImageNamed:imgSendButtonDefaultImgName] forState:UIControlStateNormal];
        return;
    }
    CGRect rect = [self frameForImageButton];
    UIImage * showImg = [SSImageUtil cutImage:img withCutWidth:rect.size.width withSideHeight:rect.size.height cutPosition:SSImageUtilCutTypeCenter];
    [_imageButton setImage:showImg forState:UIControlStateNormal];
}

#pragma mark -- public Method

- (void)setInputTextViewText:(NSString *)text
{
    if (isEmptyString(text)) {
        [_inputTextView setText:@""];
    }
    else {
        [_inputTextView setText:text];
    }
    
    self.inputTextView.selectedRange = NSMakeRange(self.inputTextView.text.length, 0);
    
}

#pragma mark -- Protected Method

- (void)submitImgCancel
{
    [_submitProgressView removeFromSuperview];
    self.submitProgressView = nil;
}

- (void)setSubmitProgress:(CGFloat)progress
{
    if (!_submitProgressView) {
        self.submitProgressView = [[SSPublishProgressView alloc] initWithFrame:self.bounds];
        [_submitProgressView addTarget:self selecter:@selector(submitImgCancel)];
        [self addSubview:_submitProgressView];
    }
    [_submitProgressView setProgress:progress];
}

- (void)removeProgressView
{
    [_submitProgressView removeFromSuperview];
    self.submitProgressView = nil;
}

- (void)pickedImage:(UIImage *)image withReferenceURL:(NSURL *)url
{
    // sub class implement
}

- (void)deletePickedImg
{
    //sub class implement
}

- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName
{
    [self showIndicatorMsg:msg imageName:imgName autoHidden:YES];
}

- (void)showIndicatorMsg:(NSString *)msg autoHidden:(BOOL)autoHide
{
    [self showIndicatorMsg:msg imageName:nil autoHidden:autoHide];
}

- (void)hideIndicator:(BOOL)animated
{
    [TTIndicatorView dismissIndicators];
}

- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName autoHidden:(BOOL)autoHide
{
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:[UIImage themedImageNamed:imgName] autoDismiss:YES dismissHandler:nil];
}

- (void)imageButtonClicked:(UIButton *)sender
{
    UIActionSheet *tSheet = nil;
    
    BOOL hasPickedImg = [self hasPickedImg];
    
    if([TTDeviceHelper OSVersionNumber] >= 8.0 && [TTDeviceHelper isPadDevice])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
        if(hasPickedImg)
        {
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"删除图片", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [self deletePickedImg];
                                                              }]];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"手机相册", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self openPickerControllerByType:UIImagePickerControllerSourceTypePhotoLibrary];
                                                          }]];
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.sourceRect = sender.bounds;

        UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self];
        [topVC presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [self.inputTextView resignFirstResponder];
        
        if (hasPickedImg) {
            
            tSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"删除图片", nil), NSLocalizedString(@"手机相册", nil), nil];
            
        }
        else {
            tSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"手机相册", nil), nil];
        }
        
        
        if (tSheet) {
            tSheet.delegate = self;
            tSheet.tag = kPhotoSourceSelectActionSheetTag;
            [tSheet showInView:self];
        }
    }
    
}

/*
 *  返回YES，可以发送
 */
- (BOOL)inputContentLegal
{
    NSString * content = [_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger count = [content length];
    if (count > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString *)availableContact
{
    NSString * contactStr = [_contactField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!isEmptyString(contactStr)) {
        return contactStr;
    }
    else {
        contactStr = [_contactField.placeholder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (!isEmptyString(contactStr) && ![contactStr isEqualToString:ContactViewNoInputTip]) {
            return contactStr;
        }
    }
    return nil;
}

#pragma mark -- life cycle

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _tipLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"bfbfbf" nightColorName:@"b1b1b1"]];
    _bgImgView.image = [self backgroundImge];
    _contactImageView.image = [self backgroundImge];
    _inputTextView.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"000000" nightColorName:@"b1b1b1"]];
    _contactField.textColor = _inputTextView.textColor;
}

- (void)willAppear
{
    [super willAppear];
    [_inputTextView becomeFirstResponder];
}

- (void)didAppear
{
    [super didAppear];
}

- (void)didDisappear
{
    [super didDisappear];
}

- (void)willDisappear
{
    [super willDisappear];
    
    NSString * contactStr = [self availableContact];
    
    if (!isEmptyString(contactStr)) {
        [SSFeedbackManager saveDefaultContactString:contactStr];
    }
}

#pragma mark -- UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
        [self.inputTextView showOrHidePlaceHolderTextView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //    textView.selectedRange = NSMakeRange(0, 0);
    [self.inputTextView showOrHidePlaceHolderTextView];
}

#pragma mark -- UIActionSheetDelegate

- (BOOL) hasPickedImg {
    return (_imageButton.imageView.image != [UIImage themedImageNamed:imgSendButtonDefaultImgName]);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kPhotoSourceSelectActionSheetTag)
    {
        if(buttonIndex == actionSheet.cancelButtonIndex)
        {
            return;
        }
        
        BOOL hasPickedImg = [self hasPickedImg];
        
        if (hasPickedImg) {
            switch (buttonIndex) {
                case 0:
                {
                    [self deletePickedImg];
                    return;
                }
                    break;
                case 1:
                {
                    [self openPickerControllerByType:UIImagePickerControllerSourceTypePhotoLibrary];
                }
                    break;
                default:
                    return;
                    break;
            }
        }
        else {
            
            switch (buttonIndex) {
                case 0:
                {
                    [self openPickerControllerByType:UIImagePickerControllerSourceTypePhotoLibrary];
                }
                    break;
                default:
                    return;
                    break;
            }
        }
    }
}

- (void)openPickerControllerByType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *tController = [[UIImagePickerController alloc] init];
    tController.delegate = self;
    tController.sourceType = sourceType;
    
    if ([TTDeviceHelper isPadDevice]) {
        UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:tController];
        self.popover = popOverController;
        [_popover presentPopoverFromRect:_imageButton.frame inView:_containerView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        UINavigationController *nav = (UINavigationController *)[TTUIResponderHelper topViewControllerFor: self];
        if ([nav isKindOfClass:[UINavigationController class]]) {
            [nav presentViewController:tController animated:YES completion:NULL];
        }
        else {
            [nav.navigationController presentViewController:tController animated:YES completion:NULL];
        }
    }
    
}

- (void)applicationStatusBarOrientationDidChanged
{
    [super applicationStatusBarOrientationDidChanged];
    if ([TTDeviceHelper isPadDevice] && [_popover.contentViewController isKindOfClass:[UIImagePickerController class]] && ((UIImagePickerController *)self.popover.contentViewController).sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImagePickerController *tController = [[UIImagePickerController alloc] init];
        tController.delegate = self;
        tController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        self.popover.contentViewController = tController;
    }
}

#pragma mark -- UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *tImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    if ([TTDeviceHelper isPadDevice]) {
        [_popover dismissPopoverAnimated:YES];
        if (tImage) {
            [self pickedImage:tImage withReferenceURL:imageURL];
        }
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:^{
            if (tImage) {
                [self pickedImage:tImage withReferenceURL:imageURL];
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([TTDeviceHelper isPadDevice]) {
        [_popover dismissPopoverAnimated:YES];
    }
    else {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
