//
//  FHPostUGCViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHPostUGCViewController.h"
#import "TTNavigationController.h"
#import "SSThemed.h"
#import "SSNavigationBar.h"
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

static NSInteger const kMaxPostImageCount = 9;

@interface FHPostUGCViewController ()<FRAddMultiImagesViewDelegate>

@property (nonatomic, strong) SSThemedButton * cancelButton;
@property (nonatomic, strong) SSThemedButton * postButton;
@property (nonatomic, strong) TTUGCTextView * inputTextView;
@property (nonatomic, strong) UIScrollView       *containerView;
@property (nonatomic, strong) SSThemedView * inputContainerView;
@property (nonatomic, strong) TTUGCTextViewMediator       *textViewMediator;
@property (nonatomic, strong) TTUGCToolbar *toolbar;
@property (nonatomic, strong) FRAddMultiImagesView * addImagesView;
@property (nonatomic, copy) NSDictionary *trackDict; //  add by zyk
@property (nonatomic, assign) CGRect keyboardEndFrame;
@property (nonatomic, assign) BOOL keyboardVisibleBeforePresent; // 保存 present 页面之前的键盘状态，用于 Dismiss 之后恢复键盘
@property (nonatomic, copy) NSArray <TTAssetModel *> * outerInputAssets; //传入的assets
@property (nonatomic, copy) NSArray <UIImage *> * outerInputImages; //传入的images

@end

@implementation FHPostUGCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNaviBar];
    [self createComponent];
}

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
    TTNavigationBarItemContainerView * leftBarItem = nil;
    leftBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft
                                                                                           withTitle:NSLocalizedString(@"取消", nil)
                                                                                              target:self
                                                                                              action:@selector(cancel:)];
    if ([leftBarItem isKindOfClass:[TTNavigationBarItemContainerView class]]) {
        leftBarItem.button.titleColorThemeKey = kColorText1;
        leftBarItem.button.highlightedTitleColorThemeKey = kColorText1Highlighted;
        leftBarItem.button.disabledTitleColorThemeKey = kColorText1;
        if ([TTDeviceHelper is736Screen]) {
            // Plus上bar button item的左边距会多4.3个点（13px），调整到间距为30px
            [leftBarItem.button setTitleEdgeInsets:UIEdgeInsetsMake(0, -4.3, 0, 4.3)];
        }
    }
    self.cancelButton = leftBarItem.button;
    UIBarButtonItem * leftPaddingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                      target:nil
                                                                                      action:nil];
    leftPaddingItem.width = 17.f;
    TTNavigationBarItemContainerView * rightBarItem = nil;
    rightBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight
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
}

- (void)createComponent {
    //Container View
    CGFloat top = 44.f + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height - top)];
    self.containerView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
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
    
    //Input view
    self.inputTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(kLeftPadding - 5, y + kInputViewTopPadding, self.view.width - kLeftPadding - kRightPadding + 10.f, kTextViewHeight)];
