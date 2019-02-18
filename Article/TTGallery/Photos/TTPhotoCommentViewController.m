//
//  TTPhotoCommentViewController.m
//  Article
//
//  Created by yuxin on 4/20/16.
//
//

#import "TTPhotoCommentViewController.h"
#import "TTCommentViewController.h"
#import "TTCommentDataManager.h"
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
#import "TTCommentDefines.h"
#import "ExploreDetailTextlinkADView.h"

#import "UIImage+TTThemeExtension.h"
 
#import "TTDeviceHelper.h"
#import "TTBusinessManager.h"
#import "TTDeviceUIUtils.h"
#import <TTKitchen/TTKitchen.h>
#import "SSUserModel.h"
#import "SSCommentInputHeader.h"
#import "TTCommentWriteView.h"

//爱看
#import "AKHelper.h"

#define  KPhotoCommentTipViewHeight    55

@interface TTPhotoCommentViewController () <TTCommentViewControllerDelegate,TTCommentDataSource,TTCommentWriteManagerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, strong) TTCommentViewController * commentViewController;
@property (nonatomic, strong) ExploreDetailToolbarView * toolbarView;

@property (nonatomic, strong) SSThemedLabel  *tipLabel;
//下滑手势
@property (nonatomic, assign) TTPhotoDetailMoveDirection direction;
@property (nonatomic, strong) UIPanGestureRecognizer *picturesGesture;
@property (nonatomic, assign) CGFloat beginDragY;

@property (nonatomic, strong) TTDetailNatantContainerView *natantContainerView;

@property (nonatomic, strong) TTCommentWriteView *commentWriteView;
@end

@implementation TTPhotoCommentViewController
{
    BOOL _reachDismissCondition;
}

- (instancetype)initViewModel:(TTDetailModel *)model delegate:(id <TTCommentViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _detailModel = model;
        _delegate = delegate;
    }

    return self;
}

