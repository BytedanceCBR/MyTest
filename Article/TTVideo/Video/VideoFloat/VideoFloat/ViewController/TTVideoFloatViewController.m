
#import "TTVideoFloatViewController.h"
#import "TTVideoFloatViewModel.h"
#import "TTVideoFloatProtocol.h"
#import "TTVideoFloatDataSource.h"
#import "TTTableFacility.h"
#import "UIViewController+NavigationBarStyle.h"
#import "ExploreDetailManager.h"
#import "TTVideoFloatParameter.h"
#import "SSThemed.h"
#import "ExploreMovieView.h"
#import "NSObject+FBKVOController.h"
#import "ExploreVideoDetailHelper.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTVideoFloatTopBar.h"
#import "TTIndicatorView.h"
#import "NewsDetailConstant.h"
#import "TTVideoFloatViewController+Share.h"
#import "TTVideoFloatViewController+Action.h"
#import "TTVideoFloatSingletonTransition.h"
#import "ExploreCellHelper.h"
#import "TTSharedViewTransition.h"
#import "TTVideoFloatViewController+Impression.h"
#import "FRPageStayManager.h"
#import "TTModuleBridge.h"
#import "NetworkUtilities.h"
#import "TTReachability.h"
#import "TTVideoFloatViewController+Gesture.h"
#import "TTMovieViewCacheManager.h"
#import "TTVideoTip.h"
#import "ExploreOrderedData+TTAd.h"

#define kTopInViewLength 250
#define kBottomInViewLength 70

@implementation TTHittestTableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self.hit_delegate respondsToSelector:@selector(tt_hitTest:withEvent:)]) {
        [self.hit_delegate tt_hitTest:point withEvent:event];
    }
    return [super hitTest:point withEvent:event];
}

@end


typedef NS_ENUM(NSUInteger, TTUserChooseNetwork) {
    TTUserChooseNetwork_unkown,
    TTUserChooseNetwork_play,
    TTUserChooseNetwork_dontPlay,
};
@interface TTVideoFloatViewController ()<TTVideoFloatProtocol ,
ExploreMovieViewDelegate,
ExploreDetailManagerDelegate,
FRPageStayManagerDelegate,
TTHittestTableViewDelegate,
TTDataSourceDelegate,
TTSectionDataSourceDelegate,
TTBaseCellAction>
@property (nonatomic) TTVideoFloatViewModel *table_viewModel;
@property (nonatomic) TTVideoFloatDataSource  *table_dataSource;
@property(nonatomic)TTTableFacility *tableFacility;
@property(nonatomic, strong) TTHittestTableView *tableView;
@property (nonatomic, assign) BOOL movieViewInitiated;
@property (nonatomic, assign) CGPoint lastOffset;
@property (nonatomic, strong) TTVideoFloatCell *toPlayCell;
@property (nonatomic, strong) TTVideoFloatCell *prePlayCell;
@property (nonatomic, strong) NSIndexPath *preIndexPath;
@property (nonatomic, strong) ArticleVideoPosterView *firstMovieShotView;
@property (nonatomic, strong) TTVideoFloatTopBar *topView;
@property (nonatomic, strong) TTDetailModel *currentDetailModel;
@property (nonatomic, assign) __block BOOL canPlay;
@property (nonatomic, strong, nullable) TTActivityShareManager *activityActionManager;
@property(nonatomic ,strong) SSThemedView *containerView;

@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isMainVideoFirstPlay;
@property (nonatomic, assign) TTUserChooseNetwork chooseNetwork;
@property (nonatomic, assign) BOOL isPlayButtonClicked;
@property (nonatomic, assign) BOOL timeLessThanFiveSecond;
@property (nonatomic, assign) BOOL isAutoScroll;
@property (nonatomic, assign) BOOL decelerate;
@property (nonatomic, strong) NSIndexPath *nextIndexPath;
@property (nonatomic, assign) CGPoint targetContentOffset;
@property (nonatomic, assign) BOOL hasPlayEndMainVideo;
@end

@implementation TTVideoFloatViewController
- (void)dealloc
{
    [self.movieView stopMovie];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTabbarShowTipNotification" object:nil];
    LOGD(@"TTVideoFloatViewController dealloc");
    [self expression_setIsViewAppear:NO];

    [self removeObserver];
    [self removeMovieViewObserver];
    [self tt_invalideMovieView];
    [self impressionDealloc];
    [self hiddenStatusbar:NO animated:NO];
}

- (instancetype)initWithDetailViewModel:(TTDetailModel *)model
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSDictionary *params = model.baseCondition;
        self.canImmerse = YES;
        self.detailModel = model;
        self.detailModel.orderedData = [self orderedData];
        self.currentDetailModel = model;
        self.ttHideNavigationBar = YES;
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
        self.preIndexPath = [NSIndexPath indexPathForRow:1000 inSection:0];//开始不能为0-0;
        self.chooseNetwork = TTUserChooseNetwork_unkown;
        self.shareMovie = params[@"movie_shareMovie"];
        [self configMovieView:self.shareMovie.movieView];
        [self settingMovieShotView:self.shareMovie.posterView];
        if (!self.shareMovie) {
            self.shareMovie = [[TTVideoShareMovie alloc] init];
        }
        if (!self.movieShotView) {
            [self addMovieShotView];
        }
        [self actionInit];

    }
    return self;
}

