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
#import "TTKitchen.h"
#import "TTPostThreadKitchenConfig.h"
#import "FRPostThreadAddLocationView.h"
#import <KVOController/KVOController.h>
#import "TTLocationManager.h"
#import "TTGoogleMapGeocoder.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Link.h"
#import "TTThemeManager.h"

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

@interface FHPostUGCViewController ()<FRAddMultiImagesViewDelegate,UITextFieldDelegate, UIScrollViewDelegate,  TTUGCTextViewDelegate, TTUGCToolbarDelegate,FRPostThreadAddLocationViewDelegate>

@property (nonatomic, strong) SSThemedButton * cancelButton;
@property (nonatomic, strong) SSThemedButton * postButton;
@property (nonatomic, strong) TTUGCTextView * inputTextView;
@property (nonatomic, strong) UIScrollView       *containerView;
@property (nonatomic, strong) SSThemedView * inputContainerView;
@property (nonatomic, strong) TTUGCTextViewMediator       *textViewMediator;
@property (nonatomic, strong) TTUGCToolbar *toolbar;
@property (nonatomic, strong) FRAddMultiImagesView * addImagesView;
@property (nonatomic, copy) NSDictionary *position; //编辑带入的位置信息
@property (nonatomic, strong) FRPostThreadAddLocationView * addLocationView;
@property (nonatomic, copy) NSDictionary *trackDict; //  add by zyk
@property (nonatomic, assign) CGRect keyboardEndFrame;
@property (nonatomic, assign) BOOL keyboardVisibleBeforePresent; // 保存 present 页面之前的键盘状态，用于 Dismiss 之后恢复键盘
@property (nonatomic, copy) NSArray <TTAssetModel *> * outerInputAssets; //传入的assets
@property (nonatomic, copy) NSArray <UIImage *> * outerInputImages; //传入的images
@property (nonatomic, assign) FRShowEtStatus showEtStatus; //控制发帖页面展示项 add by zyk
@property (nonatomic, copy) NSString * cid; //关心ID  add by zyk
@property (nonatomic, copy) NSString * categoryID; //频道ID  add by zyk
@property (nonatomic, copy) NSDictionary *sdkParamsDict;// 分享调起
@property (nonatomic, strong) SSThemedLabel * tipLabel;
@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;
@property (nonatomic, assign) BOOL firstAppear;
@property (nonatomic, strong) SSThemedView * infoContainerView;
@property (nonatomic, copy) NSString * postContentHint; //输入框占位文本
@property (nonatomic, copy) NSString * postPreContent; //外部代入的输入框文本
@property (nonatomic, copy) NSString * postPreContentRichSpan;//外部代入的输入框的富文本信息
@property (nonatomic, copy) TTRichSpanText *outerInputRichSpanText; //编辑带入的文字信息

@property (nonatomic, strong) TTRichSpanText *richSpanText;



@end

@implementation FHPostUGCViewController


- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary * params = paramObj.allParams;
        if ([params isKindOfClass:[NSDictionary class]]) {
            /* add by zyk
             {
             "category_id" = "__all__";
             cid = 6454692306795629069;
             "enter_type" = "feed_publisher";
             "post_content_hint" = "\U5206\U4eab\U65b0\U9c9c\U4e8b";
             "post_ugc_enter_from" = 1;
             refer = 1;
             "show_et_status" = 8;
             }
             */
            //Post hint
            self.postContentHint = [params tt_stringValueForKey:@"post_content_hint"];
            self.postPreContent = [params tt_stringValueForKey:@"post_content"];
            self.postPreContentRichSpan = [params tt_stringValueForKey:@"post_content_rich_span"];
            if (!isEmptyString(self.postPreContent) || !isEmptyString(self.postPreContentRichSpan)) {
                self.postPreContent = self.postPreContent ?: @"";
                self.richSpanText = [[[TTRichSpanText alloc] initWithText:self.postPreContent richSpansJSONString:self.postPreContentRichSpan] replaceWhitelistLinks];
            } else {
                self.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
            }
            self.outerInputRichSpanText = self.richSpanText;
            
            // 添加google地图注册
            [[TTLocationManager sharedManager] registerReverseGeocoder:[TTGoogleMapGeocoder sharedGeocoder] forKey:NSStringFromClass([TTGoogleMapGeocoder class])];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.firstAppear = YES;
    [self setupNaviBar];
    [self createComponent];
    [self addImagesViewSizeChanged];
    [self addObserverAndNoti];
    // 等待构造完成之后初始化
    self.inputTextView.richSpanText = self.richSpanText; // add by zyk  richSpanText要搞明白
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

- (void)createInputComponent {
    CGFloat y = 0;
    
    //Input container view
    self.inputContainerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.inputContainerView.backgroundColorThemeKey = kColorBackground4;
    [self.containerView addSubview:self.inputContainerView];
    
    //Input view
    self.inputTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(kLeftPadding - 5, y + kInputViewTopPadding, self.view.width - kLeftPadding - kRightPadding + 10.f, kTextViewHeight)];

    self.inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    
    self.inputTextView.source = @"post";
    y = self.inputTextView.bottom;
    
    HPGrowingTextView *internalTextView = self.inputTextView.internalGrowingTextView;
    
    // 图文发布器展示
    internalTextView.minHeight = kTextViewHeight;
    internalTextView.maxNumberOfLines = 8;
    
    if (!isEmptyString(self.postContentHint)) {
        internalTextView.placeholder = self.postContentHint;
    } else {
        internalTextView.placeholder = [NSString stringWithFormat:@"分享新鲜事"];
    }
    
    
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
  
    self.inputContainerView.height =  self.addImagesView.bottom + kAddImagesViewBottomPadding;
//     self.inputContainerView.height = 500;
    
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
    
    //Tip label
    CGFloat tipLabelWidth = 70.0;
    self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(self.view.width - tipLabelWidth - kRightPadding, 0, tipLabelWidth, 36.f)];
    
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

