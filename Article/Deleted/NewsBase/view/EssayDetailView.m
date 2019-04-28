//
//  EssayDetailView.m
//  Article
//
//  Created by Hua Cao on 13-10-20.
//
//

#import "EssayDetailView.h"
#import "EssayContentManager.h"

#import "ArticleTitleImageView.h"

#import "ExploreCellHelper.h"
#import "ExploreArticleEssayCellView.h"
#import "ExploreArticleEssayGIFCellView.h"

#import "SSCommentInputHeader.h"
#import "SSNavigationBar.h"

#import "NewsDetailFunctionView.h"

#import "ExploreItemActionManager.h"
#import <TTAccountBusiness.h>

#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "ArticleShareManager.h"

#import "TTReportManager.h"
#import "ExploreDetailNatantUserActionView.h"

#import "ArticleListNotifyBarView.h"
#import "TTNavigationController.h"

#import "ExploreDetailToolbarView.h"
#import "TTNavigationController.h"

#import "TTNavigationController.h"
#import "ExploreDetailManager.h"
#import "TTIndicatorView.h"
#import "SSUserSettingManager.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTActionSheetController.h"
#import "TTUIResponderHelper.h"
#import "TTAdManager.h"

#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"

// These macros are copied from "NewsDetailView.m"
// Be used to set the frame of AASettingButton
#define kMoreButtonWidth 38
#define kMoreButtonHeight 44
#define kMoreButtonRightPadding 4

typedef enum ShowLoginReason
{
    ShowLoginReasonNone = 0,
    ShowLoginReasonClickWriteComment = 1,
    ShowLoginReasonClickShare = 2,
}ShowLoginReason;


@implementation SSNavigationBar (AASettingButton)

+ (UIButton *) navigationAASettingButtonWithTarget:(id) target action:(SEL) action WithFrame:(CGRect) frame
{
    SSThemedButton * button = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    button.imageName = @"show_title_details.png";
    button.highlightedImageName = @"show_title_details_press.png";
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.frame = frame;
    return button;
}

@end

@interface EssayDetailView () <ExploreCommentViewDelegate, SSActivityViewDelegate, UIPopoverControllerDelegate, SSCommentManagerDelegate>
{
    BOOL _currentIsOpenStatus;//当前是否是打开状态
    NSString * _tag;
}
@property (nonatomic, retain) EssayData * essayData;
@property (nonatomic, assign) BOOL needScrollToComment;
@property (nonatomic, retain) NSString * trackEvent;
@property (nonatomic, retain) NSString * trackLabel;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;

@property(nonatomic,retain)ExploreArticleEssayCellView * essayCellView;
// @property (nonatomic, retain) UIButton * essayCommentButton;

@property (nonatomic, retain) EssayContentManager * essayContentManager;

@property (nonatomic, retain) UIImageView * loadingImageView;
@property (nonatomic, retain) UIActivityIndicatorView * loadingIndicatorView;
@property (nonatomic, retain) UIButton * retryButton;

@property (nonatomic, retain) NewsDetailFunctionView * functionView;

@property (nonatomic, retain) ExploreDetailToolbarView *toolBarView;
@property(nonatomic, retain) ExploreItemActionManager *  itemAction;
@property (nonatomic, retain) TTActivityShareManager *activityActionManager;
@property (nonatomic, retain) SSActivityView * phoneShareView;

// 顶踩按钮的view
@property(nonatomic, retain)ExploreDetailNatantUserActionView * userActionView;

@property(nonatomic, retain)UIPopoverController * padAccountPopOverController;
@property(nonatomic, assign)ShowLoginReason showLoginIfNeededReason;
@property(nonatomic, assign)TTActivityType activityType;

@property(nonatomic, retain)ArticleListNotifyBarView * notInterestNotifyBarView;

@property (nonatomic, retain) UIView * titleBar;

@end

@implementation EssayDetailView

