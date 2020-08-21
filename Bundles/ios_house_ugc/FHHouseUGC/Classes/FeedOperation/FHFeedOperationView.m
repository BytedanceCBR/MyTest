//
//  FHFeedOperationView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/14.
//

#import "FHFeedOperationView.h"
#import "TTFeedDislikeKeywordsView.h"
#import "FHFeedOperationWord.h"
#import "SSThemed.h"

#import "TTThemeConst.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>

#import "TTFriendRelationService.h"
#import "TTAccessibilityElement.h"

// Modern
#import "TTFeedDislikeOptionSelectorView.h"
#import "TTFeedPopupController.h"
#import "extobjc.h"
#import "FHFeedOperationOption.h"
#import "TTGroupModel.h"
#import "TTReportManager.h"
#import "TTReportContentModel.h"
#import "TTFeedDislikeReportTextController.h"
#import "TTFeedDislikeKeywordSelectorView.h"
#import "TTReportDefine.h"
#import "UIView+CustomTimingFunction.h"
#import "TTFeedDislikeConfig.h"
#import "TTSandBoxHelper.h"
#import "TTIndicatorView.h"
#import "FHErrorHubManagerUtil.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>

#define kMaskViewTag 20141209

#pragma mark - global variable

// 在内存中保存上次选中的dislikeWords
static NSString *__lastGroupID;
static NSMutableArray *__lastDislikedWords;
static BOOL s_enable = YES;
static FHFeedOperationView *__visibleDislikeView;

#pragma mark - TTFeedDislikeView
@implementation FHFeedOperationViewModel
@end

#pragma mark - TTFeedDislikeView
//---------------------------------------------------------------
@interface FHFeedOperationView () <TTFeedDislikeKeywordsViewDelegate>
@property (nonatomic, strong) UIView *arrowBgView;
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) SSThemedButton *okBtn;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) TTFeedDislikeKeywordsView *keywordsView;
@property (nonatomic, strong) NSMutableArray *dislikeWords;
@property (nonatomic, strong) SSThemedButton *dislikeBtn;
@property (nonatomic, copy) NSString *adLogExtra;
@property (nonatomic, strong) TTFeedDislikeBlock didDislikeBlock;
@property (nonatomic, copy) TTFeedDislikeOptionBlock didDislikeWithOptionBlock;
@property (nonatomic, assign)TTFeedDislikeViewPushFrom pushFrom;
@property (nonatomic, assign) BOOL showUnFollowBtnFlag;  //红色确认按钮title是否显示取消关注
@property (nonatomic, strong) FHFeedOperationViewModel *viewModel;

// Modern
@property (nonatomic, strong) TTFeedDislikeOptionSelectorView *optionSelectorView;
@property (nonatomic, strong) TTFeedPopupController *navController;
@property (nonatomic) BOOL isArrowOnTop;
@property (nonatomic) BOOL forceHiddeArrow;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *commonTrackingParameters;

@end


@implementation FHFeedOperationView

- (void)dealloc {
    __visibleDislikeView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame_modern:frame];
}

- (void)refreshWithModel:(nullable FHFeedOperationViewModel *)model {
    [self modern_refreshWithModel:model];
}

- (void)refreshArrowUI {
    if ([FHFeedOperationView isFeedDislikeRefactorEnabled]) {
        NSString *imageName = @"ugc_pop_corner";
        [self.arrowImageView removeFromSuperview];
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:imageName inBundle:FHFeedOperationView.resourceBundle]];
        [_arrowImageView sizeToFit];
        [_arrowBgView addSubview:self.arrowImageView];
        _arrowBgView.height = _arrowImageView.height;
        _arrowImageView.top = self.arrowDirection == TTFeedPopupViewArrowUp ? 1.f : -1.f; // overlapping
        CGPoint arrowPoint = [self convertPoint:self.arrowPoint fromView:self.maskView];
        _arrowImageView.right = arrowPoint.x + 8;
        CGFloat angle = (self.arrowDirection == TTFeedPopupViewArrowUp ? 0 : M_PI);
        self.arrowImageView.transform = CGAffineTransformMakeRotation(angle);
    }
    else {
        NSString *imageName = self.arrowDirection == TTFeedPopupViewArrowUp ? @"arrow_up_popup_textpage.png" : @"arrow_down_popup_textpage.png";
        [self.arrowImageView removeFromSuperview];
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:imageName inBundle:FHFeedOperationView.resourceBundle]];
        [_arrowImageView sizeToFit];
        [_arrowBgView addSubview:self.arrowImageView];
        _arrowBgView.height = _arrowImageView.height;
        _arrowImageView.top = self.arrowDirection == TTFeedPopupViewArrowUp ? 1.f : -1.f; // overlapping
        CGPoint arrowPoint = [self convertPoint:self.arrowPoint fromView:self.maskView];
        _arrowImageView.right = arrowPoint.x + 8;
    }
    
}

