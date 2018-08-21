//
//  WDDetailSlideNavigationView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/22.
//
//

#import "WDDetailSlideNavigationView.h"
#import "WDDetailSlideBackButtonView.h"
#import "WDDetailSlideMoreButtonView.h"
#import "WDDetailModel.h"
#import "WDAnswerEntity.h"
#import "WDDetailTitleView.h"

#import "NSObject+FBKVOController.h"
#import "TTUIResponderHelper.h"
#import "WDSettingHelper.h"

@interface WDDetailSlideNavigationView ()

@property (nonatomic, strong) SSThemedView *bgView;
@property (nonatomic, strong) TTAlphaThemedButton *transparentButton;
@property (nonatomic, strong) SSThemedView *bottomLineView;
@property (nonatomic, strong) WDDetailSlideBackButtonView *backButtonView;
@property (nonatomic, strong) WDDetailSlideMoreButtonView *moreButtonView;
@property (nonatomic, strong) WDDetailTitleView *titleView;
@property (nonatomic, strong) WDDetailModel *detailModel;

@end

@implementation WDDetailSlideNavigationView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if ([TTDeviceHelper isPadDevice]) {
            self.backgroundColorThemeKey = kColorBackground4;
        }
        else {
            self.backgroundColor = [UIColor clearColor];
        }
    }
    return self;
}

#pragma mark - public

- (void)setShowSlideType:(NSInteger)showSlideType {
    _showSlideType = showSlideType;
    [self addBgViewAndTransparentButton];
    [self addBottomLineView];
    [self addBackButton];
}

- (void)addExtraViewWithDetailModel:(WDDetailModel *)detailModel {
    self.detailModel = detailModel;
    [self p_buildTitleView];
    [self bringSubviewToFront:self.transparentButton];
    [self bringSubviewToFront:self.backButtonView];
    [self addMoreButton];
}

- (void)setTitleShow:(BOOL)show {
    [self.titleView show:show animated:YES];
    if (self.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        return;
    }
    self.backButtonView.style = show ? WDDetailBackButtonStyleDefault : WDDetailBackButtonStyleLightContent;
    self.moreButtonView.style = show ? WDDetailMoreButtonStyleDefault : WDDetailMoreButtonStyleLightContent;
    self.bottomLineView.hidden = !show;
    if (show) {
        self.bgView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    }
    else {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.bgView.backgroundColor = [UIColor colorWithHexString:@"#67778B"];
        }
        else {
            self.bgView.backgroundColor = [UIColor colorWithHexString:@"#333B45"];
        }
    }
}

- (void)reLayoutSubviews {
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        CGRect rect = CGRectMake(edgePadding, 0, windowSize.width - edgePadding*2, self.height);
        self.bgView.frame = rect;
        self.transparentButton.frame = rect;
        self.moreButtonView.left = self.width - 46;
        [self updateTitleViewPosition];
    }
}

- (void)statusBarHeightChanged {
    self.backButtonView.top = self.height - self.backButtonView.height;
    self.moreButtonView.top = self.height - self.moreButtonView.height;
    self.titleView.top = self.height - self.backButtonView.height;
    self.bottomLineView.top = self.height - [TTDeviceHelper ssOnePixel];
    CGRect rect = self.bounds;
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        rect = CGRectMake(edgePadding, 0, windowSize.width - edgePadding*2, self.height);
    }
    self.bgView.frame = rect;
    self.transparentButton.frame = rect;
}

- (BOOL)isTitleShow {
    return self.titleView.isShow;
}

#pragma mark - private

