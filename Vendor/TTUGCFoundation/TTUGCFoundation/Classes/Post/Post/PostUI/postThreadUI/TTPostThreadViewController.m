//
//  TTPostThreadViewController.m
//  Article
//
//  Created by 王霖 on 16/8/24.
//
//

#import "TTPostThreadViewController.h"
#import "TTRateMovieView.h"
#import "TTIndicatorView.h"
#import "FRAddMultiImagesView.h"
#import <TTUIWidget/SSNavigationBar.h>
#import "FRPostThreadAddLocationView.h"
#import "NetworkUtilities.h"
#import <TTAccountBusiness.h>
#import "TTForumPostThreadCenter.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TTRichSpanText.h"
#import "TTPostCheckBindPhoneViewModel.h"
#import "FRForumMonitor.h"
#import "TTCategoryDefine.h"
#import "TTKitchenHeader.h"
#import "TTUGCEmojiParser.h"
#import "TTUGCTextView.h"
#import "TTUGCEmojiParser.h"
#import "TTUGCToolbar.h"
#import "TTUGCTextViewMediator.h"
#import "NSObject+MultiDelegates.h"
#import "TTForumPostThreadTask.h"
#import "UITextView+TTAdditions.h"
#import "TTUIResponderHelper.h"
#import "TTThemeManager.h"
#import "TTAccountAlertView.h"
#import "TTUGCPodBridge.h"

static CGFloat const kLeftPadding = 15.f;
static CGFloat const kRightPadding = 15.f;
static CGFloat const kMidPadding = 10.f;
static CGFloat const kInputViewTopPadding = 8.f;
static CGFloat const kRateMovieViewHeight = 100.f;
static CGFloat const kTextViewHeight = 100.f;
static CGFloat const kUserInfoViewHeight = 44.f;
static CGFloat const kAddImagesViewTopPadding = 10.f;
static CGFloat const kAddImagesViewBottomPadding = 18.f;
static CGFloat kUGCToolbarHeight = 80.f;

static NSString * const kPostTopicEventName = @"topic_post";
static NSString * const kUserInputTelephoneKey = @"userInputTelephoneKey";
static NSInteger const kTitleCharactersLimit = 20;

NSString * const kForumPostThreadFinish = @"ForumPostThreadFinish";

extern unsigned int g_postForumMinCharactersLimit;
extern unsigned int g_postMomentMaxCharactersLimit;


@interface TTPostThreadViewController ()<UITextFieldDelegate, UIAlertViewDelegate, UIScrollViewDelegate, FRAddMultiImagesViewDelegate, FRPostThreadAddLocationViewDelegate, TTUGCTextViewDelegate>

@property (nonatomic, copy) NSString * cid; //关心ID
@property (nonatomic, copy) NSString * categoryID; //频道ID
@property (nonatomic, copy) NSString * navigationTitle; //导航栏标题
@property (nonatomic, assign) BOOL showCustomNavigationTitle; //是否展示用户自定义导航栏标题
@property (nonatomic, assign) FRShowEtStatus showEtStatus; //控制发帖页面展示项
@property (nonatomic, copy) NSString * postContentHint; //输入框占位文本
@property (nonatomic, assign) FRFromWhereType fromWhere; //默认FRFromWhereTypeAPP_TOUTIAO_IOS，表示帖子来之iOS平台
@property (nonatomic, assign) NSUInteger refer; //发帖页面来源：1：频道 2：关心主页
@property (nonatomic, assign) TTPostUGCEnterFrom postUGCEnterFrom;
@property (nonatomic, copy) NSString * enterType;
@property (nonatomic, copy) NSString * upLevelEnterFrom; //发帖页面上级页面的来源
@property (nonatomic, copy) NSArray <TTAssetModel *> * outerInputAssets; //传入的assets
@property (nonatomic, copy) NSArray <UIImage *> * outerInputImages; //传入的images

@property (nonatomic, strong) SSThemedButton * postButton;

@property (nonatomic, strong) SSThemedScrollView * containerView;

@property (nonatomic, strong) SSThemedView * inputContainerView;
@property (nonatomic, strong) SSThemedLabel * tipLabel;
@property (nonatomic, strong) TTRateMovieView * rateMovieView;
@property (nonatomic, strong) SSThemedTextField * titleTextField;
@property (nonatomic, strong) TTUGCTextView * inputTextView;
@property (nonatomic, strong) FRAddMultiImagesView * addImagesView;
@property (nonatomic, strong) TTUGCToolbar *toolbar;
@property (nonatomic, strong) TTUGCTextViewMediator *textViewMediator;

@property (nonatomic, strong) SSThemedView * infoContainerView;
@property (nonatomic, strong) SSThemedTextField * phoneTextField;
@property (nonatomic, strong) SSThemedView * phoneBgView;
@property (nonatomic, strong) FRPostThreadAddLocationView * addLocationView;

@property (nonatomic, copy) NSDictionary *trackDict;

@property (nonatomic, assign) CGRect keyboardEndFrame;
@property (nonatomic, assign) BOOL keyboardVisibleBeforePresent; // 保存 present 页面之前的键盘状态，用于 Dismiss 之后恢复键盘

@property (nonatomic, assign) BOOL firstAppear;