- (void)refreshContentUI
{
    [self refreshOKBtn];
    [self refreshTitleLabel];
    
    if ([FHFeedOperationView isFeedDislikeRefactorEnabled]) {
        _keywordsView.origin = CGPointMake(0, [TTDeviceUIUtils tt_newPadding:20.f]);
        _okBtn.origin = CGPointMake(_contentBgView.width - [self leftPadding] - _okBtn.width, _keywordsView.bottom +  12.f);
        _titleLabel.centerX = ceilf(self.width / 4);
        _okBtn.width = [TTDeviceUIUtils tt_newPadding:140.f];
        _okBtn.height = [TTDeviceUIUtils tt_newPadding:40.f];
        _okBtn.centerX = self.width * 3 / 4 - 5;
        _okBtn.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:20.f];
        
        _titleLabel.centerY = _okBtn.centerY;
        _contentBgView.height = _okBtn.bottom + [TTDeviceUIUtils tt_newPadding:20.f];
        
        _titleLabel.left = ceilf(_titleLabel.left);
        _titleLabel.top = ceilf(_titleLabel.top);
    }
    else {
        _okBtn.origin = CGPointMake(_contentBgView.width - [self leftPadding] - _okBtn.width, 12.f);
        _titleLabel.left = [self leftPadding];
        _titleLabel.centerY = _okBtn.centerY;
        _keywordsView.origin = CGPointMake(0, _okBtn.bottom + 10.f);
        _contentBgView.height = _keywordsView.bottom + 12.f;
    }
    
}

- (void)refreshUI {
    if (self.dislikeWords.count == 0) {
        self.contentBgView.hidden = YES;
        self.arrowBgView.hidden = YES;
        self.dislikeBtn.hidden = NO;
        
        self.bounds = self.dislikeBtn.bounds;
    } else {
        self.contentBgView.hidden = NO;
        self.arrowBgView.hidden = NO;
        self.dislikeBtn.hidden = YES;
        
        [self refreshArrowUI];
        if (self.arrowDirection == TTFeedPopupViewArrowUp) {
            _arrowBgView.origin = CGPointMake(0, 0);
            _contentBgView.origin = CGPointMake(0, _arrowBgView.bottom);
            [self refreshContentUI];
        } else {
            _contentBgView.origin = CGPointMake(0, 0);
            [self refreshContentUI];
            _arrowBgView.origin = CGPointMake(0, _contentBgView.bottom);
        }
        
        self.height = _contentBgView.height + _arrowBgView.height;
    }
}

- (void)viewWillDisappear {
    __lastDislikedWords = self.dislikeWords;
}

- (void)okBtnClicked:(id)sender {
    
    if (self.didDislikeBlock) {
        self.didDislikeBlock(self);
    }
    
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    if (self.adLogExtra) {
        extValueDic[@"log_extra"] = self.adLogExtra;
    }
    
    if (self.dislikeWords.count > 0) {
        [self dismiss];
        
        [BDTrackerProtocol trackEventWithCustomKeys:@"dislike" label:@"dislike" value:__lastGroupID source:nil extraDic:extValueDic];
//        ttTrackEventWithCustomKeys(@"dislike", @"confirm_with_reason", __lastGroupID, nil, extValueDic);
        
        __lastDislikedWords = nil;
        __lastGroupID = nil;
        
    } else {
        [self showDislikeButton:NO atPoint:self.origin];
        
        [BDTrackerProtocol trackEventWithCustomKeys:@"dislike" label:@"confirm_no_reason" value:__lastGroupID source:nil extraDic:extValueDic];

//        ttTrackEventWithCustomKeys(@"dislike", @"confirm_no_reason", __lastGroupID, nil, extValueDic);
    }
}

- (void)clickMask {
    if ([self enableModernMode]) {
        [self modern_clickMask];
    } else {
        [self legacy_clickMask];
    }
}

- (void)legacy_clickMask {
    if (self.dislikeWords.count > 0) {
        [self dismiss];
    } else {
        [self showDislikeButton:NO atPoint:self.origin];
    }
}

//["id1", "id2", ...]
- (NSArray<NSString *> *)selectedWords {
    return [self modern_selectedWords];
}

#pragma mark - TTFeedDislikeKeywordsViewDelegate

- (void)dislikeKeywordsSelectionChanged {
    [self refreshOKBtn];
    [self refreshTitleLabel];
}

- (void)dismissWithAnimation:(BOOL)animation {
    [self dismiss:animation];
}

#pragma mark -

- (void)refreshOKBtn {
    
    if (self.showUnFollowBtnFlag) {
        [self.okBtn setTitle:@"取消关注" forState:UIControlStateNormal];
        [self.dislikeBtn setTitle:@"取消关注" forState:UIControlStateNormal];
    } else {
        if (self.selectedWords.count > 0) {
            [self.okBtn setTitle:@"确定" forState:UIControlStateNormal];
        } else {
            if ([FHFeedOperationView isFeedDislikeRefactorEnabled]) {
                [self.okBtn setTitle:@"不喜欢" forState:UIControlStateNormal];
            } else {
                [self.okBtn setTitle:@"不感兴趣" forState:UIControlStateNormal];
            }
        }
    }
}

