//
//  TTPhotoNewCommentViewController.m
//  Article
//
//  Created by zhaoqin on 09/01/2017.
//
//

#import "TTPhotoNewCommentViewController.h"
#import "TTCommentViewController.h"
#import "TTCommentDataManager.h"
#import "TTCommentWriteView.h"
#import "ExploreDetailToolbarView.h"
#import "NewsDetailLogicManager.h"
#import "TTIndicatorView.h"
#import "Article.h"
#import "SSThemed.h"
#import "SSWebViewBackButtonView.h"
#import "ArticleFriend.h"
#import "TTPhotoDetailContainerViewController.h"
#import "TTDetailNatantContainerView.h"
#import "TTDetailNatantHeaderPaddingView.h"
#import "TTDetailNatantLayout.h"
#import "ExploreDetailTextlinkADView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTBusinessManager.h"
#import "TTDeviceUIUtils.h"
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import "TTCommentDetailViewController.h"
#import "TTViewWrapper.h"
#import "UIView+CustomTimingFunction.h"
#import "TTUIResponderHelper.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTKitchen/TTKitchen.h>
#import "SSCommentInputHeader.h"
#import "TTCommentViewControllerProtocol.h"
#import "AKHelper.h"
#import "FHTraceEventUtils.h"

#define  KPhotoCommentTipViewHeight    55

@interface TTPhotoNewCommentViewController () <TTCommentViewControllerDelegate,TTCommentDataSource,TTCommentWriteManagerDelegate>

@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, strong) TTCommentViewController * commentViewController;
@property (nonatomic, strong) ExploreDetailToolbarView * toolbarView;


@property (nonatomic, strong) SSThemedLabel  *tipLabel;
@property (nonatomic, assign) TTPhotoDetailMoveDirection direction;
@property (nonatomic, strong) UIPanGestureRecognizer *picturesGesture;
@property (nonatomic, assign) CGFloat beginDragY;

@property (nonatomic, strong) TTDetailNatantContainerView *natantContainerView;
@property (nonatomic, strong) TTViewWrapper *viewWrapper;
@property (nonatomic, assign) BOOL isPortraitPanGesture;
@property (nonatomic, strong) NSDictionary *insertDict;

@property (nonatomic, strong) TTCommentWriteView *commentWriteView;

@end

@implementation TTPhotoNewCommentViewController
{
    BOOL _reachDismissCondition;
}


- (instancetype)initViewModel:(TTDetailModel *)model {
    self = [super init];
    if (self) {
        self.detailModel = model;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttHideNavigationBar = YES;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    self.toolbarView = [[ExploreDetailToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, ExploreDetailGetToolbarHeight())];
    self.toolbarView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - self.toolbarView.frame.size.height, CGRectGetWidth(self.view.frame), self.toolbarView.frame.size.height);
    self.toolbarView.bottom = self.view.bounds.size.height;
    self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.toolbarView.viewStyle = TTDetailViewStylePhotoOnlyWriteButton;
    self.toolbarView.toolbarType = ExploreDetailToolbarTypePhotoOnlyWriteButton;
    self.toolbarView.writeButton.centerY = self.toolbarView.centerY;
    [self.toolbarView.writeButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.emojiButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];

    self.title = @"评论";
    self.commentViewController = [[TTCommentViewController alloc] initWithViewFrame:[TTUIResponderHelper splitViewFrameForView:self.view] dataSource:self delegate:self];
    self.commentViewController.view.top = 0;
    self.commentViewController.view.height -= ExploreDetailGetToolbarHeight();
    self.commentViewController.enableImpressionRecording = YES;
    self.viewWrapper = [TTViewWrapper viewWithFrame:self.view.bounds targetView:self.commentViewController.view];
    self.viewWrapper.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.viewWrapper.backgroundColorThemeKey = kColorBackground3;
    [self.view addSubview:self.viewWrapper];
    
    [self addChildViewController:self.commentViewController];
    [self.commentViewController willMoveToParentViewController:self];
    [self.viewWrapper addSubview:self.commentViewController.view];
    [self.commentViewController didMoveToParentViewController:self];
    [self.view addSubview:self.toolbarView];

    self.commentViewController.hasSelfShown = YES;
    self.commentViewController.view.backgroundColor = [UIColor whiteColor];
    [self.commentViewController tt_sendShowStatusTrackForCommentShown:YES];
    
    [self.commentViewController.commentTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStautsBarDidRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.commentViewController respondsToSelector:@selector(tt_reloadData)]) {
        [self.commentViewController tt_reloadData];
    }

    if ([self.delegate respondsToSelector:@selector(ttPhotoNewCommentViewControllerAppear:)]) {
        [self.delegate ttPhotoNewCommentViewControllerAppear:self];
    }
}

