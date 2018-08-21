//
//  TTRepostViewController.m
//  Article
//
//  Created by 王霖 on 2017/5/18.
//
//

#import "TTRepostViewController.h"
#import "Article.h"
#import "TTArticleCategoryManager.h"
#import <TTNavigationController.h>
#import <UIColor+TTThemeExtension.h>
#import <SSNavigationBar.h>
#import <TTAccountBusiness.h>
#import <UITextView+TTAdditions.h>
#import <TTThemeManager.h>
#import <TTUIResponderHelper.h>
//#import "ArticleMobileViewController.h"
#import "TTForumPostThreadCenter.h"
//#import "TSVShortVideoOriginalData.h"
//#import "TTPostCheckBindPhoneViewModel.h"
//#import "ArticleMobileNumberViewController.h"
//#import "WDAnswerEntity.h"
#import <TTKitchenHeader.h>
#import "TTUGCTextView.h"
//#import "TTUGCEmojiParser.h"
#import "TTRepostThreadSchemaQuoteView.h"
#import "TTRepostService.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Link.h"
//#import "TTKitchenMgr.h"
#import "TTUGCToolbar.h"
#import "TTUGCTextViewMediator.h"
#import "NSObject+MultiDelegates.h"
#import <Aspects.h>

#import "TTRepostThreadModel.h"

#import "TTRepostOriginModels.h"

static NSString * const KKCCommentRepostRepostToCommentText = @"tt_ugc_repost_comment_union.repost_region.title"; //转发发布器转发并评论文字
static NSString * const KKCCommentRepostRepostToCommentEnable = @"tt_ugc_repost_comment_union.repost_region.enable"; //转发发布器转发并评论开关
static NSString * const KKCCommentRepostRepostToCommentSelected = @"repost_comment_repost_to_comment_selected"; //转发并评论，☑️是否默认勾选，会记录
static NSString * kKCUGCHideRepostCommentCheckBox = @"tt_hide_comment_check_box"; // 是否隐藏，如果隐藏，默认上面开关是开

static CGFloat const kLeftPadding = 15.f;
static CGFloat const kRightPadding = 15.f;
static CGFloat const kInputViewTopPadding = 8.f;
static CGFloat const kTextViewHeight = 100.f;
static CGFloat const kRepostQuoteViewVerticalPadding = 10.f;
static CGFloat kUGCToolbarHeight = 80.f;

extern unsigned int g_postForumMinCharactersLimit;
extern unsigned int g_postMomentMaxCharactersLimit;

@interface TTRepostViewController () <UIScrollViewDelegate, TTUGCTextViewDelegate>

@property (nonatomic, copy) NSString * cid; //关心ID
@property (nonatomic, copy) NSString * categoryID; //频道ID
@property (nonatomic, strong) TTRepostThreadModel *repostModel;
@property (nonatomic, strong) TTRepostQuoteModel *repostQuoteModel;

@property (nonatomic, strong) TTRichSpanText *richSpanText;
@property (nonatomic, assign) BOOL firstAppear;
@property (nonatomic, assign) CGRect keyboardEndFrame;

@property (nonatomic, strong) SSThemedButton *postButton;
@property (nonatomic, strong) SSThemedScrollView *containerView;
@property (nonatomic, strong) SSThemedView *inputContainerView;
@property (nonatomic, strong) SSThemedLabel *tipLabel;
@property (nonatomic, strong) TTUGCTextView *inputTextView;
@property (nonatomic, strong) TTRepostThreadSchemaQuoteView *repostQuoteView;
@property (nonatomic, strong) TTUGCToolbar *toolbar;
@property (nonatomic, strong) TTUGCTextViewMediator *textViewMediator;
@property (nonatomic, strong) SSThemedButton *repostToCommentCheckButton;
@property (nonatomic, assign) BOOL isNeedShowTips;

@end

@implementation TTRepostViewController

#pragma mark - Life cycle