- (void)refreshTitleLabel
{
    if (self.selectedWords.count > 0) {
        NSString * title = [NSString stringWithFormat:@"已选%lu个理由", (unsigned long)self.selectedWords.count];
        NSRange range = NSMakeRange(2, 1);
        NSMutableAttributedString * atrrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [atrrTitle setAttributes:@{ NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText4] } range:range];
        [self.titleLabel setAttributedText:atrrTitle];
    } else {
        [self.titleLabel setText:@"可选理由，精准屏蔽"];
    }
    
    [self.titleLabel sizeToFit];
    if ([FHFeedOperationView isFeedDislikeRefactorEnabled]) {
        self.titleLabel.centerX = ceilf(self.width / 4);
    }
    else {
        self.titleLabel.left = [self leftPadding];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    _contentBgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    if ([FHFeedOperationView isFeedDislikeRefactorEnabled]) {
        [self.titleLabel setTextColor:[UIColor tt_themedColorForKey:kColorText1]];
    }
    else {
        [self.titleLabel setTextColor:[UIColor tt_themedColorForKey:kColorText2]];
    }
}

- (void)showAtPoint:(CGPoint)p
           fromView:(UIView *)fromView
    didDislikeBlock:(TTFeedDislikeBlock)didDislikeBlock
{
    [self showAtPoint:p
             fromView:fromView
      didDislikeBlock:didDislikeBlock
             pushFrom:TTFeedDislikeViewPushFromRight];
}

- (void)showAtPoint:(CGPoint)arrowPoint
           fromView:(UIView *)fromView
didDislikeWithOptionBlock:(TTFeedDislikeOptionBlock)didDislikeWithOptionBlock {
    
    [self showAtPoint:arrowPoint
             fromView:fromView
      didDislikeBlock:nil
             pushFrom:TTFeedDislikeViewPushFromRight];
    
    self.didDislikeWithOptionBlock = didDislikeWithOptionBlock;
}

- (void)showAtPoint:(CGPoint)p
           fromView:(UIView *)fromView
    didDislikeBlock:(TTFeedDislikeBlock)didDislikeBlock
           pushFrom:(TTFeedDislikeViewPushFrom)pushFrom
{
    if ([self enableModernMode]) {
        [self modern_showAtPoint:p fromView:fromView didDislikeBlock:didDislikeBlock pushFrom:pushFrom];
    } else {
        [self legacy_showAtPoint:p fromView:fromView didDislikeBlock:didDislikeBlock pushFrom:pushFrom];
    }
}

- (void)legacy_showAtPoint:(CGPoint)p
                  fromView:(UIView *)fromView
           didDislikeBlock:(TTFeedDislikeBlock)didDislikeBlock
                  pushFrom:(TTFeedDislikeViewPushFrom)pushFrom
{
    if (!s_enable || !fromView) {
        return;
    }
    self.pushFrom = pushFrom;
    
    UIView *parentView = ({
        UIView *view;
        UIWindow *window = SSGetMainWindow();
        if (window.rootViewController.view) {
            view = window.rootViewController.view;
        } else {
            view = window;
        }
        
        view;
    });
    
    __visibleDislikeView = self;
    
    self.didDislikeBlock = didDislikeBlock;
    
    if (!self.maskView) {
        self.maskView = [UIButton buttonWithType:UIButtonTypeCustom];
        self.maskView.frame = parentView.bounds;
        self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.maskView addTarget:self action:@selector(clickMask) forControlEvents:UIControlEventTouchUpInside];
        self.maskView.accessibilityViewIsModal = YES;
        self.maskView.isAccessibilityElement = NO;
        [self.maskView addSubview:self];
        
        TTAccessibilityElement *element = [[TTAccessibilityElement alloc] initWithAccessibilityContainer:self.maskView];
        element.accessibilityLabel = @"关闭弹窗";
        WeakSelf;
        element.activateActionBlock = ^BOOL{
            StrongSelf;
            [self clickMask];
            return YES;
        };
        element.accessibilityFrame = UIAccessibilityConvertFrameToScreenCoordinates(parentView.bounds, parentView);
        self.maskView.accessibilityElements = @[element, self];
    }
    
    [parentView addSubview:self.maskView];
    [parentView bringSubviewToFront:self.maskView];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.titleLabel);
    
    self.maskView.tag = kMaskViewTag;
    
    p = [self.maskView convertPoint:p fromView:fromView.superview];
    
    CGPoint dislikeOrigin = p;
    self.arrowPoint = p;
    [self refreshUI];
    
    if (p.y + [self arrowOffsetY] + self.height + 15 > parentView.height) {
        p.y -= [self arrowOffsetY];
        self.arrowDirection = TTFeedPopupViewArrowDown;
        self.bottom = p.y;
    } else {
        p.y += [self arrowOffsetY];
        self.arrowDirection = TTFeedPopupViewArrowUp;
        self.top = p.y;
    }
    
    if ([FHFeedOperationView isFeedDislikeRefactorEnabled]) {
        if ([TTDeviceHelper isPadDevice]) {
            if (p.x + self.width/2 > self.maskView.width) {
                self.right = self.maskView.width - 15;
            } else {
                self.right = p.x + self.width/2;
            }
        } else {
            self.right = self.maskView.width;
            self.left = 0;
        }
    } else {
        if (self.pushFrom == TTFeedDislikeViewPushFromRight) {
            if (p.x + self.width/2 > self.maskView.width) {
                self.right = self.maskView.width - 15;
            } else {
                self.right = p.x + self.width/2;
            }
        } else {
            if (p.x - self.width/2 < 0) {
                self.left = 15;
            } else {
                self.left = p.x - self.width/2;
            }
        }
    }
    
    [self refreshUI];
    
    CGPoint arrowPoint = [self convertPoint:p fromView:self.maskView];
    
    if (self.frame.size.width > 0 && self.frame.size.height > 0) {
        CGRect frame = self.frame;
        self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.width, arrowPoint.y / self.height);
        self.frame = frame;
    }
    
    if (self.dislikeWords.count > 0) {
        self.alpha = 1.f;
        self.maskView.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
            //self.alpha = 1.f;
            self.maskView.alpha = 1.f;
        } completion:^(BOOL finished) {
            //self.alpha = 1.f;
            self.maskView.alpha = 1.f;
            [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:nil];
        }];
    } else {
        [self showDislikeButton:YES atPoint:dislikeOrigin];
    }
}