- (void)addMovieShotView
{
    [self settingMovieShotView:[[ArticleVideoPosterView alloc] init]];
    [self movieShotView].isAD = NO;
    [self movieShotView].showSourceLabel = YES;
    [self movieShotView].showPlayButton = YES;
    if (!self.firstMovieShotView) {
        _firstMovieShotView = [self movieShotView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstAppearAndShowing = YES;
    self.isMainVideoFirstPlay = YES;
    self.view.backgroundColor = [UIColor colorWithHexString:kFloatVideoCellBackgroundColor];
    _containerView = [[SSThemedView alloc] init];
    _containerView.frame = self.view.bounds;

    _containerView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_containerView];
    [self addObserver];

    {
        _topView = [[TTVideoFloatTopBar alloc] init];
        _topView.frame = CGRectMake(0, 0, self.view.width, 44 + 20);
        _topView.backgroundColor = [UIColor clearColor];
        [_topView.backButton addTarget:self action:@selector(tt_topViewBackButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }

    {
        self.tableView = [[TTHittestTableView alloc] initWithFrame:self.view.bounds];
        self.tableView.hit_delegate = self;
        self.tableView.backgroundColor = self.view.backgroundColor;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.separatorColor = [UIColor colorWithHexString:@"0x252525"];
        self.tableView.contentInset = UIEdgeInsetsMake(_topView.bottom, 0, 150, 0);
        self.tableView.frame = self.view.bounds;

    }

    [self.containerView addSubview:self.tableView];
    [self.containerView addSubview:_topView];
    [self loadData];
    [self impressionViewDidLoad];
    [self addGesture];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self expression_setIsViewAppear:YES];
    if (self.movieView) {
        [self.movieView willAppear];
        if (self.shareMovie.hasClickRelated && !self.shareMovie.hasClickPrePlay) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self tt_playButtonClicked];
            });
        }
        else
        {
            [self configMovieView:_shareMovie.movieView];
            [self.movieView hiddenMiniSliderView:YES];
            if (!TTNetworkConnected()) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else
            {
                if (self.movieView.isPlayingWhenBackToFloat) {
                    [self.movieView resumeMovie];
                }
            }

            if (self.toPlayCell) {
                if ([self isFrirstCell]) {
                    self.movieView.tracker.type = ExploreMovieViewTypeVideoFloat_main;
                }
                else
                {
                    self.movieView.tracker.type = ExploreMovieViewTypeVideoFloat_related;
                    [self.movieView.tracker addExtraValue:[NSString stringWithFormat:@"%ld",[self.tableView indexPathForCell:self.toPlayCell].row] forKey:@"rank"];
                }
            }
            if (self.movieView.superview != self.movieShotView) {
                [self.movieShotView addSubview:self.movieView];
            }
            [self.toPlayCell addMovieView:self.movieShotView];
            [self.movieShotView refreshUI];
        }
    }
    self.shareMovie.hasClickPrePlay = NO;
    self.shareMovie.hasClickRelated = NO;
    self.movieView.isPlayingWhenBackToFloat = NO;
    [self immerseHalfTimer];
    [self showMiniSlider:NO];
    [self affirmTrackType];
    self.movieView.shouldShowNewFinishUI = NO;
}

- (void)showMiniSlider:(BOOL)show
{
    [self.movieView.moviePlayerController.controlView setHiddenMiniSliderView:!show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.movieView didAppear];

}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.movieView didDisappear];
    if (self.action != TTVideoFloatCellAction_Comment) {
        [self.movieView pauseMovie];
    }
    [self expression_setIsViewAppear:NO];
    [self hiddenStatusbar:NO animated:NO];
    [self showMiniSlider:YES];
    self.movieView.shouldShowNewFinishUI = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.movieView willDisappear];
    [self.immerseTimer invalidate];
    self.immerseTimer = nil;
    [self removeMovieViewObserver];
}


- (TTVideoFloatParameter *)parameter
{
    
    TTVideoFloatParameter *parameter = [[TTVideoFloatParameter alloc] init];
    Article *article = self.detailModel.article;
    NSString *cateoryID = self.detailModel.categoryID;
    if (article.groupModel) {
        parameter.groupModel = article.groupModel;
    }
    if ([[article.comment allKeys] containsObject:@"comment_id"]) {
        parameter.comment_id = [article.comment objectForKey:@"comment_id"];
    }
    
    NSString *videoSubjectID = [self.detailModel.article videoSubjectID];
    if (videoSubjectID && [self.detailModel isFromList]) {
        parameter.videoSubjectID = videoSubjectID;
    }
    
    // 转载推荐评论ids
    NSString *zzCommentsID = [article zzCommentsIDString];
    if (!isEmptyString(zzCommentsID)) {
        parameter.zzids = zzCommentsID;
    }
    
    //待确定逻辑
    ExploreOrderedData *orderedData = [self orderedData];
    parameter.ad_id = orderedData.ad_id;
    parameter.cateoryID = cateoryID;
    parameter.from = self.detailModel.gdLabel;
    parameter.flags = @(0x40);
    parameter.article_page = @(1);
    return parameter;
}

- (Article *)currentCellArticle
{
    return self.toPlayCell.cellEntity.article;
}

- (void)showVideoTrack:(TTVideoFloatCell *)cell
{
    Article *article = cell.cellEntity.article;
    if (!cell.cellEntity.showed) {
        wrapperTrackEventWithCustomKeys(@"video_float", @"show", article.groupModel.groupID, article.groupModel.itemID, [[self class] baseExtraWithArticle:article]);
    }
    cell.cellEntity.showed = YES;
}