- (void)applicationStautsBarDidRotate {
//    self.subViewController.view.frame = CGRectMake(0, 20, self.view.width, self.view.height - 20);
//    self.commentViewController.view.frame = CGRectMake([TTUIResponderHelper paddingForViewWidth:self.view.width], 0, self.subViewController.view.width - 2 * [TTUIResponderHelper paddingForViewWidth:self.view.width], self.subViewController.view.height - self.titleView.height - self.toolbarView.height);
//    self.toolbarView.frame = CGRectMake(0, CGRectGetHeight(self.subViewController.view.frame) - self.toolbarView.frame.size.height, CGRectGetWidth(self.subViewController.view.frame), self.toolbarView.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.automaticallyTriggerCommentAction) {
        [self _openCommentWithText:nil switchToEmojiInput:NO];
        self.automaticallyTriggerCommentAction = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(ttPhotoNewCommentViewControllerAppear:)]) {
        [self.delegate ttPhotoNewCommentViewControllerAppear:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(ttPhotoNewCommentViewControllerDisappear:)]) {
        [self.delegate ttPhotoNewCommentViewControllerDisappear:self];
    }
}

- (TTDetailNatantContainerView *)natantContainerView
{
    if (!_natantContainerView) {
        _natantContainerView = [[TTDetailNatantContainerView alloc] init];
    }
    return _natantContainerView;
}

- (void)setInfoManager:(ArticleInfoManager *)infoManager
{
    CGSize windowSize = [TTUIResponderHelper windowSize];
    CGFloat containerWidth = windowSize.width - [TTUIResponderHelper paddingForViewWidth:windowSize.width]*2;
    NSMutableArray *natantViewArray = [NSMutableArray array];
    if ([infoManager.adminDebugInfo count] > 0) {
        CGFloat edgePadding = 15.f;
        ExploreDetailTextlinkADView *adminDebugView = [[ExploreDetailTextlinkADView alloc] initWithWidth:containerWidth - edgePadding*2];
        adminDebugView.left = edgePadding;
        [natantViewArray addObject:adminDebugView];
        
        TTDetailNatantHeaderPaddingView *spacingItem = [[TTDetailNatantHeaderPaddingView alloc] initWithWidth:containerWidth];
        spacingItem.height = [[TTDetailNatantLayout sharedInstance_tt] topMargin];;
        spacingItem.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        spacingItem.userInteractionEnabled = NO;
        [natantViewArray insertObject:spacingItem atIndex:0];
    }
    
    self.natantContainerView.items = natantViewArray;
    [self.natantContainerView reloadData:infoManager];
}

#pragma mark - TTCommentDataSource & TTCommentDelegate
- (void)tt_commentViewControllerDidFetchCommentsWithError:(nullable NSError *)error {
    
    if (self.insertDict) {
        [self.commentViewController tt_insertCommentWithDict:self.insertDict];
        [self.commentViewController tt_markStickyCellNeedsAnimation];
        [self.commentViewController tt_commentTableViewScrollToTop];
        self.insertDict = nil;
    }

    // toolbar 禁表情

    BOOL  isBanRepostOrEmoji = ![TTKitchen getBOOL:kTTKCommentRepostFirstDetailEnable] || (self.detailModel.adID > 0) || ak_banEmojiInput();
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.toolbarView.banEmojiInput = self.commentViewController.tt_banEmojiInput || isBanRepostOrEmoji;
    }
}

