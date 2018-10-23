//
//  WDBottomToolView.m
//  Article
//
//  Created by 延晋 张 on 2016/12/2.
//
//

#import "WDBottomToolView.h"
#import "UIButton+TTAdditions.h"
#import "TTAlphaThemedButton.h"
#import "WDDetailModel.h"
#import "WDAnswerEntity.h"
#import "TTBusinessManager+StringUtils.h"
#import "WDAnswerService.h"
#import <TTBubbleView.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/SSMotionRender.h>
#import <KVOController/NSObject+FBKVOController.h>

//#import "TTUGCEmojiTextAttachment.h"

static NSString * const kWDHasTipSupportsEmojiInputDefaultKey = @"WDHasTipSupportsEmojiInputDefaultKey";

@interface WDBottomToolView ()

@property (nonatomic, strong) TTBubbleView *bubbleView;

@end

@implementation WDBottomToolView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        BOOL _isIPad = [TTDeviceHelper isPadDevice];
        TTAlphaThemedButton *writeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [writeButton setTitle:@"写评论..." forState:UIControlStateNormal];
        writeButton.height = [TTDeviceHelper isPadDevice] ? [TTDeviceUIUtils tt_newPadding:36] : [TTDeviceUIUtils tt_newPadding:32];
        writeButton.titleLabel.font = [UIFont systemFontOfSize:(_isIPad ? 18 : 13)];
        writeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        writeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 8.f, 0, 0);
        writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, _isIPad ? 25 : 8, 0, 0);
        writeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [writeButton addTarget:self action:@selector(writeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:writeButton];
        _writeButton = writeButton;
        _writeButton.borderColors = nil;
        _writeButton.borderColorThemeKey = kColorLine1;
        _writeButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _writeButton.titleColorThemeKey = kColorText1;
        _writeButton.layer.cornerRadius = _writeButton.height / 2.f;
        _writeButton.backgroundColorThemeKey = kColorBackground3;
        _writeButton.layer.masksToBounds = YES;
        
        [_writeButton setImageName:@"write_new"];
        _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        
        UIEdgeInsets toolBarButtonHitTestInsets = UIEdgeInsetsMake(-8.f, -12.f, -15.f, -12.f);
        
        TTAlphaThemedButton *emojiButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:emojiButton];
        _emojiButton = emojiButton;
        [_emojiButton addTarget:self action:@selector(emojiButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _emojiButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _emojiButton.imageName = @"input_emoji";
        if ([TTDeviceHelper isPadDevice]) { // iPad 暂时不支持
            [self setBanEmojiInput:YES];
        }

        TTAlphaThemedButton *commentButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:commentButton];
        _commentButton = commentButton;
        [_commentButton addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _commentButton.imageName = @"tab_comment";

        self.badgeLabel = [[SSThemedLabel alloc] init];
        self.badgeLabel.backgroundColorThemeKey = kColorBackground7;
        self.badgeLabel.textColorThemeKey = kColorText8;
        self.badgeLabel.font = [UIFont systemFontOfSize:8];
        self.badgeLabel.layer.cornerRadius = 5;
        self.badgeLabel.layer.masksToBounds = YES;
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        [_commentButton addSubview:self.badgeLabel];
        
        TTAlphaThemedButton *digButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _digButton = digButton;
        _digButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        _digButton.imageName = @"tab_like";
        _digButton.selectedImageName = @"tab_like_press";
        [_digButton addTarget:self action:@selector(diggButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:digButton];
        
        SSThemedButton *nextButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:nextButton];
        _nextButton = nextButton;
        _nextButton.imageName = @"tab_next";
        _nextButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
        [_nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _separatorView = [[SSThemedView alloc] init];
        _separatorView.backgroundColorThemeKey = kColorLine7;
        _separatorView.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
        _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_separatorView];
        
        self.backgroundColorThemeKey = kColorBackground4;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWriteTitle:) name:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil];
    }
    return self;
}