- (void)hiddenStatusbar:(BOOL)hidden animated:(BOOL)animated
{
    if ([self.movieView isMovieFullScreen]) {
        return;
    }
    [_topView hidden:hidden animated:animated];
}

- (void)unimmerseHalfWithCell:(TTVideoFloatCell *)cell
{
    if (cell) {
        [cell unImmerseHalf];
        [self hiddenStatusbar:NO animated:YES];
    }
}

- (void)immerseHalf
{
    if ((self.toPlayCell.indexPath.row == [self.tableView numberOfRowsInSection:0] - 1 && [self.movieView isPlayingFinished])
        || self.timeLessThanFiveSecond
        || [self.toPlayCell isImmersed]) {
        return;
    }
    [self hiddenStatusbar:YES animated:YES];
    NSArray *cells = [self.tableView visibleCells];
    for (TTVideoFloatCell *cell in cells) {
        if (cell == self.toPlayCell) {
            [cell immerseHalf];
        }
    }
    
}

- (void)loadData
{
    if (!self.tableFacility) {
        TTTableConfigure *configure = [[TTTableConfigure alloc] init];
        configure.dataSourceClass = [TTVideoFloatDataSource class];
        configure.viewModelClass = [TTVideoFloatViewModel class];
        self.tableFacility = [[TTTableFacility alloc] initWithTableView:self.tableView tableConfigure:configure tableDelegate:self];
        [self.tableFacility refreshTableWithData:self.detailModel.article];
        self.table_viewModel = (TTVideoFloatViewModel *)self.tableFacility.viewModel;
        self.table_viewModel.detailModel = self.detailModel;
    }
    
    if (!self.detailModel.isArticleReliable) {
        return;
    }
    WeakSelf;
    [self.tableFacility refreshDataWithParameter:[self parameter] finished:^(TTTableViewModel *viewModel) {
        StrongSelf;
        self.canPlay = YES;
        TTVideoFloatCell *firstCell = nil;
        if ([self.tableView numberOfRowsInSection:0] >= 1) {
            firstCell  = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            firstCell.cellEntity.showed = YES;
        }
        if (self.movieView.moviePlayerController.controlView.tipViewType == ExploreMoviePlayerControlViewTipTypeLoading) {
            [self.movieView showLoadingView:ExploreMoviePlayerControlViewTipTypeLoading];
        }
    } error:^(NSError *error) {
        StrongSelf;
        wrapperTrackEventWithCustomKeys(@"video_float", @"related_failed", [self currentCellArticle].groupModel.groupID, [self currentCellArticle].groupModel.itemID, [[self class] baseExtraWithArticle:[self currentCellArticle]]);
    }];
}


- (void)tt_cellAction:(NSUInteger)action object:(TTVideoFloatCellEntity *)object callbackBlock:(TTCellActionCallback)callbackBlock
{
    [self doAction:action withCellEntity:object callbackBlock:callbackBlock];
    
}

