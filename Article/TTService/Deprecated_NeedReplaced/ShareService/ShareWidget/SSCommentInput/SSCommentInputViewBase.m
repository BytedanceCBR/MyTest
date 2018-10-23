//
//  SSCommentInputViewBase.m
//  Article
//
//  Created by Zhang Leonardo on 13-3-31.
//
//

#import "SSCommentInputViewBase.h"
#import "SSCommentInputHeader.h"
#import "TTThirdPartyAccountInfoBase.h"
#import "AccountButton.h"
#import "TTIndicatorView.h"
#import "TTNavigationController.h"

#import "UIColor+TTThemeExtension.h"
#import "UIImage+TTThemeExtension.h"
#import "TTProjectLogicManager.h"
#import "TTDeviceHelper.h"
#import <TTAccountBusiness.h>



#define countLabelFontSize 14.f
#define countLabelBottomPadding   2.f

#define kPadPlatformButtonsShadowViewTag 99
#define kPadPlatformButtonsBgViewTag 98

@interface SSCommentInputViewBase()<UITextViewDelegate>
@property (nonatomic, retain) SSNavigationBar    * navigationView;
@end

@implementation SSCommentInputViewBase

+ (Class)userAccountClassForCommentInputViewType:(SSCommentInputViewType)type
{
    Class className = nil;
    switch (type) {
        case SSCommentInputViewTypeAllPlatform:
            break;
//        case SSCommentInputViewTypeQQZone:
//            className = [QZoneUserAccount class];
//            break;
//        case SSCommentInputViewTypeQQWeibo:
//            className = [TencentWBUserAccount class];
//            break;
//        case SSCommentInputViewTypeRenren:
//            className = [RenrenUserAccount class];
//            break;
//        case SSCommentInputViewTypeSinaWeibo:
//            className = [SinaUserAccount class];
//            break;
//        case SSCommentInputViewTypeKaixin:
//            className = [KaixinUserAccount class];
//            break;
        default:
            break;
    }
    return className;
}

- (void)dealloc
{
    self.containerView = nil;
    self.tipLabel = nil;
    self.bgImgView = nil;
    self.titleBarView = nil;
    self.platformButtonsView = nil;
    self.countLabel = nil;
    self.inputTextView = nil;
    self.leftButton = nil;
    self.rightButton = nil;
    self.navigationBar = nil;
    self.navigationView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _inputViewType = SSCommentInputViewTypeAllPlatform;
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
    self.backgroundColor = [UIColor blueColor];
    
    self.bgImgView = [[UIImageView alloc] initWithImage:[self backgroundImge]];
    _bgImgView.frame = [self frameForBgImgView];
    [_containerView addSubview:_bgImgView];
    
    
    self.inputTextView = [[UITextView alloc] initWithFrame:[self frameForInputTextView]];
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.delegate = self;
    _inputTextView.font = [UIFont systemFontOfSize:15.f];
    _inputTextView.scrollsToTop = NO;
    _inputTextView.placeHolder = [SSCommonLogic commentInputViewPlaceHolder];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        _inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    } else {
        _inputTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    
    [_containerView addSubview:_inputTextView];
    
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _countLabel.text = [NSString stringWithFormat:@" %d ", kMaxCommentLength];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.font = [UIFont systemFontOfSize:countLabelFontSize];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.frame = [self frameForCountLabel];
    [_containerView addSubview:_countLabel];
    
    [self initTipLabel];
    
    [self updatePlatformsButton];
}

- (void)setDesignatedMaxWordsCount:(NSInteger)designatedMaxWordsCount
{
    NSInteger maxWordsCount = designatedMaxWordsCount ? designatedMaxWordsCount : kMaxCommentLength;
    _designatedMaxWordsCount = maxWordsCount;
    self.countLabel.text = [NSString stringWithFormat:@" %ld ", (long)_designatedMaxWordsCount];
}

- (void)setInputTypeByPlatformKey:(NSString *)key
{
    if ([key isEqualToString:PLATFORM_SINA_WEIBO]) {
        self.inputViewType = SSCommentInputViewTypeSinaWeibo;
    }
    else if ([key isEqualToString:PLATFORM_QQ_WEIBO]) {
        self.inputViewType = SSCommentInputViewTypeQQWeibo;
    }
    else if ([key isEqualToString:PLATFORM_QZONE]) {
        self.inputViewType = SSCommentInputViewTypeQQZone;
    }
    else if ([key isEqualToString:PLATFORM_RENREN_SNS]) {
        self.inputViewType = SSCommentInputViewTypeRenren;
    }
    else if ([key isEqualToString:PLATFORM_KAIXIN_SNS]) {
        self.inputViewType = SSCommentInputViewTypeKaixin;
    }
}