- (void)showDislikeButton:(BOOL)bShow atPoint:(CGPoint)dislikeOrigin {
    CGFloat w = [self dislikeButtonWidth];
    CGFloat h = [self dislikeButtonHeight];
    
    if (bShow) {
        self.alpha = 0.f;
        self.maskView.alpha = 0.f;
        CGPoint destPoint;
        if (self.pushFrom == TTFeedDislikeViewPushFromRight) {
            self.frame = CGRectMake(dislikeOrigin.x - [self dislikeButtonGapX], dislikeOrigin.y - h/2, 0, h);
            destPoint = CGPointMake(dislikeOrigin.x - [self dislikeButtonGapX] - w, dislikeOrigin.y - h/2);
        } else {
            self.frame = CGRectMake(dislikeOrigin.x + [self dislikeButtonGapX] - w, dislikeOrigin.y - h/2, 0, h);
            destPoint = CGPointMake(dislikeOrigin.x + [self dislikeButtonGapX], dislikeOrigin.y - h/2);
        }
        [UIView animateWithDuration:0.15 delay:0.f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.alpha = 1.f;
            self.maskView.alpha = 1.f;
            self.frame = CGRectMake(destPoint.x, destPoint.y, w, h);
        } completion:^(BOOL finished) {
            self.alpha = 1.f;
            self.maskView.alpha = 1.f;
        }];
    } else {
        CGPoint origin = self.origin;
        CGPoint destPoint;
        if (self.pushFrom == TTFeedDislikeViewPushFromRight) {
            destPoint = CGPointMake(origin.x + w, origin.y);
        } else {
            destPoint = CGPointMake(origin.x - w, origin.y);
        }
        [UIView animateWithDuration:0.15 delay:0.f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.alpha = 0.f;
            self.maskView.alpha = 0.f;
            self.frame = CGRectMake(destPoint.x, destPoint.y, 0, h);
        } completion:^(BOOL finished) {
            self.alpha = 0.f;
            self.maskView.alpha = 0.f;
            [self dismiss:NO];
        }];
    }
}

#pragma mark - size & height

- (CGFloat)leftPadding {
    static CGFloat padding = 0;
    if (padding == 0) {
        padding = 14.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
            case TTDeviceWidthMode375:
            case TTDeviceWidthMode320:
                padding = 12.f;
        }
    }
    return padding;
}

- (CGFloat)bottomPadding {
    static CGFloat padding = 0;
    if (padding == 0) {
        padding = 11.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
                padding = 12.f;
                break;
            case TTDeviceWidthMode375:
                padding = 11.f;
                break;
            case TTDeviceWidthMode320:
                padding = 10.f;
        }
    }
    return padding;
}

- (CGFloat)heightForTitleBar {
    static CGFloat h = 0;
    if (h == 0) {
        h = 37.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
                h = 38.f;
                break;
            case TTDeviceWidthMode375:
                h = 37.f;
                break;
            case TTDeviceWidthMode320:
                h = 36.f;
        }
    }
    return h;
}