@property (nonatomic, copy) NSString *source;
@property (nonatomic, strong) TTRichSpanText *richSpanText;
@end

@implementation TTPostThreadViewController

+ (void)load {
    RegisterRouteObjWithEntryName(@"send_thread");
}

#pragma mark - Life circle

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary * params = paramObj.allParams;
        if ([params isKindOfClass:[NSDictionary class]]) {
            //Concern id
            self.cid = [params tt_stringValueForKey:@"cid"];
            
            //Category id
            self.categoryID = [params tt_stringValueForKey:@"category_id"];

            //Navigation title
            self.navigationTitle = [params tt_stringValueForKey:@"title"];

            //Show custom title
            self.showCustomNavigationTitle = [params tt_boolValueForKey:@"show_custom_title"];

            //Source
            self.source = [params tt_stringValueForKey:@"source"];

            //Show edit state
            NSNumber * showEtStatus = [params objectForKey:@"show_et_status"];
            if ([showEtStatus isKindOfClass:[NSNumber class]]) {
                self.showEtStatus = showEtStatus.unsignedIntegerValue;
            }else {
                self.showEtStatus = FRShowEtStatusOfTitle | FRShowEtStatusOfPhone | FRShowEtStatusOfLocation;
            }

            //Post hint
            self.postContentHint = [params tt_stringValueForKey:@"post_content_hint"];

            //From where
            NSNumber * fromWhere = [params objectForKey:@"from_where"];
            if ([fromWhere isKindOfClass:[NSNumber class]]) {
                self.fromWhere = fromWhere.integerValue;
            }else {
                self.fromWhere = FRFromWhereTypeAPP_TOUTIAO_IOS;
            }

            //Refer from
            NSNumber * referFrom = [params objectForKey:@"refer"];
            if ([referFrom isKindOfClass:[NSNumber class]]) {
                self.refer = referFrom.unsignedIntegerValue;
            }else {
                self.refer = 1;
            }
            
            //Post UGC enter from
            NSNumber * postUGCEnterFrom = [params objectForKey:@"post_ugc_enter_from"];
            if ([postUGCEnterFrom isKindOfClass:[NSNumber class]]) {
                switch (postUGCEnterFrom.integerValue) {
                    case TTPostUGCEnterFromCategory:
                        self.postUGCEnterFrom = TTPostUGCEnterFromCategory;
                        break;
                    case TTPostUGCEnterFromConcernHomepage:
                        self.postUGCEnterFrom = TTPostUGCEnterFromConcernHomepage;
                        break;
                    case TTPostUGCEnterFromWeitoutiaoTabTopEntrance:
                        self.postUGCEnterFrom = TTPostUGCEnterFromWeitoutiaoTabTopEntrance;
                        break;
                    default:
                        self.postUGCEnterFrom = TTPostUGCEnterFromCategory;
                        break;
                }
            }else {
                self.postUGCEnterFrom = TTPostUGCEnterFromCategory;
            }

            //Enter type
            self.enterType = [params tt_stringValueForKey:@"enter_type"];

            //Up level enter form
            self.upLevelEnterFrom = [params tt_stringValueForKey:@"up_level_enter_from"];

            //Outer input images
            self.outerInputImages = [params tt_arrayValueForKey:@"images"];

            //Outer input assetsLibrary
            ALAssetsLibrary * assetsLibrary = [params tt_objectForKey:@"library"];
            if ([assetsLibrary isKindOfClass:[ALAssetsLibrary class]]) {
                //Outer input assets
                self.outerInputAssets = [params tt_arrayValueForKey:@"assets"];
            }

            // 关心主页发布的直接插入到 richSpanText, 同时不显示 navigationTitle
            NSString *forumName = [params tt_stringValueForKey:@"title"];
            NSString *forumSchema = [params tt_stringValueForKey:@"schema"];
            if (self.postUGCEnterFrom == TTPostUGCEnterFromConcernHomepage &&
                !isEmptyString(self.cid) && !isEmptyString(forumName) && !isEmptyString(forumSchema) &&
                [forumName hasPrefix:@"#"] && [forumName hasSuffix:@"#"]) {
                TTRichSpanLink *hashtagLink = [[TTRichSpanLink alloc] initWithStart:0
                                                                             length:forumName.length
                                                                               link:forumSchema
                                                                               text:nil
                                                                               type:TTRichSpanLinkTypeHashtag];
                hashtagLink.userInfo = @{@"forum_name": forumName ?: @"", @"concern_id" : self.cid ?: @""
                };
                self.richSpanText = [[TTRichSpanText alloc] initWithText:[forumName stringByAppendingString:@" "] richSpanLinks:@[hashtagLink]];

                self.showCustomNavigationTitle = NO;
            } else {
                self.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
            }
            
            self.entrance = @"others";
        }

        [self trackWithEvent:kPostTopicEventName label:@"enter" containExtra:YES extraDictionary:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor tt_themedColorForKey: kColorBackground4];
    self.automaticallyAdjustsScrollViewInsets = NO;
    TTNavigationBarItemContainerView * leftBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft
                                                                                                                              withTitle:NSLocalizedString(@"取消", nil)
                                                                                                                                 target:self
                                                                                                                                 action:@selector(cancel:)];
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
    TTNavigationBarItemContainerView * rightBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight
                                                                                                                               withTitle:NSLocalizedString(@"发布", nil)
                                                                                                                                  target:self
                                                                                                                                  action:@selector(sendPost:)];
    if ([rightBarItem isKindOfClass:[TTNavigationBarItemContainerView class]]) {
        rightBarItem.button.titleColorThemeKey = kColorText6;
        rightBarItem.button.highlightedTitleColorThemeKey = kColorText6Highlighted;
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
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:leftBarItem], leftPaddingItem];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:rightBarItem], rightPaddingItem];
    if (self.showCustomNavigationTitle && !isEmptyString(self.navigationTitle)) {
        self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:self.navigationTitle];
    }

    self.firstAppear = YES;

    [self createComponent];
    [self addImagesViewSizeChanged];

    [self addNotification];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.containerView addGestureRecognizer:tapGestureRecognizer];

    [self restoreDraft];
    
    // 等待构造完成之后初始化
    self.inputTextView.richSpanText = self.richSpanText;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // 避免视频详情页转发时，出现 statusBar 高度获取为 0 的情况
    CGFloat top = MAX(self.ttNavigationBar.bottom, [TTDeviceHelper isIPhoneXDevice] ? 88 : 64);
    self.containerView.frame = CGRectMake(0, top, self.view.width, self.view.height - top);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.firstAppear) {
        self.firstAppear = NO;

        // 图文发布器展示
        if (!(self.showEtStatus & FRShowEtStatusOfTitle)) {
            [self.inputTextView becomeFirstResponder];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidEnterBackground {
    [self saveDraft];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createComponent {
    //Container View
    CGFloat top = 44.f + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.containerView = [[SSThemedScrollView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height - top)];
    self.containerView.backgroundColorThemeKey = kColorBackground4;
    self.containerView.alwaysBounceVertical = YES;
    self.containerView.delegate = self;
    [self.view addSubview:self.containerView];

    //Create input component
    [self createInputComponent];

    //Create info component
    [self createInfoComponent];
}

- (void)createInputComponent {
    CGFloat y = 0;

    //Input container view
    self.inputContainerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.inputContainerView.backgroundColorThemeKey = kColorBackground4;
    [self.containerView addSubview:self.inputContainerView];

    //Rate movie view
    if (self.showEtStatus & FRShowEtStatusOfRateView) {
        self.rateMovieView = [[TTRateMovieView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kRateMovieViewHeight)];
        self.rateMovieView.backgroundColorThemeKey = kColorBackground4;
        y = kRateMovieViewHeight;
        [self.inputContainerView addSubview:self.rateMovieView];

        SSThemedView *separateLine = [[SSThemedView alloc] initWithFrame:CGRectMake(kLeftPadding, self.rateMovieView.bottom, self.view.width - kLeftPadding - kRightPadding, [TTDeviceHelper ssOnePixel])];
        separateLine.backgroundColorThemeKey = kColorLine1;
        [self.inputContainerView addSubview:separateLine];
    }

    //Title view
    if (self.showEtStatus & FRShowEtStatusOfTitle) {
        self.titleTextField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(kLeftPadding, y, self.view.width - kLeftPadding - kRightPadding, kUserInfoViewHeight)];
        self.titleTextField.delegate = self;
        self.titleTextField.textColorThemeKey = kColorText1;
        self.titleTextField.placeholderColorThemeKey = kColorText3;
        self.titleTextField.font = [UIFont systemFontOfSize:16];
        self.titleTextField.placeholder = NSLocalizedString(@"标题", nil);
        [self.inputContainerView addSubview:self.titleTextField];

        SSThemedView *separateLine = [[SSThemedView alloc] initWithFrame:CGRectMake(kLeftPadding, self.titleTextField.bottom, self.view.width - kLeftPadding - kRightPadding, [TTDeviceHelper ssOnePixel])];
        separateLine.backgroundColorThemeKey = kColorLine1;
        [self.inputContainerView addSubview:separateLine];
        y += kUserInfoViewHeight;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFiledEditDidChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:self.titleTextField];
    }

    //Input view
    self.inputTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(kLeftPadding - 5, y + kInputViewTopPadding, self.view.width - kLeftPadding - kRightPadding + 10.f, kTextViewHeight)];
    self.inputTextView.source = @"post";
    y = self.inputTextView.bottom;

    HPGrowingTextView *internalTextView = self.inputTextView.internalGrowingTextView;

    // 图文发布器展示
    if (!(self.showEtStatus & FRShowEtStatusOfTitle)) {
        internalTextView.minHeight = kTextViewHeight;
        internalTextView.maxNumberOfLines = 8;
    } else {
        internalTextView.maxHeight = kTextViewHeight;
    }

    if (!isEmptyString(self.postContentHint)) {
        internalTextView.placeholder = self.postContentHint;
    } else {
        if (isEmptyString(self.navigationTitle)) {
            internalTextView.placeholder = NSLocalizedString(@"说点什么...", nil);
        } else {
            internalTextView.placeholder = [NSString stringWithFormat:@"分享「%@」的新鲜事", self.navigationTitle];
        }
    }
    internalTextView.backgroundColor = [UIColor clearColor];
    internalTextView.textColor = SSGetThemedColorWithKey(kColorText1);
    internalTextView.placeholderColor =  SSGetThemedColorWithKey(kColorText3);
    internalTextView.internalTextView.placeHolderFont = [UIFont systemFontOfSize:self.inputTextView.textViewFontSize];
    internalTextView.font = [UIFont systemFontOfSize:self.inputTextView.textViewFontSize];
    internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.inputContainerView addSubview:self.inputTextView];

    //add image view
    y += kAddImagesViewTopPadding;
    self.addImagesView = [[FRAddMultiImagesView alloc] initWithFrame:CGRectMake(kLeftPadding, y, self.view.width - kLeftPadding - kRightPadding, self.view.height - y)
                                                              assets:self.outerInputAssets
                                                              images:self.outerInputImages];
    self.addImagesView.eventName = kPostTopicEventName;
    self.addImagesView.delegate = self;
    self.addImagesView.ssTrackDict = self.trackDict;
    [self.addImagesView startTrackImagepicker];

    WeakSelf;
    [self.addImagesView frameChangedBlock:^(CGSize size) {
        StrongSelf;
        [self addImagesViewSizeChanged];
    }];
    [self.inputContainerView addSubview:self.addImagesView];
    self.inputContainerView.height = self.addImagesView.bottom + kAddImagesViewBottomPadding;

    // toolbar
    kUGCToolbarHeight = 80.f + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    self.toolbar = [[TTUGCToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - kUGCToolbarHeight, self.view.width, kUGCToolbarHeight)];
    self.toolbar.emojiInputView.source = @"post";
    [self.view addSubview:self.toolbar];

    //Location view
    self.addLocationView = [[FRPostThreadAddLocationView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36.f) andShowEtStatus:self.showEtStatus];
    self.addLocationView.concernId = self.cid;
    self.addLocationView.trackDic = self.trackDict;
    self.addLocationView.delegate = self;
    [self.toolbar addSubview:self.addLocationView];

    //Tip label
    self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(self.view.width - 70 - kRightPadding, 0, 70, 36.f)];
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
}

