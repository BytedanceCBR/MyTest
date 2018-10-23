//
//  ArticleXPCommentView.m
//  Article
//
//  Created by SunJiangting on 14-4-10.
//
//

#import "ExploreWriteCommentView.h"
#import <TTAccountBusiness.h>
#import "PGCAccountManager.h"
#import "TTIndicatorView.h"
#import "NetworkUtilities.h"


#import "SSCommentInputHeader.h"
#import "SSPGCActionManager.h"
#import "NSStringAdditions.h"
#import "SSCommonLogic.h"
#import "SSShareMessageManager.h"
#import "TTThemedAlertController.h"
#import "TTGroupModel.h"
#import "ArticleURLSetting.h"
#import "ArticleMobileViewController.h"
#import "TTNavigationController.h"
#import "TTArticleTabBarController.h"


#import <sys/time.h>
#import "UIViewAdditions.h"
#import "UIButton+TTAdditions.h"
#import "TTDeviceHelper.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIImage+TTThemeExtension.h"

#import "UITextView+TTAdditions.h"
#import "ExploreMixListDefine.h"
#import "STPersistence.h"
#define PUBLISHBUTTON_WIDTH [TTDeviceUIUtils tt_newPadding:57.f]
#define PUBLISHBUTTON_HEIGHT [TTDeviceUIUtils tt_newPadding:28.f]

unsigned int g_exploreDetailWriteCommentMaxCharactersLimit = kMaxCommentLength;

static struct timeval commentTimeval;

@interface ExploreWriteCommentView () <UITextViewDelegate, UIGestureRecognizerDelegate, SSPGCActionManagerDelegate> {
    NSInteger   _defaultTextPosition;
    BOOL didBeginToComment;
}

@property (nonatomic, strong) UIView * inputBackgroundView;
@property (nonatomic, strong) UIView      * shareBarView;

@property (nonatomic, strong) SSThemedLabel     *tipLabel;

@property (nonatomic, strong) SSThemedButton    * publishButton;
@property (nonatomic, assign) BOOL                 hasRemovedFromWindow;

@property (nonatomic, strong) SSThemedButton    * recommendToFansCheckButton;

@property(nonatomic, strong)TTGroupModel *groupModel;
@property(nonatomic, copy)  NSString     *mediaID;
@property(nonatomic, copy)NSString * itemTag;
@property(nonatomic, copy)NSString * replyToCommentID;
@property(nonatomic, copy)NSString * adID;
@property(nonatomic, assign)BOOL hasImage;
@property(nonatomic, assign, getter = isSending)BOOL sending;
@property(nonatomic, assign)BOOL isSharePGCUser;//是否是分享PGC用户
@property(nonatomic, strong)SSPGCActionManager * pgcActionManager;
@property(nonatomic, assign, readwrite)BOOL isDismiss;

@end

const NSInteger ExploreWriteCommentViewDefaultHeight = 160;

@implementation ArticleReadQualityModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"[ReadQuality]read_pct:%@%%, staytime:%d(s)", self.readPct, (int)[self.stayTimeMs doubleValue]/1000];
}

@end

@implementation ExploreWriteCommentView

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeGestureRecognizer:obj];
    }];
}

+ (CGRect)frameForCommentInputView
{
    CGRect frame = [UIApplication sharedApplication].keyWindow.bounds;
    
    if ([TTDeviceHelper isPadDevice] &&
        [TTDeviceHelper OSVersionNumber] < 8.0 &&
        !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        frame.size = CGSizeMake(frame.size.height, frame.size.width);
    }
    
    return frame;
}

- (instancetype) initWithFrame:(CGRect) frame {
    frame = [ExploreWriteCommentView frameForCommentInputView];
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self previousFrame:frame];
    }
    return self;
}