- (FRLocationEntity *)generateLocationEntity {
    FRLocationEntity *posEntity = [[FRLocationEntity alloc] init];
    NSString *detail_pos = [self.position tt_stringValueForKey:@"position"];
    NSRange blankRange = [detail_pos rangeOfString:@" "];
    if (blankRange.location != NSNotFound) {
        posEntity.locationName = [detail_pos substringFromIndex:blankRange.location + 1];
    }
    posEntity.latitude = [self.position tt_integerValueForKey:@"latitude"];
    posEntity.longitude = [self.position tt_integerValueForKey:@"longitude"];;
    posEntity.city = [[detail_pos componentsSeparatedByString:@" "] firstObject];
    posEntity.locationType = [posEntity.city isEqualToString:detail_pos] ? FRLocationEntityTypeCity : FRLocationEntityTypeNomal;
    return posEntity;
}

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
    
    //Info container view
    self.infoContainerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.inputContainerView.bottom + kMidPadding , self.view.width, 0)];
    self.infoContainerView.backgroundColorThemeKey = kColorBackground4;
    [self.containerView addSubview:self.infoContainerView];
    
    CGFloat y = 0;
    // 添加其他视图
    self.infoContainerView.height = y;
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
    NSUInteger maxTextCount = [TTKitchen getInt:kTTKUGCPostAndRepostContentMaxCount];
    NSString *inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (inputText.length > maxTextCount) {
        self.tipLabel.hidden = NO;
        NSUInteger excludeCount = (unsigned long)(inputText.length - maxTextCount);
        excludeCount = MIN(excludeCount, 9999);
        self.tipLabel.text = [NSString stringWithFormat:@"-%lu", excludeCount];
    } else {
        self.tipLabel.hidden = YES;
    }
    
    [self refreshPostButtonUI];
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
    //编辑发布器按钮刷新逻辑
    if (([self textHasChanged] || [self imageHasChanged] || [self locationHasChanged]) && ![self emptyThread]) {
        self.postButton.titleColorThemeKey = kColorText6;
        self.postButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
        self.postButton.disabledTitleColorThemeKey = kColorText6;
    } else {
        self.postButton.titleColorThemeKey = kColorText9;
        self.postButton.highlightedTitleColorThemeKey = kColorText9Highlighted;
        self.postButton.disabledTitleColorThemeKey = kColorText9;
    }
}

