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
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTUIWidget/SSMotionRender.h>
#import <KVOController/NSObject+FBKVOController.h>
#import "UIImage+FIconFont.h"
#import "UIColor+Theme.h"
#import "TTAccountManager.h"
#import "FHCommonDefines.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIButton+FHUGCMultiDigg.h"

static NSString * const kWDHasTipSupportsEmojiInputDefaultKey = @"WDHasTipSupportsEmojiInputDefaultKey";

@implementation WDBottomToolView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstraints];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWriteTitle:) name:@"TTCOMMENT_UPDATE_WRITETITLE" object:nil];
    }
    return self;
}

-(void)initView {
    UIEdgeInsets toolBarButtonHitTestInsets = UIEdgeInsetsMake(-6, -6, -6, -6);
    
    _writeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    [_writeButton setTitle:@"写评论..." forState:UIControlStateNormal];
    _writeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _writeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _writeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
    _writeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
    _writeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    _writeButton.borderColors = nil;
    _writeButton.borderColorThemeKey = kColorLine1;
    _writeButton.layer.borderWidth = 0.5;
    _writeButton.titleColorThemeKey = @"grey3";
    _writeButton.layer.cornerRadius = 16;
    _writeButton.backgroundColorThemeKey = @"grey7";
    _writeButton.layer.masksToBounds = YES;
    _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
    [_writeButton addTarget:self action:@selector(writeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_writeButton];

    _commentButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    _commentButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
    [_commentButton setImage:ICON_FONT_IMG(20, @"\U0000e699", [UIColor themeGray1]) forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_commentButton];
    
    _badgeLabel = [[SSThemedLabel alloc] init];
    _badgeLabel.backgroundColorThemeKey = kColorBackground7;
    _badgeLabel.textColorThemeKey = kColorText8;
    _badgeLabel.font = [UIFont systemFontOfSize:8];
    _badgeLabel.layer.cornerRadius = 5;
    _badgeLabel.layer.masksToBounds = YES;
    _badgeLabel.textAlignment = NSTextAlignmentCenter;
    [self.commentButton addSubview:_badgeLabel];
    
    _digButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    _digButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
    [_digButton addTarget:self action:@selector(diggButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_digButton];
    [_digButton enableMulitDiggEmojiAnimation];
    
    _collectButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    _collectButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
    [_collectButton setImage:ICON_FONT_IMG(24, @"\U0000e696", [UIColor themeGray1]) forState:UIControlStateNormal];
    [_collectButton setImage:ICON_FONT_IMG(24, @"\U0000e6b2", [UIColor themeOrange4]) forState:UIControlStateSelected];
    [_collectButton addTarget:self action:@selector(collectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_collectButton];
    
    _shareButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    _shareButton.hitTestEdgeInsets = toolBarButtonHitTestInsets;
    [_shareButton setImage:ICON_FONT_IMG(24, @"\U0000e692", [UIColor themeGray1])forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareButton];
    
    _separatorView = [[SSThemedView alloc] init];
    _separatorView.backgroundColorThemeKey = kColorLine7;
    _separatorView.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
    _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_separatorView];
    
    self.backgroundColorThemeKey = kColorBackground4;
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
    WeakSelf;
    [self setCommentBadgeValue:[self.detailModel.answerEntity.commentCount stringValue]];
    [self.KVOController observe:self.detailModel.answerEntity keyPath:NSStringFromSelector(@selector(commentCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSString *commentCount = [change tt_stringValueForKey:NSKeyValueChangeNewKey];
        WDBottomToolView *bottomToolView = observer;
        [bottomToolView setCommentBadgeValue:commentCount];
        //评论完成后发送通知修改评论数
        NSMutableDictionary *userInfo = @{}.mutableCopy;
        userInfo[@"group_id"] = wself.detailModel.answerEntity.ansid;
        userInfo[@"comment_conut"] = commentCount;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPostMessageFinishedNotification"
                                                                       object:nil
                                                                     userInfo:userInfo];
        
    }];
    self.collectButton.selected = self.detailModel.answerEntity.userRepined;
    RAC(self.collectButton,selected) = RACObserve(self.detailModel.answerEntity, userRepined);
    self.digButton.selected = self.detailModel.answerEntity.isDigg;
    RAC(self.digButton,selected) = RACObserve(self.detailModel.answerEntity, isDigg);
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

- (void)initConstraints {
    NSInteger buttonNumber = 4;
    CGFloat writeButtonWidth = SCREEN_WIDTH - 24 * buttonNumber - 15 * (buttonNumber + 2);
    [self.writeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(6);
        make.width.mas_equalTo(writeButtonWidth);
        make.height.mas_equalTo(32);
    }];
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.left.equalTo(self.writeButton.mas_right).offset(15);
        make.top.equalTo(self).offset(10);
    }];
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.left.equalTo(self.commentButton.mas_right).offset(15);
        make.top.equalTo(self).offset(10);
    }];
    [self.digButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.left.equalTo(self.collectButton.mas_right).offset(15);
        make.top.equalTo(self).offset(10);
    }];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.left.equalTo(self.digButton.mas_right).offset(15);
        make.top.equalTo(self).offset(10);
    }];
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