- (void)previousFrame:(CGRect)frame {
    self.backgroundView.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.backgroundView];
    
    UIGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapActionFired:)];
    tapGesture.delegate = self;
    [self.backgroundView addGestureRecognizer:tapGesture];
    
    UIGestureRecognizer * fakePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fakePan)];
    [self addGestureRecognizer:fakePanGesture];
    
    CGFloat commentViewHeight = [TTDeviceUIUtils tt_newPadding:ExploreWriteCommentViewDefaultHeight];
    self.commentView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - commentViewHeight, CGRectGetWidth(frame), commentViewHeight)];
    self.commentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // self.commentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.commentView];
    
    CGFloat inputViewPadding = [TTDeviceUIUtils tt_newPadding:14.f];
    CGFloat inputViewBottomPadding = [TTDeviceUIUtils tt_newPadding:44.f];
    self.inputBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(inputViewPadding, inputViewPadding, CGRectGetWidth(self.commentView.bounds) - (2 * inputViewPadding), CGRectGetHeight(self.commentView.bounds) - (inputViewPadding + inputViewBottomPadding))];
    self.inputBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.inputBackgroundView.layer.cornerRadius = 4.f;
    self.inputBackgroundView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    [self.commentView addSubview:self.inputBackgroundView];
    
    CGRect textRect = CGRectMake(8, 2, CGRectGetWidth(self.inputBackgroundView.bounds) - 14, CGRectGetHeight(self.inputBackgroundView.bounds) - 4);
    self.textView = [[SSThemedTextView alloc] initWithFrame:textRect];
    self.textView.contentInset = UIEdgeInsetsZero;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
    self.textView.placeHolderFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
    self.textView.scrollsToTop = NO;
    self.textView.placeHolder = [SSCommonLogic commentInputViewPlaceHolder];
    [self.inputBackgroundView addSubview:self.textView];
    
    self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textView.frame) - 70, CGRectGetMaxY(self.textView.frame) - 12, 70, 10)];
    self.tipLabel.font = [UIFont boldSystemFontOfSize:11.];
    self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.tipLabel.backgroundColor = [UIColor clearColor];
    self.tipLabel.textAlignment = NSTextAlignmentRight;
    [self.inputBackgroundView addSubview:self.tipLabel];
    
    self.shareBarView = [[UIView alloc] initWithFrame:CGRectMake(self.inputBackgroundView.left, CGRectGetMaxY(self.inputBackgroundView.frame) + 8, self.inputBackgroundView.width, CGRectGetHeight(self.commentView.bounds) - CGRectGetMaxY(self.inputBackgroundView.frame) - 15)];
    self.shareBarView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
    [self.commentView addSubview:self.shareBarView];
    
    // PGC账号登录的用户发表评论时可以同时转发到微头条
    if ([TTAccountManager isLogin]) {
        CGFloat btnW = 12;
        self.recommendToFansCheckButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.recommendToFansCheckButton.imageName = @"select_reviewbar_all";
        self.recommendToFansCheckButton.selectedImageName = @"select_reviewbar_all_press";
        self.recommendToFansCheckButton.highlightedImageName = nil;
        self.recommendToFansCheckButton.selected = [self needSelectedPGCCheckButton];
        [self.recommendToFansCheckButton addTarget:self action:@selector(recommendToFansCheckButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat edge = (44 - 12)/2.f;
        self.recommendToFansCheckButton.hitTestEdgeInsets = UIEdgeInsetsMake(-edge, -edge, -edge, -edge);
        self.backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundView];
        
        UIGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapActionFired:)];
        tapGesture.delegate = self;
        [self.backgroundView addGestureRecognizer:tapGesture];
        
        UIGestureRecognizer * fakePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fakePan)];
        [self addGestureRecognizer:fakePanGesture];
        
        CGFloat commentViewHeight = [TTDeviceUIUtils tt_newPadding:ExploreWriteCommentViewDefaultHeight];
        self.commentView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - commentViewHeight, CGRectGetWidth(frame), commentViewHeight)];
        self.commentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.commentView.backgroundColorThemeKey = kColorBackground3;
        self.commentView.borderColorThemeKey = kColorLine7;
        self.commentView.separatorAtTOP = YES;
        
        // self.commentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.commentView];
        
        NSString *hintText = [NSString stringWithFormat:@"同时转发到%@",[SSCommonLogic ugcTabName]];
        UIFont *labelFont = [UIFont systemFontOfSize:14];
        self.recommendToFansCheckButton.titleLabel.font = labelFont;
        [self.recommendToFansCheckButton setTitle:hintText forState:UIControlStateNormal];
        
        self.recommendToFansCheckButton.titleColorThemeKey = kColorText1;
        
        CGFloat hintLabelLeft = 24.0;
        CGFloat hintLabelRight = _inputBackgroundView.right - 66 - 10;
        
        CGRect rect = [hintText boundingRectWithSize:CGSizeMake(hintLabelRight - hintLabelLeft, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context:nil];
        self.recommendToFansCheckButton.frame = CGRectMake(2, 0, btnW + 9 + rect.size.width, 16);
        self.recommendToFansCheckButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 9);
        self.recommendToFansCheckButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0);
        self.recommendToFansCheckButton.centerY = self.shareBarView.height/2;
        self.recommendToFansCheckButton.titleColorThemeKey = kColorText1;
        [self.shareBarView addSubview:self.recommendToFansCheckButton];
    }
    
    self.publishButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    self.publishButton.frame = CGRectMake(0, 0, PUBLISHBUTTON_WIDTH, PUBLISHBUTTON_HEIGHT);
    self.publishButton.right = self.shareBarView.width;
    self.publishButton.centerY = self.shareBarView.height / 2;
    [self.publishButton setTitle:@"发表" forState:UIControlStateNormal];
    self.publishButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
    self.publishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.publishButton.layer.cornerRadius = 6;
    self.publishButton.backgroundColorThemeKey = kColorBackground8;
    self.publishButton.titleColorThemeKey = kColorText12;
    self.publishButton.disabledTitleColorThemeKey = kColorText10;
    self.publishButton.disabledBackgroundColors = SSThemedColors(@"cacaca", @"505050");
    [self.publishButton addTarget:self action:@selector(publishActionFired:) forControlEvents:UIControlEventTouchUpInside];
    self.publishButton.enabled = NO;
    [self.shareBarView addSubview:self.publishButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postMessageFinished:) name:kPostMessageFinishedNotification object:nil];
    
    [self reloadThemeUI];
}