+ (TTRepostViewController *)presentRepostToWeitoutiaoViewControllerWithRepostType:(TTThreadRepostType)repostType
                                                                originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                                                                  operationItemID:(NSString *)operationItemID
                                                                   repostSegments:(NSArray<TTRepostContentSegment *> *)segments {
    return [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:repostType
                                                                           originArticle:nil
                                                                            originThread:nil
                                                                          originShortVideoOriginalData:nil
                                                                       originWendaAnswer:originWendaAnswer
                                                                       operationItemType:TTRepostOperationItemTypeWendaAnswer
                                                                         operationItemID:operationItemID
                                                                          repostSegments:segments];
}

+ (TTRepostViewController *)presentRepostToWeitoutiaoViewControllerWithRepostType:(TTThreadRepostType)repostType
                                                                    originArticle:(TTRepostOriginArticle *)originArticle
                                                                     originThread:(TTRepostOriginThread *)originThread
                                                                   originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                                                                operationItemType:(TTRepostOperationItemType)operationItemType
                                                                  operationItemID:(NSString *)operationItemID
                                                                   repostSegments:(NSArray<TTRepostContentSegment *> *)segments {
    return [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:repostType
                                                                           originArticle:originArticle
                                                                            originThread:originThread
                                                                          originShortVideoOriginalData:originShortVideoOriginalData
                                                                       originWendaAnswer:nil
                                                                       operationItemType:operationItemType
                                                                         operationItemID:operationItemID
                                                                          repostSegments:segments];
}

+ (TTRepostViewController *)presentRepostToWeitoutiaoViewControllerWithRepostType:(TTThreadRepostType)repostType
                                                                    originArticle:(TTRepostOriginArticle *)originArticle
                                                                     originThread:(TTRepostOriginThread *)originThread
                                                                   originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                                                                originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                                                                operationItemType:(TTRepostOperationItemType)operationItemType
                                                                  operationItemID:(NSString *)operationItemID
                                                                   repostSegments:(NSArray<TTRepostContentSegment *> *)segments {
    [TTRepostService repostAdapterWithRepostType:repostType originArticle:originArticle originThread:originThread originShortVideoOriginalData:originShortVideoOriginalData originWendaAnswer:originWendaAnswer operationItemType:operationItemType operationItemID:operationItemID repostSegments:segments];;
    return nil;
}

+ (void)load {
    RegisterRouteObjWithEntryName(@"repost_page");
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj{
    self = [super initWithRouteParamObj:nil];
    if (self) {

        self.repostModel = [[TTRepostThreadModel alloc] initWithRepostParam:paramObj.allParams];
        self.repostQuoteModel = [[TTRepostQuoteModel alloc] initWithRepostParam:paramObj.allParams];

        self.cid = KTTFollowPageConcernID;
        self.categoryID = kTTWeitoutiaoCategoryID;

        if (!isEmptyString(self.repostModel.content)) {
            TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.repostModel.content_rich_span];
            self.richSpanText = [[TTRichSpanText alloc] initWithText:self.repostModel.content richSpans:richSpans];
        } else {
            self.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
        }

        [self trackRepostWithEvent:self.source label:@"open" extra:nil];
    }
    return self;
}