- (CGFloat)fontSizeForTitleLabel {
    static float fontSize = 0;
    if (fontSize == 0) {
        fontSize = 15.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
            case TTDeviceWidthMode375:
                fontSize = 15.f;
                break;
            case TTDeviceWidthMode320:
                fontSize = 13.f;
        }
    }
    return fontSize;
}

- (CGFloat)fontSizeForSubTitleLabel {
    static float fontSize = 0;
    if (fontSize == 0) {
        fontSize = 12.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
                fontSize = 13.f;
                break;
            case TTDeviceWidthMode375:
                fontSize = 12.f;
                break;
            case TTDeviceWidthMode320:
                fontSize = 11.f;
        }
    }
    return fontSize;
}

- (CGFloat)buttonWidth {
    static float w = 0;
    if (w == 0) {
        w = 106.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
            case TTDeviceWidthMode375:
                w = 106.f;
                break;
            case TTDeviceWidthMode320:
                w = 100.f;
        }
    }
    return w;
}


- (CGFloat)buttonHeight {
    static float h = 0;
    if (h == 0) {
        h = 32.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
            case TTDeviceWidthMode375:
                h = 32.f;
                break;
            case TTDeviceWidthMode320:
                h = 30.f;
        }
    }
    return h;
}

- (CGFloat)fontSizeForButton {
    static float fontSize = 0;
    if (fontSize == 0) {
        fontSize = 17.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
            case TTDeviceWidthMode375:
                fontSize = 17.f;
                break;
            case TTDeviceWidthMode320:
                fontSize = 15.f;
        }
    }
    return fontSize;
}

- (CGFloat)buttonGapX {
    static float gapx = 0;
    if (gapx == 0) {
        gapx = 21.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
                gapx = 22.f;
                break;
            case TTDeviceWidthMode375:
                gapx = 21.f;
                break;
            case TTDeviceWidthMode320:
                gapx = 20.f;
        }
    }
    return gapx;
}

- (CGFloat)buttonRightPadding {
    static float gapx = 0;
    if (gapx == 0) {
        gapx = 11.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
                gapx = 12.f;
                break;
            case TTDeviceWidthMode375:
                gapx = 11.f;
                break;
            case TTDeviceWidthMode320:
                gapx = 10.f;
        }
    }
    return gapx;
}

- (CGFloat)arrowOffsetY {
    static float gapY = 0;
    if (gapY == 0) {
        gapY = 8.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
                gapY = 9.f;
                break;
            case TTDeviceWidthMode375:
                gapY = 8.f;
                break;
            case TTDeviceWidthMode320:
                gapY = 7.f;
        }
    }
    return gapY;
}

- (void)dismiss:(BOOL)animated {
    if ([self enableModernMode]) {
        [self modern_dismiss:animated];
    } else {
        [self legacy_dismiss:animated];
    }
}

- (void)legacy_dismiss:(BOOL)animated {
    if (self.dislikeWords.count > 0 && animated) {
        [self viewWillDisappear];
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            self.maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.maskView removeFromSuperview];
            self.maskView = nil;
        }];
    } else {
        [super dismiss:animated];
    }
    __visibleDislikeView = nil;
}

+ (void)dismissIfVisible {
    if (__visibleDislikeView) {
        [__visibleDislikeView dismiss:NO];
        __visibleDislikeView = nil;
        return;
    }
}

+ (void)enable
{
    s_enable = YES;
}

+ (void)disable
{
    s_enable = NO;
}

+ (BOOL)isFeedDislikeRefactorEnabled
{
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_article_feed_dislike_refactor"];
}

+ (NSBundle *)resourceBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle bundleForClass:self.class].resourcePath stringByAppendingPathComponent:@"TTFeedDislikeViewResource.bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}

#pragma mark - dislike btn

- (CGFloat)dislikeButtonWidth {
    static float w = 0;
    if (w == 0) {
        w = 106.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
            case TTDeviceWidthMode375:
                w = 106.f;
                break;
            case TTDeviceWidthMode320:
                w = 100.f;
        }
    }
    return w;
}

- (CGFloat)dislikeButtonHeight {
    static float h = 0;
    if (h == 0) {
        h = 32.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
            case TTDeviceWidthMode375:
                h = 32.f;
                break;
            case TTDeviceWidthMode320:
                h = 30.f;
        }
    }
    return h;
}

- (CGFloat)fontSizeForDislikeButton {
    static float fontSize = 0;
    if (fontSize == 0) {
        fontSize = 17.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
            case TTDeviceWidthMode375:
                fontSize = 17.f;
                break;
            case TTDeviceWidthMode320:
                fontSize = 15.f;
        }
    }
    return fontSize;
}

- (CGFloat)dislikeButtonGapX {
    static float w = 0;
    if (w == 0) {
        w = 17.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
                w = 18.f;
                break;
            case TTDeviceWidthMode375:
                w = 17.f;
                break;
            case TTDeviceWidthMode320:
                w = 16.f;
        }
    }
    return w;
}