#pragma mark Init & Memory Management
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.essayData removeObserver:self forKeyPath:@"commentCount"];
    [self.essayData removeObserver:self forKeyPath:@"userRepined"];
    self.essayData = nil;
    self.trackEvent = nil;
    self.trackLabel = nil;
    
    self.titleBar = nil;
    [self.essayCommentView unregisterFromImpressionManager];
    self.essayCommentView.commentManager.delegate = nil;
    self.essayCommentView = nil;
    
    self.essayContentManager = nil;
    self.loadingImageView = nil;
    self.loadingIndicatorView = nil;
    self.retryButton = nil;
    self.functionView = nil;
    self.essayCellView = nil;
    self.toolBarView = nil;
    self.itemAction = nil;
    self.activityActionManager = nil;
    self.phoneShareView = nil;
    self.userActionView = nil;
    self.padAccountPopOverController = nil;
    self.notInterestNotifyBarView = nil;
    
}

- (id)initWithFrame:(CGRect)frame
          essayData:(EssayData *)essayData
    scrollToComment:(BOOL)scrollToComment
         trackEvent:(NSString *)trackEvent
         trackLabel:(NSString *)trackLabel {
    //
    self = [super initWithFrame:frame];
    if (self) {
        
        _currentIsOpenStatus = NO;
        self.essayData = essayData;
        self.needScrollToComment = scrollToComment;
        self.trackEvent = trackEvent;
        self.trackLabel = trackLabel;
        
        self.showLoginIfNeededReason = ShowLoginReasonNone;
        self.activityType = TTActivityTypeNone;
        [self setupUI];
        [self reloadThemeUI];
        [self reloadData];
        
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew;
        [essayData addObserver:self forKeyPath:@"commentCount" options:options context:NULL];
        [essayData addObserver:self forKeyPath:@"userRepined" options:options context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontChanged:)
                                                     name:kSettingFontSizeChangedNotification
                                                   object:nil];
        [self bringSubviewToFront:_toolBarView];
        self.toolBarView.commentBadgeValue = [@(essayData.commentCount) stringValue];
        self.toolBarView.collectButton.selected = essayData.userRepined;
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    [self setupNavigationBar];
    [self setupToolBar];
    [self setupDetailView];
}

- (void)setupNavigationBar {
    // 导航栏
    BOOL isPad = [TTDeviceHelper isPadDevice];
    if(isPad) {
        ArticleTitleImageView * titleImageView = [[ArticleTitleImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
        titleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:titleImageView];
        self.titleBar = titleImageView;
        
        SSThemedButton * backButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        backButton.backgroundImageName = @"leftBackButtonBGNormal";
        backButton.highlightedBackgroundImageName = @"leftBackButtonBG_press";
        backButton.imageName = @"leftBackButtonFGNormal";
        backButton.highlightedImageName = @"leftBackButtonFG_press";
        [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        titleImageView.leftView = backButton;
        titleImageView.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleImageView.titleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"fafafa" nightColorName:@"b1b1b1"]];
        [titleImageView setTitleText:NSLocalizedString(@"详情", nil)];
    } else {
        SSNavigationBar * navigationBar = [[SSNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.width, [SSNavigationBar navigationBarHeight])];
        navigationBar.title = NSLocalizedString(@"详情", nil);
        navigationBar.leftBarView = [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(goBack:)];
        CGRect frame = CGRectMake(navigationBar.width - kMoreButtonWidth - kMoreButtonRightPadding,0, kMoreButtonWidth, kMoreButtonHeight);
        navigationBar.rightBarView = [SSNavigationBar navigationAASettingButtonWithTarget:self action: @selector(openAASettingView:) WithFrame: frame];
        
        [self addSubview:navigationBar];
        self.titleBar = navigationBar;
    }
}


#pragma mark -- SSCommentManagerDelegate

- (void)articleInfoManager:(SSCommentManager *)manager refreshCommentsCount:(NSUInteger)commentsCount
{
    self.essayData.commentCount = (int)commentsCount;
    [self.essayData save];
    //[[SSModelManager sharedManager] save:nil];
}