- (void)clickToPlay
{
    if (self.chooseNetwork == TTUserChooseNetwork_dontPlay) {
        if (![self.movieView isPlaying])
        {
            if ([self.movieView isPaused])
            {
                [self.movieView resumeMovie];
            }
            else
            {
                [self tt_playButtonClicked];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self unimmerseHalfWithCell:self.toPlayCell];
    [self immerseHalfTimer];
    [self clickToPlay];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //willDisplayCell在9.3.1中做UI布局会出问题,autoLayout中调用的willDisplayCell
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StrongSelf;
        if (!self.toPlayCell) {
            if (indexPath.row == 0)
            {
                self.toPlayCell = (TTVideoFloatCell *)cell;
                [self.toPlayCell unImmerseAll];
                if (self.movieView) {
                    if (!self.movieView.superview) {
                        [self.movieShotView addSubview:self.movieView];
                    }
                    [self.movieShotView refreshWithArticle:[self currentCellArticle]];
                    self.movieView.pasterADEnableOptions = 0;
                    [self.toPlayCell addMovieView:self.movieShotView];
                }
                else
                {
                    [self playNext];
                    [self unimmerseHalfWithCell:self.toPlayCell];
                }
                [self immerseHalfTimer];
                self.toPlayCell.cellEntity.showed = YES;
            }
        }
        [self expression_tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    });
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self showVideoTrack:(TTVideoFloatCell *)cell];
    [self expression_tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    LOGD(@"scrollViewWillBeginDragging");
    self.isDragging = YES;
    self.isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    LOGD(@"scrollViewDidEndDragging willDecelerate %d",decelerate);

    self.isDragging = NO;
    if (!decelerate) {
        [self playNext];
        self.targetContentOffset = CGPointZero;
    }
    self.decelerate = decelerate;

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint targetOffset = CGPointMake(targetContentOffset->x, targetContentOffset->y);
    LOGD(@"scrollViewWillEndDragging withVelocity %@ targetContentOffset %@",NSStringFromCGPoint(velocity),NSStringFromCGPoint(CGPointMake(targetContentOffset->x, targetContentOffset->y)));

    if (fabs(velocity.y) <= 0) {
        return;
    }
    UITableView *tableView = (UITableView *)scrollView;
    if ([scrollView isKindOfClass:[UITableView class]]) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];

        if (fabs(targetOffset.y - scrollView.contentOffset.y) > rect.size.height + 10) {
//            CGRect currentRect = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//            CGFloat cellHeight = currentRect.size.height;
//            NSInteger cellIndex = floor(targetOffset / cellHeight);
//
//            // Round to the next cell if the scrolling will stop over halfway to the next cell.
//            if ((targetOffset - (floor(targetOffset / cellHeight) * cellHeight)) > cellHeight) {
//                cellIndex++;
//            }
//
//            // Adjust stopping point to exact beginning of cell.
//            targetContentOffset->y = cellIndex * cellHeight - (CGRectGetHeight(self.tableView.frame) - cellHeight) / 2;

            LOGD(@"scrollViewWillEndDragging targetContentOffset %@",NSStringFromCGPoint(*targetContentOffset));
            CGRect targetRect = rect;
            while (!CGRectContainsPoint(targetRect, targetOffset)) {
                indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
                if (indexPath.row < [tableView numberOfRowsInSection:0]) {
                    CGRect currentRect = [tableView rectForRowAtIndexPath:indexPath];
                    targetRect.origin.y += targetRect.size.height;
                    targetRect.size.height = currentRect.size.height;
                }
                else
                {
                    return;
                }
            }
//            if (CGRectContainsPoint(CGRectMake(targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height / 2), targetOffset))//前半部分包含
            {
                targetOffset.y = targetOffset.y - (fabs(targetOffset.y - targetRect.origin.y)) - (tableView.bounds.size.height - targetRect.size.height) / 2.0;
                targetContentOffset->y = targetOffset.y;
            }
//            else
//            {
//                indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
//                if (indexPath.row < [tableView numberOfRowsInSection:0]) {
//                    CGRect currentRect = [tableView rectForRowAtIndexPath:indexPath];
//                    targetRect.origin.y += targetRect.size.height;
//                    targetRect.size.height = currentRect.size.height;
//                    targetOffset.y = targetOffset.y + (CGRectGetHeight(targetRect) - fabs(targetOffset.y - targetRect.origin.y)) + (tableView.bounds.size.height - targetRect.size.height) / 2.0;
//                    targetContentOffset->y = targetOffset.y;
//                }
//            }
            self.targetContentOffset = targetOffset;

        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    LOGD(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.targetContentOffset = CGPointZero;
    self.decelerate = YES;
    LOGD(@"scrollViewDidEndDecelerating");
    [self playNext];
    self.isScrolling = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.targetContentOffset = CGPointZero;
    self.decelerate = YES;
    LOGD(@"scrollViewDidEndScrollingAnimation");
    [self playNext];
    self.isScrolling = NO;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isAutoScroll)
    {
        [self autoplayNextWithScrollView:scrollView];
    }
    else
    {
        [self playNextWithScrollView:scrollView];
    }
    self.isAutoScroll = NO;
}

- (void)playNext
{
    self.movieShotView.hidden = NO;
    LOGD(@"%ld %ld",[self.tableView indexPathForCell:self.toPlayCell].row,self.preIndexPath.row);
    if ([self.tableView indexPathForCell:self.toPlayCell].row == self.preIndexPath.row) {
        LOGD(@"indexPath == preIndexPath");
        if (self.prePlayCell == self.toPlayCell) {
            if ([self.movieView isPaused]) {
                [self.movieView.moviePlayerController.controlView setToolBarHidden:NO needAutoHide:NO];
            }
        }
        else
        {
            LOGD(@"self.toPlayCell != self.prePlayCell");
            if ([self.movieView isPaused]) {
                LOGD(@"[self tt_playMovie] TTMoviePlaybackStateStopped");
                [self tt_playMovie];
            }
            else{
                [self.movieView resumeMovie];
            }
        }
    }
    else
    {
        if ([self.movieView isPlaying]) {
            [self.movieView stopMovie];
        };
        LOGD(@"[self tt_playMovie]");
        [self tt_playMovie];
    }
}

//scrollTo
- (void)autoplayNextWithScrollView:(UIScrollView *)scrollView
{
    if (!self.canPlay) {
        self.lastOffset = scrollView.contentOffset;
        return;
    }

    TTVideoFloatCell *nextToPlayCell = nil;
    BOOL hasPlayedCell = NO;

    if (self.nextIndexPath.row <= [self.tableView numberOfRowsInSection:0]) {
        nextToPlayCell = [self.tableView cellForRowAtIndexPath:self.nextIndexPath];
        hasPlayedCell = YES;
    }

    self.movieShotView.hidden = hasPlayedCell ? NO : YES;
    [self playNextCell:nextToPlayCell];
}

- (void)playNextWithScrollView:(UIScrollView *)scrollView
{
    if (!self.canPlay) {
        self.lastOffset = scrollView.contentOffset;
        return;
    }
    
    NSArray *cells = [self.tableView visibleCells];

    TTVideoFloatCell *nextToPlayCell = nil;
    BOOL hasPlayedCell = NO;
    if (scrollView.contentOffset.y > self.lastOffset.y) {//index 增大方向 tableview上滑

        NSArray *revertCells = [[cells reverseObjectEnumerator] allObjects];

        for (TTVideoFloatCell *cell in revertCells) {
            if (cell.indexPath.row == self.movieShotView.index) {
                hasPlayedCell = YES;
            }
            CGRect rect = [cell.superview convertRect:cell.frame toView:self.view];
            if (CGRectGetMaxY(rect) <= self.view.height + kBottomInViewLength) {
                nextToPlayCell = cell;
                break;
            }
        }
    }
    else //index 减小方向 手下拉滑动
    {
        NSArray *revertCells = [[cells reverseObjectEnumerator] allObjects];
        
        for (TTVideoFloatCell *cell in revertCells) {
            if (cell.indexPath.row == self.movieShotView.index) {
                hasPlayedCell = YES;
            }
            CGRect rect = [cell.superview convertRect:cell.frame toView:self.view];
            if (CGRectGetMaxY(rect) >= kTopInViewLength && CGRectGetMaxY(rect) <= self.view.height) {
                nextToPlayCell = cell;
                break;
            }
        }
    }
    self.movieShotView.hidden = hasPlayedCell ? NO : YES;
    [self playNextCell:nextToPlayCell];
}

- (void)playNextCell:(TTVideoFloatCell *)nextToPlayCell
{
//    NSLog(@"isTracking %d dragging %d decelerationRate %f",self.tableView.isTracking,self.tableView.dragging,self.tableView.decelerationRate);
//    NSLog(@"ContentOffset %f",fabs(self.targetContentOffset.y - self.tableView.contentOffset.y));
    if (self.toPlayCell == nil) {
        self.toPlayCell = nextToPlayCell;
        self.lastOffset = self.tableView.contentOffset;
        return;
    }
    if (self.isDragging && [self.toPlayCell isImmersed]) {
        [self tt_logImmerseActivity];
    }
    [self unimmerseHalfWithCell:self.toPlayCell];
    if (self.toPlayCell == nextToPlayCell || nextToPlayCell == nil) {
        self.lastOffset = self.tableView.contentOffset;
        if (self.canImmerse) {
            [self immerseHalfTimer];
        }
        return;
    }
    if (self.toPlayCell != nextToPlayCell) {
        self.toPlayCell = nextToPlayCell;
        [self doImmerseWithPlayCell:self.toPlayCell];
        if (self.isAutoScroll) {
            [self tt_playMovie];
        }
        else
        {
            if (self.tableView.isTracking) {
                [self tt_playMovie];
            }
            else
            {
                if (fabs(self.targetContentOffset.y - self.tableView.contentOffset.y) <= 372) {//372 cell高度
                    [self tt_playMovie];
                }
                else
                {
                    [self.movieView pauseMovie];
                }
            }
        }
    }
    self.topView.hiddenTitle = [self isFrirstCell];
    self.lastOffset = self.tableView.contentOffset;
    if (self.canImmerse) {
        [self immerseHalfTimer];
    }
}

- (void)immerseHalfTimer
{
    [self.immerseTimer invalidate];
    self.immerseTimer = [NSTimer scheduledTimerWithTimeInterval:kImmerseTime target:self selector:@selector(immerseHalf) userInfo:nil repeats:NO];
}

- (void)doImmerseWithPlayCell:(TTVideoFloatCell *)toPlayCell
{
    NSArray *cells = [self.tableView visibleCells];
    for (TTVideoFloatCell *cell in cells) {
        if (cell == toPlayCell) {
            [self unimmerseHalfWithCell:cell];
        }
        else
        {
            [cell immerseAll];
        }
    }
}

- (void)tt_closeViewControllerAnimated:(BOOL)animated
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)tt_topViewBackButtonPressed
{
    [self tt_closeViewControllerAnimated:NO];
}

