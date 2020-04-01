//
//  FHWDAnswerPictureTextViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/31.
//

#import "FHWDAnswerPictureTextViewController.h"
#import "TTNavigationController.h"
#import "SSNavigationBar.h"
#import "TTDeviceHelper.h"
#import "TTAdCanvasNavigationBar.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"
#import "TTThemedAlertController.h"
#import "TTUGCTextView.h"
#import "UIView+TTFFrame.h"
#import "UITextView+TTAdditions.h"
#import "TTUGCTextViewMediator.h"
#import "TTUGCToolbar.h"
#import "NSObject+MultiDelegates.h"
#import "UIViewAdditions.h"
#import "FRAddMultiImagesView.h"
#import "NSDictionary+TTAdditions.h"
#import "NSString+URLEncoding.h"
#import "TTKitchen.h"
#import "TTPostThreadKitchenConfig.h"
#import "FRPostThreadAddLocationView.h"
#import <KVOController/KVOController.h>
#import "TTLocationManager.h"
#import "TTGoogleMapGeocoder.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Link.h"
#import "TTThemeManager.h"
#import "TTIndicatorView.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "TTPostThreadModel.h"
#import "TTPostThreadCenter.h"
#import "TTUGCEmojiParser.h"
#import "TTUGCHashtagModel.h"
#import "TTAdCanvasDefine.h"
#import "WDSettingHelper.h"
#import "WDAnswerService.h"
#import "WDUploadImageManager.h"
#import "WDPostAnswerTaskModel.h"
#import "JSONAdditions.h"
#import "WDMonitorManager.h"
#import "FHWenDaToolbar.h"
#import "FHUserTracker.h"
#import "FHBubbleTipManager.h"
#import "HMDTTMonitor.h"
#import "SSAPNsAlertManager.h"

static CGFloat const kLeftPadding = 20.f;
static CGFloat const kRightPadding = 20.f;
static CGFloat const kInputViewTopPadding = 10.f;
static CGFloat const kTextViewHeight = 100.f;
static CGFloat const kAddImagesViewTopPadding = 10.f;
static CGFloat const kAddImagesViewBottomPadding = 18.f;

static CGFloat kWenDaToolbarHeight = 80.f;

@interface FHWDAnswerPictureTextViewController ()<FRAddMultiImagesViewDelegate,UITextFieldDelegate, UIScrollViewDelegate,  TTUGCTextViewDelegate, TTUGCToolbarDelegate ,WDUploadImageManagerDelegate>

@property (nonatomic, copy) NSString *qid;
@property (nonatomic, copy) NSString *ansid;
@property (nonatomic, copy) NSString *answerSchema;
@property (nonatomic, assign) BOOL isForbidComment;
@property (nonatomic, copy, nullable) NSDictionary *gdExtJson;
@property (nonatomic,   copy) NSString *source;
@property (nonatomic,   copy) NSString *listEntrance;
@property (nonatomic, strong) NSDictionary *apiParam;

@property (nonatomic, strong) SSThemedButton * cancelButton;
@property (nonatomic, strong) SSThemedButton * postButton;
@property (nonatomic, strong) TTNavigationBarItemContainerView *rightBarView;
@property (nonatomic, strong) SSThemedScrollView * containerView;
@property (nonatomic, strong) TTUGCTextView * inputTextView;
@property (nonatomic, strong) SSThemedView * inputContainerView;
@property (nonatomic, strong) FRAddMultiImagesView * addImagesView;
@property (nonatomic, strong) FHWenDaToolbar *toolbar;
@property (nonatomic, strong) TTUGCTextViewMediator *textViewMediator;
@property (nonatomic, strong) TTIndicatorView *sendingIndicatorView;
@property (nonatomic, strong) SSThemedLabel * tipLabel;
@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;
@property (nonatomic, assign) BOOL firstAppear;
@property (nonatomic, strong) SSThemedView * infoContainerView;

@property (nonatomic, copy) NSArray <TTAssetModel *> * outerInputAssets; //传入的assets
@property (nonatomic, copy) NSArray <UIImage *> * outerInputImages; //传入的images
@property (nonatomic, copy) TTRichSpanText *outerInputRichSpanText; //编辑带入的文字信息
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, assign) BOOL useDraftFirst;//是否优先使用concern_id草稿，否则使用传入值（postPreContent || postPreContentRichSpan）

@property (nonatomic, strong) TTRichSpanText *richSpanText;