#pragma mark - Action & Reponse

- (void)writeButtonClicked:(SSThemedButton *)writeButton
{
    if ([self.delegate respondsToSelector:@selector(bottomView:writeButtonClicked:)]) {
        [self.delegate bottomView:self writeButtonClicked:writeButton];
    }
}

- (void)commentButtonClicked:(SSThemedButton *)commentButton
{
    [self generateImpactFeedback];
    if ([self.delegate respondsToSelector:@selector(bottomView:commentButtonClicked:)]) {
        [self.delegate bottomView:self commentButtonClicked:commentButton];
    }
}

- (void)diggButtonClicked:(SSThemedButton *)diggButton
{
    if(![TTAccountManager isLogin]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@"answer" forKey:@"enter_from"];
        [params setObject:@"feed_like" forKey:@"enter_type"];
        // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
        [params setObject:@(YES) forKey:@"need_pop_vc"];
        params[@"from_ugc"] = @(YES);
        __weak typeof(self) wSelf = self;
        [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                // 登录成功
                if ([TTAccountManager isLogin]) {
                    [wSelf diggButtonClicked:diggButton];
                }
            }
        }];
        
        return;
    }
    
    if ([self.detailModel.answerEntity isBuryed]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经反对过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    } else {
        if (![self.detailModel.answerEntity isDigg]) {
            self.detailModel.answerEntity.diggCount = @([self.detailModel.answerEntity.diggCount longLongValue] + 1);
            self.detailModel.answerEntity.isDigg = YES;
            [WDAnswerService digWithAnswerID:self.detailModel.answerEntity.ansid
                                    diggType:WDDiggTypeDigg
                                   enterFrom:kWDDetailViewControllerUMEventName
                                    apiParam:self.detailModel.apiParam
                                 finishBlock:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"TTAppStoreStarManagerShowNotice" object:nil userInfo:@{@"trigger":@"like"}];
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

- (void)shareButtonClicked:(SSThemedButton *)shareButton
{
    if ([self.delegate respondsToSelector:@selector(bottomView:shareButtonClicked:)]) {
        [self.delegate bottomView:self shareButtonClicked:shareButton];
    }
}

- (void)collectButtonClicked:(SSThemedButton *)collectButton
{
    [self generateImpactFeedback];
    self.collectButton.imageView.contentMode = UIViewContentModeCenter;
    self.collectButton.imageView.transform = CGAffineTransformMakeScale(1, 1);
    self.collectButton.alpha = 1;
    [UIView animateWithDuration:0.1 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.collectButton.imageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        self.collectButton.alpha = 0;
    } completion:^(BOOL finished){
        if ([self.delegate respondsToSelector:@selector(bottomView:collectButtonClicked:)]) {
            [self.delegate bottomView:self collectButtonClicked:collectButton];
        }
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.collectButton.imageView.transform = CGAffineTransformMakeScale(1, 1);
            self.collectButton.alpha = 1.f;
        } completion:^(BOOL finished){
        }];
    }];
}

- (void)themeChanged:(NSNotification *)notification
{
    _writeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)generateImpactFeedback {
    if (@available(iOS 10.0, *)){
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
        [generator prepare];
        [generator impactOccurred];
    }
}

@end

CGFloat WDDetailGetToolbarHeight(void) {
    return 44;
}