#pragma mark - ExploreCommentView delegate

- (void)commentViewShouldShowWriteCommentView
{
    [self handleWriteCommentButtonPressed];
}

- (void)commentView:(ExploreCommentView *)view scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > view.commentTableView.tableHeaderView.height) {
        if (!_currentIsOpenStatus) {
            wrapperTrackEvent(@"detail", @"pull_open_drawer");
        }
        _currentIsOpenStatus = YES;
    }
    else {
        if (_currentIsOpenStatus) {
            wrapperTrackEvent(@"detail", @"pull_close_drawer");
        }
        _currentIsOpenStatus = NO;
    }
}

// setup toolbar
- (CGRect)frameForToolBar
{
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat width = [[UIApplication sharedApplication] keyWindow].width;
        return CGRectMake((self.width - width)/2, self.frame.size.height - ExploreDetailGetToolbarHeight(), width, ExploreDetailGetToolbarHeight());
    }
    else {
        return CGRectMake(0, self.frame.size.height - ExploreDetailGetToolbarHeight(), self.width, ExploreDetailGetToolbarHeight());
    }
}

- (void)setupToolBar {
    
    ExploreDetailToolbarView *toolBarView = [[ExploreDetailToolbarView alloc] init];
    toolBarView.frame = [self frameForToolBar];
    toolBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    toolBarView.toolbarType = ExploreDetailToolbarTypeNormal;
    toolBarView.viewStyle = TTDetailViewStyleDarkContent;
//    [toolBarView refreshArticle:_essayData];
    
    self.toolBarView = toolBarView;
    [self addSubview:_toolBarView];
    
    [_toolBarView.collectButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBarView.writeButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBarView.commentButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBarView.shareButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    // 段子、美女、趣图 不支持表情输入
    _toolBarView.banEmojiInput = YES;
}

- (void)setupDetailView {
    UIImageView * loadingImageView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"detail_loading.png"]];
    loadingImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    loadingImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:loadingImageView];
    self.loadingImageView = loadingImageView;

    // 评论列表页，将段子内容页作为列表页的 tableHeaderView
    ExploreCommentView * essayCommentView = [[ExploreCommentView alloc] initWithFrame:[self frameForCommentView] commentManager:nil fromEssay:YES];
    essayCommentView.delegate = self;
    essayCommentView.commentManager.delegate = self;
    essayCommentView.isShowRepostEntrance = NO;
    essayCommentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    essayCommentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    essayCommentView.enableInputedScrollToComment = YES;
    essayCommentView.banEmojiInput = YES;
    [self addSubview:essayCommentView];
    self.essayCommentView = essayCommentView;
}