@property (nonatomic, assign) CGRect keyboardEndFrame;
@property (nonatomic, assign) BOOL keyboardVisibleBeforePresent; // 保存 present 页面之前的键盘状态，用于 Dismiss 之后恢复键盘
@property (nonatomic, copy) NSString *enterConcernID; //entrance为concern时有意义

@property(nonatomic, strong) WDUploadImageManager *uploadImageManager;
@property (nonatomic, copy) void(^sendAnswerBlock)(void);
@property(nonatomic, strong) WDPostAnswerTaskModel * taskModel;
@property (nonatomic, assign) BOOL isPosting;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, assign)   BOOL       lastCanShowMessageTip;
@property (nonatomic, assign)   BOOL       lastInAppPushTipsHidden;
@property (nonatomic, weak)     TTNavigationController       *navVC;

@end

@implementation FHWDAnswerPictureTextViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
        NSString *qid = [paramObj.allParams objectForKey:@"qid"];
        NSString *ansid = [paramObj.allParams objectForKey:@"ansid"];
       
        self.qid = qid;
        self.ansid = ansid;
        self.answerSchema = @"";
        self.isForbidComment = NO;
        self.isPosting = NO;
        self.gdExtJson = params[@"gd_ext_json"];
        
        self.tracerDict[@"page_type"] = @"answer_publisher";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.firstAppear = YES;
    [self setupData];
    [self setupUI];
    [self addImagesViewSizeChanged];
    [self refreshUI];
    self.startDate = [NSDate date];
    [self goDetail];
    
    // 顶部 消息 弹窗tips
    self.lastCanShowMessageTip = [FHBubbleTipManager shareInstance].canShowTip;
    [FHBubbleTipManager shareInstance].canShowTip = NO;
    // App 内push
    self.lastInAppPushTipsHidden = kFHInAppPushTipsHidden;
    kFHInAppPushTipsHidden = YES;// 不展示
}

- (void)setupData {
    WDPostAnswerTaskModel *taskModel = [[WDPostAnswerTaskModel alloc] initWithQid:self.qid content:nil contentRichSpan:nil imageList:nil];
    self.taskModel = taskModel;
    self.uploadImageManager = [[WDUploadImageManager alloc] init];
    self.uploadImageManager.delegate = self;
}

- (void)restoreData {
    // 构建 richSpanText
    if (self.richSpanText == nil) {
        self.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
        self.outerInputRichSpanText = self.richSpanText;
    }
    
    // 加载草稿
    if (![self hasPresettingThreadContent]) {
        [self restoreDraft];
    }
    
    // 等待构造完成之后初始化
    self.inputTextView.richSpanText = self.richSpanText;
    
    // 待richSpanText更新后，再更新光标位置
    if (self.selectedRange.location > 0 && self.inputTextView.text.length >= self.selectedRange.location) {
        self.inputTextView.selectedRange = self.selectedRange;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [FHBubbleTipManager shareInstance].canShowTip = self.lastCanShowMessageTip;
    kFHInAppPushTipsHidden = self.lastInAppPushTipsHidden;// 展示
}

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
    TTNavigationBarItemContainerView *leftView = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"取消" target:self action:@selector(previousAction:)];
    leftView.button.titleLabel.font = [UIFont systemFontOfSize:16];
    if ([TTDeviceHelper getDeviceType] == TTDeviceMode736) {
        leftView.button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, -4.3, 0.0f, 4.3);
    }
    leftView.button.titleColorThemeKey = kColorText1;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.cancelButton = leftView.button;
    [self.cancelButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor themeGray1] forState:UIControlStateDisabled];
    self.rightBarView = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:NSLocalizedString(@"发布", nil) target:self action:@selector(postQuestionAction:)];
    self.rightBarView.button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarView];
    self.postButton = self.rightBarView.button;
    if ([TTDeviceHelper getDeviceType] == TTDeviceMode736) {
        self.rightBarView.button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 3.0f, 0, -3.0f);
    }
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [self setupNaviBar];
    [self createComponent];
}

#pragma mark - View

- (void)createComponent {
    //Container View
    self.containerView = [[SSThemedScrollView alloc] initWithFrame:[self containerFrame]];
    self.containerView.backgroundColorThemeKey = kColorBackground4;
    self.containerView.alwaysBounceVertical = YES;
    self.containerView.delegate = self;
    [self.view addSubview:self.containerView];
    
    [self addObserverAndNoti];
    
    //Create input component
    [self createInputComponent];
    
    [self createInfoComponent];
}