- (void)updatePlatformsButton
{
    if (!_platformButtonsView) {
        self.platformButtonsView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _platformButtonsView.backgroundColor  = [UIColor clearColor];
        [_containerView addSubview:_platformButtonsView];
        
        UIImageView * bgView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"sharebar.jpg"]];
        bgView.tag = kPadPlatformButtonsBgViewTag;
        [_platformButtonsView addSubview:bgView];
        
        UIImageView * topShadowView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"sharebar_shadow.png"]];
        topShadowView.tag = kPadPlatformButtonsShadowViewTag;
        [_platformButtonsView addSubview:topShadowView];
    }
    
    _platformButtonsView.frame = [self frameForPlatformButtonsView];
    
    
    
    
    for (UIView * subView in [_platformButtonsView subviews]) {
        if (subView.tag != kPadPlatformButtonsShadowViewTag && subView.tag != kPadPlatformButtonsBgViewTag) {
            [subView removeFromSuperview];
        }
    }
    
    NSArray * tmpAccounts = [[TTPlatformAccountManager sharedManager] platformAccounts];
    NSMutableArray * accounts = [NSMutableArray arrayWithCapacity:10];
    //3.4需求， 不在显示QQ空间分享， 此处进行过滤
    for (int i = 0; i < [tmpAccounts count]; i++) {
        id account = [tmpAccounts objectAtIndex:i];
//        if ([account isKindOfClass:[QZoneUserAccount class]]) {
//            continue;
//        }
//
//        //国际版需求，去掉人人、开心
//        if (TTLogicBool(@"isI18NVersion", NO)) {
//            if ([account isKindOfClass:[RenrenUserAccount class]] ||
//                [account isKindOfClass:[KaixinUserAccount class]]) {
//                continue;
//            }
//        }
        
        [accounts addObject:account];
    }
    
    for (int idx = 0; idx < [accounts count]; idx ++)
    {
        TTThirdPartyAccountInfoBase *account = [accounts objectAtIndex:idx];
        AccountButton * button = [[AccountButton alloc] initWithFrame:CGRectMake(64 * idx + 10, 0, 45, 35) accountInfo:account];
        [_platformButtonsView addSubview:button];
    }
    
}

#pragma mark -- resource

- (UIImage *)backgroundImge
{
    return [[UIImage themedImageNamed:@"inputbox_repost.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    
}

#pragma mark -- calculate frame

- (void)refreshTipLabelFrame
{
    
    _tipLabel.origin = CGPointMake((_inputTextView.left) + 8, (_countLabel.top));
    
    
    _tipLabel.height = [self heightForCountLabel];
}

- (CGRect)frameForTitleBarView
{
    return CGRectMake(0, 0, CGRectGetWidth([self frameForContainerView]), [SSTitleBarView titleBarHeight]);
}

- (CGRect)frameForCountLabel
{
    
    CGRect rect = CGRectZero;
    rect = CGRectMake((_bgImgView.right) - 60, (_bgImgView.bottom) - [self heightForCountLabel] - countLabelBottomPadding, 60, [self heightForCountLabel]);
    
    return rect;
}

- (CGRect)frameForPlatformButtonsView
{
    CGRect platformButtonViewsFrame = CGRectZero;
    
    platformButtonViewsFrame = CGRectMake(0, CGRectGetMaxY([self frameForBgImgView]) + 5, CGRectGetWidth([self frameForContainerView]), 44.f);
    
    return platformButtonViewsFrame;
}



- (CGRect)frameForContainerView
{
    CGRect rect = CGRectZero;
    rect = CGRectInset(self.bounds, [TTUIResponderHelper paddingForViewWidth:0], 0);
    return rect;
}


- (CGRect)frameForInputTextView
{
    CGRect rect = CGRectZero;
    rect = CGRectInset(self.bounds, [TTUIResponderHelper paddingForViewWidth:0], 0);
    float height = [TTDeviceHelper is568Screen] ? 172 : 84;
    if ([TTDeviceHelper is568Screen]) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            height = 44;
        }
        else {
            height = 172;
        }
    }
    else {
        height = 84;
    }
    rect = CGRectMake(8, CGRectGetMaxY([self frameForTitleBarView]) + 8, CGRectGetWidth(rect) - 16, height);
    return rect;
}

