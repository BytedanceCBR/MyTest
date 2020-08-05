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
#import "FHUGCToolbar.h"
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
#import "FHPostUGCMainView.h"
#import "TTCategoryDefine.h"
#import "ToastManager.h"
#import "FHUserTracker.h"
#import "FHBubbleTipManager.h"
#import "FHUGCConfig.h"
#import "FHUGCCommunityListViewController.h"
#import "FHUGCConfig.h"
#import "FHEnvContext.h"
#import "NSString+UGCUtils.h"
#import "FHTopicHeaderModel.h"
#import "FHTopicListModel.h"
#import "FHHouseUGCAPI.h"
#import "FHUGCPublishTagModel.h"
#import "SSAPNsAlertManager.h"
#import "FHUGCTagsView.h"
#import "FHUGCTagAndRemarkModel.h"

static CGFloat const kLeftPadding = 20.f;
static CGFloat const kRightPadding = 20.f;
static CGFloat const kMidPadding = 10.f;
static CGFloat const kInputViewTopPadding = 10.f;
static CGFloat const kRateMovieViewHeight = 100.f;
static CGFloat const kTextViewHeight = 100.f;
static CGFloat const kUserInfoViewHeight = 44.f;
static CGFloat const kAddImagesViewTopPadding = 10.f;
static CGFloat const kAddImagesViewBottomPadding = 18.f;

static NSString * const kPostTopicEventName = @"topic_post";
static NSString * const kUserInputTelephoneKey = @"userInputTelephoneKey";
static NSInteger const kTitleCharactersLimit = 20;

static NSInteger const kMaxPostImageCount = 9;

@interface FHPostUGCViewController ()<FRAddMultiImagesViewDelegate,UITextFieldDelegate, UIScrollViewDelegate,  TTUGCTextViewDelegate, TTUGCToolbarDelegate,FRPostThreadAddLocationViewDelegate,FHUGCCommunityChooseDelegate,FHUGCToolbarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) SSThemedButton * cancelButton;
@property (nonatomic, strong) SSThemedButton * postButton;
@property (nonatomic, strong) TTUGCTextView * inputTextView;
@property (nonatomic, strong) UIScrollView       *containerView;
@property (nonatomic, strong) SSThemedView * inputContainerView;
@property (nonatomic, strong) TTUGCTextViewMediator       *textViewMediator;
@property (nonatomic, strong) FHUGCToolbar *toolbar;
@property (nonatomic, strong) FRAddMultiImagesView * addImagesView;
@property (nonatomic, copy) NSDictionary *position; //编辑带入的位置信息
@property (nonatomic, strong) FRPostThreadAddLocationView * addLocationView;
@property (nonatomic, copy) NSDictionary *trackDict;
@property (nonatomic, assign) CGRect keyboardEndFrame;
@property (nonatomic, assign) BOOL keyboardVisibleBeforePresent; // 保存 present 页面之前的键盘状态，用于 Dismiss 之后恢复键盘
@property (nonatomic, copy) NSArray <TTAssetModel *> * outerInputAssets; //传入的assets
@property (nonatomic, copy) NSArray <UIImage *> * outerInputImages; //传入的images
@property (nonatomic, assign) FRShowEtStatus showEtStatus; //控制发帖页面展示项
@property (nonatomic, copy) NSString * cid; //关心ID
@property (nonatomic, copy) NSString * categoryID; //频道ID  
@property (nonatomic, copy) NSDictionary *sdkParamsDict;// 分享调起
@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;
@property (nonatomic, assign) BOOL firstAppear;
@property (nonatomic, strong) SSThemedView * infoContainerView;
@property (nonatomic, copy) NSString * postContentHint; //输入框占位文本
@property (nonatomic, copy) NSString * postPreContent; //外部代入的输入框文本
@property (nonatomic, copy) NSString * postPreContentRichSpan;//外部代入的输入框的富文本信息
@property (nonatomic, copy) TTRichSpanText *outerInputRichSpanText; //编辑带入的文字信息
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, assign) BOOL useDraftFirst;//是否优先使用concern_id草稿，否则使用传入值（postPreContent || postPreContentRichSpan）

@property (nonatomic, strong) TTRichSpanText *richSpanText;
@property (nonatomic, copy) void (^postFinishCompletionBlock)(BOOL);

@property (nonatomic, copy) NSString *entrance; //入口
@property (nonatomic, copy) NSString *enterConcernID; //entrance为concern时有意义

@property (nonatomic, copy)     NSString       *selectGroupId;// 选中的小区id 小区位置不能点击 默认是已关注
@property (nonatomic, copy)     NSString       *selectGroupName; // 选中的小区name
@property (nonatomic, copy  )   NSString   *neighborhoodId; //小区详情页id
@property (nonatomic, assign)   BOOL       hasSocialGroup;// 外部传入小区
@property (nonatomic, copy  )   NSString   *groupId; //微头条卡片进入，微头条id

@property (nonatomic, assign)   BOOL       lastCanShowMessageTip;
@property (nonatomic, assign)   BOOL       lastInAppPushTipsHidden;
@property (nonatomic, weak)     TTNavigationController       *navVC;
@property (nonatomic, strong)   FHTopicHeaderModel  *topicHeaderModel; // 话题详情页进发布器传入的话题数据
@property (nonatomic, assign)   BOOL isAddedTopicHeaderModel;

@property (nonatomic, assign)   BOOL isOuterEdit;
@property (nonatomic, copy)     NSString *outerPostId;
@property (nonatomic, strong)   NSMutableArray<FHUGCToolBarTag *> *hotTags;
@property (nonatomic, assign)   CGRect keyboardFrameForToolbar;
@property (nonatomic, assign)   BOOL isKeyboardShow;
@property (nonatomic, assign)   BOOL isToolbarWillEndEditing;
@property (nonatomic, copy)     NSString *customTitle;

// 小区点评发布器
@property (nonatomic, strong)   FHUGCTagsView *tagsView;
@end

@implementation FHPostUGCViewController