//    if ([TTThemeManager sharedInstance_tt].correctThemeMode == TTThemeModeDay) {
//        self.inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
//    } else {
//        self.inputTextView.keyboardAppearance = UIKeyboardAppearanceDark;
//    }
    self.inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    
    self.inputTextView.source = @"post";
    y = self.inputTextView.bottom;
    
    HPGrowingTextView *internalTextView = self.inputTextView.internalGrowingTextView;
    
    // 图文发布器展示
    /*
    if (!(self.showEtStatus & FRShowEtStatusOfTitle)) {
        internalTextView.minHeight = kTextViewHeight;
        internalTextView.maxNumberOfLines = 8;
    } else {
        internalTextView.maxHeight = kTextViewHeight;
    }
    
    if (!isEmptyString(self.postContentHint)) {
        internalTextView.placeholder = self.postContentHint;
    } else if (![self.enterType isEqualToString:@"edit_publish"]){
        if (isEmptyString(self.navigationTitle)) {
            internalTextView.placeholder = NSLocalizedString(@"说点什么...", nil);
        } else {
            internalTextView.placeholder = [NSString stringWithFormat:@"分享「%@」的新鲜事", self.navigationTitle];
        }
    }
     */
    
    internalTextView.minHeight = kTextViewHeight;
    internalTextView.maxNumberOfLines = 8;
    
    internalTextView.placeholder = [NSString stringWithFormat:@"分享新鲜事"];
    
    
    internalTextView.backgroundColor = [UIColor clearColor];
    internalTextView.textColor = SSGetThemedColorWithKey(kColorText1);
    internalTextView.placeholderColor =  SSGetThemedColorWithKey(kColorText3);
    internalTextView.internalTextView.placeHolderFont = [UIFont systemFontOfSize:self.inputTextView.textViewFontSize];
    internalTextView.font = [UIFont systemFontOfSize:self.inputTextView.textViewFontSize];
    internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.inputContainerView addSubview:self.inputTextView];
    
    
    // add image view
    y += kAddImagesViewTopPadding;
    self.addImagesView = [[FRAddMultiImagesView alloc] initWithFrame:CGRectMake(kLeftPadding, y, self.view.width - kLeftPadding - kRightPadding, self.view.height - y)
                                                              assets:self.outerInputAssets
                                                              images:self.outerInputImages];
    self.addImagesView.eventName = kPostTopicEventName;
    self.addImagesView.delegate = self;
    self.addImagesView.ssTrackDict = self.trackDict;
    [self.addImagesView startTrackImagepicker];
    
    [self.inputContainerView addSubview:self.addImagesView];