#pragma mark Load Data
- (void)reloadData {
    // loadData
    if (_essayData.content.length>0) {
        _essayCommentView.hidden = NO;
        _toolBarView.hidden = NO;
        // _essayCommentButton.userInteractionEnabled = YES;
        [self showEssayDetail];
    }
    else {
        _essayCommentView.hidden = YES;
        _toolBarView.hidden = YES;
        // _essayCommentButton.userInteractionEnabled = NO;
        
        // indicator view
        if(!_loadingIndicatorView)
        {
            self.loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _loadingIndicatorView.center = CGPointMake(self.width / 2, _loadingImageView.top - 10);
            _loadingIndicatorView.hidesWhenStopped = YES;
            [self addSubview:_loadingIndicatorView];
        }
        [self bringSubviewToFront:_loadingIndicatorView];
        [_loadingIndicatorView startAnimating];

        // retry button
        if(!_retryButton)
        {
            self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_retryButton setBackgroundImage:[UIImage themedImageNamed:@"btn_tryagain.png"] forState:UIControlStateNormal];
            [_retryButton setBackgroundImage:[UIImage themedImageNamed:@"btn_tryagain_press.png"] forState:UIControlStateHighlighted];
            [_retryButton setTitle:NSLocalizedString(@"重试", nil) forState:UIControlStateNormal];
            [_retryButton setTitleColor:[UIColor colorWithHexString:@"888888"] forState:UIControlStateNormal];
            _retryButton.frame = CGRectMake(0, 0, 60, 30);
            CGRect retryRect = _retryButton.frame;
            if(_loadingImageView)
            {
                retryRect.origin.y = CGRectGetMaxY(_loadingImageView.frame) + 15;
            }
            else
            {
                retryRect.origin.y = self.frame.size.height/2 - retryRect.size.height/2;
            }
            
            _retryButton.frame = retryRect;
            _retryButton.center = CGPointMake(self.frame.size.width/2, _retryButton.center.y);
            [_retryButton addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_retryButton];
        }
        _retryButton.hidden = YES;

        
        // essay content manager
        self.essayContentManager = [[EssayContentManager alloc] init];
        __block EssayDetailView * weakSelf = self;
        [_essayContentManager setDidFinishCallback:^(NSDictionary * result){
            [weakSelf.essayData updateWithDictionary:result];
            [weakSelf showEssayDetail];
            weakSelf.essayCommentView.hidden = NO;
            // weakSelf.essayCommentButton.userInteractionEnabled = YES;
            weakSelf.toolBarView.hidden = NO;
            [weakSelf.loadingIndicatorView stopAnimating];
        }];
        [_essayContentManager setDidFailCallback:^(NSError * error){
            NSString * msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
            [weakSelf displayFailMessage:msg];
            [weakSelf.loadingIndicatorView stopAnimating];
            [weakSelf bringSubviewToFront:weakSelf.retryButton];
            [weakSelf.retryButton setHidden:NO];
        }];
        
        [_essayContentManager tryLoadContentWithEssayGroupID:@(_essayData.uniqueID).stringValue];
    }
}

- (void)refreshData {
    [self reloadData];
}

- (void)layoutTableHeaderView
{
    CGFloat width = _essayCommentView.width;
    CGFloat cellHeight = [ExploreArticleEssayCellView heightWithActionButtonsForEssayData:_essayData cellWidth:width];
    _essayCellView.frame = CGRectMake(0, 0, width, cellHeight);
    [_essayCellView refreshUIForEssayDetailView];
   CGSize size = _userActionView.frame.size;
    _userActionView.frame = CGRectMake(0, cellHeight, size.width, size.height);
    UIView *header = _essayCommentView.commentTableView.tableHeaderView;
    header.frame = CGRectMake(0, 0, width, cellHeight+_userActionView.height);
    _essayCommentView.commentTableView.tableHeaderView = header;
}

// 段子详情已获取的情况下调用此方法
- (void)showEssayDetail {
    CGFloat width = _essayCommentView.width;
    CGFloat cellHeight = [ExploreArticleEssayCellView heightWithActionButtonsForEssayData:_essayData cellWidth:width];
    
    if (!self.essayCellView)
    {
        ExploreArticleEssayCellView * essayCellView;
        BOOL isGIF = ([_essayData.groupFlags integerValue] & ArticleGroupFlagsTypeGif);
        if (isGIF) {
            essayCellView = [[ExploreArticleEssayGIFCellView alloc] initWithFrame:CGRectMake(0, 0, width, cellHeight)];
        } else {
            essayCellView = [[ExploreArticleEssayCellView alloc] initWithFrame:CGRectMake(0, 0, width, cellHeight)];
        }
        
        essayCellView.from = EssayCellStyleDetail;
        self.essayCellView = essayCellView;
        self.essayCellView.autoresizingMask = UIViewAutoresizingNone;
    }
    _essayCellView.trackEventName = _trackEvent;
    _essayCellView.trackLabelPrefix = _trackLabel;
    [_essayCellView refreshWithEssayData:_essayData];
    
    if (!self.userActionView) {
        ExploreDetailNatantUserActionView *userActionView = [[ExploreDetailNatantUserActionView alloc] initWithWidth:self.frame.size.width];
        userActionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.userActionView = userActionView;
    }
    [_userActionView.digButton refreshWithArticle:_essayData adID:nil];
    [_userActionView.buryButton refreshWithArticle:_essayData adID:nil];
    [_userActionView.digButton refresh];
    [_userActionView.buryButton refresh];

    UIView * tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    _essayCommentView.commentTableView.tableHeaderView = tableHeaderView;

    [tableHeaderView addSubview:_essayCellView];
    [tableHeaderView addSubview:_userActionView];

    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:[@(_essayData.uniqueID) stringValue]];
    
    [_essayCommentView.commentManager tryLoadCommentWithGroupModel:groupModel
                                                          userInfo:nil];    
    if (_needScrollToComment) {
        _needScrollToComment = NO;
        [self scrollToCommentAnimated:NO];
    }
    
    if (![_essayData.hasRead boolValue]) {
        _essayData.hasRead = @(YES);
        [_essayData save];
        //[[SSModelManager sharedManager] save:nil];
    }
    
    [self setNeedsLayout];
}