- (void)createInfoComponent {
    //Info container view
    self.infoContainerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.inputContainerView.bottom + kMidPadding , self.view.width, 0)];
    self.infoContainerView.backgroundColorThemeKey = kColorBackground4;
    [self.containerView addSubview:self.infoContainerView];

    CGFloat y = 0;

    //Phone view
    if (self.showEtStatus & FRShowEtStatusOfPhone) {
        self.phoneBgView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, y, self.view.width, kUserInfoViewHeight)];
        self.phoneBgView.backgroundColorThemeKey = kColorBackground4;
        [self.infoContainerView addSubview:self.phoneBgView];

        SSThemedImageView * phoneIconView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(kLeftPadding, 12, 20, 20)];
        phoneIconView.imageName = @"phone_repost";
        [self.phoneBgView addSubview:phoneIconView];
        self.phoneTextField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(kLeftPadding + 27, 0, self.phoneBgView.width - kLeftPadding - kRightPadding - 27, kUserInfoViewHeight)];
        NSString * preInputPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kUserInputTelephoneKey];
        if (!isEmptyString(preInputPhoneNumber)) {
            self.phoneTextField.text = preInputPhoneNumber;
        }
        self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.phoneTextField.delegate = self;
        self.phoneTextField.font = [UIFont systemFontOfSize:16];
        self.phoneTextField.textColorThemeKey = kColorText1;
        self.phoneTextField.placeholderColorThemeKey = kColorText3;
        self.phoneTextField.placeholder = NSLocalizedString(@"联系电话（选填，仅工作人员可见）", nil);
        [self.phoneBgView addSubview:self.phoneTextField];

        SSThemedView *separateLine = [[SSThemedView alloc] initWithFrame:CGRectMake(15, kUserInfoViewHeight - [TTDeviceHelper ssOnePixel], self.view.width - 15, [TTDeviceHelper ssOnePixel])];
        separateLine.backgroundColorThemeKey = kColorLine1;
        [self.phoneBgView addSubview:separateLine];
        y = self.phoneBgView.bottom;
    }

    self.infoContainerView.height = y;
}