- (NSMutableArray<FHUGCToolBarTag *> *)hotTags {
    if(!_hotTags) {
        _hotTags = [[NSMutableArray alloc] init];
        
        // 不使用本地记录，改使用接口返回数据
        // 本地发布历史添加标签列表数据
//        NSMutableArray<FHUGCToolBarTag *> *tags = [[NSMutableArray alloc] init];
//        FHPostUGCSelectedGroupHistory *selectedGroupHistory = [[FHUGCConfig sharedInstance] loadPublisherHistoryData];
//        NSString* currentUserID = [TTAccountManager currentUser].userID.stringValue;
//        NSString *currentCityID = [FHEnvContext getCurrentSelectCityIdFromLocal];
//        FHPostUGCSelectedGroupModel *selectedGroup = nil;
//        if(selectedGroupHistory && currentCityID.length > 0 && currentUserID.length > 0) {
//            NSString *saveKey = [currentUserID stringByAppendingString:currentCityID];
//            selectedGroup = [selectedGroupHistory.historyInfos objectForKey:saveKey];
//        }
//        if(selectedGroup) {
//            FHUGCToolBarTag *tag = [[FHUGCToolBarTag alloc] init];
//            tag.groupId = selectedGroup.socialGroupId;
//            tag.groupName = selectedGroup.socialGroupName;
//            tag.tagType = FHPostUGCTagType_History;
//            [_hotTags addObject:tag];
//        }
    }
    return _hotTags;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary * params = paramObj.allParams;
        if ([params isKindOfClass:[NSDictionary class]]) {
            self.customTitle = [params tta_stringForKey:@"title"]?:@"发贴";
            self.useDraftFirst = [params tt_boolValueForKey:@"use_draft_first"];
            self.isOuterEdit = [params tta_boolForKey:@"isOuterEdit"];
            self.outerPostId = [params tta_stringForKey:@"outerPostId"];
            //Post hint
            self.postContentHint = [params tt_stringValueForKey:@"post_content_hint"];
            self.postPreContent = [params tt_stringValueForKey:@"post_content"];
            self.postPreContentRichSpan = [params tt_stringValueForKey:@"post_content_rich_span"];
            if (!isEmptyString(self.postPreContent) || !isEmptyString(self.postPreContentRichSpan)) {
                self.postPreContent = self.postPreContent ?: @"";
                self.richSpanText = [[[TTRichSpanText alloc] initWithText:self.postPreContent richSpansJSONString:self.postPreContentRichSpan] replaceWhitelistLinks];
                NSString *highlight_color_string = [NSString hexStringWithColor:[UIColor themeRed3]];
                [self.richSpanText.richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull spanLink, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSMutableDictionary *userInfo = spanLink.userInfo.mutableCopy;
                    userInfo[@"color_info"] = @{
                        @"day": highlight_color_string,
                        @"night": highlight_color_string
                    };
                    spanLink.userInfo = userInfo;
                }];
            } else {
                self.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
            }
            self.outerInputRichSpanText = self.richSpanText;
            self.outerInputAssets = [params tt_arrayValueForKey:@"outerInputAssets"];
            self.postFinishCompletionBlock = [params tt_objectForKey:@"completionBlock"];
            // 选中圈子
            self.neighborhoodId = [params tta_stringForKey:@"neighborhood_id"];
            self.groupId = [params tta_stringForKey:@"group_id"];
            self.selectGroupId = [params tt_stringValueForKey:@"select_group_id"];
            self.selectGroupName = [params tt_stringValueForKey:@"select_group_name"];
            if (!((self.selectGroupId.length > 0 && self.selectGroupName.length > 0) || self.neighborhoodId.length > 0)) {
                // 必须都有值
                self.hasSocialGroup = NO;
                self.selectGroupId = nil;
                self.selectGroupName = nil;
            } else {
                self.hasSocialGroup = YES;
            }
            
            // 话题详情页传入的话题数据
            self.topicHeaderModel = [params tt_objectForKey:@"topic_model"];
            
            // 取链接中的埋点数据
            NSString *enter_from = params[@"enter_from"];
            if (enter_from.length > 0) {
                self.tracerDict[@"enter_from"] = enter_from;
            }
            NSString *enter_type = params[@"enter_type"];
            if (enter_type.length > 0) {
                self.tracerDict[@"enter_type"] = enter_type;
            }
            NSString *element_from = params[@"element_from"];
            if (element_from.length > 0) {
                self.tracerDict[@"element_from"] = element_from;
            }
            NSString *log_pb_str = params[@"log_pb"];
            if ([log_pb_str isKindOfClass:[NSString class]] && log_pb_str.length > 0) {
                NSData *jsonData = [log_pb_str dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err = nil;
                NSDictionary *dic = nil;
                @try {
                    dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&err];
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
                if (!err && [dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
                    self.tracerDict[@"log_pb"] = dic;
                }
            }
            
            // H5传递过来的参数
            NSString *report_params = params[@"report_params"];
            if ([report_params isKindOfClass:[NSString class]]) {
                NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
                if (report_params_dic) {
                    [self.tracerDict addEntriesFromDictionary:report_params_dic];
                }
            }
            self.trackDict = [self.tracerDict copy];
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
    [self restoreData];
    __weak typeof(self) weakSelf = self;
    self.panBeginAction = ^{
        [weakSelf.inputTextView resignFirstResponder];
    };
    // 顶部 消息 弹窗tips
    self.lastCanShowMessageTip = [FHBubbleTipManager shareInstance].canShowTip;
    [FHBubbleTipManager shareInstance].canShowTip = NO;
    // App 内push
    self.lastInAppPushTipsHidden = kFHInAppPushTipsHidden;
    kFHInAppPushTipsHidden = YES;// 不展示
    
    [self addGoDetailLog];
    
    [self requestHotTags];
    
    // 小区点评发布器调用，内部有判断条件
    [self requestNeightborhoodRemark];
}

- (void)requestHotTags {
    
    NSMutableDictionary *param = @{}.mutableCopy;
    param[@"f_city_id"] = [FHEnvContext getCurrentSelectCityIdFromLocal];

    @weakify(self);
    [FHHouseUGCAPI requestPublishHotTagsWithParam:param class:FHUGCPublishTagModel.class completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        @strongify(self);
        
        if([model isKindOfClass:[FHUGCPublishTagModel class]]) {
            FHUGCPublishTagModel* tagsModel = (FHUGCPublishTagModel *)model;
            
            
            if(tagsModel.data.recentlySocials.count > 0) {
                [tagsModel.data.recentlySocials enumerateObjectsUsingBlock:^(FHUGCPublishTagSocialModel * _Nonnull tagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    FHUGCToolBarTag *tag = [[FHUGCToolBarTag alloc] init];
                    tag.groupId = @(tagModel.socialGroupId).stringValue;
                    tag.groupName = tagModel.socialGroupName;
                    tag.tagType = FHPostUGCTagType_History;
                    
                    // 热门圈子标签优先于发布历史
                    NSUInteger index = [self.hotTags indexOfObject:tag];
                    if(index == NSNotFound) {
                        [self.hotTags addObject:tag];
                    }
                }];
            }
            
            if(tagsModel.data.socials.count > 0) {
                [tagsModel.data.socials enumerateObjectsUsingBlock:^(FHUGCPublishTagSocialModel * _Nonnull tagModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    FHUGCToolBarTag *tag = [[FHUGCToolBarTag alloc] init];
                    tag.groupId = @(tagModel.socialGroupId).stringValue;
                    tag.groupName = tagModel.socialGroupName;
                    tag.tagType = FHPostUGCTagType_HotTag;
                    
                    // 热门圈子标签优先于发布历史
                    NSUInteger index = [self.hotTags indexOfObject:tag];
                    if(index == NSNotFound) {
                        [self.hotTags addObject:tag];
                    }
                }];
            }
        }
        
        [self.hotTags enumerateObjectsUsingBlock:^(FHUGCToolBarTag * _Nonnull tag, NSUInteger idx, BOOL * _Nonnull stop) {
            tag.index = idx;
        }];
        
        [self needRelayoutToolbar];
        
    }];
}

- (void)requestNeightborhoodRemark {
    
    [self needRelayoutToolbar];
    
    if(self.neighborhoodId.length <= 0) {
        return;
    }
    
    NSMutableDictionary *param = @{}.mutableCopy;
    param[@"neighborhood_id"] = self.neighborhoodId;
    
    @weakify(self);
    [FHHouseUGCAPI requestNeighborhoodRemarkWithParam:param class:FHUGCTagAndRemarkModel.class completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        @strongify(self);
        if(!error && model) {
            FHUGCTagAndRemarkModel *tagAndRemarkModel = (FHUGCTagAndRemarkModel *)model;
            [self.tagsView refreshWithTags:tagAndRemarkModel.data.tags];
        }
    }];
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

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
    [self setTitle:self.customTitle];
    TTNavigationBarItemContainerView * leftBarItem = nil;
    leftBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft
                                                                                           withTitle:NSLocalizedString(@"取消", nil)
                                                                                              target:self
                                                                                              action:@selector(cancel:)];
    if ([leftBarItem isKindOfClass:[TTNavigationBarItemContainerView class]]) {
        [leftBarItem.button setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [leftBarItem.button setTitleColor:[UIColor themeGray1] forState:UIControlStateDisabled];
        leftBarItem.button.highlightedTitleColorThemeKey = kColorText1Highlighted;
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
        [rightBarItem.button setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
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
    tapGestureRecognizer.delegate = self;
    [self.containerView addGestureRecognizer:tapGestureRecognizer];
}

- (void) createInputComponent {
    
    //Container View
    CGFloat top = 44.f + [UIApplication sharedApplication].statusBarFrame.size.height;

    self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, self.view.width, self.view.height - top)];
    self.containerView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.containerView.alwaysBounceVertical = YES;
    self.containerView.delegate = self;
    [self.view addSubview:self.containerView];
    
    
    CGFloat y = 0;
    //Input container view
    self.inputContainerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    self.inputContainerView.backgroundColorThemeKey = kColorBackground4;
    [self.containerView addSubview:self.inputContainerView];
    
    //Input view
    self.inputTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(kLeftPadding - 5, y + kInputViewTopPadding, self.view.width - kLeftPadding - kRightPadding + 10.f, kTextViewHeight)];

    self.inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    self.inputTextView.isBanAt = YES;
    self.inputTextView.isBanHashtag = YES;
    self.inputTextView.source = @"post";
    self.inputTextView.typingAttributes = @{
        NSFontAttributeName: [UIFont themeFontRegular:self.inputTextView.textViewFontSize],
        NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText1),
    };
    
    y = self.inputTextView.bottom;
    
    HPGrowingTextView *internalTextView = self.inputTextView.internalGrowingTextView;
    
    // 图文发布器展示
    internalTextView.minHeight = kTextViewHeight;
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
    if (!self.hasSocialGroup) {
        maxNumberOfLines -= 2;
    }
    internalTextView.maxNumberOfLines = maxNumberOfLines;
    internalTextView.backgroundColor = [UIColor clearColor];
    internalTextView.textColor = SSGetThemedColorWithKey(kColorText1);
    internalTextView.tintColor = [UIColor themeRed1];
    internalTextView.placeholderColor =  SSGetThemedColorWithKey(kColorText3);
    internalTextView.internalTextView.placeHolderFont = [UIFont themeFontRegular:self.inputTextView.textViewFontSize];
    internalTextView.font = [UIFont themeFontRegular:self.inputTextView.textViewFontSize];
    internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    if (!isEmptyString(self.postContentHint)) {
        internalTextView.placeholder = self.postContentHint;
    } else {
        internalTextView.placeholder = [NSString stringWithFormat:@"新鲜事"];
    }
    [self.inputContainerView addSubview:self.inputTextView];
    
    // add image view
    y += kAddImagesViewTopPadding;
    self.addImagesView = [[FRAddMultiImagesView alloc] initWithFrame:CGRectMake(kLeftPadding, y, self.view.width - kLeftPadding - kRightPadding, self.view.height - y) assets:self.outerInputAssets images:self.outerInputImages];
    self.addImagesView.eventName = kPostTopicEventName;
    self.addImagesView.delegate = self;
    self.addImagesView.ssTrackDict = self.trackDict;
    self.addImagesView.hideAddImagesButtonWhenEmpty = YES;
    self.addImagesView.selectionLimit = 9;
    [self.addImagesView startTrackImagepicker];
    
    [self.inputContainerView addSubview:self.addImagesView];
  

    
    CGFloat inputContainerViewHeight = (self.addImagesView.selectedImageCacheTasks.count <= 0 ? self.inputTextView.bottom : self.addImagesView.bottom) + kAddImagesViewBottomPadding;

    // 小区点评标签选择视图
    if(self.neighborhoodId.length > 0) {
        self.tagsView = [[FHUGCTagsView alloc] initWithFrame:CGRectMake(0, inputContainerViewHeight, self.inputContainerView.width, 100)];
        [self.inputContainerView addSubview:self.tagsView];
        
        inputContainerViewHeight = self.tagsView.bottom + kAddImagesViewTopPadding;
        
    }
    self.inputContainerView.height = inputContainerViewHeight;
    
    // toolbar
    CGFloat toolbarHeight = [FHUGCToolbar toolbarHeightWithTags:self.hotTags hasSelected:self.hasSocialGroup];
    self.toolbar = [[FHUGCToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - toolbarHeight, self.view.width, toolbarHeight) type:FHPostUGCMainViewType_Post];
    self.toolbar.emojiInputView.source = @"post";
    self.toolbar.banHashtagInput = YES;
    self.toolbar.banLongText = YES;
    __weak typeof(self) weakSelf = self;
    self.toolbar.picButtonClkBlk = ^{
        // 添加图片
        [weakSelf.addImagesView showImagePicker];
    };
    self.toolbar.tagDelegate = self;
    
    // 报数参数设置
    FHUGCToolbarReportModel *reportModel = [FHUGCToolbarReportModel new];
    reportModel.enterFrom = self.tracerModel.enterFrom;
    reportModel.originFrom = self.tracerModel.originFrom;
    reportModel.pageType = @"feed_publisher";
    self.toolbar.reportModel = reportModel;
    
    // 圈子选择列表跳转手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCommunityViewClick:)];
    [self.toolbar.socialGroupSelectEntry addGestureRecognizer:tap];
    [self.view addSubview:self.toolbar];
    
    // 选择小区
    if (self.selectGroupId.length > 0 && self.selectGroupName.length > 0) {
        self.toolbar.socialGroupSelectEntry.groupId = self.selectGroupId;
        self.toolbar.socialGroupSelectEntry.communityName = self.selectGroupName;
        self.toolbar.socialGroupSelectEntry.followed = YES;
        self.toolbar.socialGroupSelectEntry.tagType = FHPostUGCTagType_Normal;
        self.toolbar.socialGroupSelectEntry.tagIndex = INVALID_TAG_INDEX;
    }
    
    //Location view
    
    self.addLocationView = [[FRPostThreadAddLocationView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36.f) andShowEtStatus:self.showEtStatus];
    if (!isEmptyString([self.position tt_stringValueForKey:@"position"])) {
        self.addLocationView.selectedLocation = [self generateLocationEntity];
    }
    self.addLocationView.concernId = self.cid;
    self.addLocationView.categotyID = self.categoryID;
    self.addLocationView.trackDic = self.trackDict;
    self.addLocationView.delegate = self;
    self.addLocationView.hidden = YES;
    [self.toolbar addSubview:self.addLocationView];
    
    // TextView and Toolbar Mediator
    self.textViewMediator = [[TTUGCTextViewMediator alloc] init];
    self.textViewMediator.textView = self.inputTextView;
    self.textViewMediator.toolbar = self.toolbar;
    self.textViewMediator.showCanBeCreatedHashtag = YES;
    self.textViewMediator.richSpanColorHexStringForDay = [NSString hexStringWithColor:[UIColor themeRed3]];
    self.textViewMediator.richSpanColorHexStringForNight = self.textViewMediator.richSpanColorHexStringForDay;
    self.toolbar.emojiInputView.delegate = self.inputTextView;
    self.toolbar.delegate = self.textViewMediator;
    [self.toolbar tt_addDelegate:self asMainDelegate:NO];
    self.inputTextView.delegate = self.textViewMediator;
    [self.inputTextView tt_addDelegate:self asMainDelegate:NO];
    self.inputTextView.textLenDelegate = self;
    // 配置话题按钮
    [self configTopicBtnOnToolBar];
    // 配置@人按钮
    [self configAtBtnOnToolBar];
}