//
//    self.goodsInfoView = [[SSThemedView alloc] initWithFrame:CGRectMake(kLeftPadding, self.addImagesView.bottom + 13, self.view.width - kLeftPadding - kRightPadding, 70)];
//    self.goodsInfoView.backgroundColorThemeKey = kColorBackground3;
//    self.goodsInfoView.hidden = !self.postWithGoods;
//    [self.inputContainerView addSubview:self.goodsInfoView];
//    
//    self.goodsImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(1, 1, 68, 68)];
//    self.goodsImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.goodsInfoView addSubview:self.goodsImageView];
//    
//    self.goodsNameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(82, 14, CGRectGetWidth(self.goodsInfoView.frame) - 117, 20)];
//    self.goodsNameLabel.textColorThemeKey = kColorText1;
//    self.goodsNameLabel.font = [UIFont systemFontOfSize:16];
//    [self.goodsInfoView addSubview:self.goodsNameLabel];
//    
//    self.goodsDescLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(82, CGRectGetMaxY(self.goodsNameLabel.frame) + 4, self.goodsNameLabel.width, 18)];
//    self.goodsDescLabel.textColorThemeKey = kColorText3;
//    self.goodsDescLabel.font = [UIFont systemFontOfSize:13];
//    [self.goodsInfoView addSubview:self.goodsDescLabel];
//    
//    self.arrowIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.goodsNameLabel.frame) + 15, 27, 9, 16)];
//    self.arrowIcon.imageName = @"goods_arrow_icon";
//    [self.goodsInfoView addSubview:self.arrowIcon];
//    
//    self.inputContainerView.height = self.postWithGoods ? self.goodsInfoView.bottom : self.addImagesView.bottom + kAddImagesViewBottomPadding;
     self.inputContainerView.height = 500;
    
    // toolbar
    kUGCToolbarHeight = 80.f + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    self.toolbar = [[TTUGCToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - kUGCToolbarHeight, self.view.width, kUGCToolbarHeight)];
    self.toolbar.emojiInputView.source = @"post";
    
    self.toolbar.banLongText = YES;
    
    [self.view addSubview:self.toolbar];
    
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
    
    /*
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
    if ([TTThemeManager sharedInstance_tt].correctThemeMode == TTThemeModeDay) {
        self.inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    } else {
        self.inputTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    }
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
    } else if (![self.enterType isEqualToString:@"edit_publish"]){
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
    
    [self.inputContainerView addSubview:self.addImagesView];
    
    self.goodsInfoView = [[SSThemedView alloc] initWithFrame:CGRectMake(kLeftPadding, self.addImagesView.bottom + 13, self.view.width - kLeftPadding - kRightPadding, 70)];
    self.goodsInfoView.backgroundColorThemeKey = kColorBackground3;
    self.goodsInfoView.hidden = !self.postWithGoods;
    [self.inputContainerView addSubview:self.goodsInfoView];
    
    self.goodsImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(1, 1, 68, 68)];
    self.goodsImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.goodsInfoView addSubview:self.goodsImageView];
    
    self.goodsNameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(82, 14, CGRectGetWidth(self.goodsInfoView.frame) - 117, 20)];
    self.goodsNameLabel.textColorThemeKey = kColorText1;
    self.goodsNameLabel.font = [UIFont systemFontOfSize:16];
    [self.goodsInfoView addSubview:self.goodsNameLabel];
    
    self.goodsDescLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(82, CGRectGetMaxY(self.goodsNameLabel.frame) + 4, self.goodsNameLabel.width, 18)];
    self.goodsDescLabel.textColorThemeKey = kColorText3;
    self.goodsDescLabel.font = [UIFont systemFontOfSize:13];
    [self.goodsInfoView addSubview:self.goodsDescLabel];
    
    self.arrowIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.goodsNameLabel.frame) + 15, 27, 9, 16)];
    self.arrowIcon.imageName = @"goods_arrow_icon";
    [self.goodsInfoView addSubview:self.arrowIcon];
    
    self.inputContainerView.height = self.postWithGoods ? self.goodsInfoView.bottom : self.addImagesView.bottom + kAddImagesViewBottomPadding;
    
    // toolbar
    kUGCToolbarHeight = 80.f + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    self.toolbar = [[TTUGCToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - kUGCToolbarHeight, self.view.width, kUGCToolbarHeight)];
    self.toolbar.emojiInputView.source = @"post";
    
    self.toolbar.banLongText = YES;
    
    [self.view addSubview:self.toolbar];
    
    //Location view
    self.addLocationView = [[FRPostThreadAddLocationView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36.f) andShowEtStatus:self.showEtStatus];
    if (!isEmptyString([self.position tt_stringValueForKey:@"position"])) {
        self.addLocationView.selectedLocation = [self generateLocationEntity];
    }
    self.addLocationView.concernId = self.cid;
    self.addLocationView.categotyID = self.categoryID;
    self.addLocationView.trackDic = self.trackDict;
    self.addLocationView.delegate = self;
    [self.toolbar addSubview:self.addLocationView];
    
    //分享到R
    BOOL showSyncToRocketButton = NO;
    showSyncToRocketButton = [self shouldShowSyncToRocketButton];
    if (showSyncToRocketButton) {
        self.syncToRocketButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.syncToRocketButton.imageName = @"details_choose_icon";
        self.syncToRocketButton.selectedImageName = @"details_choose_ok_icon";
        self.syncToRocketButton.highlightedImageName = nil;
        NSInteger checkStatus = [TTKitchen getInt:kTTKUGCSyncToRocketCheckStatus];
        BOOL firstChecked = [TTKitchen getBOOL:kTTKUGCSyncToRocketFirstChecked];
        BOOL firstSelected = checkStatus >= 0 ? (checkStatus > 0) : firstChecked;
        self.syncToRocketButton.selected = firstSelected;
        
        self.syncToRocketButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.syncToRocketButton addTarget:self action:@selector(syncToRocketButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat insets = (44 - 12) / 2.f;
        self.syncToRocketButton.hitTestEdgeInsets = UIEdgeInsetsMake(-insets, -insets, -insets, -insets);
        NSString *syncToRocketTitle = [TTKitchen getString:kTTKUGCPostSyncToRocketText];
        [self.syncToRocketButton setTitle:syncToRocketTitle forState:UIControlStateNormal];
        self.syncToRocketButton.titleColorThemeKey = kColorText1;
        
        UIFont *labelFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        self.syncToRocketButton.titleLabel.font = labelFont;
        self.syncToRocketButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.syncToRocketButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6);
        self.syncToRocketButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, -6);
        
        [self.toolbar addSubview:self.syncToRocketButton];
        CGRect rect = [syncToRocketTitle boundingRectWithSize:CGSizeMake(180, 16)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName : labelFont}
                                                      context:nil];
        CGFloat width = [TTDeviceUIUtils tt_newPadding:14 + 6 + rect.size.width];
        self.syncToRocketButton.frame = CGRectMake(self.view.width - width - 15, (80 - 44 - [TTDeviceUIUtils tt_newPadding:19]) / 2, width, [TTDeviceUIUtils tt_newPadding:19]);
        
        NSMutableDictionary *syncToRocketTrack = @{}.mutableCopy;
        [syncToRocketTrack setValue:@"publisher_text" forKey:@"source"];
        [TTTrackerWrapper eventV3:@"flipchat_sync_button_show" params:syncToRocketTrack];
        
    }
    
    //Tip label
    CGFloat tipLabelWidth = 70.0;
    self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(self.view.width - tipLabelWidth - kRightPadding, 0, tipLabelWidth, 36.f)];
    
    if (showSyncToRocketButton) {
        self.tipLabel.frame = CGRectMake(self.syncToRocketButton.left - tipLabelWidth - kRightPadding, 0, tipLabelWidth, 36.f);
    }
    self.tipLabel.font = [UIFont systemFontOfSize:12];
    self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.tipLabel.textAlignment = NSTextAlignmentRight;
    self.tipLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    self.tipLabel.textColorThemeKey = kColorText4;
    self.tipLabel.hidden = YES;
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
     */
}