- (CGFloat)dislikeButtonImageTitleSpacing {
    static float w = 0;
    if (w == 0) {
        w = 5.f;
        switch ([TTDeviceHelper deviceWidthType]) {
            case TTDeviceWidthModePad:
            case TTDeviceWidthMode414:
                w = 6.f;
                break;
            case TTDeviceWidthMode375:
                w = 5.f;
                break;
            case TTDeviceWidthMode320:
                w = 4.f;
        }
    }
    return w;
}

- (void)rootViewWillTransitionToSize:(NSNotification *)noti
{
    //    CGSize size = [noti.object CGSizeValue];
    [[self class] dismissIfVisible];
}

#pragma mark - Modern
// 尽量将新版本逻辑放在下面，减少对老代码的入侵，方便移除老代码

- (BOOL)enableModernMode {
    return [TTFeedDislikeConfig enableModernStyle];
}

- (instancetype)initWithFrame_modern:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!__lastDislikedWords) __lastDislikedWords = [NSMutableArray arrayWithCapacity:10];
        _dislikeWords = [NSMutableArray arrayWithCapacity:10];
        _adLogExtra = @"";
        
        _commonTrackingParameters = [NSMutableDictionary dictionary];
        
        self.backgroundColor = [UIColor clearColor];
        self.width = SSGetMainWindow().width - 30.0;
        self.left = 15.0;
        
        _contentBgView = ({
            UIView *v = [UIView new];
            v.backgroundColor = [UIColor whiteColor];
            v.layer.cornerRadius = 6.f;
            v.clipsToBounds = YES;
            v;
        });
        [self addSubview:_contentBgView];
        
        _arrowBgView = ({
            UIView *v = [UIView new];
            v.backgroundColor = [UIColor clearColor];
            v;
        });
        [self addSubview:_arrowBgView];
        
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"arrow_up_popup_textpage" inBundle:FHFeedOperationView.resourceBundle]];
        [_arrowBgView addSubview:_arrowImageView];
        
        _optionSelectorView =({
            TTFeedDislikeOptionSelectorView *v = [TTFeedDislikeOptionSelectorView new];
            @weakify(self);
            [v setSelectionFinished:^(FHFeedOperationWord * _Nonnull keyword, FHFeedOperationOptionType optionType) {
                @strongify(self);
                self.selectdWord = keyword;
                [self finishSelectionAnimated:YES];
                if (self.didDislikeWithOptionBlock) self.didDislikeWithOptionBlock(self, optionType);
            }];
            
            v.dislikeTracerBlock = ^{
                @strongify(self);
                if(self.dislikeTracerBlock){
                    self.dislikeTracerBlock();
                }
            };
            
            if ([TTSandBoxHelper isInHouseApp] && [self shouldShowDebug]) {
                UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressSelectorView:)];
                gesture.minimumPressDuration = 1.0;
                [v addGestureRecognizer:gesture];
            }
            
            v;
        });
        
        [self reloadThemeUI];
        
        _navController = [[TTFeedPopupController alloc] initWithContainer:self contentView:_contentBgView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootViewWillTransitionToSize:) name:@"kRootViewWillTransitionToSize" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startReportProcess:) name:FeedDislikeNeedReportNotification object:nil];
    }
    return self;
}

- (void)didLongPressSelectorView:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"%@", self.viewModel.groupID];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拷贝成功" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
}

- (void)modern_refreshWithModel:(nullable FHFeedOperationViewModel *)model {
    self.viewModel = model;
    NSString *groupID = model.groupID;
    self.adLogExtra = model.logExtra;

    NSMutableDictionary<NSString *, NSString *> *commonTrackingParameters = self.commonTrackingParameters;
    commonTrackingParameters[@"position"] = @"list";
    commonTrackingParameters[@"group_id"] = groupID;
    commonTrackingParameters[@"item_id"] = groupID;
    commonTrackingParameters[@"category_name"] = model.categoryID;
    if (model.categoryID) {
        commonTrackingParameters[@"enter_from"] = [model.categoryID isEqualToString:@"__all__"] ? @"click_headline" : @"click_category";
    }
    // 业务方透传字段在这里加上
    if (model.trackExtraDict) {
        [commonTrackingParameters addEntriesFromDictionary:model.trackExtraDict];
    }
    
//    NSArray *keywords = model.keywords;
    
//    if (keywords != nil && keywords.count > 0) {
        // 如果上次已选择过，使用上次的选择，理论上应该全量比较__lastDislikedWords和keywords，关键词完全一致才能使用之前缓存的
//        if ([__lastGroupID isEqualToString:groupID] && __lastDislikedWords.count == keywords.count) {
//            self.dislikeWords = __lastDislikedWords;
//        } else {
//            [self.dislikeWords removeAllObjects];
//            [__lastDislikedWords removeAllObjects];

//            for (NSDictionary *dict in keywords) {
//                if ([dict isKindOfClass:[NSDictionary class]]) {
//                    FHFeedOperationWord *word = [[FHFeedOperationWord alloc] initWithDict:dict];
//                    [self.dislikeWords addObject:word];
//                }
//            }
//        }
//
//        __lastGroupID = groupID;

//        NSMutableArray<FHFeedOperationWord *> *items = @[].mutableCopy;
//        [items addObjectsFromArray:self.dislikeWords];
//    }
    
    
    self.optionSelectorView.commonTrackingParameters = commonTrackingParameters;
    
    NSArray<FHFeedOperationWord *> *items = [TTFeedDislikeConfig operationWordListWithViewModel:self.viewModel];
//    if(self.viewModel.permission.count > 0){
//        items = [TTFeedDislikeConfig operationWordListWithPermission:self.viewModel.permission];
//    }else{
//        items = [TTFeedDislikeConfig operationWordList:self.viewModel.userID];
//    }
    
    if ([TTSandBoxHelper isInHouseApp] && [self shouldShowDebug]) {
        for (FHFeedOperationWord *word in items) {
            word.title = [word.title stringByAppendingString:[NSString stringWithFormat:@"  jid:%@",self.viewModel.groupID]];
        }
    }
    
    [self.optionSelectorView refreshWithkeywords:items];
}