+ (TTRouteViewControllerOpenStyle)preferredRouteViewControllerOpenStyle {
    return TTRouteViewControllerOpenStylePresent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    //cancel repost bar item
    TTNavigationBarItemContainerView * leftBarItem =
    (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft
                                                                             withTitle:NSLocalizedString(@"取消", nil)
                                                                                target:self
                                                                                action:@selector(cancelRepost:)];
    if ([leftBarItem isKindOfClass:[TTNavigationBarItemContainerView class]]) {
        leftBarItem.button.titleColorThemeKey = kColorText1;
        leftBarItem.button.highlightedTitleColorThemeKey = kColorText1Highlighted;
        if ([TTDeviceHelper is736Screen]) {
            //Plus上bar button item的左边距会多4.3个点（13px），调整到间距为30px
            [leftBarItem.button setTitleEdgeInsets:UIEdgeInsetsMake(0, -4.3, 0, 4.3)];
        }
    }
    UIBarButtonItem * leftPaddingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                      target:nil
                                                                                      action:nil];
    leftPaddingItem.width = 17.f;
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:leftBarItem], leftPaddingItem];

    //repost bar item
    TTNavigationBarItemContainerView * rightBarItem =
    (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight
                                                                             withTitle:NSLocalizedString(@"发布", nil)
                                                                                target:self
                                                                                action:@selector(sendRepost:)];
    if ([rightBarItem isKindOfClass:[TTNavigationBarItemContainerView class]]) {
        rightBarItem.button.titleColorThemeKey = kColorText6;
        rightBarItem.button.highlightedTitleColorThemeKey = kColorText6Highlighted;
        rightBarItem.button.disabledTitleColorThemeKey = kColorText9;
        rightBarItem.button.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        if ([TTDeviceHelper is736Screen]) {
            //Plus上bar button item的右边距会多4.3个点（13px），调整到间距为30px
            [rightBarItem.button setTitleEdgeInsets:UIEdgeInsetsMake(0, 4.3, 0, -4.3)];
        }
        self.postButton = rightBarItem.button;
    }
    UIBarButtonItem * rightPaddingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:nil];
    rightPaddingItem.width = 17.f;
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:rightBarItem], rightPaddingItem];

    //title view
    NSString * title = [KitchenMgr getString:kKCUGCRepostWordingRepostPageTitle];
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:title];

    self.firstAppear = YES;
    [self createComponent];
    [self addNotification];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.containerView addGestureRecognizer:tapGestureRecognizer];

    self.inputTextView.richSpanText = [self.richSpanText replaceWhitelistLinks];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.firstAppear) {
        self.firstAppear = NO;

        [self.inputTextView becomeFirstResponder];
        self.inputTextView.selectedRange = NSMakeRange(0, 0);

        // 修复从个人主页 WebView 跳转到转发发布器，UIWebDocumentView 调用 becomeFirstResponder 导致键盘被收起的问题
        if (NSClassFromString(@"UIWebDocumentView")) {
            id <AspectToken> aspect = [NSClassFromString(@"UIWebDocumentView") aspect_hookSelector:@selector(becomeFirstResponder) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
                return;
            } error:nil];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [aspect remove];
            });
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // 避免视频详情页转发时，出现 statusBar 高度获取为 0 的情况
    CGFloat top = MAX(self.ttNavigationBar.bottom, [TTDeviceHelper isIPhoneXDevice] ? 88 : 64);
    self.containerView.frame = CGRectMake(0, top, self.view.width, self.view.height - top);
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createComponent {
    CGFloat y = 0;

    // container view
    CGFloat top = 44.f + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.containerView = [[SSThemedScrollView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height - top)];
    self.containerView.backgroundColorThemeKey = kColorBackground4;
    self.containerView.alwaysBounceVertical = YES;
    self.containerView.delegate = self;
    [self.view addSubview:self.containerView];

    // input container view
    self.inputContainerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.inputContainerView.backgroundColorThemeKey = kColorBackground4;
    [self.containerView addSubview:self.inputContainerView];

    // input view
    self.inputTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(kLeftPadding - 5, y + kInputViewTopPadding, self.view.width - kLeftPadding - kRightPadding + 10, kTextViewHeight)];
    self.inputTextView.source = @"repost";
    self.inputTextView.delegate = self;
    y = self.inputTextView.bottom;

    HPGrowingTextView *internalTextView = self.inputTextView.internalGrowingTextView;
    internalTextView.minHeight = kTextViewHeight;
    internalTextView.minNumberOfLines = 3;
    internalTextView.maxNumberOfLines = 8;
    internalTextView.placeholder = [[TTKitchenMgr sharedInstance] getString:kKCUGCRepostPlaceHolder];
    internalTextView.backgroundColor = [UIColor clearColor];
    internalTextView.internalTextView.textColor = SSGetThemedColorWithKey(kColorText1);
    internalTextView.internalTextView.placeHolderColor = SSGetThemedColorWithKey(kColorText3);
    internalTextView.internalTextView.placeHolderFont = [UIFont systemFontOfSize:self.inputTextView.textViewFontSize];
    internalTextView.font = [UIFont systemFontOfSize:self.inputTextView.textViewFontSize];
    internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

    [self.inputContainerView addSubview:self.inputTextView];

    // repost quote view
    y += kRepostQuoteViewVerticalPadding;
    self.repostQuoteView = [[TTRepostThreadSchemaQuoteView alloc] initWithQuoteModel:self.repostQuoteModel];
    self.repostQuoteView.frame = CGRectMake(kLeftPadding, y, self.view.width - kLeftPadding - kRightPadding, 70);
    [self.inputContainerView addSubview:self.repostQuoteView];

    self.inputContainerView.height = self.repostQuoteView.bottom + kRepostQuoteViewVerticalPadding;

    // toolbar
    kUGCToolbarHeight = 80.f + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    self.toolbar = [[TTUGCToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - kUGCToolbarHeight, self.view.width, kUGCToolbarHeight)];
    self.toolbar.emojiInputView.delegate = self.inputTextView;
    self.toolbar.emojiInputView.source = @"repost";
    [self.view addSubview:self.toolbar];

    // repost to comment button
    if ([self shouldShowRepostToCommentCheckButton]) {
        self.repostToCommentCheckButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.repostToCommentCheckButton.imageName = @"details_choose_icon";
        self.repostToCommentCheckButton.selectedImageName = @"details_choose_ok_icon";
        self.repostToCommentCheckButton.highlightedImageName = nil;
        self.repostToCommentCheckButton.selected = [self shouldSetCheckedRepostToCommentCheckButton];
        self.repostToCommentCheckButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.repostToCommentCheckButton addTarget:self action:@selector(repostToCommentCheckButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat insets = (44 - 12) / 2.f;
        self.repostToCommentCheckButton.hitTestEdgeInsets = UIEdgeInsetsMake(-insets, -insets, -insets, -insets);

        NSString *repostTitle = [KitchenMgr getString:KKCCommentRepostRepostToCommentText];
        [self.repostToCommentCheckButton setTitle:repostTitle forState:UIControlStateNormal];
        self.repostToCommentCheckButton.titleColorThemeKey = self.repostToCommentCheckButton.selected ? kColorText1 : kColorText3;

        UIFont *labelFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        self.repostToCommentCheckButton.titleLabel.font = labelFont;
        self.repostToCommentCheckButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.repostToCommentCheckButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 9);
        self.repostToCommentCheckButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, -9);

        [self.toolbar addSubview:self.repostToCommentCheckButton];
        CGRect rect = [repostTitle boundingRectWithSize:CGSizeMake(180, 16)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName : labelFont}
                                                context:nil];
        self.repostToCommentCheckButton.frame =
            CGRectMake([TTDeviceUIUtils tt_newPadding:14.f], (80 - 44 - [TTDeviceUIUtils tt_newPadding:19]) / 2,
                [TTDeviceUIUtils tt_newPadding:12 + 18 + rect.size.width], [TTDeviceUIUtils tt_newPadding:19]);
    }

    //tips label
    self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(self.view.width - 70 - 15, 0, 70, 36.f)];
    self.tipLabel.font = [UIFont systemFontOfSize:12];
    self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.tipLabel.textAlignment = NSTextAlignmentRight;
    self.tipLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    self.tipLabel.textColorThemeKey = kColorText4;
    self.tipLabel.hidden = true;
    [self.toolbar addSubview:self.tipLabel];

    // TextView and Toolbar Mediator
    self.textViewMediator = [[TTUGCTextViewMediator alloc] init];
    self.textViewMediator.textView = self.inputTextView;
    self.textViewMediator.toolbar = self.toolbar;
    self.toolbar.emojiInputView.delegate = self.inputTextView;
    self.toolbar.delegate = self.textViewMediator;
    self.inputTextView.delegate = self.textViewMediator;
    [self.inputTextView tt_addDelegate:self asMainDelegate:NO];

    [self refreshUI];
}