- (void) willAppear {
    [super willAppear];
    
}

- (void) didAppear {
    [super didAppear];
    
}

- (void) willDisappear {
    [super willDisappear];
    
}

- (void) willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: self];
    TTNavigationController * navigationController = (TTNavigationController *)viewController;
    
    if (!newWindow) {
        _defaultTextPosition = self.textView.selectedRange.location;
        self.hasRemovedFromWindow = YES;
        if ([navigationController isKindOfClass:[TTNavigationController class]]) {
            navigationController.topViewController.ttDisableDragBack = NO;
        }
    }
    if (newWindow && self.hasRemovedFromWindow) {
        if (!self.textView.isFirstResponder) {
            //            [self.textView becomeFirstResponder];
        }
        if ([navigationController isKindOfClass:[TTNavigationController class]]) {
            navigationController.topViewController.ttDisableDragBack = YES;
        }
    }
}

- (void)themeChanged:(NSNotification*)notification {
    // Ugly code: copied from "ArticleCommentView.m"
    [super themeChanged:notification];
    self.inputBackgroundView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.inputBackgroundView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine7) CGColor];
    self.textView.placeHolderColor = SSGetThemedColorWithKey(kColorText9);
    self.textView.textColor = SSGetThemedColorWithKey(kColorText1);
    self.tipLabel.textColor = SSGetThemedColorWithKey(kColorText3);
}

