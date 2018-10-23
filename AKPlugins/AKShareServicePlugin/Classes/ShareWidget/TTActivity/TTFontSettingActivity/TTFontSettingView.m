//
//  TTFontSettingView.m
//  Article
//
//  Created by 延晋 张 on 2017/2/3.
//
//

#import "TTFontSettingView.h"

#import <QuartzCore/QuartzCore.h>
#import "UIImageAdditions.h"
#import "SSThemed.h"
#import "ExploreDetailFontSettingView.h"
#import <Masonry/Masonry.h>
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import <TTTracker/TTTracker.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import "TTDeviceHelper.h"

#define kTopPading          24
#define kItemWidth          60
#define kItemHeight         83
#define kCancelButtonHeight 48
#define kItemContentHeight  174

@interface TTFontSettingView() <UIScrollViewDelegate>

@property(nonatomic, strong) UIView *itemContentView;
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) SSThemedButton *cancelButton;
@property(nonatomic, strong) UIButton *hideButton;
@property(nonatomic, strong) ExploreDetailFontSettingView *fontSettingView;
@property(nonatomic, strong) UIView *cancelButtonTopDivideLineView;
@property(nonatomic, strong) SSThemedView *bottomSafeAreaView;

@end

@implementation TTFontSettingView

- (void)dealloc
{
    self.hideButton = nil;
    self.itemContentView = nil;
    self.bgView = nil;
    self.cancelButton = nil;
    self.fontSettingView = nil;
    self.cancelButtonTopDivideLineView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = [UIApplication sharedApplication].keyWindow.frame;
        [self buildViews];
        [self reloadThemeUI];
    }
    return self;
}

- (void)buildViews
{
    CGFloat bottomInset = 0;
    if ([TTDeviceHelper isIPhoneXDevice]){
        bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    }
    [self.contentBaseView addSubview:self.hideButton];
    [self.hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentBaseView);
        make.bottom.equalTo(self.contentBaseView).offset(-kItemContentHeight - bottomInset);
    }];
    
    [self.contentBaseView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hideButton.mas_bottom);
        make.left.right.equalTo(self.contentBaseView);
        make.height.mas_equalTo(kItemContentHeight - kCancelButtonHeight - [TTDeviceHelper ssOnePixel]);
    }];
    
    [self.bgView addSubview:self.itemContentView];
    [self.itemContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bgView);
    }];
    
    [self.contentBaseView addSubview:self.cancelButtonTopDivideLineView];
    [_cancelButtonTopDivideLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentBaseView);
        make.top.equalTo(self.bgView.mas_bottom);
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    if (bottomInset > 0){
        [self.contentBaseView addSubview:self.bottomSafeAreaView];
        [self.bottomSafeAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentBaseView);
            make.height.mas_equalTo(bottomInset);
        }];
        [self.contentBaseView addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.bottomSafeAreaView);
            make.bottom.equalTo(self.bottomSafeAreaView.mas_top);
            make.height.mas_equalTo(kCancelButtonHeight);
        }];
    }else{
        [self.contentBaseView addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentBaseView);
            make.height.mas_equalTo(kCancelButtonHeight);
        }];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    UIColor *bgColor = SSGetThemedColorWithKey(kColorBackground18);
    self.bgView.backgroundColor = bgColor;
    self.cancelButtonTopDivideLineView.backgroundColor = SSGetThemedColorWithKey(kColorLine10);
    self.cancelButton.titleColorThemeKey = kColorText1;
    self.cancelButton.backgroundColors = @[[UIColor colorWithHexString:@"0xf8f8f8"], [UIColor colorWithHexString:@"0x303030"]];
    self.cancelButton.highlightedBackgroundColors = @[[UIColor colorWithHexString:@"0xe8e8e8"], [UIColor colorWithHexString:@"0x252525"]];
    self.itemContentView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Public

- (void)show
{
    self.fontSettingView.transform = CGAffineTransformMakeScale(0, 1);
    self.fontSettingView.alpha = 0;
    [UIView animateWithDuration: 0.25 animations:^{
        self.fontSettingView.alpha = 0.98;
        self.fontSettingView.transform = CGAffineTransformMakeScale(1, 1);
        
    } completion:^(BOOL finished) {
        self.fontSettingView.alpha = 0.98;
        self.fontSettingView.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
    UIWindow * window = SSGetMainWindow();
    if ([TTDeviceHelper OSVersionNumber] < 8.f && [TTDeviceHelper isPadDevice]) {
        [super showOnViewController:window.rootViewController];
    }
    else {
        [super showOnWindow:window];
    }
}

- (void)showOnController:(UIViewController *)controller {
    self.fontSettingView.transform = CGAffineTransformMakeScale(0, 1);
    self.fontSettingView.alpha = 0;
    [UIView animateWithDuration: 0.25 animations:^{
        self.fontSettingView.alpha = 0.98;
        self.fontSettingView.transform = CGAffineTransformMakeScale(1, 1);
        
    } completion:^(BOOL finished) {
        self.fontSettingView.alpha = 0.98;
        self.fontSettingView.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
    [super showOnViewController:controller];
}

#pragma mark -- protected

- (void)dismissWithAnimation:(BOOL)animation
{
    [super dismissWithAnimation:animation];
    if (self.dismissHandler) {
        self.dismissHandler();
    }
}

#pragma mark - Action & Response

- (void)cancelButtonClicked
{
    [self dismissWithAnimation:YES];
}

- (void)hideButtonClicked:(id)sender
{
    [self dismissWithAnimation:YES];
}

#pragma mark - getter

- (UIButton *)hideButton
{
    if (!_hideButton) {
        _hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _hideButton.backgroundColor = [UIColor clearColor];
        [_hideButton addTarget:self action:@selector(hideButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideButton;
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kItemContentHeight, self.width, kItemContentHeight - kCancelButtonHeight - [TTDeviceHelper ssOnePixel])];
        self.bgView.alpha = 0.98;
    }
    return _bgView;
}

- (UIView *)itemContentView
{
    if (!_itemContentView) {
        _itemContentView = [[UIView alloc] initWithFrame:self.bgView.frame];
        _itemContentView.backgroundColor = [UIColor clearColor];
        _itemContentView.clipsToBounds = NO;
        _itemContentView.alpha = 0.98;
    }
    return _itemContentView;
}

- (ExploreDetailFontSettingView *)fontSettingView
{
    if (!_fontSettingView) {
        _fontSettingView = [[ExploreDetailFontSettingView alloc] initWithFrame:CGRectMake(0, kTopPading, self.width, (_itemContentView.height) - kTopPading)];
        _fontSettingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.itemContentView addSubview:_fontSettingView];
    }
    return _fontSettingView;
}

- (SSThemedButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.frame = CGRectMake(0, self.height - kCancelButtonHeight, self.width,kCancelButtonHeight);
    }
    return _cancelButton;
}

- (UIView *)cancelButtonTopDivideLineView
{
    if (!_cancelButtonTopDivideLineView) {
        _cancelButtonTopDivideLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kCancelButtonHeight - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
    }
    return _cancelButtonTopDivideLineView;
}

- (SSThemedView *)bottomSafeAreaView
{
    if (_bottomSafeAreaView == nil){
        _bottomSafeAreaView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomSafeAreaView.backgroundColors = @[[UIColor colorWithHexString:@"0xf8f8f8"], [UIColor colorWithHexString:@"0x303030"]];
    }
    return _bottomSafeAreaView;
}

@end