- (void)parseOutInputImagesWithParamDic:(NSDictionary *)params {
    
    // userInfo input assetsLibrary
    ALAssetsLibrary * assetsLibrary = [params tt_objectForKey:@"library"];
    NSMutableArray *outInputImageAssets = [NSMutableArray new];
    
    NSArray *images;
    if ([assetsLibrary isKindOfClass:[ALAssetsLibrary class]]) {
        images = [params tt_arrayValueForKey:@"assets"];
    } else {
        images = [self generateInputAssets:[params tt_arrayValueForKey:@"threadImages"]];
    }
    
    if (!SSIsEmptyArray(images)) {
        [outInputImageAssets addObjectsFromArray:images];
    }
    
    images = nil;
    
    // schema input assets
    NSArray *presetWebImage = [params tt_arrayValueForKey:@"post_images"];
    if (!SSIsEmptyArray(presetWebImage)) {
        images = [self generateInputAssets:presetWebImage];
    } else {
        NSString *presetWebImageString = [[params tt_stringValueForKey:@"post_images"] URLDecodedString];
        
        if (!isEmptyString(presetWebImageString)) {
            NSError *jsonError;
            NSArray *presetImageURLArray = [NSJSONSerialization JSONObjectWithData:[presetWebImageString dataUsingEncoding:NSUTF8StringEncoding]
                                                                           options:0
                                                                             error:&jsonError];
            
            if (!jsonError && !SSIsEmptyArray(presetImageURLArray)) {
                images = [self generateInputAssets:presetImageURLArray];
            }
        }
    }
    
    if (!SSIsEmptyArray(images)) {
        [outInputImageAssets addObjectsFromArray:images];
    }
    
    // 过滤超9图的数据
    if ([outInputImageAssets count] > kMaxPostImageCount) {
        [outInputImageAssets removeObjectsInRange:NSMakeRange(kMaxPostImageCount, [outInputImageAssets count] - kMaxPostImageCount)];
    }
    self.outerInputAssets = [outInputImageAssets copy];
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

- (NSArray<TTAssetModel *> *)generateInputAssets:(NSArray<NSDictionary *> *)threadImages {
    NSMutableArray *assetModelsArrM = [NSMutableArray array];
    for (NSDictionary *dict in threadImages) {
        NSUInteger width = [dict tt_integerValueForKey:@"width"];
        NSUInteger height = [dict tt_integerValueForKey:@"height"];
        NSString *url = [dict tt_stringValueForKey:@"url"];
        NSString *uri = [dict tt_stringValueForKey:@"uri"];
        TTAssetModel *assetModel = [TTAssetModel modelWithImageWidth:width height:height url:url uri:uri];
        if (assetModel) {
            [assetModelsArrM addObject:assetModel];
        }
    }
    return [assetModelsArrM copy];
}

- (void)createInfoComponent {
    /*
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
     */
}

- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count > 1) {
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
    
//    [self.toolbar endEditing:YES];
}