- (void)tt_playButtonClicked
{
    self.isPlayButtonClicked = YES;
    [self tt_playMovie];
    self.isPlayButtonClicked = NO;
}

- (ExploreOrderedData *)orderedData
{
    if (self.toPlayCell.indexPath.row == 0 && self.detailModel.orderedData) {
        return self.detailModel.orderedData;
    }
    Article *article = self.toPlayCell.cellEntity.article;
    if (article) {
        ExploreOrderedData *data = [[ExploreOrderedData alloc] initWithArticle:article];
        data.uniqueID = [NSString stringWithFormat:@"%lld", article.uniqueID];
        data.itemID = article.itemID;
        data.cellType = ExploreOrderedDataCellTypeArticle;
        data.logExtra = [article relatedLogExtra];
        data.adID = article.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
//        if (data.adID) {
//            data.adIDStr = [NSString stringWithFormat:@"%@",data.adID];
//        }
        return data;
    }
    return nil;
}

#pragma mark movieView logic

- (void)configMovieView:(ExploreMovieView *)movieView
{
    if (![movieView isKindOfClass:[ExploreMovieView class]]) {
        return;
    }
    [self removeMovieViewObserver];
    self.shareMovie.movieView = movieView;
    [self addMovieViewObserver];
    movieView.pasterADEnableOptions = 0;
    [movieView setValue:@YES forKey:@"disablePlayPasterAD"];
    movieView.tracker.type = ExploreMovieViewTypeUnknow;
    movieView.pauseMovieWhenEnterForground = NO;
    movieView.showDetailButtonWhenFinished = NO;
    movieView.enableMultiResolution = YES;
    movieView.movieViewDelegate = self;
    [movieView enableRotate:![self.toPlayCell.cellEntity.article detailShowPortrait]];
    [movieView hiddenMiniSliderView:YES];
    movieView.tracker.isAutoPlaying = !self.isMainVideoFirstPlay;
    self.movieView.disableNetworkAlert = [self disableNetworkAlert];
}

- (void)settingMovieView:(ExploreMovieView *)movieView
{
    if (self.shareMovie.movieView != movieView) {
        [self configMovieView:movieView];
    }
}

- ( ExploreMovieView * _Nullable )movieView
{
    return self.shareMovie.movieView;
}

- ( ArticleVideoPosterView * _Nullable )movieShotView
{
    return self.shareMovie.posterView;
}