- (void)setDetailModel:(WDDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    [self addKVO];
}

#pragma mark - Private

- (void)addKVO
{
    [self.KVOController unobserveAll];
    
    [self setCommentBadgeValue:[self.detailModel.answerEntity.commentCount stringValue]];
    [self.KVOController observe:self.detailModel.answerEntity keyPath:NSStringFromSelector(@selector(commentCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSString *commentCount = [change tt_stringValueForKey:NSKeyValueChangeNewKey];
        WDBottomToolView *bottomToolView = observer;
        [bottomToolView setCommentBadgeValue:commentCount];
    }];
    
    self.digButton.selected = self.detailModel.answerEntity.isDigg;
    [self.KVOController observe:self.detailModel.answerEntity keyPath:NSStringFromSelector(@selector(isDigg)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        BOOL isDigg = [change tt_boolValueForKey:NSKeyValueChangeNewKey];
        WDBottomToolView *bottomToolView = observer;
        bottomToolView.digButton.selected = isDigg;
    }];
    
    [self updateNextButtonWithHasNext:self.detailModel.hasNext];
    [self.KVOController observe:self.detailModel keyPath:NSStringFromSelector(@selector(hasNext)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        WDBottomToolView *bottomToolView = observer;
        BOOL hasNext = [change tt_boolValueForKey:NSKeyValueChangeNewKey];
        [bottomToolView updateNextButtonWithHasNext:hasNext];
    }];
}

- (void)updateNextButtonWithHasNext:(BOOL)hasNext
{
    if (hasNext) {
        self.nextButton.alpha = 1.0f;
    } else {
        self.nextButton.alpha = 0.5f;
    }
}

- (void)updateWriteTitle:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (![userInfo tt_boolValueForKey:@"hasComments"]) {
        [self.writeButton setTitle:@"抢沙发..." forState:UIControlStateNormal];
    }
    else {
        [self.writeButton setTitle:@"写评论..." forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat leftInset = self.tt_safeAreaInsets.left;
    CGFloat rightInset = self.tt_safeAreaInsets.right;
    CGFloat hInset = leftInset + rightInset;//水平缩进
    CGFloat bottomSafeInset = self.tt_safeAreaInsets.bottom;
    CGFloat writeButtonHeight = [TTDeviceHelper isPadDevice] ? 36 : 32;
    CGFloat writeTopMargin = ((NSInteger)self.height - writeButtonHeight - bottomSafeInset) / 2;
    CGFloat iconTopMargin = ((NSInteger)self.height - 24 - bottomSafeInset) / 2;
    CGRect writeFrame = CGRectZero, emojiFrame = CGRectZero, commentFrame = CGRectZero, nextFrame = CGRectZero, digFrame = CGRectZero;
    CGFloat width = self.width;
    CGFloat margin = [TTDeviceHelper is736Screen] ? 10 : ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]?5:0);
    writeFrame = CGRectMake(15 + leftInset, writeTopMargin, width - (169 + margin * 3) - hInset, writeButtonHeight);
    emojiFrame = CGRectMake(CGRectGetMaxX(writeFrame) - 22 - 6, CGRectGetMinY(writeFrame) + 5, 22, 22);
    commentFrame = CGRectMake(CGRectGetMaxX(writeFrame) + 22 + margin, iconTopMargin, 24, 24);
    nextFrame = CGRectMake(width - 38 - rightInset, iconTopMargin, 24, 24);
    digFrame = CGRectMake(CGRectGetMinX(nextFrame) - 46 - margin, iconTopMargin, 24, 24);
    
    _writeButton.frame = writeFrame;
    _emojiButton.frame = emojiFrame;
    _commentButton.frame = commentFrame;
    _digButton.frame = digFrame;
    _nextButton.frame = nextFrame;
    
    BOOL _isIPad = [TTDeviceHelper isPadDevice];
    _writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, _isIPad ? 25 : 8, 0, _emojiButton.width + 4);
    
    [self relayoutItems];
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInset = self.superview.safeAreaInsets;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGRect frameInWindow = [self convertRect:self.bounds toView:nil];
        if (ceil(self.height) - ceil(WDDetailGetToolbarHeight()) == 0 &&
            screenHeight == ceil(CGRectGetMaxY(frameInWindow))){
            CGFloat toolBarHeight = (WDDetailGetToolbarHeight() + safeInset.bottom);
            frameInWindow = CGRectMake(frameInWindow.origin.x, screenHeight - toolBarHeight, self.width,toolBarHeight);
            self.frame = [self.superview convertRect:frameInWindow fromView:nil];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    if (CGRectGetHeight(frame) == 0){
        frame.size.height = WDDetailGetToolbarHeight();
    }
    [super setFrame:frame];
}