- (void)addImagesViewSizeChanged {
    self.inputContainerView.height = self.addImagesView.bottom + kAddImagesViewBottomPadding;
    self.infoContainerView.top = self.inputContainerView.height + kMidPadding;

    CGFloat targetHeight = self.infoContainerView.bottom + kMidPadding;
    CGFloat containerHeight = self.view.height - 64;
    containerHeight = containerHeight >= targetHeight ? containerHeight : targetHeight;
    containerHeight += kUGCToolbarHeight;
    self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width, containerHeight);
    [self refreshPostButtonUI];
}

- (void)refreshUI {
    NSString *inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (inputText.length > g_postMomentMaxCharactersLimit) {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = [NSString stringWithFormat:@"-%lu", (unsigned long)(inputText.length - g_postMomentMaxCharactersLimit)];
    } else {
        self.tipLabel.hidden = YES;
    }

    [self refreshPostButtonUI];
}

- (void)refreshPostButtonUI {
    if (self.inputTextView.text.length > 0 || self.addImagesView.selectedImageCacheTasks.count > 0) {
        self.postButton.titleColorThemeKey = kColorText6;
        self.postButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
    } else {
        self.postButton.titleColorThemeKey = kColorText9;
        self.postButton.highlightedTitleColorThemeKey = kColorText9Highlighted;
    }
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
    if (self.titleTextField.isFirstResponder) {
        firstResponder = self.titleTextField;
    }else if (self.inputTextView.isFirstResponder) {
        firstResponder = self.inputTextView;
    }else if (self.phoneTextField.isFirstResponder) {
        firstResponder = self.phoneTextField;
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

- (void)textFiledEditDidChanged:(NSNotification *)notification {
    if (self.titleTextField == notification.object) {
        NSString * content = @"";
        if (!isEmptyString(self.titleTextField.text)) {
            content = self.titleTextField.text;
        }

        UITextRange * selectedRange = self.titleTextField.markedTextRange;
        if (selectedRange && [self.titleTextField positionFromPosition:selectedRange.start offset:0]) {
            return;
        }

        if (content.length > kTitleCharactersLimit) {
            NSString * resultContent = [content substringToIndex:kTitleCharactersLimit];
            self.titleTextField.text = resultContent;
        }
    }
}

#pragma mark - Selectors & Actions

- (void)sendPost:(id)sender {
    NSString *titleText = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    TTRichSpanText *richSpanText = self.inputTextView.richSpanText;
    [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *inputText = richSpanText.text;
    NSString *phoneText = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (![self isValidateWithTitleText:titleText inputText:inputText phoneText:phoneText]) {
        return;
    }

    if ([self hasUncompletedIcloudTask]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"iCloud同步中", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }
    if ([self hasFailedIcloudTask]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"iCloud同步失败", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }

    [self endEditing];

    WeakSelf;
    if (![TTAccountManager isLogin]) {

        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost
                                          source:self.source
                                     inSuperView:self.navigationController.view
                                      completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                          StrongSelf;
                                          if (type == TTAccountAlertCompletionEventTypeDone) {
                                              [self sendThreadWithLoginState:1 withTitleText:titleText inputText:inputText phoneText:phoneText];
                   
                                          } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                              [TTAccountManager presentQuickLoginFromVC:self
                                                                                   type:TTAccountLoginDialogTitleTypeDefault
                                                                                 source:self.source
                                                                             completion:^(TTAccountLoginState state) {

                                                                             }];
                                          }
                                      }];
    }else {
        [self sendThreadWithLoginState:1 withTitleText:titleText inputText:inputText phoneText:phoneText];
    }
}