- (void)settingMovieShotView:(ArticleVideoPosterView *)movieShotView
{
    if (movieShotView != self.shareMovie.posterView) {
        self.shareMovie.posterView = movieShotView;
    }
    if (self.shareMovie.posterView) {
        [self.shareMovie.posterView removeAllActions];
        [self.shareMovie.posterView.playButton addTarget:self action:@selector(tt_playMovie) forControlEvents:UIControlEventTouchUpInside];
    }

}


- (CGFloat)maxWidth
{
    return self.view.bounds.size.width;
}

- (CGRect)frameForMovieShotView
{
    CGFloat proportion = 9.f/16.f;
    CGSize videoAreaSize = [ExploreVideoDetailHelper videoAreaSizeForMaxWidth:[self maxWidth] areaAspect:proportion];
    if ([ExploreVideoDetailHelper currentVideoDetailRelatedStyleForMaxWidth:[self maxWidth]] == VideoDetailRelatedStyleNatant) {
        return CGRectMake((self.view.bounds.size.width - videoAreaSize.width)/2, 0, videoAreaSize.width, videoAreaSize.height);
    } else {
        return CGRectMake(0, 0, videoAreaSize.width, videoAreaSize.height);
    }
}

- (CGRect)frameForMovieView
{
    return CGRectMake(0, 0, [self frameForMovieShotView].size.width, [self frameForMovieShotView].size.height);
}

- (void)attachMovieView
{
    [self.movieShotView addSubview:self.movieView];
    [self.movieShotView bringSubviewToFront:self.movieView];
    [self.movieView setVideoTitle:self.detailModel.article.title fontSizeStyle:TTVideoTitleFontStyleNormal showInNonFullscreenMode:NO];
    [self.toPlayCell addMovieView:self.movieShotView];
    if ([self.movieView isPlaying]) {
        //如果在正在播放时进入详情页，会没有注册监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
    }
}

- (void)tt_resumeMovie
{
    [self.movieView resumeMovie];
}

- (void)tt_invalideMovieView
{
    if (self.movieView) {
        [self.movieView stopMovieAfterDelayNoNotification];
        self.movieShotView.showPlayButton = YES;
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView removeFromSuperview];
        [self settingMovieView:nil];
    }
}

#pragma mark MovieView notification
- (void)stopMovieViewPlay:(NSNotification *)notification
{
    [self tt_invalideMovieView];
}

- (void)stopMovieViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    if (self.movieView) {
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView pauseMovie];
    }
}

- (void)movieViewPlayFinishedNormally:(NSNotification *)notification //正常播放结束后通知,无其他原因的结束.
{
    if (self.chooseNetwork == TTUserChooseNetwork_dontPlay) {
        return;
    }
    BOOL continuePlay = YES;
    if ([self.movieView isMovieFullScreen]) {
        if (self.toPlayCell.indexPath.row == [self.tableView numberOfRowsInSection:0] - 1) {//最后一个cell
            continuePlay = NO;
        }
    }
    if (self.toPlayCell.indexPath.row == [self.tableView numberOfRowsInSection:0] - 1) {//最后一个cell
        [self unimmerseHalfWithCell:self.toPlayCell];
        continuePlay = NO;
    }
    self.playNextInterrupt = NO;
    if (continuePlay) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:MIN(self.toPlayCell.indexPath.row + 1, [self.tableView numberOfRowsInSection:0] - 1) inSection:0];
        self.nextIndexPath = indexPath;
        if (!self.playNextInterrupt) {
            self.tableView.userInteractionEnabled = NO;
            [UIView animateWithDuration:1 animations:^{
                self.isAutoScroll = YES;
                self.tableView.userInteractionEnabled = YES;
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                self.movieView.hidden = YES;
                self.movieView.moviePlayerController.muted = YES;
            } completion:^(BOOL finished) {
                self.movieView.hidden = NO;
                self.isAutoScroll = NO;
                self.movieView.moviePlayerController.muted = NO;
            }];
        }

    }
}

- (BOOL)isFrirstCell
{
    return [self.tableView indexPathForCell:self.toPlayCell].row == 0;
}

- (void)affirmTrackType
{
    if (self.isMainVideoFirstPlay)
    {
        self.movieView.tracker.type = ExploreMovieViewTypeVideoFloat_main;//初始进入的时候才统计,在浮层内第二次播放的时候就不统计了.相关视频每次都统计
        self.movieView.tracker.isAutoPlaying = NO;
        [self.movieView.tracker addExtraValue:@"0" forKey:@"rank"];
    }
    else
    {
        if ([self isFrirstCell]) {
            self.movieView.tracker.type = ExploreMovieViewTypeVideoFloat_main;
            self.movieView.tracker.isAutoPlaying = YES;
            [self.movieView.tracker addExtraValue:@"1" forKey:@"rank"];
        }
        else
        {
            self.movieView.tracker.type = ExploreMovieViewTypeVideoFloat_related;
            self.movieView.tracker.isAutoPlaying = YES;
            [self.movieView.tracker addExtraValue:[NSString stringWithFormat:@"%ld",[self.tableView indexPathForCell:self.toPlayCell].row] forKey:@"rank"];
        }
    }
}