- (void)addObserverAndNoti {
    WeakSelf;
    [self.KVOController observe:self.addImagesView keyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        CGRect newFrame = [change[NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldFrame = [change[NSKeyValueChangeOldKey] CGRectValue];
    }];
    
    [self addNotification];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.containerView addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (CGRect)containerFrame {
    CGFloat yOffset = kNavigationBarHeight;
    return CGRectMake(0, yOffset, self.view.width, self.view.height - yOffset);
}

- (void)createInputComponent {
    CGFloat y = 0;
    
    //Input container view
    self.inputContainerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.inputContainerView.backgroundColorThemeKey = kColorBackground4;
    [self.containerView addSubview:self.inputContainerView];
    
    //Input view
    self.inputTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(kLeftPadding - 5, y + kInputViewTopPadding, self.view.width - kLeftPadding - kRightPadding + 10.f, kTextViewHeight)];
    self.inputTextView.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpansJSONString:nil];
    self.inputTextView.contentInset = UIEdgeInsetsZero;
    self.inputTextView.isBanAt = YES;
    self.inputTextView.isBanHashtag = YES;
    y = self.inputTextView.bottom;
    
    HPGrowingTextView *internalTextView = self.inputTextView.internalGrowingTextView;
    internalTextView.minHeight = kTextViewHeight;
//    internalTextView.maxHeight = INT_MAX;
    // 行数适配
    int maxNumberOfLines = 8;
    if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
        maxNumberOfLines = 8;
    } else if ([TTDeviceHelper is667Screen]) {
        maxNumberOfLines = 10;
    } else if ([TTDeviceHelper is736Screen]) {
        maxNumberOfLines = 11;
    } if ([TTDeviceHelper isIPhoneXDevice]) {
        maxNumberOfLines = 12;
    }
    internalTextView.maxNumberOfLines = maxNumberOfLines;
    internalTextView.tintColor = [UIColor themeRed1];
    internalTextView.placeholder = @"分享你的观点";
    
    // 图文发布器展示
    internalTextView.backgroundColor = [UIColor clearColor];
    internalTextView.textColor = SSGetThemedColorWithKey(kColorText1);
    internalTextView.placeholderColor =  SSGetThemedColorWithKey(kColorText3);
    internalTextView.internalTextView.placeHolderFont = [UIFont systemFontOfSize:self.inputTextView.textViewFontSize];
    internalTextView.font = [UIFont systemFontOfSize:self.inputTextView.textViewFontSize];
    internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.inputContainerView addSubview:self.inputTextView];
    
    //add image view
    y += kAddImagesViewTopPadding;
    CGFloat kAddImagesViewHeight = floor((self.view.width - kLeftPadding - kRightPadding - 6 * 2) / 3);
    self.addImagesView = [[FRAddMultiImagesView alloc] initWithFrame:CGRectMake(kLeftPadding, y, self.view.width - kLeftPadding - kRightPadding, kAddImagesViewHeight)
                                                              assets:self.outerInputAssets
                                                              images:self.outerInputImages];
    self.addImagesView.hidden = NO;
    self.addImagesView.dragEnable = NO;
    self.addImagesView.hideAddImagesButtonWhenEmpty = YES; // 只有第一次添加图片后才显示
    self.addImagesView.selectionLimit = 9;
    self.addImagesView.delegate = self;
    WeakSelf;
    self.addImagesView.shouldAddPictureHandle = ^{
        StrongSelf;
        [self.inputTextView resignFirstResponder];
    };
    
//    [self.containerView addSubview:self.addImagesView];
    [self.inputContainerView addSubview:self.addImagesView];
    
    self.inputContainerView.height =  self.addImagesView.bottom + kAddImagesViewBottomPadding;
    
    // toolbar
    kWenDaToolbarHeight = 80.f + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    self.toolbar = [[FHWenDaToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - kWenDaToolbarHeight, self.view.width, kWenDaToolbarHeight)];
    self.toolbar.emojiInputView.source = @"wenda";
    __weak typeof(self) weakSelf = self;
    self.toolbar.picButtonClkBlk = ^{
        // 添加图片
        [weakSelf.addImagesView showImagePicker];
    };
    self.toolbar.banLongText = YES;
    
    [self.view addSubview:self.toolbar];
    
    //Tip label
    CGFloat tipLabelWidth = self.view.width - kRightPadding * 2;
    self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kRightPadding, 11, tipLabelWidth, 25.f)];
    self.tipLabel.backgroundColor = [UIColor whiteColor];
    
    self.tipLabel.font = [UIFont systemFontOfSize:11];
    self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.tipLabel.textAlignment = NSTextAlignmentRight;
    self.tipLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    [self.tipLabel setTextColor:[UIColor themeGray4]];
    self.tipLabel.hidden = NO;
    [self.toolbar addSubview:self.tipLabel];
    
    // TextView and Toolbar Mediator
    self.textViewMediator = [[TTUGCTextViewMediator alloc] init];
    self.textViewMediator.textView = self.inputTextView;
    self.textViewMediator.toolbar = self.toolbar;
    self.textViewMediator.showCanBeCreatedHashtag = YES;
    self.toolbar.emojiInputView.delegate = self.inputTextView;
    self.toolbar.delegate = self.textViewMediator;
    [self.toolbar tt_addDelegate:self asMainDelegate:NO];
    self.inputTextView.delegate = self.textViewMediator;
    [self.inputTextView tt_addDelegate:self asMainDelegate:NO];
    self.inputTextView.textLenDelegate = self;
}