- (void)showInView:(UIView *)view animated:(BOOL)animated {
    [self showInView:view animated:animated resetCommentViewFrame:YES];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated resetCommentViewFrame:(BOOL)shouldReset {
    UIViewController *viewController = [self shouldShowedInViewControllerForView:view];
    if ([viewController isKindOfClass:[TTNavigationController class]]) {
        TTNavigationController *navigationController = (TTNavigationController *)viewController;
        navigationController.topViewController.ttDisableDragBack = YES;
    }
    
    [viewController.view addSubview:self];
    
    if (shouldReset) {
        self.commentView.top = CGRectGetHeight(self.bounds);
    }
    
    void (^completion)(BOOL) = ^(BOOL finished) {
        [self.textView becomeFirstResponder];
        CGRect textRect = CGRectMake(4, 0, CGRectGetWidth(self.inputBackgroundView.bounds) - 4, CGRectGetHeight(self.inputBackgroundView.bounds));
        textRect.size.width -= 1;
        self.textView.frame = textRect;
    };
    
    self.backgroundView.alpha = 0.0;
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.5;
        completion(YES);
    };
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:animations completion:nil];
    } else {
        animations();
    }
    
    // 统计 写评论时「同时转发到微头条」选项展示
    if (self.recommendToFansCheckButton && !self.recommendToFansCheckButton.hidden) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
        
        // 评论者mediaId,uid
        NSString *mediaID = [PGCAccountManager shareManager].currentLoginPGCAccount.mediaID;
        NSString *uid = [TTAccountManager userID];
        [extra setValue:mediaID forKey:@"media_id"];
        [extra setValue:uid forKey:@"uid"];
        
        [TTTrackerWrapper event:@"detail" label:@"show_recommend_to_fans" value:_groupModel.groupID extValue:_groupModel.itemID extValue2:nil dict:extra];
    }
}

- (UIViewController *)shouldShowedInViewControllerForView:(UIView *)view
{
    if (!view) {
        view = SSGetMainWindow();
    }
    
    UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: view];
    if ([viewController isKindOfClass:[TTNavigationController class]]) {
        viewController = (TTNavigationController *)viewController;
    }
    else if ([viewController isKindOfClass:[TTArticleTabBarController class]]) {
        viewController = (TTArticleTabBarController *)viewController;
    }
    else {
        viewController = (TTNavigationController *)viewController.navigationController;
    }
    
    if (viewController.presentedViewController != nil) {
        UIViewController *presentedNav = [viewController presentedViewController];
        if ([presentedNav isKindOfClass:[TTNavigationController class]]) {
            viewController = [[((TTNavigationController *)presentedNav) viewControllers] lastObject];
        }
        else {
            viewController = [TTUIResponderHelper topViewControllerFor: viewController];
        }
    }
    return viewController;
}

- (void) dismissAnimated:(BOOL) animated {
    _isDismiss = YES;
    // 取消的时候保存draft， 产品需求如下
    //    如果此次评论对象与上次记忆对象相同，则更新为最新评论内容。
    //    如果此次评论对象与上次记忆对象不同：
    //    评论框内容非空，则记忆本次内容。
    //    评论框内容为空，则不记忆本次内容，保留上次草稿。
    if (!isEmptyString(self.replyToCommentID)) {
        NSDictionary *originalDraft = [SSCommonLogic draftForType:SSCommentTypeArticleComment];
        if ([[originalDraft valueForKey:@"Identifier"] isEqual:self.replyToCommentID] || !isEmptyString(self.textView.text)) {
            NSMutableDictionary *draft = [NSMutableDictionary dictionaryWithCapacity:2];
            [draft setValue:self.replyToCommentID forKey:@"Identifier"];
            [draft setValue:self.textView.text forKey:self.replyToCommentID];
            [draft setValue:@(self.textView.selectedRange.location) forKey:@"TextPosition"];
            
            
            [SSCommonLogic setDraft:draft forType:SSCommentTypeArticleComment];
        }
    } else {
        NSDictionary *originalDraft = [SSCommonLogic draftForType:SSCommentTypeArticle];
        if ([[originalDraft valueForKey:@"Identifier"] isEqual:self.groupModel.groupID] || !isEmptyString(self.textView.text)) {
            NSMutableDictionary *draft = [NSMutableDictionary dictionaryWithCapacity:2];
            [draft setValue:self.groupModel.groupID forKey:@"Identifier"];
            [draft setValue:self.textView.text forKey:self.groupModel.groupID];
            [draft setValue:@(self.textView.selectedRange.location) forKey:@"TextPosition"];
            
            [SSCommonLogic setDraft:draft forType:SSCommentTypeArticle];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.textView resignFirstResponder];
    self.backgroundView.alpha = 0.5;
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.f;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: self.superview];
        if ([viewController isKindOfClass:[TTNavigationController class]]) {
            TTNavigationController * navigationController = (TTNavigationController *)viewController;
            navigationController.topViewController.ttDisableDragBack = NO;
        }
        [self removeFromSuperview];
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:animations completion:completion];
    } else {
        animations();
        completion(YES);
    }
}