- (void)tt_playMovieViewWithArticle:(Article *)article movieViewModel:(ExploreMovieViewModel *)movieViewModel
{
    [self affirmTrackType];
    [self.movieView setVideoTitle:article.title fontSizeStyle:TTVideoTitleFontStyleNormal showInNonFullscreenMode:NO];
    NSDictionary *videoLargeImageDict = article.largeImageDict;
    if (!videoLargeImageDict) {
        videoLargeImageDict = [article.videoDetailInfo objectForKey:VideoInfoImageDictKey];
    }
    [self.movieView setVideoDuration:[article.videoDuration doubleValue]];
    [self.movieShotView addSubview:self.movieView];
    
    ExploreVideoSP sp = ([article.groupFlags longLongValue] & ArticleGroupFlagsDetailSP) > 0 ? ExploreVideoSPLeTV : ExploreVideoSPToutiao;
    NSString *videoID = article.videoID;
    if (isEmptyString(videoID)) {
        videoID = [article.videoDetailInfo objectForKey:VideoInfoIDKey];
    }
    NSDictionary *dic = [[self class] baseExtraWithArticle:article];
    for (NSString *key in [dic allKeys]) {
        [self.movieView.tracker addExtraValue:[dic valueForKey:key] forKey:key];
    }
    [self addMovieTrackerEvent3Data];
    [self.movieView playVideoForVideoID:videoID exploreVideoSP:sp videoPlayType:movieViewModel.videoPlayType];
    [self.movieView showLoadingView:ExploreMoviePlayerControlViewTipTypeLoading];
    [self.movieView.moviePlayerController.controlView setToolBarHidden:YES needAutoHide:NO animate:NO];
    self.movieView.hidden = NO;
    [self.movieView setLogoImageDict:videoLargeImageDict];
    [self.movieShotView refreshUI];
    [self.toPlayCell addMovieView:self.movieShotView];
    self.preIndexPath = [self.tableView indexPathForCell:self.toPlayCell];
    self.prePlayCell = self.toPlayCell;
}

- (ExploreMovieViewModel *)tt_movieViewModelWithArticle:(Article *)article
{
    ExploreOrderedData *orderedData = [self orderedData];//主视频的
    ExploreMovieViewModel *movieViewModel = [ExploreMovieViewModel viewModelWithOrderData:orderedData];
    if ([self isFrirstCell]) {
        movieViewModel.type = ExploreMovieViewTypeVideoFloat_main;
    }
    else
    {
        movieViewModel.type = ExploreMovieViewTypeVideoFloat_related;
    }
    movieViewModel.gModel                 = article.groupModel;
    movieViewModel.gdLabel                = self.detailModel.clickLabel;
    movieViewModel.videoPlayType          = TTVideoPlayTypeNormal ;
    movieViewModel.useSystemPlayer = !isEmptyString(article.videoLocalURL);

    //直播cell类型
    NSInteger videoType = 0;
    if ([[article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
        videoType = ((NSNumber *)[article.videoDetailInfo objectForKey:@"video_type"]).integerValue;
    }
    if (videoType == 1) {
        movieViewModel.videoPlayType  = TTVideoPlayTypeLive;
    }

    if (self.toPlayCell.indexPath.row == 0) {
        movieViewModel.aID            = orderedData.ad_id;
        movieViewModel.logExtra       = orderedData.log_extra;
    }
    else
    {
        movieViewModel.aID            = article.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];;
        movieViewModel.logExtra       = article.relatedVideoExtraInfo[kArticleInfoRelatedVideoLogExtraKey];
    }

    return movieViewModel;
}

- (Article *)mainArticle
{
    return self.detailModel.article;
}

- (BOOL)disableNetworkAlert
{
    BOOL disableNetworkAlert = NO;
    if (self.chooseNetwork == TTUserChooseNetwork_dontPlay)
    {
        if (self.isPlayButtonClicked) {
            disableNetworkAlert = NO;
        }
        else
        {
            disableNetworkAlert = YES;
        }
    }
    return disableNetworkAlert;
}

- (void)tt_playMovie
{
    BOOL disableNetworkAlert = [self disableNetworkAlert];
    if (disableNetworkAlert) {
        return;
    }
    Article *article = [self currentCellArticle];
    ExploreMovieViewModel *movieViewModel = [self tt_movieViewModelWithArticle:article];
    self.movieView.disableNetworkAlert = NO;

    BOOL isReuse = self.movieView != nil;
    if (!isReuse)
    {
        ExploreMovieView *movie = [[TTMovieViewCacheManager sharedInstance] movieViewWithVideoID:article.videoID frame:[self frameForMovieView] type:ExploreMovieViewTypeVideoFloat_main trackerDic:nil movieViewModel:movieViewModel];
        [self settingMovieView:movie];
    }
    else
    {
        self.isMainVideoFirstPlay = NO;
        [self.movieView willReusePlayer];
        [self.movieView userPause];
        [self.movieView.tracker sendEndTrack];
    }
    self.movieView.videoModel = movieViewModel;
    [self configMovieView:self.movieView];
    [self.movieShotView refreshWithArticle:article];
    self.movieShotView.index = self.toPlayCell.indexPath.row;
    self.movieView.tracker.isReplaying = NO;
    [self tt_playMovieViewWithArticle:article movieViewModel:movieViewModel];
    if (isReuse)
    {
        [self.movieView didReusePlayer];
    }

}

#pragma mark movieView delegate

- (void)controlViewTouched:(ExploreMoviePlayerControlView *)controlView
{
    [self unimmerseHalfWithCell:self.toPlayCell];
    [self immerseHalfTimer];
    [self clickToPlay];
}

- (void)movieDidExitFullScreen
{
    [self showMiniSlider:NO];
}

- (void)movieDidEnterFullScreen
{
    [self showMiniSlider:YES];
}

- (void)showDetailButtonClicked
{
    
}

- (BOOL)shouldShowDetailButton
{
    return NO;
}

- (CGRect)movieViewFrameAfterExitFullscreen
{
    return self.toPlayCell.frame;
}

- (BOOL)shouldDisableUserInteraction
{
    return NO;
}

- (BOOL)shouldStopMovieWhenInBackground
{
    return NO;
}

- (void)shareButtonClicked
{
    [self shareActionWithCellEntity:self.toPlayCell.cellEntity];
    self.playNextInterrupt = YES;
}

- (void)replayButtonClickedInTrafficView
{
    self.playNextInterrupt = YES;
}

- (void)replayButtonClicked
{
    self.movieView.tracker.isReplaying = YES;
    self.movieView.tracker.isAutoPlaying = NO;
    self.playNextInterrupt = YES;
}

- (void)retryButtonClicked
{
    self.playNextInterrupt = YES;
}

- (void)movieRemainderTime:(NSTimeInterval)remainderTime
{
    self.timeLessThanFiveSecond = remainderTime <= 5;
}

- (void)movieSeekTime:(NSTimeInterval)seeekTime
{
    [self immerseHalfTimer];
}

- (void)setTimeLessThanFiveSecond:(BOOL)timeLessThanFiveSecond
{
    if (timeLessThanFiveSecond != _timeLessThanFiveSecond) {
        _timeLessThanFiveSecond = timeLessThanFiveSecond;
        if (_timeLessThanFiveSecond) {
            [self unimmerseHalfWithCell:self.toPlayCell];
        }
    }
}

#pragma mark 统计
- (void)tt_logImmerseActivity
{
    wrapperTrackEventWithCustomKeys(@"video_float", @"float_click_screen", self.toPlayCell.cellEntity.article.groupModel.groupID, nil, nil);
}

+ (nullable NSMutableDictionary *)baseExtraWithArticle:( Article * _Nonnull )article
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (article.groupModel.groupID) {
        [dic setValue:article.groupModel.groupID forKey:@"group_id"];
    }
    if (article.groupModel.itemID) {
        [dic setValue:article.groupModel.itemID forKey:@"item_id"];
    }
    if ([article.mediaInfo valueForKey:@"media_id"]) {
        [dic setValue:[article.mediaInfo valueForKey:@"media_id"] forKey:@"media_id"];
    }
    return dic;
}