- (void)sendThreadWithLoginState:(NSInteger)loginState withTitleText:(NSString *)titleText inputText:(NSString *)inputText phoneText:(NSString *)phoneText{

    if (self && [TTAccountManager isLogin]) {

        if ([KitchenMgr getBOOL:KSSCommonUgcPostBindingPhoneNumberKey]) {

            self.view.userInteractionEnabled = NO;
            TTIndicatorView * checkBoundPhoneIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView
                                                                                               indicatorText:@"发布中..."
                                                                                              indicatorImage:nil
                                                                                              dismissHandler:nil];
            checkBoundPhoneIndicatorView.autoDismiss = NO;
            [checkBoundPhoneIndicatorView showFromParentView:self.view];

            WeakSelf;
            [TTPostCheckBindPhoneViewModel checkPostNeedBindPhoneOrNotWithCompletion:^(FRPostBindCheckType checkType) {

                StrongSelf;
                [checkBoundPhoneIndicatorView dismissFromParentView];
                self.view.userInteractionEnabled = YES;

                if (checkType == FRPostBindCheckTypePostBindCheckTypeNeed) {
                    
                    WeakSelf;
                    UIViewController *bindViewController= [[TTUGCPodBridge sharedInstance] pushBindPhoneNumberWhenPostThreadWithCompletion:^{
                        StrongSelf;
                        [self postThreadWithTitleText:titleText inputText:inputText phoneText:phoneText];
                    }];

                    if ([self.navigationController isKindOfClass:[UINavigationController class]] && bindViewController && [bindViewController isKindOfClass:[UIViewController class]]) {
                        [self.navigationController pushViewController:bindViewController animated:YES];
                    }
                }
                else {
                    [self postThreadWithTitleText:titleText inputText:inputText phoneText:phoneText];
                }
            }];
        }

        else {
            [self postThreadWithTitleText:titleText inputText:inputText phoneText:phoneText];
        }

    }
}