- (void)recommendToFansCheckButtonClicked:(id)sender {
    self.recommendToFansCheckButton.selected = !self.recommendToFansCheckButton.selected;
    [self setPGCCheckButtonSelected:self.recommendToFansCheckButton.selected];
}

#pragma mark - Gesture
- (void) backgroundTapActionFired:(id) sender {
    wrapperTrackEvent(@"comment", @"write_cancel");
    if([self.delegate respondsToSelector:@selector(commentViewCancelled:)]) {
        [self.delegate performSelector:@selector(commentViewCancelled:) withObject:self];
    }
    [self dismissAnimated:YES];
}

- (void)fakePan
{
    NSLog(@"just capture pan gesture on TTNavigationController.view to avoid poping");
}




#pragma mark - PublishAction
- (void) publishActionFired:(id) sender {
    /// 发布评论
    struct timeval currentTime;
    gettimeofday(&currentTime, NULL);
    CFTimeInterval interval = [TTBusinessManager timeIntervalFromStartTime:commentTimeval toEndTime:currentTime];
    
    if(!TTNetworkConnected()) {
        [self showWrongImgIndicatorWithMsg:kNoNetworkTipMessage];
        return;
    }
    if (self.textView.text.length > g_exploreDetailWriteCommentMaxCharactersLimit) {//非法内容， 不能发送
        [self showContentTooLongTip];
        return;
    }
    if (_isSharePGCUser) {
        
        if (![TTAccountManager isLogin]) {
            [self showWrongImgIndicatorWithMsg:sNoLoginTip];
            return;
        }
        
        [_pgcActionManager cancel];
        _pgcActionManager.delegate = nil;
        self.pgcActionManager = [[SSPGCActionManager alloc] init];
        _pgcActionManager.delegate = self;
        [_pgcActionManager sharePGCUser:_mediaID shareMsg:self.textView.text];
        
    }
    else {
        
        if([self.groupModel.groupID length] == 0) {
            NSLog(@"commentInputView itemID length must large 0");
            return;
        }
        
        BOOL couldSend = YES;
        if ([self.delegate respondsToSelector:@selector(commentViewWillSendMsg:)]) {
            couldSend = [self.delegate commentViewWillSendMsg:self];
        }
        if (!couldSend) {
            return;
        }
        //没有内容， 没有勾选平台， 不能发送
        if([self.textView.text trimmed].length == 0 &&
           [[TTPlatformAccountManager sharedManager] numberOfCheckedAccounts] == 0) {
            [self showWrongImgIndicatorWithMsg:sInputContentTooShortTip];
            return;
        }
        
        __weak typeof(self) wself = self;
        ArticleMobilePiplineCompletion sendLogic =  ^(ArticleLoginState state){
            if (!wself.sending) {
                wself.sending = YES;
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
                [userInfo setValue:@"CommentInputView" forKey:@"ClassName"];
                [userInfo setObject:self forKey:@"inputViewClass"];
                if ([wself.adID longLongValue] != 0) {
                    [userInfo setValue:wself.adID forKey:@"ad_id"];
                }
                
                NSString * shareStr = wself.textView.text;
                BOOL isComment = isEmptyString(shareStr) ? NO : YES;
                NSString *timeInterval = [NSString stringWithFormat:@"%.0f", interval];
                [[TTPostMessageManager manager] postMessage:wself.textView.text groupModel:wself.groupModel forumModel:nil tag:wself.itemTag hasComment:isComment replyToCommentID:wself.replyToCommentID commentTimeInterval:timeInterval userInfo:userInfo adID:wself.adID staytime:wself.readQuality.stayTimeMs readPct:wself.readQuality.readPct isZZ:NO shareTT:wself.recommendToFansCheckButton.isSelected];
                
                wrapperTrackEvent(@"comment", @"write_confirm");
                
                // 统计 最终发评论时勾选了「同时转发到微头条」——发回gid、作者mid、uid
                if (!self.recommendToFansCheckButton.hidden) {
                    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
                    
                    // 评论者mediaId,uid
                    [extra setValue:@(wself.recommendToFansCheckButton.isSelected ? 1 : 0) forKey:@"recommend_to_fans"];
                }
                
            }
        };
        
        if (![TTAccountManager isLogin]) {
            
            [self.textView resignFirstResponder];
            // [self dismissAnimated:NO];//隐藏键盘的黑罩，否则会导致两个黑罩叠加
            
            if ([TTDeviceHelper isPadDevice]) {
                [self dismissAnimated:NO];
            }
            
            [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"post_comment" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    //登录成功 走发送逻辑
                    if ([TTAccountManager isLogin]) {
                        sendLogic(ArticleLoginStatePlatformLogin);
                    }
                } else if (type == TTAccountAlertCompletionEventTypeTip) {
                    [TTAccountManager presentQuickLoginFromVC:self.viewController type:TTAccountLoginDialogTitleTypeDefault source:@"post_comment" isPasswordStyle:YES completion:^(TTAccountLoginState state) {

                    }];
                } else if(type == TTAccountAlertCompletionEventTypeCancel) {
                    [wself.textView becomeFirstResponder];
                    ssTrackEvent(@"auth", @"comment_cancel");
                }
            }];
        }
        else {
            
            sendLogic(ArticleLoginStatePlatformLogin);
            
        }
    }
}