- (void)refreshUI {
    NSString *inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (inputText.length > g_postMomentMaxCharactersLimit) {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = [NSString stringWithFormat:@"-%lu", (unsigned long)(inputText.length - g_postMomentMaxCharactersLimit)];
    } else {
        self.tipLabel.hidden = YES;
    }

    if (!self.tipLabel.hidden || !self.repostToCommentCheckButton.hidden) {
        self.toolbar.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    } else {
        self.toolbar.backgroundColor = nil;
    }
}

#pragma mark - RepostToComment

- (BOOL)shouldShowRepostToCommentCheckButton {
    // enableCommentRepost表示后台支持的“转发并评论”类型
    BOOL enableCommentRepost = (self.repostModel.fw_id_type == FRUGCTypeCodeCOMMENT
                                || self.repostModel.fw_id_type == FRUGCTypeCodeTHREAD
                                || self.repostModel.fw_id_type == FRUGCTypeCodeREPLY
                                || self.repostModel.fw_id_type == FRUGCTypeCodeITEM
                                || self.repostModel.fw_id_type == FRUGCTypeCodeGROUP
                                || self.repostModel.fw_id_type == FRUGCTypeCodeANSWER);
    if (self.repostModel.repost_type == TTThreadRepostTypeLink && !isEmptyString(self.repostModel.fw_id)) {
        enableCommentRepost = YES;
    }
    return [KitchenMgr getBOOL:KKCCommentRepostRepostToCommentEnable] && enableCommentRepost;
}