- (void)configTopicBtnOnToolBar {
    
    BOOL isShowHashTagBtn = YES;
    self.toolbar.banHashtagInput = !isShowHashTagBtn;
    self.inputTextView.isBanHashtag = self.toolbar.banHashtagInput;
    if(isShowHashTagBtn) {
        WeakSelf;
        self.textViewMediator.hashTagBtnClickBlock = ^(BOOL didInputTextHashtag) {
            StrongSelf;
            
            self.keyboardVisibleBeforePresent = self.inputTextView.keyboardVisible;
            [self endEditing];
            
            NSURLComponents *components = [NSURLComponents componentsWithString:@"sslocal://ugc_post_topic_list"];
            NSString *groupId = self.hasSocialGroup ? self.selectGroupId : self.toolbar.socialGroupSelectEntry.groupId;
            NSURLQueryItem *groudIPItem = [NSURLQueryItem queryItemWithName:@"groupId" value:groupId];
            
            NSURL *url = components.URL;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"delegate"] = self.textViewMediator;
            
            NSMutableDictionary *tracer = self.tracerDict.mutableCopy;
            
            tracer[UT_ELEMENT_FROM] = didInputTextHashtag ? @"write_label" : @"publisher_topic";
            tracer[UT_ENTER_FROM] = @"feed_publisher";
            tracer[UT_ENTER_TYPE] = @"click";
            param[TRACER_KEY] = tracer;
            
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:param];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            
            if(!didInputTextHashtag) {
                // 发布器内点击“话题”按钮
                NSMutableDictionary *param = self.tracerDict.mutableCopy;
                param[@"click_position"] = @"publisher_topic";
                TRACK_EVENT(@"click_options", param);
            }
        };
    } else {
        self.textViewMediator.hashTagBtnClickBlock = nil;
    }
}