- (void)postThreadWithTitleText:(NSString *)titleText inputText:(NSString *)inputText phoneText:(NSString *)phoneText {

    //debugReal 用于问题追查
    NSMutableDictionary *debugReal = @{}.mutableCopy;
    [debugReal setValue:self.addLocationView.selectedLocation.locationName forKey:@"loc"];
    if (inputText.length > 0) {
        if (inputText.length < 25) {
            [debugReal setValue:inputText forKey:@"text"]; //文字字数限制在20个，仅仅用来追查问题
        } else {
            [debugReal setValue:[inputText substringToIndex:20] forKey:@"text"]; //文字字数限制在20个，仅仅用来追查问题
        }
    }
    [debugReal setValue:@(self.addImagesView.selectedThumbImages.count) forKey:@"thumbImgCount"]; //看看能不能和真实数据对上
    if (self.addImagesView.selectedImageCacheTasks) {
        [debugReal setValue:self.addImagesView.selectedImageCacheTasks forKey:@"imgs"]; //上传真实数据
    }
    UGCLog(@"%@", debugReal);

    TTRichSpanText *richSpanText = self.inputTextView.richSpanText;

    NSMutableArray *mentionUsers = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in richSpanText.richSpans.links) {
        NSString *userId = [link.userInfo tt_stringValueForKey:@"user_id"];
        if (!isEmptyString(userId)) {
            [mentionUsers addObject:userId];
        }
    }

    NSMutableArray *mentionConcerns = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    NSMutableArray *hashtagNames = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    for (TTRichSpanLink *link in richSpanText.richSpans.links) {
        NSString *concernId = [link.userInfo tt_stringValueForKey:@"concern_id"];
        if (!isEmptyString(concernId)) {
            [mentionConcerns addObject:concernId];
        }

        NSString *forumName = [link.userInfo tt_stringValueForKey:@"forum_name"];
        if (!isEmptyString(forumName)) {
            [hashtagNames addObject:forumName];
        }
    }
    
    NSMutableDictionary *trackDict = [NSMutableDictionary new];
    [trackDict setValue:self.enterConcernID forKey:@"concern_id"];
    [trackDict setValue:self.entrance forKey:@"entrance"];
    [trackDict setValue:[mentionUsers componentsJoinedByString:@","] ?: @"" forKey:@"at_user_id"];
    [trackDict setValue:[hashtagNames componentsJoinedByString:@","] ?: @"" forKey:@"hashtag_name"];
    if (self.addImagesView.selectedImageCacheTasks.count == 0) {
        [TTTrackerWrapper eventV3:@"post_topic" params:trackDict];
    } else {
        [TTTrackerWrapper eventV3:@"post_topic_pic" params:trackDict];
    }
    
    if (phoneText.length > 0) {
        //telephone number is legal and save telephone number for next time
        [[NSUserDefaults standardUserDefaults] setObject:phoneText forKey:kUserInputTelephoneKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    double longitude = self.addLocationView.selectedLocation.longitude;
    double latitude = self.addLocationView.selectedLocation.latitude;
    CGFloat rate = self.rateMovieView.rate;
    NSMutableDictionary *extraTrack = [NSMutableDictionary dictionary];
    [extraTrack setValue:self.enterType forKey:@"enter_type"];

    NSDictionary <NSString *, NSString *> *emojis = [TTUGCEmojiParser parseEmojis:inputText];
    [TTUGCEmojiParser markEmojisAsUsed:emojis];
    NSArray <NSString *> *emojiIds = emojis.allKeys;
    [TTTrackerWrapper eventV3:@"emoticon_stats" params:@{
        @"with_emoticon_list" : (!emojiIds || emojiIds.count == 0) ? @"none" : [emojiIds componentsJoinedByString:@","],
        @"source" : @"post"
    }];

    [[TTForumPostThreadCenter sharedInstance_tt] postThreadWithContent:inputText
                                                      contentRichSpans:[TTRichSpans JSONStringForRichSpans:richSpanText.richSpans]
                                                          mentionUsers:[mentionUsers componentsJoinedByString:@","]
                                                       mentionConcerns:[mentionConcerns componentsJoinedByString:@","]
                                                                 title:titleText
                                                           phoneNumber:phoneText
                                                             fromWhere:self.fromWhere
                                                             concernID:self.cid
                                                            categoryID:self.categoryID
                                                            taskImages:self.addImagesView.selectedImageCacheTasks
                                                           thumbImages:self.addImagesView.selectedThumbImages
                                                           needForward:1
                                                                  city:self.addLocationView.selectedLocation.city
                                                             detailPos:self.addLocationView.selectedLocation.locationName
                                                             longitude:longitude
                                                              latitude:latitude
                                                                 score:rate
                                                                 refer:self.refer
                                                      postUGCEnterFrom:self.postUGCEnterFrom
                                                            extraTrack:extraTrack
                                                           finishBlock:^{
                                                               [self postFinished:YES];
                                                           }];
}


- (BOOL)isValidateWithTitleText:(NSString *)titleText inputText:(NSString *)inputText phoneText:(NSString *)phoneText {
    //Validate
    if (titleText.length > kTitleCharactersLimit) {
        [self endEditing];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"标题不能超过20个字", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }

    if (isEmptyString(inputText) && self.addImagesView.selectedImageCacheTasks.count == 0) {
        [self endEditing];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"说点什么...", nil)
                                 indicatorImage:nil
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }else if (inputText.length > g_postMomentMaxCharactersLimit) {
        [self endEditing];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"字数超过2000字，请调整后重试", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }

    if (phoneText.length > 0 && ![self isValidateOfPhoneNumber:phoneText]) {
        [self endEditing];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"请输入正确的手机号", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return NO;
    }

//    if (inputText.length < g_postForumMinCharactersLimit && self.addImagesView.selectedImages.count == 0 && self.repostType == TTThreadRepostTypeNone) {
//        [self endEditing];
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
//                                  indicatorText:[NSString stringWithFormat:@"请至少写%u个字", g_postForumMinCharactersLimit]
//                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
//                                    autoDismiss:YES
//                                 dismissHandler:nil];
//        return NO;
//    }

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

- (BOOL)hasUncompletedIcloudTask
{
    for (TTForumPostImageCacheTask *task in self.addImagesView.selectedImageCacheTasks)
    {
        if (task.status == IcloudSyncExecuting) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasFailedIcloudTask
{
    for (TTForumPostImageCacheTask *task in self.addImagesView.selectedImageCacheTasks)
    {
        if (task.status == IcloudSyncFailed) {
            return YES;
        }
    }
    return NO;
}

- (void)cancel:(id)sender {
    [self endEditing];
    NSString * titleText = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * phoneText = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    BOOL shouldAlert = !(isEmptyString(titleText) && isEmptyString(phoneText) && isEmptyString(inputText) && self.addImagesView.selectedImageCacheTasks.count == 0);

    if (!shouldAlert) {
        [self trackWithEvent:kPostTopicEventName label:@"cancel_none" containExtra:YES extraDictionary:nil];
        [self postFinished:NO];
    } else {
        [self trackWithEvent:kPostTopicEventName label:@"cancel" containExtra:YES extraDictionary:nil];
        TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"确定退出？", comment: nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alertController addActionWithTitle:NSLocalizedString(@"取消", comment:nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        WeakSelf;
        [alertController addActionWithTitle:NSLocalizedString(@"退出", comment:nil) actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
            StrongSelf;
            [self trackWithEvent:kPostTopicEventName label:@"cancel_confirm" containExtra:YES extraDictionary:nil];
            [self postFinished:NO];
        }];
        [alertController showFrom:self animated:YES];
    }
}

- (void)postFinished:(BOOL)hasSent {
    [self clearDraft];
    
    // 爆料逻辑，跳爆料频道
    if (hasSent && !isEmptyString(self.cid)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kForumPostThreadFinish object:nil userInfo:@{@"cid" : self.cid}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostingThreadActionCancelledNotification
                                                            object:nil
                                                          userInfo:nil];
    }

    // 发帖跳关注频道
    if ([TTDeviceHelper OSVersionNumber] < 8.0 && self.presentedViewController) {
        WeakSelf;
        self.view.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself dismissSelf];

            if ([KitchenMgr getBOOL:KKCUGCPostToFollowPageEnable] && !isEmptyString(self.cid) && [self.cid isEqualToString:KTTFollowPageConcernID]) {
                if (hasSent) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostingThreadActionFinishNotification
                                                                        object:nil
                                                                      userInfo:@{
                                                                          @"entrance" : @(_postUGCEnterFrom),
                                                                          @"cid" : self.cid
                                                                      }];
                }
            }
        });
    } else {
        [self dismissSelf];

        if ([KitchenMgr getBOOL:KKCUGCPostToFollowPageEnable] && !isEmptyString(self.cid) && [self.cid isEqualToString:KTTFollowPageConcernID]) {
            if (hasSent) {

                if ([[NSThread currentThread] isMainThread]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostingThreadActionFinishNotification
                                                                        object:nil
                                                                      userInfo:@{
                                                                          @"entrance" : @(_postUGCEnterFrom),
                                                                          @"cid" : self.cid
                                                                      }];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostingThreadActionFinishNotification
                                                                            object:nil
                                                                          userInfo:@{
                                                                              @"entrance" : @(_postUGCEnterFrom),
                                                                              @"cid" : self.cid
                                                                          }];
                    });
                }
            }
        }
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