- (BOOL)textHasChanged {
    // add by zyk 可能有问题
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

- (BOOL)locationHasChanged {
    if (!self.addLocationView.selectedLocation.locationName) {
        return !isEmptyString([self.position tt_stringValueForKey:@"position"]);
    }else{
        NSString *locationName = @"";
        NSString *detail_pos = [self.position tt_stringValueForKey:@"position"];
        NSRange blankRange = [detail_pos rangeOfString:@" "];
        if (blankRange.location != NSNotFound) {
            locationName = [detail_pos substringFromIndex:blankRange.location + 1];
        }
        return !([self.addLocationView.selectedLocation.locationName isEqualToString:locationName]);
    }
}

- (BOOL)emptyThread {
    TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
    [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *inputText = richSpanText.text;
    return isEmptyString(inputText) && self.addImagesView.selectedImageCacheTasks.count == 0;
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
    [self refreshPostButtonUI];
}



#pragma mark - TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {
    [self refreshUI];
}

- (void)textView:(TTUGCTextView *)textView willChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight {
    // 图文发布器展示
    self.addImagesView.top = self.inputTextView.bottom + kAddImagesViewTopPadding;
    self.inputContainerView.height = self.addImagesView.bottom + kAddImagesViewBottomPadding;
    self.infoContainerView.top = self.inputContainerView.height + kMidPadding;
    
    CGFloat targetHeight = self.infoContainerView.bottom + kMidPadding;
    CGFloat containerHeight = self.view.height - 64;
    containerHeight = containerHeight >= targetHeight ? containerHeight : targetHeight;
    containerHeight += kUGCToolbarHeight;
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
//    [TTTrackerWrapper eventV3:@"click_article_editor" params:@{@"uid":[[BDContextGet() findServiceByName:TTAccountProviderServiceName] userID]?:@""}];
//    if (![[BDContextGet() findServiceByName:TTAccountProviderServiceName] isLogin]) {
//        [self endEditing];
//        WeakSelf;
//        [[TTPostThreadBridge sharedInstance] showLoginAlertWithSource:self.source superView:self.navigationController.view completion:^(BOOL tips) {
//            StrongSelf;
//            if (tips) {
//                [[TTPostThreadBridge sharedInstance] presentQuickLoginFromVC:self source:self.source];
//            }
//        }];
//    } else {
//        [self handleLongTextRoute];
//    }
}

- (void)handleLongTextRoute {
    
}


- (void)toolbarDidClickShoppingButton {
//    [TTTrackerWrapper eventV3:@"xuanpin_button_click" params:@{@"source":@"post"}];
//    if (![[BDContextGet() findServiceByName:TTBusinessAllianceServiceName] ba_isProtocolAccepted]) {
//        WeakSelf;
//        [[BDContextGet() findServiceByName:TTBusinessAllianceServiceName] ba_showProtocolAlertWithCompletionBlock:^{
//            StrongSelf;
//            FRUgcBusinessAllianceUpdateProtocolStatusRequestModel *requestModel = [FRUgcBusinessAllianceUpdateProtocolStatusRequestModel new];
//            requestModel.user_id = [[BDContextGet() findServiceByName:TTAccountProviderServiceName] userID];
//            requestModel.status = @(1);
//            [TTUGCRequestManager requestModel:requestModel callBackWithMonitor:^(NSError *error, id<TTResponseModelProtocol> responseModel, TTUGCRequestMonitorModel *monitorModel) {
//                if (!error) {
//                    FRUgcBusinessAllianceUserInfoResponseModel *response = (FRUgcBusinessAllianceUserInfoResponseModel *)responseModel;
//                    if ([response.err_no integerValue] == 0) {
//                        [[BDContextGet() findServiceByName:TTBusinessAllianceServiceName] ba_updateUserId:[[BDContextGet() findServiceByName:TTAccountProviderServiceName] userID]
//                                                                                         acceptedProtocol:YES
//                                                                                                 showIcon:YES];
//                        [self goToShoppingPage];
//                    }
//                }
//            }];
//        }];
//    } else {
//        [self goToShoppingPage];
//    }
}

- (void)goToShoppingPage {
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setValue:[[BDContextGet() findServiceByName:TTAccountProviderServiceName] userID] forKey:@"user_id"];
//    [params setValue:[[BDContextGet() findServiceByName:TTAccountProviderServiceName] phoneNumber] forKey:@"phone_number"];
//    [params setValue:@"/select_product_page" forKey:@"route"];
//    [params setValue:[self.goodsItem toJSONString] forKey:@"product_info"];
//    [params setValue:@"/business_alliance" forKey:@"url"];
//    [params setValue:[NSString stringWithFormat:@"sslocal://webview?url=%@", [[KitchenMgr getString:kTTUGCBusinessAllianceChoiceProtocolUrl] URLEncodedString]] forKey:@"agreement_schema"];
//
//    NSString *url = [NSString stringWithFormat:@"sslocal://flutter?"];
//    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:url] userInfo:TTRouteUserInfoWithDict(params)];
}

//- (void)setGoodsItem:(TTPostGoodsItem *)goodsItem {
//    _goodsItem = goodsItem;
//    self.postWithGoods = goodsItem != nil;
//}