- (void)configAtBtnOnToolBar {
    BOOL isShowAtBtn = YES;
    self.toolbar.banAtInput = !isShowAtBtn;
    self.inputTextView.isBanAt = self.toolbar.banAtInput;
    if(isShowAtBtn) {
        WeakSelf;
        self.textViewMediator.atBtnClickBlock = ^(BOOL didInputAt) {
            StrongSelf;
            self.keyboardVisibleBeforePresent = NO;// 不显示键盘了
            [self endEditing];
            
            NSURLComponents *components = [NSURLComponents componentsWithString:@"sslocal://ugc_post_at_list"];
            NSString *groupId = self.hasSocialGroup ? self.selectGroupId : self.toolbar.socialGroupSelectEntry.groupId;
            NSURLQueryItem *groudIPItem = [NSURLQueryItem queryItemWithName:@"groupId" value:groupId];
            
            NSURL *url = components.URL;
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"delegate"] = self.textViewMediator;
            param[@"isPushOutAtListController"] = @(YES);
            param[@"isShowCancelNavigationBar"] = @(YES);
            
            NSMutableDictionary *tracer = self.tracerDict.mutableCopy;
            
            tracer[UT_ELEMENT_FROM] = didInputAt ? @"write_label" : @"publisher_at";
            tracer[UT_ENTER_FROM] = @"feed_publisher";
            tracer[UT_ENTER_TYPE] = @"click";
            param[TRACER_KEY] = tracer;
            
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:param];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            
            if(!didInputAt) {
                // 发布器内点击“@”按钮
                NSMutableDictionary *param = self.tracerDict.mutableCopy;
                param[@"click_position"] = @"publisher_at";
                TRACK_EVENT(@"click_options", param);
            }
        };
    } else {
        self.textViewMediator.atBtnClickBlock = nil;
    }
}