#pragma mark - PostFinished
- (void) postMessageFinished:(NSNotification*)notification {
    _sending = NO;
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    SSLog(@"%s, error:%@", __PRETTY_FUNCTION__, error);
    
    if ([[[notification userInfo] objectForKey:kAccountManagerUserInfoKey] objectForKey:@"inputViewClass"] != self) {
        return;
    }
    
    if(error) {
        NSString *msg = nil;
        if([error.domain isEqualToString:kCommonErrorDomain]) {
            msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
            if (isEmptyString(msg) && error.code == kSessionExpiredErrorCode) {
                msg = kSessionExpiredTipMessage;
            }
        }
        
        
        if(isEmptyString(msg)) msg = kNetworkConnectionErrorTipMessage;
        [self showWrongImgIndicatorWithMsg:msg];
    }
    else {
        // 发送成功之后就清空draft
        if (!isEmptyString(self.replyToCommentID)) {
            [SSCommonLogic setDraft:nil forType:SSCommentTypeArticleComment];
        } else {
            [SSCommonLogic setDraft:nil forType:SSCommentTypeArticle];
        }
        [self showRightImgIndicatorWithMsg:sSendDone];
        self.textView.text = nil;
        [self.textView showOrHidePlaceHolderTextView];
        if ([self.delegate respondsToSelector:@selector(commentView:responsedReceived:)]) {
            [self.delegate commentView:self responsedReceived:notification];
        }
        
        BOOL isZZ = [[notification userInfo] integerValueForKey:@"is_zz" defaultValue:0];
        BOOL isPGCAccount = [[PGCAccountManager shareManager] hasPGCAccount];
        if (isZZ && isPGCAccount) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTPublishCommentSuccessWithZZNotification object:nil userInfo:notification.userInfo];
        }
    }
}

- (void)showRightImgIndicatorWithMsg:(NSString *)msg {
    [self showIndicatorMsg:msg imageName:@"doneicon_popup_textpage.png"];
}

- (void)showWrongImgIndicatorWithMsg:(NSString *)msg {
    [self showIndicatorMsg:msg imageName:@"close_popup_textpage.png"];
}

- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName {
    UIImage *tipImage = nil;
    if (!isEmptyString(imgName)) {
        tipImage = [UIImage themedImageNamed:imgName];
    }
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:tipImage autoDismiss:YES dismissHandler:nil];
}

- (void)showContentTooLongTip {
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:[NSString stringWithFormat:sInputContentTooLongTip, g_exploreDetailWriteCommentMaxCharactersLimit] message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:sOK actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
    CGFloat frameTop = 0;
    if ([self.textView isFirstResponder]) {
        frameTop = CGRectGetMaxY(self.commentView.frame);
    }
    [alert showFrom:self.viewController animated:YES keyboardPresentingWithFrameTop:frameTop];
}


#pragma mark - SetCondation