- (BOOL)shouldShowDebug {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kUGCDebugConfigKey"];
}

- (void)modern_showAtPoint:(CGPoint)p
                  fromView:(UIView *)fromView
           didDislikeBlock:(TTFeedDislikeBlock)didDislikeBlock
                  pushFrom:(TTFeedDislikeViewPushFrom)pushFrom
{
    if (!s_enable || !fromView) return;
    __visibleDislikeView = self;
    self.didDislikeBlock = didDislikeBlock;
    
    UIView *parentView = SSGetMainWindow().rootViewController.view ? : SSGetMainWindow();
    self.maskView = self.maskView ? : ({
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.isAccessibilityElement = NO;
        b.accessibilityViewIsModal = YES;
        b.frame = parentView.bounds;
        b.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [b addTarget:self action:@selector(clickMask) forControlEvents:UIControlEventTouchUpInside];
        [b addSubview:self];
        
        TTAccessibilityElement *element = [[TTAccessibilityElement alloc] initWithAccessibilityContainer:b];
        element.accessibilityLabel = @"关闭弹窗";
        WeakSelf;
        element.activateActionBlock = ^BOOL{
            StrongSelf;
            [self clickMask];
            return YES;
        };
        element.accessibilityFrame = UIAccessibilityConvertFrameToScreenCoordinates(parentView.bounds, parentView);
        b.accessibilityElements = @[element, self];
        b;
    });
    self.maskView.tag = kMaskViewTag;
    [parentView addSubview:self.maskView];
    [parentView bringSubviewToFront:self.maskView];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.optionSelectorView.tableView.visibleCells.firstObject);
    
    CGPoint arrowPoint = [self.maskView convertPoint:p fromView:fromView.superview];
    self.arrowPoint = arrowPoint;
    BOOL isArrowOnTop = arrowPoint.y < parentView.height / 2;;
    self.isArrowOnTop = isArrowOnTop;
    self.navController.isArrowOnTop = isArrowOnTop;
    [self.navController pushView:self.optionSelectorView animated:NO];
    if (isArrowOnTop) {
        self.top = arrowPoint.y + [self arrowOffsetY] - 3.0;
    } else {
        self.bottom = arrowPoint.y - [self arrowOffsetY] + 3.0;
    }
    
    CGFloat topEdge = 100.0 + 8.0;
    CGFloat bottomEdge = parentView.height - (44.0 + 8.0);
    if (self.top < topEdge) {
        self.top = topEdge;
        self.forceHiddeArrow = YES;
    } else if (self.bottom > bottomEdge) {
        self.bottom = bottomEdge;
        self.forceHiddeArrow = YES;
    }
    
    CGRect containerToFrame = self.frame;
    CGRect containerFromFrame = containerToFrame;
    if (!isArrowOnTop) {
        containerFromFrame.origin.y += containerFromFrame.size.height;
    }
    containerFromFrame.size.height = 0.0;
    
    CGRect contentToFrame = self.optionSelectorView.frame;
    CGRect contentFromFrame = contentToFrame;
    if (isArrowOnTop) {
        contentFromFrame.origin.y -= 10.0;
        
    } else {
        contentFromFrame.origin.y += 10.0;
    }
    
    self.frame = containerFromFrame;
    self.optionSelectorView.frame = contentFromFrame;
    self.maskView.alpha = 0.0;
    [UIView animateWithDuration:0.3 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        self.frame = containerToFrame;
        self.optionSelectorView.frame = contentToFrame;
        self.maskView.alpha = 1.0;
    }];
    
//    [self trackEvent:@"dislike_menu_show" extraParameters:nil];
}