- (void)dealloc {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
    
    SSThemedView * bgView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    bgView.backgroundColorThemeKey = kColorBackground4;
    [self.view addSubview:bgView];
    
    
    _toolbarView = [[ExploreDetailToolbarView alloc] init];
    _toolbarView.viewStyle = TTDetailViewStylePhotoOnlyWriteButton;
    _toolbarView.toolbarType = ExploreDetailToolbarTypePhotoOnlyWriteButton;
    
    SSThemedButton *backButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (isDayModel) {
        backButton.imageName = @"lefterbackicon_titlebar_night";
    }
    else {
        backButton.imageName = @"shadow_lefterback_titlebar";
    }
    [backButton addTarget:self action:@selector(backButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];
    
    SSThemedView *topView = [[SSThemedView alloc] initWithFrame:CGRectMake(-1, -1, self.view.frame.size.width+2, 65)];
    topView.backgroundColorThemeKey = kColorBackground4;
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    topView.borderColorThemeKey = kColorLine1;
    topView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    [topView addSubview:backButton];
    [self.view addSubview:topView];
    
    
    CGRect properRect = [TTDeviceHelper isPadDevice] ? [TTUIResponderHelper splitViewFrameForView:self.view] : self.view.bounds;
    self.commentViewController = [[TTCommentViewController alloc] initWithViewFrame:UIEdgeInsetsInsetRect(properRect,UIEdgeInsetsMake(64,0,_toolbarView.frame.size.height,0)) dataSource:self delegate:self];
    self.commentViewController.enableImpressionRecording = YES;
    [self.commentViewController tt_sendShowStatusTrackForCommentShown:YES];
    [self.commentViewController willMoveToParentViewController:self];
    [self.view addSubview:self.commentViewController.view];
    [self addChildViewController:self.commentViewController];
    [self.commentViewController didMoveToParentViewController:self];
    
    _toolbarView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - self.toolbarView.frame.size.height, CGRectGetWidth(self.view.frame), self.toolbarView.frame.size.height);
    self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_toolbarView];
    [self.toolbarView.writeButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.emojiButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];

    self.view.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.commentViewController.hasSelfShown = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.automaticallyTriggerCommentAction) {
        [self _openCommentWithText:nil switchToEmojiInput:NO];
        self.automaticallyTriggerCommentAction = NO;
    }
    
    [self refreshStatusBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.commentViewController.hasSelfShown = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //修复iPad上横屏进入再竖屏列表页宽度不对的问题
    if ([TTDeviceHelper isPadDevice]) {
        self.commentViewController.view.frame = UIEdgeInsetsInsetRect([TTUIResponderHelper splitViewFrameForView:self.view],UIEdgeInsetsMake(64,0,self.toolbarView.frame.size.height,0));
    }
    [self.commentViewController.commentTableView reloadData];
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

- (void)refreshStatusBar
{
    //statusBar
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (isDayModel) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

#pragma mark - TTCommentDataSource & TTCommentDelegate

- (void)tt_commentViewControllerDidFetchCommentsWithError:(nullable NSError *)error {

    // toolbar 禁表情
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {

        BOOL isBanRepostOrEmoji = ![TTKitchen getBOOL:kTTKCommentRepostFirstDetailEnable] || (self.detailModel.adID > 0) || ak_banEmojiInput();
        self.toolbarView.banEmojiInput = self.commentViewController.tt_banEmojiInput || isBanRepostOrEmoji;
        self.banEmojiInput = self.commentViewController.tt_banEmojiInput;

    }

    // 透传给外部
    if (self.delegate && [self.delegate respondsToSelector:@selector(tt_commentViewControllerDidFetchCommentsWithError:)]) {
        [self.delegate tt_commentViewControllerDidFetchCommentsWithError:error];
    }
}

- (void)tt_loadCommentsForMode:(TTCommentLoadMode)loadMode possibleLoadMoreOffset:(NSNumber *)offset
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
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(nonnull id<TTCommentModelProtocol>)model
{
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController scollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.beginDragY = self.view.size.height;
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (![SSCommonLogic appGallerySlideOutSwitchOn] || [self isCurrentOrientationLandScape]) {
        return;
    }
    
    if (self.beginDragY == self.view.size.height) {
        self.beginDragY = scrollView.contentOffset.y;
    }
    
    if (self.beginDragY <= 0) {
        if (self.direction == kPhotoDetailMoveDirectionNone) {
            if (scrollView.contentOffset.y < - KPhotoCommentTipViewHeight) {
                self.direction = kPhotoDetailMoveDirectionVerticalBottom;
                _reachDismissCondition = YES;
            }
        }
        
        if (self.direction == kPhotoDetailMoveDirectionVerticalBottom) {
            [self animatePhotoViewWhenGestureEnd];
        }
    }
    
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

#pragma mark NavBar action

- (void)backButtonPressed
{
    self.direction = kPhotoDetailMoveDirectionNone;
    _reachDismissCondition = YES;
    [self animatePhotoViewWhenGestureEnd];
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
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:(TTArticleReadQualityModel *)self.readQuality];

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;

    // writeCommentManager 禁表情
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.commentWriteView.banEmojiInput = self.commentViewController.tt_banEmojiInput;
    }

    if ([self.commentViewController respondsToSelector:@selector(tt_writeCommentViewPlaceholder)]) {
        [self.commentWriteView setTextViewPlaceholder:self.commentViewController.tt_writeCommentViewPlaceholder];
    }

    [self.commentWriteView showInView:nil animated:YES];
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
        [self insertCommentWithDict:data];
    }
}

- (void)insertCommentWithDict:(NSDictionary *)data {
    [self.commentViewController tt_insertCommentWithDict:data];
    [self.commentViewController tt_markStickyCellNeedsAnimation];
    [self.commentViewController tt_commentTableViewScrollToTop];
}

#pragma mark - 增加下滑手势相关