- (void)createInfoComponent {
    
    //Info container view
    self.infoContainerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.inputContainerView.bottom + 10 , self.view.width, 0)];
    self.infoContainerView.backgroundColorThemeKey = kColorBackground4;
    [self.containerView addSubview:self.infoContainerView];
    
    CGFloat y = 0;
    // 添加其他视图
    self.infoContainerView.height = y;
}

- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count>1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)endEditing {
    [self.view endEditing:YES];
    
    [self.toolbar endEditing:YES];
}

- (void)tapAction:(UITapGestureRecognizer *)sender {
    // 点击空白处可以收起或呼出键盘
    if (self.inputTextView.isFirstResponder) {
        [self.inputTextView resignFirstResponder];
    } else {
        [self.inputTextView becomeFirstResponder];
    }
}

#pragma mark - Action

- (void)previousAction:(id)sender {
    self.keyboardVisibleBeforePresent = self.inputTextView.keyboardVisible;
    [self endEditing];
    NSString * inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL shouldAlert = !isEmptyString(inputText) || self.addImagesView.selectedImageCacheTasks.count != 0;
    
    if (!shouldAlert) {
        NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
        tracerDict[@"click_position"] = @"answer_publisher_cancel";
        [FHUserTracker writeEvent:@"click_options" params:tracerDict];
        
        [self dismissSelf];
    } else {
        NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
        [FHUserTracker writeEvent:@"answer_publisher_cancelpopoup_show" params:tracerDict];
        
        TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"编辑未完成" message:@"退出后编辑的内容将不被保存" preferredType:TTThemedAlertControllerTypeAlert];
        WeakSelf;
        [alertController addActionWithTitle:NSLocalizedString(@"退出", comment:nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            StrongSelf;
            NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
            tracerDict[@"click_position"] = @"quit";
            [FHUserTracker writeEvent:@"answer_publisher_cancelpopoup_click" params:tracerDict];
            [self dismissSelf];
        }];
        [alertController addActionWithTitle:NSLocalizedString(@"继续编辑", comment:nil) actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
            StrongSelf;
            NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
            tracerDict[@"click_position"] = @"continue_edit";
            [FHUserTracker writeEvent:@"answer_publisher_cancelpopoup_click" params:tracerDict];
            if (self.keyboardVisibleBeforePresent) {
                [self.inputTextView becomeFirstResponder];
            }
        }];
        [alertController showFrom:self animated:YES];
    }
}

- (void)updateAnswer {
    
    TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
    [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *inputText = richSpanText.text;
    TTRichSpans *richSpans = richSpanText.richSpans;
    
    _taskModel.answerType = WDPostAnswerTypePictureText;
    _taskModel.content = inputText;
    _taskModel.richSpanText = [TTRichSpans JSONStringForRichSpans:richSpans];;
    _taskModel.imageList = (NSArray<id<WDUploadImageModelProtocol>>  *)self.addImagesView.selectedImages;
}


- (BOOL)isValidateWithInputText:(NSString *)inputText{
    //Validate
    
    NSUInteger maxTextCount = [TTKitchen getInt:kTTKUGCPostAndRepostContentMaxCount];

    if (isEmptyString(inputText) && self.addImagesView.selectedImageCacheTasks.count == 0) {
        [self endEditing];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"说点什么...", nil)
                                 indicatorImage:nil
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }else if (inputText.length > maxTextCount) {
        [self endEditing];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:[NSString stringWithFormat:@"字数超过%ld字，请调整后重试", maxTextCount]
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }

    if (![TTReachability isNetworkConnected]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }
    return YES;
}