- (BOOL)shouldSetCheckedRepostToCommentCheckButton {
    return [KitchenMgr getBOOL:KKCCommentRepostRepostToCommentSelected];
}

- (void)setRepostToCommentCheckButtonChecked:(BOOL)checked {
    [KitchenMgr setBOOL:checked forKey:KKCCommentRepostRepostToCommentSelected];
}

- (void)repostToCommentCheckButtonClicked:(id)sender {
    self.repostToCommentCheckButton.selected = !self.repostToCommentCheckButton.selected;
    self.repostToCommentCheckButton.titleColorThemeKey = self.repostToCommentCheckButton.selected ? kColorText1 : kColorText3;
    [self setRepostToCommentCheckButtonChecked:self.repostToCommentCheckButton.selected];

    if (self.repostToCommentCheckButton.selected) {
        [TTTrackerWrapper eventV3:@"repost_to_comment" params:nil];
    } else {
        [TTTrackerWrapper eventV3:@"repost_to_comment_cancel" params:nil];
    }
}


#pragma mark - Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];

    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    } else {
        self.inputTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    
    self.inputTextView.internalGrowingTextView.internalTextView.textColor = SSGetThemedColorWithKey(kColorText1);
    self.inputTextView.internalGrowingTextView.internalTextView.placeHolderColor = SSGetThemedColorWithKey(kColorText3);
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!CGRectIsEmpty(self.keyboardEndFrame)) {
        CGFloat offset = self.containerView.contentOffset.y - self.keyboardEndFrame.size.height;
        if (offset < 0) {
            offset = 0;
        }
        [self.containerView setContentOffset:CGPointMake(0, offset) animated:YES];
        self.keyboardEndFrame = CGRectZero;
    }
}

- (void)keyboardWillChange:(NSNotification *)notification {
    UIView * firstResponder = nil;
    if (self.inputTextView.isFirstResponder) {
        firstResponder = self.inputTextView;
    }
    if (!firstResponder) {
        return;
    }
    CGRect endFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect firstResponderFrame = [firstResponder convertRect:firstResponder.bounds toView:self.containerView];
    CGFloat offset = CGRectGetMinY(firstResponderFrame) - self.containerView.contentOffset.y;
    if (offset < 0) {
        self.keyboardEndFrame = endFrame;
        [self.containerView setContentOffset:CGPointMake(0, fabs(self.containerView.contentOffset.y+offset)) animated:YES];
        return;
    }
    offset = self.containerView.height - endFrame.size.height - (CGRectGetMaxY(firstResponderFrame) - self.containerView.contentOffset.y) - kUGCToolbarHeight;
    if (offset < 0) {
        self.keyboardEndFrame = endFrame;
        [self.containerView setContentOffset:CGPointMake(0, fabs(self.containerView.contentOffset.y-offset)) animated:YES];
        return;
    }
}



#pragma mark - Selectors & Actions