- (void)selectCommunityViewClick:(UITapGestureRecognizer *)sender {
    
    NSMutableDictionary *tracerDict = self.trackDict.mutableCopy;
    tracerDict[@"click_position"] = @"select_like_publisher_neighborhood";
    [FHUserTracker writeEvent:@"click_like_publisher_neighborhood" params:tracerDict];
    
    self.keyboardVisibleBeforePresent = self.inputTextView.keyboardVisible;
    self.isToolbarWillEndEditing = YES;
    [self endEditing];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"action_type"] = @(FHCommunityListTypeChoose);
    //无关注定位到推荐
    dict[@"select_district_tab"] = [FHUGCConfig sharedInstance].followList.count > 0 ? @(FHUGCCommunityDistrictTabIdFollow) :  @(FHUGCCommunityDistrictTabIdRecommend);
    NSHashTable *chooseDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [chooseDelegateTable addObject:self];
    dict[@"choose_delegate"] = chooseDelegateTable;
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_type"] = @"click";
    traceParam[@"enter_from"] = @"feed_publisher";
    traceParam[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    traceParam[@"element_from"] = @"select_like_publisher_neighborhood";
    dict[TRACER_KEY] = traceParam;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
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
    
    self.isToolbarWillEndEditing = YES;
    
    [self.view endEditing:YES];
    
    [self.toolbar endEditing:YES];
    
    [self needRelayoutToolbar];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    // 点击空白处可以收起或呼出键盘
    if (self.inputTextView.isFirstResponder) {
        [self.inputTextView resignFirstResponder];
    } else {
        [self.inputTextView becomeFirstResponder];
    }
}

- (BOOL)checkPostContentShowAlertIfNeedWhenCancel {
    BOOL isContentChanged = [self checkPostContentChanged];
    
    BOOL isHasNewInputContent = isContentChanged;

    // 小区点评，非编辑状态下，退出时，如果用户输入内容或选择了图片，
    // 则弹出提示确认删除弹窗
    if(self.neighborhoodId.length > 0 && !self.isOuterEdit) {
        if(self.addImagesView.selectedImageCacheTasks.count != 0 || self.inputTextView.trimmedLength > 0) {
            isHasNewInputContent = YES;
        }
    }
    
    return isHasNewInputContent;
}

- (void)cancel:(id)sender {
    
    [(TTNavigationController*)self.navigationController panRecognizer].enabled = YES;
    
    [self endEditing];
    
    NSString * inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL shouldAlert = [self checkPostContentShowAlertIfNeedWhenCancel];
    
    if (!shouldAlert) {
        [self postFinished:NO];
    } else {
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
                [self postFinished:NO];
                [self saveDraft];
            }];
            [alertController showFrom:self animated:YES];
        } else {
            // 弹窗埋点
            NSMutableDictionary *tracerDict = self.trackDict.mutableCopy;
            tracerDict[@"enter_type"] = @"click";
            [FHUserTracker writeEvent:@"publisher_cancel_popup_show" params:tracerDict];
            
            TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"编辑未完成" message:@"退出后编辑的内容将不被保存" preferredType:TTThemedAlertControllerTypeAlert];
            WeakSelf;
            [alertController addActionWithTitle:NSLocalizedString(@"退出", comment:nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                StrongSelf;
                tracerDict[@"click_position"] = @"confirm";
                [FHUserTracker writeEvent:@"publisher_cancel_popup_click" params:tracerDict];
                [self postFinished:NO];
            }];
            [alertController addActionWithTitle:NSLocalizedString(@"继续编辑", comment:nil) actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
                StrongSelf;
                tracerDict[@"click_position"] = @"cancel";
                [FHUserTracker writeEvent:@"publisher_cancel_popup_click" params:tracerDict];
            }];
            [alertController showFrom:self animated:YES];
        }
    }
}

- (void)sendPost:(id)sender {
    TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
    [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *inputText = richSpanText.text;
    
    // 网络连接已判断
    if (![self isValidateWithInputText:inputText]) {
        return;
    }
    
    [self endEditing];
    
    // 注意 参数 下一步获取手机号
    [self sendThreadWithLoginState:1 withTitleText:@"" inputText:inputText phoneText:nil];
}

- (void)sendThreadWithLoginState:(NSInteger)loginState withTitleText:(NSString *)titleText inputText:(NSString *)inputText phoneText:(NSString *)phoneText {
    if (self && [TTAccountManager isLogin]) {
        TTAccountUserEntity *userInfo = [TTAccount sharedAccount].user;
        [self followAndPostThreadWithTitleText:titleText inputText:inputText phoneText:userInfo.mobile];
    } else {
        // 应该不会走到当前位置，UGC外面限制强制登录
        [self gotoLogin];
    }
}

// 先关注再发帖
- (void)followAndPostThreadWithTitleText:(NSString *)titleText inputText:(NSString *)inputText phoneText:(NSString *)phoneText {
    if (self.toolbar.socialGroupSelectEntry.followed) {
        // 已关注，直接发帖
        [self postThreadWithTitleText:titleText inputText:inputText phoneText:phoneText];
    } else {
        // 先关注
        if(self.toolbar.socialGroupSelectEntry.groupId.length > 0) {
            __weak typeof(self) weakSelf = self;
            [[FHUGCConfig sharedInstance] followUGCBy:self.toolbar.socialGroupSelectEntry.groupId isFollow:YES enterFrom:@"feed_publisher" enterType:@"click" completion:^(BOOL isSuccess) {
                if (isSuccess) {
                    [weakSelf postThreadWithTitleText:titleText inputText:inputText phoneText:phoneText];
                } else {
                    // [[ToastManager manager] showToast:@"发帖失败"];
                }
            }];
        } else {
            [self postThreadWithTitleText:titleText inputText:inputText phoneText:phoneText];
        }
    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"feed_publisher" forKey:@"enter_from"];
    [params setObject:@"click" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wSelf sendPost:nil];
                });
            }
        }
    }];
}