- (void)cancel:(id)sender {
    [self endEditing];
    [self dismissSelf];
    /*
    NSString * titleText = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * phoneText = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL shouldAlert = !(isEmptyString(titleText) && isEmptyString(phoneText) && isEmptyString(inputText) && self.addImagesView.selectedImageCacheTasks.count == 0);
    if (self.postUGCEnterFrom == TTPostUGCEnterFromConcernHomepage && ![self textHasChanged] && ![self imageHasChanged]) { // 话题来的且未改变内容则不弹
        shouldAlert = NO;
    }
    
    if (!shouldAlert) {
        [self trackWithEvent:kPostTopicEventName label:@"cancel_none" containExtra:YES extraDictionary:nil];
        [self postFinished:NO];
    } else {
        [self trackWithEvent:kPostTopicEventName label:@"cancel" containExtra:YES extraDictionary:nil];
        
        if ([self draftEnable]) {
            TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"保存已输入的内容？" message:nil preferredType:TTThemedAlertControllerTypeAlert];
            WeakSelf;
            [alertController addActionWithTitle:@"不保存" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                StrongSelf;
                [self clearDraft];
                [self postFinished:NO];
            }];
            
            [alertController addActionWithTitle:@"保存" actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
                StrongSelf;
                [self trackWithEvent:kPostTopicEventName label:@"cancel_confirm" containExtra:YES extraDictionary:nil];
                [self postFinished:NO];
                [self saveDraft];
            }];
            [alertController showFrom:self animated:YES];
        } else {
            TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"确定退出？" message:nil preferredType:TTThemedAlertControllerTypeAlert];
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
     */
}

- (void)sendPost:(id)sender {
    
}

- (void)addImagesViewSizeChanged {
//    self.inputContainerView.height = self.postWithGoods ? self.goodsInfoView.bottom : self.addImagesView.bottom + kAddImagesViewBottomPadding;
//    self.infoContainerView.top = self.inputContainerView.height + kMidPadding;
//
//    CGFloat targetHeight = self.infoContainerView.bottom + kMidPadding;
//    CGFloat containerHeight = self.view.height - 64;
//    containerHeight = containerHeight >= targetHeight ? containerHeight : targetHeight;
//    containerHeight += kUGCToolbarHeight;
//    self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width, containerHeight);
//    [self refreshPostButtonUI];
}

- (void)refreshPostButtonUI {
//    if (![self.enterType isEqualToString:@"edit_publish"]) {
//        //发布器
//        if (self.inputTextView.text.length > 0 || self.addImagesView.selectedImageCacheTasks.count > 0) {
//            self.postButton.titleColorThemeKey = kColorText6;
//            self.postButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
//            self.postButton.disabledTitleColorThemeKey = kColorText6;
//        } else {
//            self.postButton.titleColorThemeKey = kColorText9;
//            self.postButton.highlightedTitleColorThemeKey = kColorText9Highlighted;
//            self.postButton.disabledTitleColorThemeKey = kColorText9;
//        }
//    } else {
//        //编辑发布器按钮刷新逻辑
//        if (([self textHasChanged] || [self imageHasChanged] || [self locationHasChanged]) && ![self emptyThread]) {
//            self.postButton.titleColorThemeKey = kColorText6;
//            self.postButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
//            self.postButton.disabledTitleColorThemeKey = kColorText6;
//        } else {
//            self.postButton.titleColorThemeKey = kColorText9;
//            self.postButton.highlightedTitleColorThemeKey = kColorText9Highlighted;
//            self.postButton.disabledTitleColorThemeKey = kColorText9;
//        }
//    }
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

@end