- (void)sendRepost:(id)sender {
    
    TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
    [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (isEmptyString(richSpanText.text)) {
        [richSpanText insertText:@"转发了" atIndex:0];
    }

    NSString *inputText = richSpanText.text;

    if (![self validateAttributedTextInTextView:inputText]) {
        return;
    }
    [self endEditing];
    WeakSelf;
    [[TTRepostService sharedInstance] sendRepostWithRepostModel:self.repostModel
                                                   richSpanText:richSpanText
                                                isCommentRepost:self.repostToCommentCheckButton.selected
                                             baseViewController:self
                                                      trackDict:@{@"section":@"repost_page"}
                                                    finishBlock:^{
                                                        StrongSelf;
                                                        [self repostFinished:YES];
                                                    }];

}


- (BOOL)validateAttributedTextInTextView:(NSString *)inputText {
    if (inputText.length > g_postMomentMaxCharactersLimit) {
        [self endEditing];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"超出字数限制， 请调整后再发", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }
    
    return YES;
}

- (void)cancelRepost:(id)sender {
    [self endEditing];
    
    NSMutableDictionary *trackDic = [[NSMutableDictionary alloc] init];
    if (self.repostModel.repost_type == TTThreadRepostTypeLink) {
        [trackDic setValue:@"public-benefit" forKey:@"source"];
    }
    [self trackRepostWithEvent:self.source label:@"cancel" extra:trackDic];

    NSString *inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL shouldAlert = !(isEmptyString(inputText));

    if (!shouldAlert) {
        [self repostFinished:NO];
    } else {
        [self trackRepostWithEvent:self.source label:@"alert" extra:nil];
        TTThemedAlertController * alertController =
            [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"确定退出？", comment: nil)
                                                   message:nil
                                             preferredType:TTThemedAlertControllerTypeAlert];
        WeakSelf;
        [alertController addActionWithTitle:NSLocalizedString(@"取消", comment:nil)
                                 actionType:TTThemedAlertActionTypeCancel
                                actionBlock:^{
                                    StrongSelf;
                                    [self trackRepostWithEvent:@"repost_publish_alert"
                                                         label:@"cancel"
                                                         extra:nil];
                                }];
        [alertController addActionWithTitle:NSLocalizedString(@"退出", comment:nil)
                                 actionType:TTThemedAlertActionTypeDestructive
                                actionBlock:^{
                                    StrongSelf;
                                    [self trackRepostWithEvent:@"repost_publish_alert"
                                                         label:@"confirm"
                                                         extra:nil];
                                    [self repostFinished:NO];
                                }];
        [alertController showFrom:self animated:YES];
    }
}

- (void)repostFinished:(BOOL)hasSent {
    if (!hasSent) {
        [self trackRepostWithEvent:self.source label:@"cancel_done" extra:nil];
    }

    if ([TTDeviceHelper OSVersionNumber] < 8.0 && self.presentedViewController) {
        //修复iOS7未登录发帖，登录成功后，发帖页面没有消失的bug
        WeakSelf;
        self.view.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself dismissSelf];
        });
    } else {
        [self dismissSelf];
    }
}

- (void)endEditing {
    [self.view endEditing:YES];

    [self.toolbar endEditing:YES];
}

- (void)tapAction:(id)sender {
    // 点击空白处可以收起或呼出键盘
    if (self.inputTextView.isFirstResponder) {
        [self.inputTextView resignFirstResponder];
    } else {
        [self.inputTextView becomeFirstResponder];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing];
}


#pragma mark - TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {
    [self refreshUI];
}

- (void)textView:(TTUGCTextView *)textView willChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight {
    self.repostQuoteView.top = self.inputTextView.bottom + kRepostQuoteViewVerticalPadding;
    self.inputContainerView.height = self.repostQuoteView.bottom + kRepostQuoteViewVerticalPadding;
}

#pragma mark - Tracker

- (NSString *)source {
    return @"repost_publish";
}

- (void)trackRepostWithEvent:(NSString *)event label:(NSString *)label extra:(NSDictionary *)extra {
    [[TTRepostService sharedInstance] trackRepostWithEvent:event label:label repostModel:self.repostModel extra:extra];
}


@end