- (void)postThreadWithTitleText:(NSString *)titleText inputText:(NSString *)inputText phoneText:(NSString *)phoneText {
    
    TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
    [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray *mentionUsers = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    NSMutableArray *mentionConcerns = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    NSMutableArray *createdConcerns = [NSMutableArray arrayWithCapacity:richSpanText.richSpans.links.count];
    
    for (TTRichSpanLink *link in richSpanText.richSpans.links) {
        
        // 外部传入编辑Feed，获取@用户和话题数组
        if(self.isOuterEdit) {
            switch (link.type) {
                case TTRichSpanLinkTypeAt:
                    if(link.idStr.length > 0) {
                        [mentionUsers addObject:link.idStr];
                    }
                    break;
                case TTRichSpanLinkTypeHashtag:
                    if(link.idStr.length > 0) {
                        [mentionConcerns addObject:link.idStr];
                    }
                    break;
                default:
                    break;
            }
        }
        
        // 内部用户输入内容发布获取@用户和话题数组
        else {
            NSString *userId = [link.userInfo tt_stringValueForKey:@"user_id"];
            if (!isEmptyString(userId)) {
                [mentionUsers addObject:userId];
            }
            if ([link.link isEqualToString:TTUGCSelfCreateHashtagLinkURLString]) {
                NSString *forumName = [link.userInfo tt_stringValueForKey:@"forum_name"];
                if (!isEmptyString(forumName)) {
                    [createdConcerns addObject:forumName];
                }
            } else {
                NSString *concernId = [link.userInfo tt_stringValueForKey:@"concern_id"];
                if (!isEmptyString(concernId)) {
                    [mentionConcerns addObject:concernId];
                }
            }
        }
    }
    
    if (phoneText.length > 0) {
        //telephone number is legal and save telephone number for next time
        [[NSUserDefaults standardUserDefaults] setObject:phoneText forKey:kUserInputTelephoneKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    double longitude = self.addLocationView.selectedLocation.longitude;
    double latitude = self.addLocationView.selectedLocation.latitude;
//    CGFloat rate = self.rateMovieView.rate;
    NSMutableDictionary *extraTrack = [NSMutableDictionary dictionary];
//    [extraTrack setValue:self.enterType forKey:@"enter_type"];
    
    NSDictionary <NSString *, NSString *> *emojis = [TTUGCEmojiParser parseEmojis:inputText];
    [TTUGCEmojiParser markEmojisAsUsed:emojis];
    NSArray <NSString *> *emojiIds = emojis.allKeys;
    [TTTrackerWrapper eventV3:@"emoticon_stats" params:@{
                                                         @"with_emoticon_list" : (!emojiIds || emojiIds.count == 0) ? @"none" : [emojiIds componentsJoinedByString:@","],
                                                         @"source" : @"post"
                                                         }];
    
    // 话题页发帖默认是带上了话题concern，如果在发布前用户手动删除话题，则将cid改回默认的，避免错误的召回到该话题下
    self.cid = KTTFollowPageConcernID;
    NSString *concernID = self.cid;
    // 去掉links中fake的自建话题
    TTRichSpans *richSpans = richSpanText.richSpans;
    if (!SSIsEmptyArray(createdConcerns)) {
        NSMutableArray<TTRichSpanLink *> *links = [NSMutableArray arrayWithCapacity:richSpans.links.count];
        [richSpans.links enumerateObjectsUsingBlock:^(TTRichSpanLink * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj.link isEqualToString:TTUGCSelfCreateHashtagLinkURLString]) {
                [links addObject:obj];
            }
        }];
        richSpans = [[TTRichSpans alloc] initWithRichSpanLinks:[links copy] imageInfoModelsDict:richSpans.imageInfoModesDict];
    }
    
    // 收集参数数据模型
    TTPostThreadModel *postThreadModel = [[TTPostThreadModel alloc] init];
    postThreadModel.postID = self.outerPostId;
    postThreadModel.content = inputText;
    postThreadModel.contentRichSpans = [TTRichSpans JSONStringForRichSpans:richSpans];
    postThreadModel.mentionUsers = [mentionUsers componentsJoinedByString:@","];
    postThreadModel.mentionConcerns = [mentionConcerns componentsJoinedByString:@","];
    postThreadModel.title = titleText;
    postThreadModel.phoneNumber = phoneText;
    postThreadModel.fromWhere = FRFromWhereTypeAPP_TOUTIAO_IOS;
    postThreadModel.concernID = concernID;
    postThreadModel.categoryID = self.categoryID;
    postThreadModel.taskImages = self.addImagesView.selectedImageCacheTasks;
    postThreadModel.thumbImages = self.addImagesView.selectedThumbImages;
    postThreadModel.needForward = 1;
    postThreadModel.city = self.addLocationView.selectedLocation.city;
    postThreadModel.detailPos = self.addLocationView.selectedLocation.locationName;
    postThreadModel.longitude = longitude;
    postThreadModel.latitude = latitude;
    postThreadModel.hasSocialGroup = self.hasSocialGroup;
    postThreadModel.extraTrack = self.trackDict.copy;
    postThreadModel.social_group_id = self.toolbar.socialGroupSelectEntry.groupId;
    postThreadModel.social_group_name = self.toolbar.socialGroupSelectEntry.communityName;
    postThreadModel.bindType = postThreadModel.social_group_id.length > 0 ? 0 : 1;
    if(self.neighborhoodId.length > 0) {
        postThreadModel.neighborhoodId = self.neighborhoodId;
        postThreadModel.source =  @"neighborhood";
        
        if(self.tagsView.selectedTags.count > 0) {
            NSMutableString *jsonString = [NSMutableString stringWithString:@"["];
            NSMutableArray *arrayStrElement = [NSMutableArray array];
            [self.tagsView.selectedTags enumerateObjectsUsingBlock:^(FHUGCTagModel * _Nonnull tagInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                [arrayStrElement addObject:tagInfo.toJSONString];
            }];
            [jsonString appendString:[arrayStrElement componentsJoinedByString:@","]];
            [jsonString appendString:@"]"];
            postThreadModel.neighborhoodTags = jsonString;
        }
    }
    
    // 外部传入图文发布器数据，重新编辑后发布
    if(self.isOuterEdit) {
        [[TTPostThreadCenter sharedInstance_tt] postEditedThreadWithPostThreadModel:postThreadModel finishBlock:^{
            [self dismissSelf];
        }];
    }
    // 图文发布器内部编辑后发布
    else {
        [[TTPostThreadCenter sharedInstance_tt] postThreadWithPostThreadModel:postThreadModel finishBlock:^(TTPostThreadTask *task) {
            [self postFinished:YES task:task];
        }];
    }
}

#pragma mark - 图文发布器内部编辑后发布

- (void)postFinished:(BOOL)hasSent {
    [self postFinished:hasSent task:nil];
}

- (void)postFinished:(BOOL)hasSent task:(TTPostThreadTask *)task {
    [self clearDraft];
    if (hasSent && !isEmptyString(self.cid)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCForumPostThreadFinish object:nil userInfo:@{@"cid" : self.cid}];
        [self addFeedPublishClickLog];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTForumPostingThreadActionCancelledNotification
                                                            object:nil
                                                          userInfo:nil];
        // 取消埋点
        NSMutableDictionary *tracerDict = self.trackDict.mutableCopy;
        tracerDict[@"click_position"] = @"publisher_cancel";
        [FHUserTracker writeEvent:@"click_options" params:tracerDict];
    }

    [(TTNavigationController*)self.navigationController panRecognizer].enabled = YES;
    
    // 发帖跳关注频道
    [self dismissSelf];
    
    !self.postFinishCompletionBlock ?: self.postFinishCompletionBlock(hasSent);
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