- (void)displayFailMessage:(NSString*)msg
{
    if(isEmptyString(msg)) msg = NSLocalizedString(@"网络连接失败", nil);
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
}

#pragma mark Frame
- (CGRect)frameForCommentView
{
    return CGRectMake(0, _titleBar.height, self.width, self.height - _titleBar.height - _toolBarView.height);
}

#pragma mark Actions
- (void)goBack:(id)sender {
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
    [topController.navigationController popViewControllerAnimated:YES];
}

- (void)writeCommentButtonClicked {
    
    NSString * gID = [NSString stringWithFormat:@"%lld", _essayData.uniqueID];
    
    BOOL banComment = [_essayData respondsToSelector:@selector(bannComment)] ? [[_essayData performSelector:@selector(bannComment)] boolValue] : NO;

    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:gID];
    [_essayCommentView openInputViewWithContent:nil inputTitle:sDefaultTitle groupModel:groupModel commentID:nil itemTag:nil itemBannComment:banComment];
    wrapperTrackEvent(@"detail", @"write_button");
    wrapperTrackEvent(@"comment", @"input_comment");
}

- (void)openAASettingView:(id) sender {
    
    if(!_functionView)
    {
        self.functionView = [[NewsDetailFunctionView alloc] initWithFrame:CGRectMake(0, 0, self.width, 174)];
        _functionView.dismissAfterChangeSetting = YES;
    }
    
    if(![_functionView isDisplay])
    {
        [_functionView showInView:self atPoint:CGPointMake(0,  self.height - _functionView.height)];
        [_functionView.superview bringSubviewToFront:_functionView];
    }
    wrapperTrackEvent(@"detail", @"preferences");
}

//现有逻辑应该走不到，加上防止crash
- (void)retry
{
    [self reloadData];
}

#pragma mark Layout
- (void)layoutSubviews {
    [super trySSLayoutSubviews];
    [self layoutTableHeaderView];
    if ([TTDeviceHelper isPadDevice]) {
        _toolBarView.frame = [self frameForToolBar];
    }
}

- (void)ssLayoutSubviews {
    [super ssLayoutSubviews];
}

#pragma mark Theme
- (void)themeChanged:(NSNotification *)notification {
    _essayCommentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

#pragma mark Font
- (void)fontChanged:(NSNotification *)notification {
    [self.essayCellView fontSizeChanged];
    
    [self layoutTableHeaderView];
}

#pragma mark Public
- (void)scrollToCommentWithAnimation {
    [self scrollToCommentAnimated:YES];
}
- (void)scrollToCommentAnimated:(BOOL)animated {
    [self.essayCommentView scrollToTopCommentAnimated:animated];
}

- (void)displayMessage:(NSString*)msg
{
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:nil autoDismiss:YES dismissHandler:nil];
}