/*
 *  ipad上根据屏幕宽度重刷item位置
 */
- (void)relayoutItems
{
    if (![TTDeviceHelper isPadDevice]) {
        return;
    }
    /*
     *  ipad下toolbarItem布局规则: l表示_writeButton宽度，m0_m1_m2表示四个item的三个间距；
     *  整个toolbar两边边距按基本规则算出；
     *  屏幕最窄时，l取最小宽度120, m0_m1_m2压缩；
     *  (1)屏幕逐渐变宽，m0_m1_m2持续拉伸；
     *  (2)m0_m1_m2到达44_44_40后不再拉伸，l开始拉伸；
     *  (3)l拉伸至最大宽度465后不再拉伸，转而拉伸m0_m1_m2；
     *  (4)m0_m1_m2再次拉伸至最大值110_110_106后不再拉伸，转而拉伸l，直至无限大；
     *
     *  特殊情况：图集详情界面会多出个下载按钮，
     *          与上述最后一个 Button 的间距为 44(对应上述情况(2)) 和 110(对应上述情况(4))，
     *          间距变化计算规则同上述。
     */
    
    
    static CGFloat writeMinLen = 120.f;
    static CGFloat writeMaxLen = 465.f;
    static CGFloat firstMarginAspect = 1.1f;
    
    CGFloat mSumMinLen = 44.f + 44.f + 40.f;
    CGFloat mSumMaxLen = 110.f + 110.f + 106.f;
    CGFloat marginAspects = 1.1f + 1.1f + 1.0f;
    
    CGFloat baseItemMargin;
    CGFloat edgeMargin = [TTUIResponderHelper paddingForViewWidth:self.width];
  
    CGFloat fixWidthOfRightItems = _commentButton.width + _nextButton.width + _digButton.width;
    CGFloat checkWidth = self.width - edgeMargin * 2 - fixWidthOfRightItems;
    _writeButton.left = edgeMargin;
    if (checkWidth < writeMinLen + mSumMinLen) {
        //case(1)
        _writeButton.width = writeMinLen;
        baseItemMargin = (checkWidth - _writeButton.width)/marginAspects;
        _commentButton.left = _writeButton.right + baseItemMargin * firstMarginAspect;
        _emojiButton.right = _commentButton.right - 22 - 6;
        _digButton.left = _commentButton.right + baseItemMargin * firstMarginAspect;
        _nextButton.left = _digButton.right + baseItemMargin;
    }
    else if (checkWidth < writeMaxLen + mSumMinLen) {
        //case(2)
        _writeButton.width = checkWidth - mSumMinLen;
        _emojiButton.right = _commentButton.right - 22 - 6;
        _commentButton.left = _writeButton.right + 44.f;
        _digButton.left = _commentButton.right + 44.f;
        _nextButton.left = _digButton.right + 40.f;
    }
    else if (checkWidth < writeMaxLen + mSumMaxLen) {
        //case(3)
        _writeButton.width = writeMaxLen;
        _emojiButton.right = _commentButton.right - 22 - 6;
        baseItemMargin = (checkWidth - _writeButton.width)/marginAspects;
        _commentButton.left = _writeButton.right + baseItemMargin * firstMarginAspect;
        _digButton.left = _commentButton.right + baseItemMargin * firstMarginAspect;
        _nextButton.left = _digButton.right + baseItemMargin;
    }
    else {
        //case(4)
        _writeButton.width = checkWidth - mSumMaxLen;
        _emojiButton.right = _commentButton.right - 22 - 6;
        _commentButton.left = _writeButton.right + 110.f;
        _digButton.left = _commentButton.right + 110.f;
        _nextButton.left = _digButton.right + 106.f;
    }
}