- (void)addImagesViewSizeChanged {
    CGFloat inputContainerViewHeight = (self.addImagesView.selectedImageCacheTasks.count <= 0 ? self.inputTextView.bottom : self.addImagesView.bottom) + kAddImagesViewBottomPadding;
    if(self.neighborhoodId.length > 0) {
        self.tagsView.top = inputContainerViewHeight;
        inputContainerViewHeight = self.tagsView.bottom + kAddImagesViewTopPadding;
    }
    self.inputContainerView.height = inputContainerViewHeight;
    self.infoContainerView.top = self.inputContainerView.height + kMidPadding;

    CGFloat targetHeight = self.infoContainerView.bottom + kMidPadding;
    CGFloat containerHeight = self.view.height - 64;
    containerHeight = containerHeight >= targetHeight ? containerHeight : targetHeight;
    containerHeight += [FHUGCToolbar toolbarHeightWithTags:self.hotTags hasSelected:self.hasSocialGroup];
    self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width, containerHeight);
    [self refreshPostButtonUI];
}

- (void)refreshUI {
    NSUInteger maxTextCount = [TTKitchen getInt:kTTKUGCPostAndRepostContentMaxCount];
    NSString *inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.toolbar.tipLabel.text = [NSString stringWithFormat:@"%ld/%lu",inputText.length, maxTextCount];
    [self refreshPostButtonUI];
}

- (void)refreshPostButtonUI {
    //发布器
    [self refreshPostButtonValidStatus];
}

- (void)refreshPostButtonValidStatus {
    
    BOOL isEnablePostButton = [self checkPostContentChanged];
    
    [self setPostButtonEnable:isEnablePostButton];
}

- (BOOL)checkPostContentChanged {
    
    BOOL ret = NO;
    
    if(self.isOuterEdit) {
        
        NSString *outerContent = self.postPreContent;
        NSMutableString *outerImageUris = [NSMutableString string];
        [self.outerInputAssets enumerateObjectsUsingBlock:^(TTAssetModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            if(model.imageURI.length > 0) {
                [outerImageUris appendFormat:@"%@", model.imageURI];
            }
        }];
        
        TTRichSpanText *richSpanText = [self.inputTextView.richSpanText restoreWhitelistLinks];
        [richSpanText trimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *currentContent = richSpanText.text;
        NSMutableString *currentImageUris = [NSMutableString string];
        [self.addImagesView.selectedImageCacheTasks enumerateObjectsUsingBlock:^(TTUGCImageCompressTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if(task.assetModel.imageURI.length > 0) {
                [currentImageUris appendFormat:@"%@", task.assetModel.imageURI];
            }
            
            if(task.preCompressFilePath.length > 0) {
                [currentImageUris appendFormat:@"%@", task.preCompressFilePath];
            } else if(task.assetModel.assetID.length > 0) {
                [currentImageUris appendFormat:@"%@", task.assetModel.assetID];
            }
        }];
        
        ret = !([currentContent isEqualToString:outerContent] &&  [currentImageUris isEqualToString:outerImageUris]);
    }
    else {
        NSInteger validContentLength = 0;
        if(self.neighborhoodId.length > 0) {
            validContentLength = 10;
            ret = self.inputTextView.trimmedLength > validContentLength;
        }
        else {
            validContentLength = 0;
            ret = self.inputTextView.trimmedLength > validContentLength || self.addImagesView.selectedImageCacheTasks.count != 0;
        }
    }
    
    return ret;
}

- (void)setPostButtonEnable:(BOOL)isEnable {
    
    self.postButton.enabled = isEnable;
    
    if(isEnable) {
        [self.postButton setTitleColor:[UIColor themeOrange1] forState:UIControlStateHighlighted];
        [self.postButton setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
        [self.postButton setTitleColor:[UIColor themeOrange1] forState:UIControlStateDisabled];
    }
    else {
        [self.postButton setTitleColor:[UIColor themeGray3] forState:UIControlStateHighlighted];
        [self.postButton setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [self.postButton setTitleColor:[UIColor themeGray3] forState:UIControlStateDisabled];
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
    CGFloat inputContainerViewHeight = (self.addImagesView.selectedImageCacheTasks.count <= 0 ? self.inputTextView.bottom : self.addImagesView.bottom) + kAddImagesViewBottomPadding;
    if(self.neighborhoodId.length > 0) {
        self.tagsView.top = inputContainerViewHeight;
        inputContainerViewHeight = self.tagsView.bottom + kAddImagesViewTopPadding;
    }
    self.inputContainerView.height = inputContainerViewHeight;
    self.infoContainerView.top = self.inputContainerView.height + kMidPadding;
    
    CGFloat targetHeight = self.infoContainerView.bottom + kMidPadding;
    CGFloat containerHeight = self.view.height - 64;
    containerHeight = containerHeight >= targetHeight ? containerHeight : targetHeight;
    containerHeight += [FHUGCToolbar toolbarHeightWithTags:self.hotTags hasSelected:self.hasSocialGroup];
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
    self.isToolbarWillEndEditing = YES;
    [self endEditing];
}


#pragma mark - FRAddMultiImagesViewDelegate

- (void)addImagesButtonDidClickedOfAddMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"page_type"] = @"feed_publisher";
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
        task.latitude = self.addLocationView.selectedLocation.latitude;
        task.longitude = self.addLocationView.selectedLocation.longitude;
        task.city = self.addLocationView.selectedLocation.city;
        task.detail_pos = self.addLocationView.selectedLocation.locationName;
        task.locationType = self.addLocationView.selectedLocation.locationType;
        task.locationAddress = self.addLocationView.selectedLocation.locationAddress;
        task.selectedRange = self.inputTextView.selectedRange;
        if (isEmptyString(task.content) && self.addImagesView.selectedImageCacheTasks.count == 0)
            return;

        [task saveToDisk];
    }
}

- (BOOL)hasPresettingThreadContent {
    if ((!isEmptyString(self.postPreContent) || !isEmptyString(self.postPreContentRichSpan) || self.outerInputAssets.count || self.outerInputImages.count) && (!self.useDraftFirst)) {
        return YES;
    } else {
        return NO;
    }
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
    CGRect keyboardEndFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.isKeyboardShow = ceil(keyboardEndFrame.origin.y)< SCREEN_HEIGHT;
    if(self.isKeyboardShow) {
        self.keyboardFrameForToolbar = keyboardEndFrame;
    } else {
        self.keyboardFrameForToolbar = CGRectZero;
    }
    
    [self needRelayoutToolbar];
    
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
    offset = self.containerView.height - endFrame.size.height - (CGRectGetMaxY(firstResponderFrame) - self.containerView.contentOffset.y) - [FHUGCToolbar toolbarHeightWithTags:self.hotTags hasSelected:self.hasSocialGroup];
    if (offset < 0) {
        self.keyboardEndFrame = endFrame;
        
        if(self.inputTextView.text.length > 0 && [self.inputTextView.text sizeWithFontCompatible:self.inputTextView.internalGrowingTextView.font].width > self.inputTextView.internalGrowingTextView.width) {
            [self.containerView setContentOffset:CGPointMake(0, fabs(self.containerView.contentOffset.y-offset)) animated:YES];
        }
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

-(void)addHashTagToTextView {
    
    // 从话题详情页带入的话题内容
    if(!self.isAddedTopicHeaderModel) {
        NSError *error = nil;
        FHTopicListResponseDataListModel *topicListItemModel = [[FHTopicListResponseDataListModel alloc] initWithDictionary:self.topicHeaderModel.forum.toDictionary error:&error];
        if(!error) {
            [self.textViewMediator addHashtag:topicListItemModel];
        }
        self.isAddedTopicHeaderModel = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addHashTagToTextView];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
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
    if (self.firstAppear) {
        self.firstAppear = NO;
        if(self.neighborhoodId.length > 0) {
            // 小区点评发布器，进入不弹键盘
            [self.tagsView becomeFirstResponder];
        } else {
            [self.inputTextView becomeFirstResponder];
        }
    } else {
        // 选择圈子子
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.keyboardVisibleBeforePresent) {
                [weakSelf.inputTextView becomeFirstResponder];
            }
        });
    }
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
    
    [FHBubbleTipManager shareInstance].canShowTip = self.lastCanShowMessageTip;
    // App 内push
    kFHInAppPushTipsHidden = self.lastInAppPushTipsHidden;// 展示
}