- (void)setCondition:(NSDictionary *)conditions {
    self.isSharePGCUser = [[conditions objectForKey:kQuickInputViewConditionIsSharePGCUser] boolValue];
    if (_isSharePGCUser) {
        //        self.tipLabel.text = sCommentInputViewSharePGCUserTip;
    }
    
    self.groupModel = [conditions objectForKey:kQuickInputViewConditionGroupModel];
    self.mediaID = conditions[kQuickInputViewConditionMediaID];
    
    if ([conditions objectForKey:kQuickInputViewConditionItemTag]) {
        self.itemTag = [NSString stringWithFormat:@"%@", [conditions objectForKey:kQuickInputViewConditionItemTag]];
    } else {
        self.itemTag = nil;
    }
    
    if ([[conditions allKeys] containsObject:kQuickInputViewConditionADIDKey]) {
        self.adID = [NSString stringWithFormat:@"%@", [conditions objectForKey:kQuickInputViewConditionADIDKey]];
    } else {
        self.adID = nil;
    }
    
    if ([conditions objectForKey:kQuickInputViewConditionReplyToCommentID]) {
        self.replyToCommentID = [conditions objectForKey:kQuickInputViewConditionReplyToCommentID];
    } else {
        self.replyToCommentID = nil;
    }
    
    self.hasImage = [[conditions objectForKey:kQuickInputViewConditionHasImageKey] boolValue];
    
    NSString * content = nil;
    if ([conditions objectForKey:kQuickInputViewConditionInputViewText]) {
        content = [conditions objectForKey:kQuickInputViewConditionInputViewText];
    } else {
        content = nil;
    }
    
    NSDictionary *forumInfoDic;
    if (self.replyToCommentID) {
        NSDictionary *draft = [SSCommonLogic draftForType:SSCommentTypeArticleComment];
        NSString *draftID = [draft valueForKey:@"Identifier"];
        if ([draftID isEqualToString:self.replyToCommentID]) {
            content = [draft valueForKey:draftID];
            _defaultTextPosition = [[draft valueForKey:@"TextPosition"] intValue];
            forumInfoDic = [draft valueForKey:@"forum"];
        }
    } else {
        NSDictionary *draft = [SSCommonLogic draftForType:SSCommentTypeArticle];
        NSString *draftID = [draft valueForKey:@"Identifier"];
        if ([draftID isEqualToString:self.groupModel.groupID]) {
            content = [draft valueForKey:draftID];
            _defaultTextPosition = [[draft valueForKey:@"TextPosition"] intValue];
            forumInfoDic = [draft valueForKey:@"forum"];
        }
    }
    self.textView.text = content;
    [self.textView showOrHidePlaceHolderTextView];
    self.publishButton.enabled = !isEmptyString(self.textView.text);
}

- (void)setConditionWithCommentModel:(SSCommentModel *)model {
    [self setConditionWithCommentModel:model adID:nil];
}

- (void)setConditionWithCommentModel:(SSCommentModel *)model adID:(NSString *)adID {
    self.isSharePGCUser = NO;
    if (isEmptyString(adID)) {
        self.adID = nil;
    } else {
        self.adID = [NSString stringWithFormat:@"%@", adID];
    }
    
    self.groupModel = model.groupModel;
    
    if (model.itemTag) {
        self.itemTag = [NSString stringWithFormat:@"%@", model.itemTag];
    } else {
        self.itemTag = nil;
    }
    
    if (model.commentID) {
        self.replyToCommentID = [NSString stringWithFormat:@"%@", model.commentID];
    } else {
        self.replyToCommentID = nil;
    }
    
    self.hasImage = NO;
    
    NSString * text = @"";
    if (model.commentContent) {
        text = [NSString stringWithFormat:@"%@", model.commentContent];
    }
    if([text length] > forwardCommentMaxLength) {
        text = [NSString stringWithFormat:@"%@...", [text substringToIndex:forwardCommentMaxLength]];
    }
    NSString * replyName =  isEmptyString(model.userName) ? @"" : [NSString stringWithFormat:@"%@", model.userName];
    NSString *content = [NSString stringWithFormat:@" //@%@:%@", replyName, text];
    if (self.replyToCommentID) {
        NSDictionary *draft = [SSCommonLogic draftForType:SSCommentTypeArticleComment];
        NSString *draftID = [draft valueForKey:@"Identifier"];
        if ([draftID isEqualToString:self.replyToCommentID]) {
            content = [draft valueForKey:draftID];
            _defaultTextPosition = [[draft valueForKey:@"TextPosition"] intValue];
            
        }
    } else {
        NSDictionary *draft = [SSCommonLogic draftForType:SSCommentTypeArticle];
        NSString *draftID = [draft valueForKey:@"Identifier"];
        if ([draftID isEqualToString:self.groupModel.groupID]) {
            content = [draft valueForKey:draftID];
            _defaultTextPosition = [[draft valueForKey:@"TextPosition"] intValue];
        }
    }
    
    self.textView.text = content;
    [self.textView showOrHidePlaceHolderTextView];
}