- (void)restoreDraft {
//    if ([self draftEnable]) {
//        NSArray *tasks = [TTPostThreadTask fetchTasksFromDiskForConcernID:[self draftConcernID]];
//        TTPostThreadTask *task = [tasks lastObject];
//        if ([task isKindOfClass:[TTPostThreadTask class]]) {
//            if (!isEmptyString(task.content)) {
//                self.richSpanText = [[[TTRichSpanText alloc] initWithText:task.content richSpansJSONString:task.contentRichSpans] replaceWhitelistLinks];
//            }
//
//            FRLocationEntity *posEntity = [[FRLocationEntity alloc] init];
//            posEntity.city = task.city;
//            posEntity.locationName = task.detail_pos;
//            posEntity.latitude = task.latitude;
//            posEntity.longitude = task.longitude;
//            posEntity.locationAddress = task.locationAddress;
//            posEntity.locationType = task.locationType;
//            if (isEmptyString(posEntity.locationAddress)
//                && isEmptyString(posEntity.city)
//                && isEmptyString(posEntity.locationName)) {
//                //本地存储地址都未空，不恢复地址位置。
//            } else {
//                self.addLocationView.selectedLocation = posEntity;
//                [self.addLocationView refresh];
//            }
//
//            NSArray<FRUploadImageModel *> *imageModels = task.images;
//            [self.addImagesView restoreDraft:imageModels];
//
//            self.selectedRange = task.selectedRange;
//        }
//        [self clearDraft];
//    }
}

- (void)clearDraft {
    // add by zyk
//    if ([self draftEnable]) {
//        NSArray *tasks = [TTPostThreadTask fetchTasksFromDiskForConcernID:[self draftConcernID]];
//        for (TTPostThreadTask *task in tasks) {
//            [TTPostThreadTask removeTaskFromDiskByTaskID:task.taskID concernID:[self draftConcernID]];
//        }
//    }
}

- (void)saveDraft {
     // add by zyk
//    if ([self draftEnable]) {
//        TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
//        [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//        TTPostThreadTask *task = [[TTPostThreadTask alloc] initWithTaskType:TTPostTaskTypeThread];
//
//        task.content = richSpanText.text;
//        task.contentRichSpans = [TTRichSpans JSONStringForRichSpans:richSpanText.richSpans];
//        task.create_time = [[NSDate date] timeIntervalSince1970];
//        task.userID = [[BDContextGet() findServiceByName:TTAccountProviderServiceName] userID];
//        task.concernID = [self draftConcernID];
//        task.categoryID = [self draftConcernID];
//        [task addTaskImages:self.addImagesView.selectedImageCacheTasks thumbImages:self.addImagesView.selectedThumbImages];
//        task.latitude = self.addLocationView.selectedLocation.latitude;
//        task.longitude = self.addLocationView.selectedLocation.longitude;
//        task.city = self.addLocationView.selectedLocation.city;
//        task.detail_pos = self.addLocationView.selectedLocation.locationName;
//        task.locationType = self.addLocationView.selectedLocation.locationType;
//        task.locationAddress = self.addLocationView.selectedLocation.locationAddress;
//        task.selectedRange = self.inputTextView.selectedRange;
//        if (isEmptyString(task.content) && self.addImagesView.selectedImageCacheTasks.count == 0)
//            return;
//
//        [task saveToDisk];
//    }
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
    offset = self.containerView.height - endFrame.size.height - (CGRectGetMaxY(firstResponderFrame) - self.containerView.contentOffset.y) - kUGCToolbarHeight;
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
        // 图文发布器展示
//        if (!(self.showEtStatus & FRShowEtStatusOfTitle) && self.publishMode != 1) {
//            [self.inputTextView becomeFirstResponder];
//        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    } else {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
}

- (void)viewDidEnterBackground {
    
    if (SSIsEmptyDictionary(self.sdkParamsDict)) {
        [self saveDraft];
    } else {
        
        UIViewController *controller = [TTUIResponderHelper visibleTopViewController];
        NSInteger retryCount = 0;
        while (controller != self && controller) {
            [controller dismissViewControllerAnimated:NO completion:nil];
            retryCount++;
            if (retryCount >= 15) {
                break;
            }
            controller = [TTUIResponderHelper visibleTopViewController];
        }
        [controller dismissViewControllerAnimated:NO completion:nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeViewController:)
                                                 name:kClosePostThreadViewControllerNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGoodsInfo:)
                                                 name:kUpdateGoodsItemInfomationNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 移除google地图注册
    [[TTLocationManager sharedManager] unregisterReverseGeocoderForKey:NSStringFromClass([TTGoogleMapGeocoder class])];
}

@end