- (CGRect)frameForBgImgView
{
    CGRect rect = CGRectZero;
    rect = [self frameForInputTextView];
    rect.size.height += ([self heightForCountLabel] + countLabelBottomPadding);
    return rect;
}

- (CGFloat)heightForCountLabel
{
    return 20.f;
}

- (void)setInputViewType:(SSCommentInputViewType)inputViewType
{
    _inputViewType = inputViewType;
    if (_inputViewType == SSCommentInputViewTypeAllPlatform)
    {
        if ([_platformButtonsView superview] == nil) {
            [_containerView addSubview:_platformButtonsView];
        }
        _tipLabel.text = sOnlyWannaCommentTip;
    }
    else
    {
        [_platformButtonsView removeFromSuperview];
    }
    
    NSString * titleStr = nil;
    id className = [SSCommentInputViewBase userAccountClassForCommentInputViewType:inputViewType];
    if (className == nil) {
        titleStr = sDefaultTitle;
    }
    else {
        titleStr = [NSString stringWithFormat:@"%@%@", sShareTo, [className platformDisplayName]];
    }
    
    [_titleBarView setTitleText:titleStr];
    _navigationBar.title = titleStr;
}

#pragma mark -- layoutSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    _containerView.frame = [self frameForContainerView];
    self.navigationView.frame = [self frameForTitleBarView];
    _bgImgView.frame = [self frameForBgImgView];
    _inputTextView.frame = [self frameForInputTextView];
    _countLabel.frame = [self frameForCountLabel];
    [self updatePlatformsButton];
    [self refreshTipLabelFrame];
}


#pragma mark -- Protected Method

- (void)showRightImgIndicatorWithMsg:(NSString *)msg
{
    [self showIndicatorMsg:msg imageName:@"doneicon_popup_textpage.png"];
}

- (void)showWrongImgIndicatorWithMsg:(NSString *)msg
{
    [self showIndicatorMsg:msg imageName:@"close_popup_textpage.png"];
}

- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName
{
    UIImage *tipImage = nil;
    if (!isEmptyString(imgName)) {
        tipImage = [UIImage themedImageNamed:imgName];
    }
    
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:tipImage autoDismiss:YES dismissHandler:nil];
}

- (void)initTipLabel
{
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tipLabel.font = [UIFont systemFontOfSize:countLabelFontSize];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.text = sOnlyWannaCommentTip;
    [_tipLabel sizeToFit];
    [self refreshTipLabelFrame];
    [_containerView addSubview:_tipLabel];
}



- (void)backButtonClicked
{
    // subview implements
}

- (void)sendButtonClicked
{
    // subview implements
}

- (void)refreshCountLabel
{
    NSString * content = [_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger count = self.designatedMaxWordsCount - [content length];
    _countLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    
    if ([self inputContentLegal]) {
        _countLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    }
    else {
        _countLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"a40000" nightColorName:@"505050"]];
    }
    
    [_inputTextView showOrHidePlaceHolderTextView];
}

/*
 *  返回YES，可以发送
 */
- (BOOL)inputContentLegal
{
    if (_designatedMaxWordsCount == 0 ) {
        [self setDesignatedMaxWordsCount:kMaxCommentLength];
    }
    NSString * content = [_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger count = self.designatedMaxWordsCount - [content length];
    if (count >= 0) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark -- lefe cycle

- (void)themeChanged:(NSNotification *)notification
{
    
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    _titleBarView.titleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"FAFAFA" nightColorName:@"B1B1B1"]];
    _bgImgView.image = [self backgroundImge];
    _inputTextView.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"000000" nightColorName:@"b1b1b1"]];
    _tipLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    [self refreshCountLabel];
    [self updatePlatformsButton];
}

- (void)willAppear
{
    [super willAppear];
    
    [self updatePlatformsButton];
    [self refreshCountLabel];
    
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
}

#pragma mark -- UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshCountLabel];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.selectedRange = NSMakeRange(0, 0);
}

@end