#pragma mark - AddLocationViewDelegate

- (void)addLocationViewWillPresent {
    self.keyboardVisibleBeforePresent = self.inputTextView.keyboardVisible;
}

- (void)addLocationViewDidDismiss {
    // 如果选择定位位置之前，键盘是弹出状态，选择完之后恢复键盘状态
    if (self.keyboardVisibleBeforePresent) {
        [self.inputTextView becomeFirstResponder];
    }
}


#pragma mark - TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {
    [self refreshUI];
}

- (void)textView:(TTUGCTextView *)textView willChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight {
    // 图文发布器展示
    if (!(self.showEtStatus & FRShowEtStatusOfTitle)) {
        self.addImagesView.top = self.inputTextView.bottom + kAddImagesViewTopPadding;
        self.inputContainerView.height = self.addImagesView.bottom + kAddImagesViewBottomPadding;
        self.infoContainerView.top = self.inputContainerView.height + kMidPadding;

        CGFloat targetHeight = self.infoContainerView.bottom + kMidPadding;
        CGFloat containerHeight = self.view.height - 64;
        containerHeight = containerHeight >= targetHeight ? containerHeight : targetHeight;
        containerHeight += kUGCToolbarHeight;
        self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width, containerHeight);
    }
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.toolbar.banAtInput = YES;
    self.toolbar.banHashtagInput = YES;
    self.toolbar.banEmojiInput = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.toolbar.banAtInput = NO;
    self.toolbar.banHashtagInput = NO;
    self.toolbar.banEmojiInput = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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


#pragma mark - Tracker

- (NSString *)source {
    return _source ?: @"post_topic";
}

- (NSDictionary *)trackDict {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.categoryID forKey:@"category_id"];
    [dict setValue:self.cid forKey:@"concern_id"];
    [dict setValue:@(self.refer) forKey:@"refer"];
    [dict setValue:self.enterType forKey:@"enter_type"];
    return dict;
}