- (NSArray<NSString *> *)modern_selectedWords {
    NSMutableArray *arr = [NSMutableArray array];
    if (!isEmptyString(self.selectdWord.ID)) [arr addObject:self.selectdWord.ID];
    return arr;
}

- (void)finishSelectionAnimated:(BOOL)animated {
    [self dismiss:animated];
    
    if(self.selectdWord.type == FHFeedOperationWordTypeReport){
        //举报
        NSString *reportType = nil;
        if([self.selectdWord.ID containsString:@":"]){
            NSUInteger index = [self.selectdWord.ID rangeOfString:@":"].location;
            if(index < self.selectdWord.ID.length){
                reportType = [self.selectdWord.ID substringFromIndex:([self.selectdWord.ID rangeOfString:@":"].location + 1)];
            }
        }
        
        [self reportingWithType:reportType criticism:nil];
    }
    
    if (self.didDislikeBlock) self.didDislikeBlock(self);
}

- (void)modern_dismiss:(BOOL)animated {
    self.alpha = 0.0;
    [super dismiss:animated];
    __visibleDislikeView = nil;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if ([self enableModernMode]) {
        [self layoutArrowView];
        [self layoutContentView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self enableModernMode]) {
        [self layoutArrowView];
        [self layoutContentView];
    }
}

- (void)layoutArrowView {
    self.arrowBgView.height = 8.0;
    self.arrowBgView.width = self.width;
    self.arrowBgView.top = self.isArrowOnTop ? 0.0 : self.height - 8.0;
    
    CGPoint arrowPoint = [self convertPoint:self.arrowPoint fromView:self.maskView];
    BOOL isArrowOnLeft = arrowPoint.x < self.arrowBgView.width / 2.0;
    self.arrowImageView.transform =
    CGAffineTransformMakeScale(isArrowOnLeft ? -1.0 : 1.0, self.isArrowOnTop ? 1.0 : -1.0);
    self.arrowImageView.size = CGSizeMake(36.0, 8.0);
    // 修复 iPhoneX 上箭头和视图之间出现缝隙的问题
    self.arrowImageView.top = self.isArrowOnTop ? 1.0 : -1.0;
    self.arrowImageView.right = isArrowOnLeft ? arrowPoint.x + 30.0 : arrowPoint.x + 3.0;
    self.arrowImageView.hidden = self.forceHiddeArrow || self.arrowImageView.left < 0 || self.arrowImageView.right > self.arrowBgView.width;
}

-(void)layoutContentView {
    if (self.isArrowOnTop) {
        self.contentBgView.top = 8.0;
    } else {
        self.contentBgView.bottom = self.height - 8.0;
    }
}

- (void)modern_clickMask {
    [self dismiss];
    [self trackEvent:@"dislike_menu_cancel" extraParameters:nil];
}

- (void)startReportProcess:(NSNotification *)notification {
    [self trackEvent:@"dislike_menu_spitslot_click" extraParameters:nil];
    
    [self dismiss:NO];
    // 注意：这里不要使用 weak self，否则会导致 self 过早释放
    [TTFeedDislikeReportTextController triggerTextReportProcessCompleted:^(NSString *message) {
        if (!isEmptyString(message)) {
            [self trackEvent:@"rt_dislike" extraParameters:@{@"dislike_type" : @"spitslot", @"content" : message}];
            [self reportingWithType:@"0" criticism:message];
            [self finishSelectionAnimated:NO];
        }
    }];
}

/// 举报
- (void)reportingWithType:(NSString *)type criticism:(NSString *)criticism {
    NSString *groupID = self.viewModel.groupID;
    NSString *itemID = groupID;
    NSString *adID = self.viewModel.adID;
    NSString *videoID = self.viewModel.videoID;
    NSString *categoryID = self.viewModel.categoryID;
    
    if (isEmptyString(type) && isEmptyString(criticism) || isEmptyString(groupID)) return;
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
//    if (self.adLogExtra) extraDic[@"extra"] = self.adLogExtra;
    
    TTReportContentModel *model = [[TTReportContentModel alloc] init];
    model.groupID = groupID;
    model.itemID = itemID;
    model.adID = adID;
    model.videoID = videoID;
    
    NSString *reportFrom = [NSString stringWithFormat:@"%@_cell", TTReportFromByEnterFromAndCategory(nil, categoryID)];
    
    [[TTReportManager shareInstance] startReportContentWithType:type inputText:criticism contentType:nil reportFrom:reportFrom contentModel:model extraDic:extraDic animated:NO];
}

- (void)trackEvent:(NSString *)event extraParameters:(NSDictionary *)extraParameters {
    if (isEmptyString(event)) return;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (self.commonTrackingParameters) {
        [parameters addEntriesFromDictionary:self.commonTrackingParameters];
    }
    if (extraParameters) {
        [parameters addEntriesFromDictionary:extraParameters];
    }
    [FHErrorHubManagerUtil checkBuryingPointWithEvent:event Params:parameters];
    [BDTrackerProtocol eventV3:event params:parameters];
}

@end