- (void)addBgViewAndTransparentButton {
    
    CGRect rect = self.bounds;
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        rect = CGRectMake(edgePadding, 0, windowSize.width - edgePadding*2, self.height);
    }
    self.bgView = [[SSThemedView alloc] initWithFrame:rect];
    if (self.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        self.backgroundColorThemeKey = kColorBackground4;
    }
    else {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.bgView.backgroundColor = [UIColor colorWithHexString:@"#67778B"];
        }
        else {
            self.bgView.backgroundColor = [UIColor colorWithHexString:@"#333B45"];
        }
    }
    [self addSubview:self.bgView];
    
    self.transparentButton = [[TTAlphaThemedButton alloc] init];
    self.transparentButton.backgroundColor = [UIColor clearColor];
    [self.transparentButton addTarget:self action:@selector(titleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.transparentButton.frame = rect;
    [self addSubview:self.transparentButton];
}

- (void)addBottomLineView{
    self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.bounds), [TTDeviceHelper ssOnePixel])];
    self.bottomLineView.backgroundColorThemeKey = kColorLine1;
    self.bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.bottomLineView.hidden = (self.showSlideType == AnswerDetailShowSlideTypeBlueHeaderWithHint);
    [self addSubview:self.bottomLineView];
}

- (void)addBackButton {
    self.backButtonView = [[WDDetailSlideBackButtonView alloc] initWithFrame:WDDetailSlideBackButtonFrame()];
    self.backButtonView.style = (self.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) ? WDDetailBackButtonStyleDefault : WDDetailBackButtonStyleLightContent;
    [self.backButtonView.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    if ([TTDeviceHelper isPadDevice]) {
        self.backButtonView.left = 12;
    }
    else {
        self.backButtonView.left = 8;
    }
    self.backButtonView.top = self.height - self.backButtonView.height;
    [self addSubview:self.backButtonView];
}

- (void)addMoreButton {
    self.moreButtonView = [[WDDetailSlideMoreButtonView alloc] initWithFrame:WDDetailSlideMoreButtonFrame()];
    self.moreButtonView.style = (self.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) ? WDDetailMoreButtonStyleDefault : WDDetailMoreButtonStyleLightContent;
    [self.moreButtonView.moreButton addTarget:self action:@selector(moreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    if ([TTDeviceHelper isPadDevice]) {
        self.moreButtonView.left = self.width - 46;
    }
    else {
        self.moreButtonView.left = self.width - 41;
    }
    self.moreButtonView.top = self.height - self.moreButtonView.height;
    [self addSubview:self.moreButtonView];
}

- (void)p_buildTitleView {
    
    self.titleView = [[WDDetailTitleView alloc] initWithFrame:CGRectZero fontSize:(self.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) ? 16 : 14];
    self.titleView.top = self.height - self.backButtonView.height;
    [self addSubview:self.titleView];
    [self updateTitleViewPosition];
    
    WeakSelf;
//    [self.titleView setTapHandler:^{
//        StrongSelf;
//        [self titleButtonTapped];
//    }];
    
    if (self.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        [self.KVOController observe:self.detailModel keyPath:NSStringFromSelector(@selector(allAnswerText)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self updateTitleViewPosition];
        }];
    }
    else {
        [self.KVOController observe:self.detailModel.answerEntity keyPath:NSStringFromSelector(@selector(questionTitle)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self updateTitleViewPosition];
        }];
    }
}

- (void)updateTitleViewPosition {
    if (self.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        [self.titleView updateNavigationTitle:self.detailModel.allAnswerText];
    }
    else {
        [self.titleView updateNavigationTitle:self.detailModel.answerEntity.questionTitle];
    }
    CGFloat val = 132;
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        val = 132 + 2 * edgePadding;
    }
    if (self.titleView.width > self.width - val) {
        self.titleView.width = self.width - val;
    }
    self.titleView.centerX = self.width / 2.0;
}

#pragma mark - action

- (void)backButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wdDetailSlideNaviViewBackButtonTapped)]) {
        [self.delegate wdDetailSlideNaviViewBackButtonTapped];
    }
}

- (void)moreButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wdDetailSlideNaviViewMoreButtonTapped)]) {
        [self.delegate wdDetailSlideNaviViewMoreButtonTapped];
    }
}

- (void)titleButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wdDetailSlideNaviViewTitleButtonTapped)]) {
        [self.delegate wdDetailSlideNaviViewTitleButtonTapped];
    }
}

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    if (self.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) return;

    if ([self isTitleShow]) {
        self.bgView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    }
    else {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.bgView.backgroundColor = [UIColor colorWithHexString:@"#67778B"];
        }
        else {
            self.bgView.backgroundColor = [UIColor colorWithHexString:@"#333B45"];
        }
    }
}

@end