- (NSDictionary *)getDictionaryFromJSONString:(NSString *)jsonString {
    NSMutableDictionary *retDic = nil;
    if (jsonString.length > 0) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        retDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if ([retDic isKindOfClass:[NSDictionary class]] && error == nil) {
            return retDic;
        } else {
            return nil;
        }
    }
    return retDic;
}

#pragma mark - FHUGCFollowListDelegate
- (void)selectedItem:(FHUGCScialGroupDataModel *)item {
    
    if (item) {
        
        if([self.toolbar.socialGroupSelectEntry hasValidData]) {
            if(![item.socialGroupId isEqualToString:self.toolbar.socialGroupSelectEntry.groupId]) {
                if(self.toolbar.socialGroupSelectEntry.tagType != FHPostUGCTagType_Normal) {
                    [self.toolbar tagCloseButtonClicked];
                }
            } else {
                if(self.toolbar.socialGroupSelectEntry.tagType != FHPostUGCTagType_Normal) {
                    return;
                }
            }
        }
        
        self.toolbar.socialGroupSelectEntry.groupId = item.socialGroupId;
        self.toolbar.socialGroupSelectEntry.communityName = item.socialGroupName;
        self.toolbar.socialGroupSelectEntry.followed = [item.hasFollow boolValue];
        self.toolbar.socialGroupSelectEntry.tagType = FHPostUGCTagType_Normal;
        self.toolbar.socialGroupSelectEntry.tagIndex = INVALID_TAG_INDEX;
        [self.toolbar stagePushDuplicateTagIfNeedWithGroupId:item.socialGroupId];
        [self refreshPostButtonUI];
        
        NSMutableDictionary *tracerDict = self.trackDict.mutableCopy;
        tracerDict[@"element_type"] = @"select_like_publisher_neighborhood";
        if (item.socialGroupId.length > 0) {
            tracerDict[@"group_id"] = item.socialGroupId;
        }
        [FHUserTracker writeEvent:@"element_show" params:tracerDict];
    }
}

- (void)addGoDetailLog {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = @"feed_publisher";
    param[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM];
    TRACK_EVENT(UT_GO_DETAIL, param);
}

- (void)addFeedPublishClickLog {
    NSMutableDictionary *param = @{}.mutableCopy;
    param[UT_PAGE_TYPE] = @"feed_publisher";
    param[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM];
    param[@"click_options"] = @"passport_publisher";
    TRACK_EVENT(@"feed_publish_click", param);
}

#pragma mark - FHUGCToolbarDelegate

- (void)selectedTag:(FHUGCToolBarTag *)tagInfo {
    self.toolbar.socialGroupSelectEntry.groupId = tagInfo.groupId;
    self.toolbar.socialGroupSelectEntry.communityName = tagInfo.groupName;
    FHUGCScialGroupDataModel * model = [[FHUGCConfig sharedInstance] socialGroupData:tagInfo.groupId];
    self.toolbar.socialGroupSelectEntry.followed = model ? [model.hasFollow boolValue] : NO;
    self.toolbar.socialGroupSelectEntry.tagType = tagInfo.tagType;
    self.toolbar.socialGroupSelectEntry.tagIndex = tagInfo.index;
    
    [self needRelayoutToolbar];
}

- (void)needRelayoutToolbar {
    
    CGFloat toolbarHeight = [FHUGCToolbar toolbarHeightWithTags:self.hotTags hasSelected:self.hasSocialGroup];
    CGRect frame = self.toolbar.frame;
    frame.origin.y = self.view.height - toolbarHeight - self.keyboardFrameForToolbar.size.height;
    if(self.isKeyboardShow) {
        frame.origin.y += [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    } else {
        if(self.toolbar.emojiInputViewVisible && !self.toolbar.switchToInput && !self.isToolbarWillEndEditing) {
            frame.origin.y -= self.toolbar.emojiInputView.height;
        }
    }
    self.isToolbarWillEndEditing = NO;
    self.toolbar.frame = frame;
    [self.toolbar layoutTagSelectCollectionViewWithTags:self.hotTags hasSelected:self.hasSocialGroup];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    CGPoint location = [touch locationInView:self.tagsView];
    
    if(CGRectContainsPoint(self.tagsView.bounds, location)) {
        return NO;
    }
    return YES;
}
@end
