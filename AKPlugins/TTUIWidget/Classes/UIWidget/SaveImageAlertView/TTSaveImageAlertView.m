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

@interface TTSaveImageAlertView ()
@property(nonatomic, strong)UIView * bgView;
@property(nonatomic, strong)SSThemedButton * cancelButton;
@property(nonatomic, strong)SSThemedButton * saveButton;
@property(nonatomic, strong)SSThemedButton * shareButton;
@property(nonatomic, strong)SSThemedView * bottomLine;
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
    CGFloat bottomSafeInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    CGFloat contentHeight = kCancelButtonHeight + kActionButtonHeight * 2 + kGapViewHeight + [TTDeviceHelper ssOnePixel] + bottomSafeInset;
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - contentHeight)];
    self.bgView.alpha = 0.98;
    [self.contentBaseView addSubview:_bgView];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentBaseView);
        make.bottom.equalTo(self.contentBaseView).offset(-contentHeight);
    }];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewTap:)];
    [_bgView addGestureRecognizer:tapGestureRecognizer];
    
    self.shareButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_shareButton setTitle:NSLocalizedString(@"分享此张图片", nil) forState:UIControlStateNormal];
    [_shareButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [_shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _shareButton.frame = CGRectMake(0, self.height - contentHeight, self.width, kActionButtonHeight);
    [self.contentBaseView addSubview:_shareButton];
    
    [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentBaseView);
        make.top.equalTo(self.bgView.mas_bottom);
        make.height.mas_equalTo(kActionButtonHeight);
    }];
    
    _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, _shareButton.bottom, self.width, [TTDeviceHelper ssOnePixel])];
    [self.contentBaseView addSubview:_bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentBaseView);
        make.top.equalTo(self.shareButton.mas_bottom);
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    self.saveButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_saveButton setTitle:NSLocalizedString(@"保存图片", nil) forState:UIControlStateNormal];
    [_saveButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [_saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.frame = CGRectMake(0, _bottomLine.bottom, self.width, kActionButtonHeight);
    [self.contentBaseView addSubview:_saveButton];
    
    [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentBaseView);
        make.top.equalTo(self.bottomLine.mas_bottom);
        make.height.mas_equalTo(kActionButtonHeight);
    }];
    
    self.gapView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, _saveButton.bottom, self.width, kGapViewHeight)];
    [self.contentBaseView addSubview:_gapView];
    [_gapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentBaseView);
        make.top.equalTo(self.saveButton.mas_bottom);
        make.height.mas_equalTo(kGapViewHeight);
    }];
    
    self.cancelButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.frame = CGRectMake(0, self.height - kCancelButtonHeight, self.width,kCancelButtonHeight);
    [self.contentBaseView addSubview:_cancelButton];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentBaseView);
        make.top.equalTo(self.gapView.mas_bottom);
        make.height.mas_equalTo(kCancelButtonHeight);
    }];
    self.bottomSafeAreaView = [[SSThemedView alloc] init];
    self.bottomSafeAreaView.backgroundColor = [UIColor whiteColor];
    [self.contentBaseView addSubview:self.bottomSafeAreaView];
    [self.bottomSafeAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentBaseView);
        make.height.mas_equalTo(bottomSafeInset);
    }];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _shareButton.titleColorThemeKey = kColorText1;
    _shareButton.backgroundColorThemeKey = kColorBackground4;
    _saveButton.titleColorThemeKey = kColorText1;
    _saveButton.backgroundColorThemeKey = kColorBackground4;
    _bottomLine.backgroundColorThemeKey = kColorBackground2;
    _gapView.backgroundColorThemeKey = kColorBackground2;
    _cancelButton.titleColorThemeKey = kColorText6;
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
}

- (void)setHideShareButton:(BOOL)hideShareButton
{
    _hideShareButton = hideShareButton;
    _shareButton.hidden = _hideShareButton;
    _bottomLine.hidden = _hideShareButton;
}

- (void)shareButtonClicked:(id)sender
{
    [self dismissWithAnimation:YES];
    if (sender && [self.delegate respondsToSelector:@selector(shareButtonFired:)]) {
        [self.delegate shareButtonFired:sender];
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

