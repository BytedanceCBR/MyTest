//
//  TTSaveImageAlertView.m
//  Article
//
//  Created by 王双华 on 15/11/1.
//
//

#import "TTSaveImageAlertView.h"
#import "SSThemed.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "UIColor+TTThemeExtension.h"
#import <Masonry/Masonry.h>
#import "TTDeviceHelper.h"


#define kCancelButtonHeight 48
#define kActionButtonHeight 48
#define kGapViewHeight 4
#define kFontSize 17.f

@interface TTSaveImageAlertView ()
@property(nonatomic, strong)UIView * bgView;
@property(nonatomic, strong)SSThemedButton * cancelButton;
@property(nonatomic, strong)SSThemedButton * saveButton;
@property(nonatomic, strong)SSThemedButton * scanQrCodeButton;
@property(nonatomic, strong)SSThemedView * scanQrCodeBottomLine;
@property(nonatomic, strong)SSThemedButton * shareButton;
@property(nonatomic, strong)SSThemedView *shareBottomLine;
@property(nonatomic, strong)SSThemedView * gapView;
@property(nonatomic, strong)SSThemedView *bottomSafeAreaView;
@end

@implementation TTSaveImageAlertView

- (id)init
{
    CGRect activityRect = CGRectZero;
    activityRect = [UIScreen mainScreen].bounds;
    self = [self initWithFrame:activityRect];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = [UIApplication sharedApplication].keyWindow.frame;
        if (![TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 8.f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGFloat temp = rect.size.width;
            rect.size.width = rect.size.height;
            rect.size.height = temp;
        }
        self.frame = rect;
        [self buildViews];
        [self reloadThemeUI];
    }
    return self;
}

- (void)buildViews
{
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.alpha = 0.98;
    [self.contentBaseView addSubview:_bgView];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewTap:)];
    [_bgView addGestureRecognizer:tapGestureRecognizer];
    
    self.shareButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_shareButton setTitle:NSLocalizedString(@"分享此张图片", nil) forState:UIControlStateNormal];
    [_shareButton.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
    [_shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _shareButton.frame = CGRectMake(0, 0, self.width, kActionButtonHeight);
    [self.contentBaseView addSubview:_shareButton];

    _shareBottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel])];
    [self.contentBaseView addSubview:_shareBottomLine];
    
    _scanQrCodeButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_scanQrCodeButton setTitle:NSLocalizedString(@"识别二维码", nil) forState:UIControlStateNormal];
    [_scanQrCodeButton.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
    [_scanQrCodeButton addTarget:self action:@selector(scanQrCodeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _scanQrCodeButton.frame = CGRectMake(0, 0, self.width, kActionButtonHeight);
    [self.contentBaseView addSubview:_scanQrCodeButton];
    
    _scanQrCodeBottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0,0, self.width, [TTDeviceHelper ssOnePixel])];
    [self.contentBaseView addSubview:_scanQrCodeBottomLine];
    
    self.saveButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_saveButton setTitle:NSLocalizedString(@"保存图片", nil) forState:UIControlStateNormal];
    [_saveButton.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
    [_saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.frame = CGRectMake(0, 0, self.width, kActionButtonHeight);
    [self.contentBaseView addSubview:_saveButton];
    
    self.gapView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kGapViewHeight)];
    [self.contentBaseView addSubview:_gapView];
    
    self.cancelButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
    [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.frame = CGRectMake(0, 0, self.width, kCancelButtonHeight);
    [self.contentBaseView addSubview:_cancelButton];
    
    CGFloat bottomSafeInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    self.bottomSafeAreaView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, bottomSafeInset)];
    self.bottomSafeAreaView.backgroundColor = [UIColor whiteColor];
    [self.contentBaseView addSubview:self.bottomSafeAreaView];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _shareButton.titleColorThemeKey = kColorText1;
    _shareButton.backgroundColorThemeKey = kColorBackground4;
    _shareBottomLine.backgroundColorThemeKey = kColorBackground2;
    _scanQrCodeButton.titleColorThemeKey = kColorText1;
    _scanQrCodeButton.backgroundColorThemeKey = kColorBackground4;
    _scanQrCodeBottomLine.backgroundColorThemeKey = kColorBackground2;
    _saveButton.titleColorThemeKey = kColorText1;
    _saveButton.backgroundColorThemeKey = kColorBackground4;
    _gapView.backgroundColorThemeKey = kColorBackground2;
    _cancelButton.titleColorThemeKey = kColorText1;
    _cancelButton.backgroundColorThemeKey = kColorBackground4;
    _bottomSafeAreaView.backgroundColorThemeKey = kColorBackground4;
}