- (void)changeFavoriteButtonClicked
{
    if (!_itemAction) {
        self.itemAction = [[ExploreItemActionManager alloc] init];
    }
    
    if (!_essayData.userRepined) {
        [_itemAction favoriteForOriginalData:_essayData adID:nil finishBlock:nil];
    }
    else {
        [_itemAction unfavoriteForOriginalData:_essayData adID:nil finishBlock:nil];
    }
    if(_essayData.userRepined)
    {
        NSString * tipMsg = NSLocalizedString(@"收藏成功", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
        }
    }
    else
    {
        NSString * tipMsg = NSLocalizedString(@"取消收藏", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if ((!isEmptyString(tipMsg))) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
        }
    }
}

- (void)shareButtonClicked
{
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
    }
    
    NSMutableArray * activityItems = [ArticleShareManager essayActivitysForManager:_activityActionManager essayData:_essayData];
    

    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:@"0" groupId:@(_essayData.uniqueID).stringValue];
    [_phoneShareView showOnViewController:[TTUIResponderHelper topViewControllerFor: self]];
    
    [self sendEssayShareTrackWithItemType:TTActivityTypeShareButton souceType:TTShareSourceObjectTypeArticle tag:nil];
}

- (void)moreButtonClicked
{
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
    }
    
    NSMutableArray * activityItems = [ArticleShareManager essayActivitysForManager:_activityActionManager essayData:_essayData];
    
//    TTActivity * favorite = [TTActivity activityOfFavorite];
//    [activityItems addObject:favorite];
    TTActivity * nightMode = [TTActivity activityOfNightMode];
    [activityItems addObject:nightMode];
    TTActivity * fontSetting = [TTActivity activityOfFontSetting];
    [activityItems addObject:fontSetting];
    TTActivity * reportActivity = [TTActivity activityOfReport];
    [activityItems addObject:reportActivity];
 
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:@"0" groupId:@(_essayData.uniqueID).stringValue];
    [_phoneShareView showOnViewController:[TTUIResponderHelper topViewControllerFor: self]];
    
    [self sendEssayShareTrackWithItemType:TTActivityTypeShareButton souceType:TTShareSourceObjectTypeArticleTop tag:nil];
   
}
-(void)reportButtonClicked {
    wrapperTrackEvent(@"detail", @"report_button");
    wrapperTrackEvent(@"detail", @"report");
    [self reportEssay];
}

-(void)commentButtonClicked
{
    static BOOL needScrollToComment = YES;
    
    if (needScrollToComment)
    {
        [_essayCommentView scrollToTopCommentAnimated:YES];
        needScrollToComment = NO;
        wrapperTrackEvent(@"detail", @"handle_open_drawer");
    }
    else
    {
        [_essayCommentView scrollToTopHeaderAnimated:YES];
        needScrollToComment = YES;
        wrapperTrackEvent(@"detail", @"handle_close_drawer");
    }
}

- (void)handleWriteCommentButtonPressed
{
    self.showLoginIfNeededReason = ShowLoginReasonClickWriteComment;
    
    [self writeCommentButtonClicked];
}

- (void)toolBarButtonClicked:(id)sender
{
    if (sender == _toolBarView.collectButton) {
        if (!TTNetworkConnected()){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            return;
        }
        _toolBarView.collectButton.imageView.contentMode = UIViewContentModeCenter;
        _toolBarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _toolBarView.collectButton.alpha = 1.f;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            _toolBarView.collectButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            _toolBarView.collectButton.alpha = 0.f;
        } completion:^(BOOL finished){
            [self changeFavoriteButtonClicked];
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                _toolBarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                _toolBarView.collectButton.alpha = 1.f;
            } completion:^(BOOL finished){
            }];
        }];
    }
    else if (sender == _toolBarView.writeButton) {
        [self handleWriteCommentButtonPressed];
    }
    else if (sender == _toolBarView.commentButton) {
        [self commentButtonClicked];
    }
    else if (sender == _toolBarView.shareButton) {
        self.showLoginIfNeededReason = ShowLoginReasonClickShare;
        [self shareButtonClicked];
    }
}

#pragma mark -- Track