#pragma mark - SSPGCActionManagerDelegate

- (void)actionManager:(SSPGCActionManager *)manager shareUserFinished:(NSError *)error {

    //    NSError *tError = [SSCommonLogic handleError:error responseResult:result exceptionInfo:nil];
    
//    if(tError && tError.code == kSessionExpiredErrorCode) {
//        [SSCommonLogic monitorLoginoutWithUrl:@"2-pgc-share_media_account" status:2 error:tError];
//    }
    
    if (error) {
        NSString * tip;
        if (!TTNetworkConnected()) {
            tip = kNoNetworkTipMessage;
        }
        else {
            tip = kExceptionTipMessage;
        }
        [self showRightImgIndicatorWithMsg:tip];
    }
    else {
        [self showRightImgIndicatorWithMsg:sSendDone];
        if ([self.delegate respondsToSelector:@selector(commentView:responsedReceived:)]) {
            [self.delegate commentView:self responsedReceived:nil];
        }
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (_defaultTextPosition < 0 || _defaultTextPosition > textView.text.length) {
        _defaultTextPosition = 0;
    }
    textView.selectedRange = NSMakeRange(_defaultTextPosition, 0);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    didBeginToComment = NO;
    NSLog(@"end comment");
}

- (void) textViewDidChange:(UITextView *)textView {
    [self.textView showOrHidePlaceHolderTextView];
    
    if (!didBeginToComment) {
        didBeginToComment = YES;
        gettimeofday(&commentTimeval, NULL);
        NSLog(@"begin comment : %@", textView.text);
    }
    
    NSInteger contentLength = self.textView.text.length;
    self.publishButton.enabled = (contentLength > 0);
    
    NSInteger count = g_exploreDetailWriteCommentMaxCharactersLimit - contentLength;
    if (count < 0) {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d", nil), count];
    } else {
        self.tipLabel.hidden = YES;
    }
}

#pragma mark - UIKeyboardNotification
- (void) keyboardWillChangeFrame:(NSNotification *) notification {
    //    [self layoutCommentWithKeyboardNotification:notification willAppear:YES];
    NSDictionary * userInfo = notification.userInfo;
    /// keyboard相对于屏幕的坐标
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 8.0) {
        keyboardScreenFrame = [self convertRect:keyboardScreenFrame fromView:nil];
    }
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    
    CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGRect frame = self.commentView.frame;
    if (keyboardScreenFrame.origin.y == self.frame.size.height) {
        frame.origin.y = self.bottom;
    }
    else{
        frame.origin.y = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame);
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.commentView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    //如果是去选择话题，不隐藏键盘
    if (_chooseViewController) {
        return;
    }
    [self dismissAnimated:YES];
}

/*
 - (void)applicationStatusBarOrientationDidChanged
 {
 self.frame = [ExploreWriteCommentView frameForCommentInputView];
 }
 */
- (BOOL)needSelectedPGCCheckButton {
    if (![SSCommonLogic saveForwordStatusEnabled]) {
        return NO;
    }
    
    NSNumber *selected = [[STPersistence persistenceNamed:@"commentview"] valueForKey:@"pgc_recommend_button_selected"];
    
    if (!selected) { //默认勾选
        return YES;
    }
    
    return [selected isKindOfClass:[NSNumber class]] && [selected boolValue];
}

- (void)setPGCCheckButtonSelected:(BOOL)selected {
    [[STPersistence persistenceNamed:@"commentview"] setValue:@(selected) forKey:@"pgc_recommend_button_selected"];
}
@end