- (void)setCommentBadgeValue:(NSString *)commentBadgeValue {
    int64_t value = [commentBadgeValue longLongValue];
    commentBadgeValue = [TTBusinessManager formatCommentCount:value];
    if ([commentBadgeValue integerValue] == 0) {
        commentBadgeValue = nil;
    }
    _commentBadgeValue = commentBadgeValue;
    self.badgeLabel.text = commentBadgeValue;
    if (isEmptyString(commentBadgeValue)) {
        self.badgeLabel.hidden = YES;
    } else {
        self.badgeLabel.hidden = NO;
        [self.badgeLabel sizeToFit];
        self.badgeLabel.width += 8;
        self.badgeLabel.width = MAX(self.badgeLabel.width, 15);
        self.badgeLabel.height = 10;
        self.badgeLabel.origin = CGPointMake(11, 0);
    }
}

- (void)setBanEmojiInput:(BOOL)banEmojiInput {
    if ([TTDeviceHelper isPadDevice]) { // iPad 暂时不支持
        banEmojiInput = YES;
    }
    
    _banEmojiInput = banEmojiInput;
    
    self.emojiButton.hidden = banEmojiInput;
    self.emojiButton.enabled = !banEmojiInput;
    
    if (banEmojiInput && self.bubbleView && self.bubbleView.isShowing) {
        [self.bubbleView hideTipWithAnimation:NO forceHide:YES];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.bubbleView && self.bubbleView.isShowing) {
        if (CGRectContainsPoint(self.bubbleView.frame, point)) {
            return self.bubbleView;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - Action & Reponse

- (void)writeButtonClicked:(SSThemedButton *)writeButton
{
    if ([self.delegate respondsToSelector:@selector(bottomView:writeButtonClicked:)]) {
        [self.delegate bottomView:self writeButtonClicked:writeButton];
    }
}

- (void)emojiButtonClicked:(SSThemedButton *)writeButton
{
    if ([self.delegate respondsToSelector:@selector(bottomView:emojiButtonClicked:)]) {
        [self.delegate bottomView:self emojiButtonClicked:writeButton];
    }
}

- (void)commentButtonClicked:(SSThemedButton *)commentButton
{
    if ([self.delegate respondsToSelector:@selector(bottomView:commentButtonClicked:)]) {
        [self.delegate bottomView:self commentButtonClicked:commentButton];
    }
}

- (void)diggButtonClicked:(SSThemedButton *)diggButton
{
    if ([self.detailModel.answerEntity isBuryed]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经反对过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    } else {
        if (![self.detailModel.answerEntity isDigg]) {
            [self diggAnimationWith:diggButton];
            self.detailModel.answerEntity.diggCount = @([self.detailModel.answerEntity.diggCount longLongValue] + 1);
            self.detailModel.answerEntity.isDigg = YES;
            [WDAnswerService digWithAnswerID:self.detailModel.answerEntity.ansid
                                    diggType:WDDiggTypeDigg
                                   enterFrom:kWDDetailViewControllerUMEventName
                                    apiParam:self.detailModel.apiParam
                                 finishBlock:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TTAppStoreStarManagerShowNotice" object:nil userInfo:@{@"trigger":@"like"}];
        } else {
            self.digButton.selected = NO;
            self.detailModel.answerEntity.diggCount = (self.detailModel.answerEntity.diggCount.longLongValue >= 1) ? @(self.detailModel.answerEntity.diggCount.longLongValue - 1) : @0;
            self.detailModel.answerEntity.isDigg = NO;
            [WDAnswerService digWithAnswerID:self.detailModel.answerEntity.ansid
                                    diggType:WDDiggTypeUnDigg
                                   enterFrom:kWDDetailViewControllerUMEventName
                                    apiParam:self.detailModel.apiParam
                                 finishBlock:nil];
        }
        if ([self.delegate respondsToSelector:@selector(bottomView:diggButtonClicked:)]) {
            [self.delegate bottomView:self diggButtonClicked:diggButton];
        }
    }
}

- (void)nextButtonClicked:(SSThemedButton *)nextButton
{
    if ([self.delegate respondsToSelector:@selector(bottomView:nextButtonClicked:)]) {
        [self.delegate bottomView:self nextButtonClicked:nextButton];
    }
}

#pragma mark - Animation

- (void)diggAnimationWith:(SSThemedButton *)button
{
    [SSMotionRender motionInView:button.imageView byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(10.f, 2.0f)];
    
    button.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    button.imageView.contentMode = UIViewContentModeCenter;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        button.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        button.alpha = 0;
    } completion:^(BOOL finished) {
        button.selected = YES;
        button.alpha = 0;
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            button.imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
            button.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }];
}

#pragma mark - TTBubbleView supportsEmojiInput

- (void)showSupportsEmojiInputBubbleViewIfNeeded {
    if (!self.detailModel.hasNext) {
        return;
    }
    
    // 避免重复展现
    if (self.bubbleView && self.bubbleView.isShowing) {
        return;
    }

    // 展现过一次
    BOOL hasSupportsEmojiInputTip = [[NSUserDefaults standardUserDefaults] boolForKey:kWDHasTipSupportsEmojiInputDefaultKey];
    if (hasSupportsEmojiInputTip) {
        return;
    }
    
    // iPad 不展现
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    
    TTBubbleView *bubbleView = [[TTBubbleView alloc] initWithAnchorPoint:CGPointMake(self.nextButton.origin.x + 11, 0.0f) imageName:@"detail_close_icon" tipText:@"查看下一个回答" attributedText:nil arrowDirection:TTBubbleViewArrowDown lineHeight:0 viewType:1];
    [self addSubview:bubbleView];
    
    WeakSelf;
    [bubbleView showTipWithAnimation:YES
                       automaticHide:YES
             animationCompleteHandle:nil
                      autoHideHandle:^{
                          StrongSelf;
                          self.bubbleView = nil;
                      } tapHandle:^{
                          StrongSelf;
                          [self dismissBubbleView:nil];
                      } closeHandle:^{
                          StrongSelf;
                          [self dismissBubbleView:nil];
                      }];
    
    self.bubbleView = bubbleView;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kWDHasTipSupportsEmojiInputDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)hideSupportsEmojiInputBubbleViewIfNeeded {
    [self dismissBubbleView:nil];
}

#pragma mark - target-action
- (void)dismissBubbleView:(id)sender {
    if (self.bubbleView && self.bubbleView.isShowing) {
        [self.bubbleView hideTipWithAnimation:NO forceHide:YES];
    }
}

- (void)shareButtonOnClicked:(id)sender
{
}

- (void)themeChanged:(NSNotification *)notification
{
    _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
}


- (NSString *)_shareIconName
{
    return @"tab_share";
}

- (NSString *)_photoShareIconName
{
    return @"icon_details_share";
}

@end

CGFloat WDDetailGetToolbarHeight(void) {
    return ([TTDeviceHelper isPadDevice] ? 50 : 44) + [TTDeviceHelper ssOnePixel];
}