#pragma mark - 埋点3.0

- (void)addMovieTrackerEvent3Data{
    [self.movieView.tracker addExtraValue:self.orderedData.article.itemID forKey:@"item_id"];
    [self.movieView.tracker addExtraValue:[self.orderedData uniqueID] forKey:@"group_id"];
    [self.movieView.tracker addExtraValue:self.orderedData.article.aggrType forKey:@"aggr_type"];
    //self.detailModel.gdExtJsonDict
    [self.movieView.tracker addExtraValue:self.orderedData.logPb forKey:@"log_pb"];
    [self.movieView.tracker addExtraValue:self.orderedData.article.videoID forKey: @"video_id"];
}
#pragma mark notification

- (void)addMovieViewObserver
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewPlayFinishedNormally:) name:kExploreMovieViewPlaybackFinishNormallyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreStopMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];

    }
}

- (void)removeMovieViewObserver
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreMovieViewPlaybackFinishNormallyNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreStopMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];
    }
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (TTActivityShareManager *)activityActionManager
{
    if (!_activityActionManager) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
    }
    return _activityActionManager;
}

- (void)appWillResignActiveNotification:(NSNotification *)notification
{
    self.playNextInterrupt = YES;
}

- (void)appDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self.immerseTimer invalidate];
}

- (void)appWillEnterForegroundNotification:(NSNotification *)notification
{
    [self immerseHalfTimer];
}

- (void)connectionChanged:(NSNotification *)notification
{
    if (TTNetworkWifiConnected() && TTNetworkConnected()) {
        self.chooseNetwork = TTUserChooseNetwork_unkown;
    }
}

#pragma mark ExploreDetailManagerDelegate

- (void)detailContainerViewController:(SSViewControllerBase *)container reloadData:(TTDetailModel *)detailModel
{
    [self loadData];
}

- (void)detailContainerViewController:(nullable SSViewControllerBase *)container loadContentFailed:(nullable NSError *)error{
    [self tt_endUpdataData];
}

- (UIImage *)animationToImage
{
    if (self.firstMovieShotView.logoImage) {
        return self.firstMovieShotView.logoImage;
    }
    return self.movieShotView.logoImage;
}

- (UIView *)animationToView
{
    if (self.movieView) {
        return self.movieView;
    }
    return [self.toPlayCell animationToView];

}

- (CGRect)animationToFrame
{
    CGRect rect = [self.movieView convertRect:self.movieView.frame toView:self.view];
    if (rect.size.height <= 0) {
        rect.size.height = 326;
    }
    if (rect.size.width <= 0) {
        rect.size.width = self.view.frame.size.width;
    }
    return rect;
}

- (void)animationToBegin:(UIView *)fromAnimatedView
{
    self.movieView.hidden = YES;
    self.movieShotView.hidden = YES;
    [self.toPlayCell showBackgroundImage:NO];
}

- (void)animationToFinished:(UIView *)fromAnimatedView
{
    self.movieView.hidden = NO;
    self.movieShotView.hidden = NO;
    [self.toPlayCell showBackgroundImage:YES];
    [self.movieShotView addSubview:self.movieView];
}

#pragma mark gesture
- (void)tt_hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [self unimmerseHalfWithCell:self.toPlayCell];
    [self immerseHalfTimer];
}

@end