- (void)tt_loadCommentsForMode:(TTCommentLoadMode)loadMode
        possibleLoadMoreOffset:(NSNumber *)offset
                       options:(TTCommentLoadOptions)options
                   finishBlock:(TTCommentLoadFinishBlock)finishBlock
{
    TTCommentDataManager *commentDataManager = [[TTCommentDataManager alloc] init];
    [commentDataManager startFetchCommentsWithGroupModel:self.detailModel.article.groupModel forLoadMode:loadMode loadMoreOffset:offset loadMoreCount:@(TTCommentDefaultLoadMoreFetchCount) msgID:self.detailModel.msgID options:options finishBlock:finishBlock];
}

- (SSThemedView *)tt_commentHeaderView
{
    return self.natantContainerView;
}

- (TTGroupModel *)tt_groupModel
{
    return self.detailModel.article.groupModel;
}

- (NSInteger)tt_zzComments
{
    return self.detailModel.article.zzComments.count;
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickCommentCellWithCommentModel:(id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController digCommentWithCommentModel:(id<TTCommentModelProtocol>)model
{
    if (!model.userDigged) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [params setValue:model.commentID.stringValue forKey:@"comment_id"];
        [params setValue:model.userID.stringValue forKey:@"user_id"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.orderedData.categoryID forKey:@"category_name"];
        [params setValue:self.detailModel.clickLabel forKey:@"enter_from"];
        [TTTrackerWrapper eventV3:@"comment_undigg" params:params];
    } else {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
        [params setValue:@"house_app2c_v2" forKey:@"event_type"];
        [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
        [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
        [params setValue:model.commentID.stringValue forKey:@"comment_id"];
        //        [params setValue:model.userID.stringValue forKey:@"user_id"];
        [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
        [params setValue:self.detailModel.orderedData.categoryID forKey:@"category_name"];
        [params setValue:[FHTraceEventUtils generateEnterfrom:self.detailModel.orderedData.categoryID] forKey:@"enter_from"];
         [params setValue:@"comment" forKey:@"position"];
        [TTTrackerWrapper eventV3:@"rt_like" params:params];
    }
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(nonnull id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController avatarTappedWithCommentModel:(id<TTCommentModelProtocol>)model
{
    
    // add by zjing 去掉个人主页跳转
    return;
    
    if ([model.userID longLongValue] == 0) {
        return;
    }
    
    NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    [baseCondition setValue:model.userID forKey:@"uid"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(baseCondition)];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info {
    id<TTCommentModelProtocol> model = [info tt_objectForKey:@"commentModel"];
    
    NSMutableDictionary *infoMutableDic;
    if(info){
       infoMutableDic  = [[NSMutableDictionary alloc] initWithDictionary:info];
    }
    if(self.detailModel.orderedData.categoryID && ![info tt_stringValueForKey:@"categoryName"])
    {
        [infoMutableDic setValue:self.detailModel.orderedData.categoryID forKey:@"categoryName"];
    }
    TTCommentDetailViewController *detailRoot = [[TTCommentDetailViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(infoMutableDic)];
    [self.navigationController pushViewController:detailRoot animated:YES];
}

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController
             refreshCommentCount:(int)count
{
    self.detailModel.article.commentCount = count;
    [self.detailModel.article save];
}

- (void)tt_commentViewControllerFooterCellClicked:(nonnull id<TTCommentViewControllerProtocol>)ttController
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    wrapperTrackEventWithCustomKeys(@"fold_comment", @"click", self.detailModel.article.groupModel.groupID, nil, extra);
    NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
    [condition setValue:self.detailModel.article.groupModel.groupID forKey:@"groupID"];
    [condition setValue:self.detailModel.article.groupModel.itemID forKey:@"itemID"];
    [condition setValue:self.detailModel.article.aggrType forKey:@"aggrType"];
    [condition setValue:[self.detailModel.article zzCommentsIDString] forKey:@"zzids"];
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fold_comment"] userInfo:TTRouteUserInfoWithDict(condition)];
}

#pragma mark Toolbar Actions

- (void)_openCommentWithText:(NSString *)text switchToEmojiInput:(BOOL)switchToEmojiInput {

    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:self.detailModel.article.groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition setValue:[NSNumber numberWithBool:self.detailModel.article.hasImage] forKey:kQuickInputViewConditionHasImageKey];
    [condition setValue:self.detailModel.adID forKey:kQuickInputViewConditionADIDKey];
    [condition setValue:self.detailModel.article.mediaInfo[@"media_id"] forKey:kQuickInputViewConditionMediaID];

    NSString *fwID = self.detailModel.article.groupModel.groupID;

    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fwID;
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:self.readQuality];

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;

    // writeCommentView 禁表情
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.commentWriteView.banEmojiInput = self.commentViewController.tt_banEmojiInput;
    }

    if ([self.commentViewController respondsToSelector:@selector(tt_writeCommentViewPlaceholder)]) {
        [self.commentWriteView setTextViewPlaceholder:self.commentViewController.tt_writeCommentViewPlaceholder];
    }

    [self.commentWriteView showInView:self.view animated:YES];
}

- (void)_writeCommentActionFired:(id)sender {
    BOOL switchToEmojiInput = (sender == self.toolbarView.emojiButton);
    if (switchToEmojiInput) {
        [TTTrackerWrapper eventV3:@"emoticon_click" params:@{
            @"status" : @"no_keyboard",
            @"source" : @"comment"
        }];
    }

    [self _openCommentWithText:nil switchToEmojiInput:switchToEmojiInput];
}

- (CGRect)_commentViewControllerFrame
{
    CGSize windowSize = [TTUIResponderHelper windowSize];
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        return CGRectMake(edgePadding, 0, windowSize.width - edgePadding*2, windowSize.height);
    }
    else {
        return self.view.bounds;
    }
}

#pragma mark - TTCommentWriteManagerDelegate

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{    
    [commentView dismissAnimated:YES];
    commentWriteManager.delegate = nil;
    if(![responseData objectForKey:@"error"])  {
        Article *article = self.detailModel.article;
        article.commentCount = article.commentCount + 1;
        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:[responseData objectForKey:@"data"]];
        [self.commentViewController tt_insertCommentWithDict:data];
        [self.commentViewController tt_markStickyCellNeedsAnimation];
        [self.commentViewController tt_commentTableViewScrollToTop];
    }
    
}

- (void)insertCommentWithDict:(NSDictionary *)data {
    self.insertDict = data;
//    [self.commentViewController tt_insertCommentWithDict:data];
//    [self.commentViewController tt_markStickyCellNeedsAnimation];
//    [self.commentViewController tt_commentTableViewScrollToTop];
}

- (UIScrollView *)tt_scrollView {
    return self.commentViewController.commentTableView;
}

#pragma mark -- Helper

- (BOOL)isCurrentOrientationLandScape {
    return (self.interfaceOrientation == UIDeviceOrientationLandscapeLeft
            || self.interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

#pragma mark -- Orientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if([self isCurrentOrientationLandScape]) {
        self.tipLabel.hidden = YES;
    } else {
        self.tipLabel.hidden = NO;
        self.tipLabel.frame = CGRectMake(0, -KPhotoCommentTipViewHeight, self.commentViewController.view.frame.size.width, KPhotoCommentTipViewHeight);
    }
}

@end