- (void)postQuestionAction:(id)sender {
    [self publish_click_tracer];
    TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
    [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *inputText = richSpanText.text;
    
    if (![self isValidateWithInputText:inputText]) {
        return;
    }
    [self endEditing];
    // 更新答案
    [self updateAnswer];
    // 上报答案
    [self sendAnswer];
}

- (void)cancelImageUpload {
    [_uploadImageManager cancelUploadImage];
    self.sendAnswerBlock = nil;
}

- (void)sendAnswer {
    if (self && [TTAccountManager isLogin] && self.qid.length > 0) {
        __weak typeof(self) wself = self;
        self.sendingIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:NSLocalizedString(@"正在发送...", nil) indicatorImage:nil dismissHandler:^(BOOL isUserDismiss){
            if (isUserDismiss) {
                //点击取消按钮
                [wself cancelImageUpload];
            }
        }];
        self.sendingIndicatorView.autoDismiss = NO;
        self.sendingIndicatorView.showDismissButton = YES;
        [self.sendingIndicatorView showFromParentView:nil];
        [self postAnswerWithApiParam:self.apiParam source:self.source listEntrance:self.listEntrance imageUploadComplete:^{
            //图片上传成功，隐藏关闭按钮
            [wself.sendingIndicatorView updateIndicatorWithText:NSLocalizedString(@"上传成功，加载中...", nil) shouldRemoveWaitingView:NO];
            wself.sendingIndicatorView.showDismissButton = NO;
        } complete:^(NSError * _Nullable error) {
            
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:wself.startDate];
            NSMutableDictionary *diction = [NSMutableDictionary dictionary];
            [diction setValue:@((NSInteger)timeInterval) forKey:@"timeInterval"];
            
            NSString *qid = wself.qid;
            NSString *ansid = wself.ansid;
            if (qid.length > 0 && ansid.length > 0) {
                //回答发送成功
                [[HMDTTMonitor defaultManager] hmdTrackService:@"f_ugc_post_answer_result" metric:nil category:@{@"status":@(0)} extra:nil];
                [wself sendAnswerSuccessTracer:ansid];
                [wself.sendingIndicatorView updateIndicatorWithText:[wself postAnswerSuccessText] shouldRemoveWaitingView:YES];
                [wself.sendingIndicatorView updateIndicatorWithImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"]];
                wself.sendingIndicatorView.showDismissButton = NO;
                NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
                [userInfoDict setValue:qid forKey:@"qid"];
                [userInfoDict setValue:ansid forKey:@"ansid"];
                if (wself.answerSchema.length > 0) {
                    [userInfoDict setValue:wself.answerSchema forKey:@"scheme"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHWDAnswerPictureTextPostSuccessNotification object:nil userInfo:userInfoDict];
                
                [wself dismissSelf];
            }else {
                [[HMDTTMonitor defaultManager] hmdTrackService:@"f_ugc_post_answer_result" metric:nil category:@{@"status":@(1)} extra:nil];
                NSNumber *errorCode = [error.userInfo objectForKey:kWDErrorCodeKey];
                //回答发送失败
                NSString *errorTips = [error.userInfo objectForKey:kWDErrorTipsKey];
                if (errorTips.length == 0) {
                    errorTips = NSLocalizedString(@"网络加载异常，请重试", nil);
                }
                [wself.sendingIndicatorView updateIndicatorWithText:errorTips shouldRemoveWaitingView:YES];
                [wself.sendingIndicatorView updateIndicatorWithImage:[UIImage themedImageNamed:@"close_popup_textpage"]];
                wself.sendingIndicatorView.showDismissButton = NO;
            }
            
            [wself.sendingIndicatorView dismissFromParentView];
        }];
    }
}

- (NSString *)postAnswerSuccessText {
    return NSLocalizedString(@"已发布", nil);
}

- (void)postAnswerWithApiParam:(NSDictionary *)apiParam
                        source:(NSString *)source
                  listEntrance:(NSString *)listEntrance
           imageUploadComplete:(void(^ __nullable)(void))uploadImageCompleteHandler
                      complete:(void(^ __nullable)(NSError * __nullable error))block
{
    //先保存最新的快照
    
    typeof(self) __weak wSelf = self;
    void(^sendAnswerBlock)(void) = ^{
        
        if (isEmptyString(wSelf.taskModel.content) && wSelf.taskModel.imageList.count == 0) {
            return;
        }
        NSString *content = wSelf.taskModel.content;
        NSString *richSpanTetxt = wSelf.taskModel.richSpanText;
        NSArray<NSString *> *imageUris = [wSelf.taskModel remoteImgUris];
        
        if (uploadImageCompleteHandler) {
            //通知vc图片上传过程完成
            uploadImageCompleteHandler();
        }
        
        if (wSelf.isPosting) {
            return;
        }
        
        NSString *gdExtJson = nil;
        if([wSelf.gdExtJson isKindOfClass:[NSString class]]){
            gdExtJson = wSelf.gdExtJson;
        }else if([wSelf.gdExtJson isKindOfClass:[NSDictionary class]]){
            gdExtJson = [wSelf.gdExtJson tt_JSONRepresentation];
        }
        
        wSelf.isPosting = YES;
        [WDAnswerService postAnswerWithQid:wSelf.qid answerType:WDAnswerTypePictureText content:content richSpanText:richSpanTetxt imageUris:imageUris videoID:nil videoCoverURI:nil videoDuration:nil isBanComment:wSelf.isForbidComment apiParameter:apiParam source:source listEntrance:listEntrance gdExtJson:gdExtJson finishBlock:^(WDWendaCommitPostanswerResponseModel * _Nullable responseModel, NSError * _Nullable error) {
            NSString *tips;
            NSError *postError;
            
            if (error) {
                tips = [[error userInfo] objectForKey:@"description"];
                postError = [NSError errorWithDomain:kWDErrorDomain code:-1 userInfo:tips.length > 0?@{kWDErrorTipsKey : tips, kWDErrorCodeKey : @(error.code)}:nil];
            }
            
            wSelf.answerSchema = responseModel.schema;
            wSelf.ansid = responseModel.ansid;
            
            if (block) {
                block(postError);
            }
            wSelf.isPosting = NO;
        }];
    };
    
    self.sendAnswerBlock = sendAnswerBlock;
    [self.uploadImageManager uploadImages:self.taskModel.imageList];
}


- (void)addImagesViewSizeChanged {
    self.inputContainerView.height = self.addImagesView.bottom + kAddImagesViewBottomPadding;
    self.infoContainerView.top = self.inputContainerView.height + 10;
    
    CGFloat targetHeight = self.infoContainerView.bottom + 10;
    CGFloat containerHeight = self.view.height - 64;
    containerHeight = containerHeight >= targetHeight ? containerHeight : targetHeight;
    containerHeight += kWenDaToolbarHeight;
    self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width, containerHeight);
    [self refreshPostButtonUI];
}