- (void)interfaceOrientationChanged
{
    if (![TTDeviceHelper isPadDevice]) {
        [self dismissWithAnimation:NO];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 从底部开始布局
    self.bottomSafeAreaView.top = self.height - self.bottomSafeAreaView.height;
    self.cancelButton.top = self.bottomSafeAreaView.top - self.cancelButton.height;
    self.gapView.top = self.cancelButton.top - self.gapView.height;
    
    self.saveButton.top = self.gapView.top - self.saveButton.height;
    
    CGFloat top = 0;
    if (self.showScanQrCodeButton) {
        self.scanQrCodeButton.hidden = NO;
        self.scanQrCodeBottomLine.hidden = NO;
        
        self.scanQrCodeBottomLine.top = self.saveButton.top - self.scanQrCodeBottomLine.height;
        self.scanQrCodeButton.top = self.scanQrCodeBottomLine.top - self.scanQrCodeButton.height;
        
        top = self.scanQrCodeButton.top;
    } else {
        self.scanQrCodeButton.hidden = YES;
        self.scanQrCodeBottomLine.hidden = YES;
        
        top = self.saveButton.top;
    }
    
    if (!self.hideShareButton) {
        self.shareButton.hidden = NO;
        self.shareBottomLine.hidden = NO;
        
        self.shareBottomLine.top = top - self.shareBottomLine.height;
        self.shareButton.top = self.shareBottomLine.top - self.shareButton.height;
    } else {
        self.shareButton.hidden = YES;
        self.shareBottomLine.hidden = YES;
    }
}

- (void)showActivityOnWindow:(UIWindow *)window
{
    self.contentBaseView.origin = CGPointMake(0, [TTUIResponderHelper screenSize].height);
    self.backgroundColor = [UIColor clearColor];
    
    if(![self superview])
    {
        UIViewController *aimVC = window.rootViewController;
        while (aimVC.presentedViewController) {
            aimVC = aimVC.presentedViewController;
        }
        [aimVC.view addSubview:self];
        [aimVC.view bringSubviewToFront:self];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithHexString:@"00000066"];
        self.contentBaseView.origin = CGPointMake(0, 0);
    }];
    
    if ([self.delegate respondsToSelector:@selector(alertDidShow)]) {
        [self.delegate alertDidShow];
    }
}

- (void)showOnKeyWindow {
    [self showOnWindow:SSGetMainWindow()];
    
    if ([self.delegate respondsToSelector:@selector(alertDidShow)]) {
        [self.delegate alertDidShow];
    }
}

- (void)dismissDone {
    [super dismissDone];
    if ([self.delegate respondsToSelector:@selector(alertDidHide)]) {
        [self.delegate alertDidHide];
    }
}

- (void)dismissWithAnimation:(BOOL)animation {
    [super dismissWithAnimation:animation];
    // 等动画结束后，再回调
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(alertDidHide)]) {
            [self.delegate alertDidHide];
        }
    });
}

- (void)shareButtonClicked:(id)sender
{
    [self dismissWithAnimation:YES];
    if (sender && [self.delegate respondsToSelector:@selector(shareButtonFired:)]) {
        [self.delegate shareButtonFired:sender];
    }
}

- (void)scanQrCodeButtonClicked:(id)sender
{
    [self dismissWithAnimation:YES];
    if (sender && [self.delegate respondsToSelector:@selector(scanQrCodeButtonFired:)]) {
        [self.delegate scanQrCodeButtonFired:sender];
    }
}

- (void)saveButtonClicked:(id)sender
{
    [self dismissWithAnimation:YES];
    if (sender && [self.delegate respondsToSelector:@selector(saveButtonFired:)]) {
        [self.delegate saveButtonFired:sender];
    }
}

- (void)cancelButtonClicked:(id)sender
{
    [self dismissWithAnimation:YES];
    if ([self.delegate respondsToSelector:@selector(cancelButtonFired:)]) {
        [self.delegate cancelButtonFired:sender];
    }
}

- (void)bgViewTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer) {
        [self cancelButtonClicked:nil];
    }
}

@end