- (void)trackWithEvent:(NSString *)event label:(NSString *)label containExtra:(BOOL)containExtra extraDictionary:(NSDictionary *)extraDictionary {
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    if (containExtra) {
        [dictionary setValue:self.cid forKey:@"concern_id"];
        [dictionary setValue:@(self.refer) forKey:@"refer"];
        [dictionary setValue:self.upLevelEnterFrom forKey:@"enter_from"];
        if (self.refer == 1 && !isEmptyString(self.categoryID)) {
            //发帖页面由频道触发并且category id非空
            [dictionary setValue:self.categoryID forKey:@"category_id"];
        }
        [dictionary setValue:self.enterType forKey:@"enter_type"];
    }

    [dictionary addEntriesFromDictionary:extraDictionary];

    [dictionary setValue:@"umeng" forKey:@"category"];
    [dictionary setValue:event forKey:@"tag"];
    [dictionary setValue:label forKey:@"label"];

    [TTTrackerWrapper eventData:dictionary];
}

- (void)trackWithEventV3:(NSString *)event extraDictionary:(NSDictionary *)extraDictionary {
    if (isEmptyString(event)) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (self.refer == 1 && !isEmptyString(self.categoryID)) {
        //发帖页面由频道触发并且category id非空
        [dictionary setValue:self.categoryID forKey:@"category_name"];
    }
    [dictionary setValue:@(self.refer) forKey:@"refer"];
    [dictionary setValue:self.enterType forKey:@"enter_type"];
    [dictionary setValue:self.cid forKey:@"concern_id"];

    [dictionary addEntriesFromDictionary:extraDictionary];

    [TTTrackerWrapper eventV3:event params:dictionary isDoubleSending:YES];
}


#pragma mark - Utils

- (BOOL)isValidateOfPhoneNumber:(NSString *)phoneNumber {
    NSString * regex = @"^1\\d{10}$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:phoneNumber]) {
        return YES;
    }
    return NO;
}

#pragma mark -- draft

- (NSString *)draftConcernID {
    return [NSString stringWithFormat:@"draft_%@", self.enterConcernID];
}
- (void)saveDraft {
    if ([self draftEnable]) {
        TTRichSpanText *richSpanText = self.inputTextView.richSpanText;
        [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        TTForumPostThreadTask *task = [[TTForumPostThreadTask alloc] initWithTaskType:TTForumPostThreadTaskTypeThread];

        task.content = richSpanText.text;
        task.contentRichSpans = [TTRichSpans JSONStringForRichSpans:richSpanText.richSpans];
        task.create_time = [[NSDate date] timeIntervalSince1970];
        task.userID = [TTAccountManager userID];
        task.concernID = [self draftConcernID];
        task.categoryID = [self draftConcernID];
        [task addTaskImages:self.addImagesView.selectedImageCacheTasks thumbImages:self.addImagesView.selectedThumbImages];
        task.latitude = self.addLocationView.selectedLocation.latitude;
        task.longitude = self.addLocationView.selectedLocation.longitude;
        task.city = self.addLocationView.selectedLocation.city;
        task.detail_pos = self.addLocationView.selectedLocation.locationName;
        task.locationType = self.addLocationView.selectedLocation.locationType;
        task.locationAddress = self.addLocationView.selectedLocation.locationAddress;
        if (isEmptyString(task.content) && self.addImagesView.selectedImageCacheTasks.count == 0)
            return;
        
        [task saveToDisk];
    }
}

- (void)restoreDraft {
    if ([self draftEnable]) {
        NSArray *tasks = [TTForumPostThreadTask fetchTasksFromDiskForConcernID:[self draftConcernID]];
        TTForumPostThreadTask *task = [tasks lastObject];
        if ([task isKindOfClass:[TTForumPostThreadTask class]]) {
            if (!isEmptyString(task.content)) {
                self.richSpanText = [[TTRichSpanText alloc] initWithText:task.content richSpansJSONString:task.contentRichSpans];
            }
            
            FRLocationEntity *posEntity = [[FRLocationEntity alloc] init];
            posEntity.city = task.city;
            posEntity.locationName = task.detail_pos;
            posEntity.latitude = task.latitude;
            posEntity.longitude = task.longitude;
            posEntity.locationAddress = task.locationAddress;
            posEntity.locationType = task.locationType;
            if (isEmptyString(posEntity.locationAddress)
                && isEmptyString(posEntity.city)
                && isEmptyString(posEntity.locationName)) {
                //本地存储地址都未空，不恢复地址位置。
            } else {
                self.addLocationView.selectedLocation = posEntity;
                [self.addLocationView refresh];
            }
            
            NSArray<FRUploadImageModel *> *imageModels = task.images;
            [self.addImagesView restoreDraft:imageModels];
        }
        [self clearDraft];
    }
}

- (void)clearDraft {
    if ([self draftEnable]) {
        NSArray *tasks = [TTForumPostThreadTask fetchTasksFromDiskForConcernID:[self draftConcernID]];
        for (TTForumPostThreadTask *task in tasks) {
            [TTForumPostThreadTask removeTaskFromDiskByTaskID:task.taskID concernID:[self draftConcernID]];
        }
    }
}

- (BOOL)draftEnable {
    return [KitchenMgr getBOOL:kKCUGCPostThreadDraftEnable] && !(self.showEtStatus & FRShowEtStatusOfTitle);
}
@end