- (void)refreshUI {
    NSUInteger maxTextCount = [TTKitchen getInt:kTTKUGCPostAndRepostContentMaxCount];
    NSString *inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.tipLabel.hidden = NO;
    self.tipLabel.text = [NSString stringWithFormat:@"%ld/%lu",inputText.length, maxTextCount];
    
    [self refreshPostButtonUI];
}

- (void)refreshPostButtonUI {
    //发布器
    if (self.inputTextView.text.length > 0 || self.addImagesView.selectedImageCacheTasks.count > 0) {
        self.postButton.enabled = YES;
        self.postButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
        [self.postButton setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
        [self.postButton setTitleColor:[UIColor themeOrange1] forState:UIControlStateDisabled];
    } else {
        self.postButton.highlightedTitleColorThemeKey = kColorText9Highlighted;
        [self.postButton setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [self.postButton setTitleColor:[UIColor themeGray3] forState:UIControlStateDisabled];
        self.postButton.enabled = NO;
    }
}

- (BOOL)textHasChanged {
    return ![self.richSpanText.text isEqualToString:self.outerInputRichSpanText.text];
}

- (BOOL)imageHasChanged {
    if (self.addImagesView.selectedImageCacheTasks.count != self.outerInputAssets.count) {
        return YES;
    }
    for (NSInteger index = 0; index < self.addImagesView.selectedImageCacheTasks.count; index++) {
        TTUGCImageCompressTask *task = [self.addImagesView.selectedImageCacheTasks objectAtIndex:index];
        if (![[self.outerInputAssets objectAtIndex:index] isEqual:task.assetModel]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {
    [self refreshUI];
}

- (void)textView:(TTUGCTextView *)textView willChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight {
    // 图文发布器展示
    self.addImagesView.top = self.inputTextView.bottom + kAddImagesViewTopPadding;
    self.inputContainerView.height = self.addImagesView.bottom + kAddImagesViewBottomPadding;
    self.infoContainerView.top = self.inputContainerView.height + 10;
    
    CGFloat targetHeight = self.infoContainerView.bottom + 10;
    CGFloat containerHeight = self.view.height - 64;
    containerHeight = containerHeight >= targetHeight ? containerHeight : targetHeight;
    containerHeight += kWenDaToolbarHeight;
    self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width, containerHeight);
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.toolbar.banAtInput = YES;
    self.toolbar.banHashtagInput = YES;
    self.toolbar.banEmojiInput = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.toolbar.banAtInput = [TTKitchen getBOOL:kTTKUGCPostAndRepostBanAt];
    self.toolbar.banHashtagInput = [TTKitchen getBOOL:kTTKUGCPostAndRepostBanHashtag];
    self.toolbar.banEmojiInput = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

// 输入文本长度限制代理
- (BOOL)textView:(TTUGCTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger maxTextCount = [TTKitchen getInt:kTTKUGCPostAndRepostContentMaxCount];
    NSUInteger currentLen = textView.text.length;
    if (currentLen + text.length > maxTextCount) {
        return NO;
    }
    if (currentLen < range.location + range.length) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing];
}


#pragma mark - FRAddMultiImagesViewDelegate

- (void)addImagesButtonDidClickedOfAddMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"click_position"] = @"picture";
    [FHUserTracker writeEvent:@"click_options" params:tracerDict];
    
    self.keyboardVisibleBeforePresent = self.inputTextView.keyboardVisible;
    [self endEditing];
}

- (void)addMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView clickedImageAtIndex:(NSUInteger)index {
    self.keyboardVisibleBeforePresent = self.inputTextView.keyboardVisible;
    [self endEditing];
}

- (void)addMultiImagesViewPresentedViewControllerDidDismiss {
    // 如果选择定位位置之前，键盘是弹出状态，选择完之后恢复键盘状态
    if (self.keyboardVisibleBeforePresent) {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)addMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView changeToSize:(CGSize)size {
    [self addImagesViewSizeChanged];
}

- (void)addMultiImagesViewNeedEndEditing {
    [self endEditing];
}

- (void)addMultiImageViewDidBeginDragging:(FRAddMultiImagesView *)addMultiImagesView {
    self.cancelButton.enabled = NO;
    self.postButton.enabled = NO;
}

- (void)addMultiImageViewDidFinishDragging:(FRAddMultiImagesView *)addMultiImagesView {
    self.cancelButton.enabled = YES;
    self.postButton.enabled = YES;
    [self refreshPostButtonUI];
}

#pragma mark - TTUGCToolbarDelegate

- (void)toolbarDidClickLongText {
    // nothing
}


- (void)toolbarDidClickShoppingButton {
    // nothing
}

- (void)restoreDraft {
    if ([self draftEnable]) {
        NSArray *tasks = [TTPostThreadTask fetchTasksFromDiskForConcernID:[self draftConcernID]];
        TTPostThreadTask *task = [tasks lastObject];
        if ([task isKindOfClass:[TTPostThreadTask class]]) {
            if (!isEmptyString(task.content)) {
                self.richSpanText = [[[TTRichSpanText alloc] initWithText:task.content richSpansJSONString:task.contentRichSpans] replaceWhitelistLinks];
            }
            
            FRLocationEntity *posEntity = [[FRLocationEntity alloc] init];
            posEntity.city = task.city;
            posEntity.locationName = task.detail_pos;
            posEntity.latitude = task.latitude;
            posEntity.longitude = task.longitude;
            posEntity.locationAddress = task.locationAddress;
            posEntity.locationType = task.locationType;
            
            NSArray<FRUploadImageModel *> *imageModels = task.images;
            [self.addImagesView restoreDraft:imageModels];
            
            self.selectedRange = task.selectedRange;
        }
        [self clearDraft];
    }
}

- (void)clearDraft {
    if ([self draftEnable]) {
        NSArray *tasks = [TTPostThreadTask fetchTasksFromDiskForConcernID:[self draftConcernID]];
        for (TTPostThreadTask *task in tasks) {
            [TTPostThreadTask removeTaskFromDiskByTaskID:task.taskID concernID:[self draftConcernID]];
        }
    }
}

- (void)saveDraft {
    if ([self draftEnable]) {
        TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
        [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        TTPostThreadTask *task = [[TTPostThreadTask alloc] initWithTaskType:TTPostTaskTypeThread];
        
        task.content = richSpanText.text;
        task.contentRichSpans = [TTRichSpans JSONStringForRichSpans:richSpanText.richSpans];
        task.create_time = [[NSDate date] timeIntervalSince1970];
        task.userID = [[TTAccount sharedAccount] userIdString];
        task.concernID = [self draftConcernID];
        task.categoryID = [self draftConcernID];
        [task addTaskImages:self.addImagesView.selectedImageCacheTasks thumbImages:self.addImagesView.selectedThumbImages];
        task.selectedRange = self.inputTextView.selectedRange;
        if (isEmptyString(task.content) && self.addImagesView.selectedImageCacheTasks.count == 0)
            return;
        
        [task saveToDisk];
    }
}

- (BOOL)hasPresettingThreadContent {
//    if ((!isEmptyString(self.postPreContent) || !isEmptyString(self.postPreContentRichSpan) || self.outerInputAssets.count || self.outerInputImages.count) && (!self.useDraftFirst)) {
//        return YES;
//    } else {
//        return NO;
//    }
    return YES;
}

- (NSString *)draftConcernID {
    return [NSString stringWithFormat:@"draft_%@", self.enterConcernID];
}

- (BOOL)draftEnable {
    return NO; // 不支持草稿
    // return [TTKitchen getBOOL:kTTKUGCPostThreadDraftEnable];
}

- (void)closeViewController:(NSNotification *)notification {
    [self clearDraft];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateGoodsInfo:(NSNotification *)notification {
    [self.inputTextView becomeFirstResponder];
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
    offset = self.containerView.height - endFrame.size.height - (CGRectGetMaxY(firstResponderFrame) - self.containerView.contentOffset.y) - kWenDaToolbarHeight;
    if (offset < 0) {
        self.keyboardEndFrame = endFrame;
        [self.containerView setContentOffset:CGPointMake(0, fabs(self.containerView.contentOffset.y-offset)) animated:YES];
        return;
    }
}

- (void)textFiledEditDidChanged:(NSNotification *)notification {
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 避免视频详情页转发时，出现 statusBar 高度获取为 0 的情况
    CGFloat top = MAX(self.ttNavigationBar.bottom, [TTDeviceHelper isIPhoneXSeries] ? 88 : 64);
    self.containerView.frame = CGRectMake(0, top, self.view.width, self.view.height - top);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (self.firstAppear) {
        self.firstAppear = NO;
        [self.inputTextView becomeFirstResponder];
    }
    if ([self.navigationController isKindOfClass:[TTNavigationController class]]) {
        [(TTNavigationController*)self.navigationController panRecognizer].enabled = NO;
        self.navVC = self.navigationController;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.navVC) {
        [self.navVC panRecognizer].enabled = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
}

- (void)viewDidEnterBackground {
    [self saveDraft];
}

#pragma mark - WDUploadImageManagerDelegate

- (void)uploadManager:(WDUploadImageManager *)manager finishUploadImage:(id<WDUploadImageModelProtocol>)imageModel
{

}

- (void)uploadManager:(WDUploadImageManager *)manager
    failedUploadImage:(id<WDUploadImageModelProtocol>)imageModel
                error:(NSError *)error
{

}

- (void)uploadManagerTaskHasFinished:(WDUploadImageManager *)manager failedImageModels:(NSArray<id<WDUploadImageModelProtocol>> *)failedModels
{
    if (self.sendAnswerBlock) {
        self.sendAnswerBlock();
    }
}

#pragma mark - tracer

- (void)goDetail {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [FHUserTracker writeEvent:@"answer_feed_go_detail" params:tracerDict];
}

// 回答发送成功埋点
- (void)sendAnswerSuccessTracer:(NSString *)answer_id {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"click_position"] = @"answer_passport_publisher";
    NSDictionary *log_pb = self.tracerDict[@"log_pb"];
    if (answer_id.length > 0) {
        NSMutableDictionary *temp_log_pb = [NSMutableDictionary new];
        if ([log_pb isKindOfClass:[NSDictionary class]]) {
            [temp_log_pb addEntriesFromDictionary:log_pb];
        }
        temp_log_pb[@"group_id"] = self.qid ?: @"be_null";
        temp_log_pb[@"answer_id"] = answer_id;
        tracerDict[@"log_pb"] = temp_log_pb;
    }
    [FHUserTracker writeEvent:@"answer_publish_success" params:tracerDict];
}

- (void)publish_click_tracer {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"group_id"] = self.qid ?: @"be_null";
    tracerDict[@"click_position"] = @"answer_passport_publisher";
    [FHUserTracker writeEvent:@"answer_publish_click" params:tracerDict];
}

@end