- (void)sendEssayShareTrackWithItemType:(TTActivityType)itemType souceType:(TTShareSourceObjectType)type tag:(NSString*)tag
{
    //段子详情页，需要给SSShareSourceObjectTypeArticle类型
    if (tag) {
        _tag = tag;
    }
    else {
        _tag = [TTActivityShareManager tagNameForShareSourceObjectType:type];
    }
    NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
    NSString *essayId = [NSString stringWithFormat:@"%lld", _essayData.uniqueID];
    wrapperTrackEventWithCustomKeys(_tag, label, essayId, nil, nil);
}

#pragma mark -- SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    self.activityType = itemType;
    if (view == _phoneShareView) {
        if (itemType == TTActivityTypeReport) {
            NSString *groupId = [NSString stringWithFormat:@"%lld", self.essayData.uniqueID];
            TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:groupId];
            self.actionSheetController = [[TTActionSheetController alloc] init];
            [self.actionSheetController insertReportArray:[TTReportManager reportEssayOptions]];
            [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
                if (parameters[@"report"]) {
                    TTReportContentModel *model = [[TTReportContentModel alloc] init];
                    model.groupID = groupModel.groupID;
                    model.itemID = groupModel.itemID;
                    model.aggrType = @(groupModel.aggrType);
                    [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeEssay reportFrom:TTReportFromByEnterFromAndCategory(nil, self.trackLabel) contentModel:model extraDic:nil animated:YES];
                }
            }];
        }
        else if (itemType == TTActivityTypeNightMode){
            NSString *tag = @"detail";
            BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
            NSString * eventID = nil;
            if (isDayMode){
                [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeNight];
                eventID = @"click_to_night";
            }
            else{
                [[TTThemeManager sharedInstance_tt] switchThemeModeto:TTThemeModeDay];
                eventID = @"click_to_day";
            }
            wrapperTrackEvent(tag, eventID);
            //做一个假的动画效果 让夜间渐变
            UIView * imageScreenshot = [self.window snapshotViewAfterScreenUpdates:NO];
            
            [self.window  addSubview:imageScreenshot];
            
            [UIView animateWithDuration:0.5f animations:^{
                imageScreenshot.alpha = 0;
            } completion:^(BOOL finished) {
                [imageScreenshot removeFromSuperview];
            }];
        }
        else if (itemType == TTActivityTypeFontSetting){

            [self.phoneShareView fontSettingPressed];

        }
        else if (itemType == TTActivityTypeFavorite) {
            [self changeFavoriteButtonClicked];
        }
        else {
            NSString *groupId = [NSString stringWithFormat:@"%lld", self.essayData.uniqueID];
            [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor: self] sourceObjectType:TTShareSourceObjectTypeEssay uniqueId:groupId];
            [self sendEssayShareTrackWithItemType:itemType souceType:-1 tag:_tag];
        }
    }
}

// ToDo by luohuaqing: 目前段子详情页不支持“Report button”，只是做一个效果
- (void)reportEssay
{
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld", _essayData.uniqueID]];
    
    self.actionSheetController = [[TTActionSheetController alloc] init];
    
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        if (parameters[@"report"]) {
            TTReportContentModel *model = [[TTReportContentModel alloc] init];
            model.groupID = groupModel.groupID;
            model.itemID = groupModel.itemID;
            model.aggrType = @(groupModel.aggrType);
            [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeEssay reportFrom:TTReportFromByEnterFromAndCategory(nil, self.trackLabel) contentModel:model extraDic:nil animated:YES];
        }
    }];
}

#pragma mark -- UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(![TTAccountManager isLogin])
    {
        wrapperTrackEvent(@"login", @"login_pop_close");
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    void (^handle)(void) = ^{
        if ([object isKindOfClass:[EssayData class]]) {
            EssayData *essay = (EssayData *)object;
            self.toolBarView.collectButton.selected = essay.userRepined;
            self.toolBarView.commentBadgeValue = [@(essay.commentCount) stringValue];
        }
    };
    if ([NSThread isMainThread]) {
        handle();
    } else {
        dispatch_async(dispatch_get_main_queue(), handle);
    }
}

@end