- (void)addSlideDownOutGesture:(UIViewController *)aimVC orientation:(UIInterfaceOrientation)orientation
{
    if (orientation != UIInterfaceOrientationPortrait && ![TTDeviceHelper isPadDevice]) {
        
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    }
    
    self.direction = kPhotoDetailMoveDirectionNone;
    self.view.hidden = NO;
    //进场动画
    self.originRect = aimVC.view.bounds;
    CGRect enterFrame = self.originRect;
    enterFrame.origin.x += enterFrame.size.width;
    self.view.frame = enterFrame;
    
    [self willMoveToParentViewController:aimVC];
    [aimVC.view addSubview:self.view];
    [aimVC addChildViewController:self];
    [self didMoveToParentViewController:aimVC];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = self.originRect;
        
    } completion:^(BOOL finished) {
        
        //新建提示
        if (!self.tipLabel && [SSCommonLogic appGallerySlideOutSwitchOn]) {
            CGRect frame = CGRectMake(0, -KPhotoCommentTipViewHeight, self.commentViewController.view.frame.size.width, KPhotoCommentTipViewHeight);
            self.tipLabel = [[SSThemedLabel alloc] initWithFrame:frame];
            self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.tipLabel.text = @"下拉关闭评论";
            self.tipLabel.textColorThemeKey = kColorText3;
            self.tipLabel.textAlignment = NSTextAlignmentCenter;
            self.tipLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
            self.commentViewController.commentTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.commentViewController.commentTableView addSubview:self.tipLabel];
            if([self isCurrentOrientationLandScape]) {
                self.tipLabel.hidden = YES;
            }
        }
        
        //准备手势监听
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveGesture:)];
        gesture.delegate = self;
        [self.view addGestureRecognizer:gesture];
        
        [self refreshStatusBar];
    }];
    
}


- (void)handleMoveGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        return;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view.superview];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged: {
            
            [self refreshPhotoViewFrame:translation velocity:velocity];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            
            [self animatePhotoViewWhenGestureEnd];
            
            break;
        }
        default:
            break;
    }
}


//move的动画
- (void)refreshPhotoViewFrame:(CGPoint)translation   velocity:(CGPoint)velocity
{
    if (self.direction == kPhotoDetailMoveDirectionNone) {
        if (translation.y > KPhotoDeMoveDirectionRecognizer) {
            self.direction = kPhotoDetailMoveDirectionVerticalBottom;
        }
    }
    else {
        
        if (![SSCommonLogic appGallerySlideOutSwitchOn] && self.direction == kPhotoDetailMoveDirectionVerticalBottom) {
            return;
        }
        
        CGFloat x = translation.x - KPhotoDeMoveDirectionRecognizer;
        CGFloat y = translation.y - KPhotoDeMoveDirectionRecognizer;
        
        CGFloat yFraction = translation.y / CGRectGetHeight(self.originRect);
        yFraction = fminf(fmaxf(yFraction, 0.0), 1.0);
        
        CGFloat xFraction = translation.x / CGRectGetHeight(self.originRect);
        xFraction = fminf(fmaxf(xFraction, 0.0), 1.0);
        
        if (x < 0) {
            x = 0;
        }
        
        if (y < 0 ) {
            y = 0;
        }
        
        if (self.direction == kPhotoDetailMoveDirectionVerticalBottom) {
            x = 0;
            if (yFraction > 0.2) {
                _reachDismissCondition = YES;
            }
            else {
                _reachDismissCondition  = NO;
            }
            
            if (velocity.y > 1500) {
                _reachDismissCondition = YES;
            }
            
            //纵向状态栏变化
            if (y < 20) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }
            else {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }
        }
        
        
        CGRect frame = CGRectMake(x, y, CGRectGetWidth(self.originRect), CGRectGetHeight(self.originRect));
        self.view.frame = frame;
        
    }
    
}

//释放的动画
- (void)animatePhotoViewWhenGestureEnd
{
    CGRect endRect = self.originRect;
    
    if (_reachDismissCondition) {
        
        if (self.direction == kPhotoDetailMoveDirectionVerticalBottom)
        {
            endRect.origin.y += CGRectGetHeight(self.originRect);
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = endRect;
        
    } completion:^(BOOL finished) {
        self.direction = kPhotoDetailMoveDirectionNone;
        if (_reachDismissCondition) {
            _reachDismissCondition = NO;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            self.view.hidden = YES;
            [self.view removeFromSuperview];
        }
    }];
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

