//
//  WDDetailSlideNewViewController.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/30.
//
//

#import "WDDetailSlideNewViewController.h"
#import "WDCollectionView.h"
#import "WDDetailSlideNavigationView.h"
#import "WDDetailAnswerNewCell.h"
#import "WDDetailSlideHeaderView.h"
#import "WDDetailSlideWhiteHeaderView.h"
#import "WDBottomToolView.h"
#import "WDNewsHelpView.h"
#import "WDDetailSlideViewModel.h"
#import "WDDetailNatantViewModel.h"
#import "WDDetailNatantViewModel+ShareCategory.h"
#import "WDDetailModel.h"
#import "WDAnswerEntity.h"
#import "WDSettingHelper.h"
#import "WDShareUtilsHelper.h"
#import "WDCollectionView.h"
#import "WDDetailSlideHintView.h"
#import "TTViewWrapper.h"
#import "DetailActionRequestManager.h"
#import "TTUIResponderHelper.h"
#import "TTIndicatorView.h"
#import "TTShareManager.h"
#import "NetworkUtilities.h"
#import "UIViewController+Track.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTRoute.h"
#import "NSObject+FBKVOController.h"
#import "WDCommonLogic.h"
#import "WDAdapterSetting.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTThemed/TTThemeManager.h>
#import <TTPlatformUIModel/TTBubbleView.h>
#import <AKCommentPlugin/TTCommentWriteView.h>


#import "WDDefines.h"
#import "HPGrowingTextView.h"

static NSString * const kkHasShownCommentPolicyIndicatorViewKey = @"HasShownComentPolicyIndicatorViewKey";
//static NSUInteger const kkkPolicyIndicatorViewKey = 20160508;

@interface WDDetailSlideNewViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TTDetailViewController, WDDetailSlideNavigationViewDelegate, TTShareManagerDelegate, WDDetailSlideHeaderViewDelegate, WDBottomToolViewDelegate, TTCommentWriteManagerDelegate, WDDetailAnswerNewCellDelegate, TTUIViewControllerTrackProtocol, UIViewControllerErrorHandler, WDDetailModelDataSource, WDDetailSlideHintViewDelegate>
{
    BOOL _backButtonTouched;
    BOOL _closeButtonTouched;
    BOOL _hiddenByDisplayImage;
    
    BOOL _isWriteCommentViewWillShow;
}

@property (nonatomic, strong) TTViewWrapper *wrapperView;
@property (nonatomic, strong) WDDetailSlideNavigationView *customNavigation;
@property (nonatomic, strong) SSThemedView *fullBgView; // 专为ipad使用
@property (nonatomic, strong) SSThemedView *topBgView;  // 背景蓝条
@property (nonatomic, strong) WDCollectionView *collectionView;
@property (nonatomic, strong) WDDetailAnswerNewCell *currentAnswerCell;
@property (nonatomic, strong) WDDetailSlideHeaderView <WDDetailSlideHeaderViewProtocol>*blueHeaderView;
@property (nonatomic, strong) WDDetailSlideWhiteHeaderView <WDDetailSlideHeaderViewProtocol>*whiteHeaderView;
@property (nonatomic, strong) WDBottomToolView *toolbarView;
@property (nonatomic, strong) TTCommentWriteView * commentWriteView;
@property (nonatomic, strong) TTBubbleView *bubbleView;

@property (nonatomic, strong) WDNewsHelpView *sliderHelpView;
@property (nonatomic, strong) TTIndicatorView *enterFoldIndicator; // 展示进入折叠回答，注意展示时机 ；

@property (nonatomic, strong) WDDetailSlideHintView *slideHintView;

@property (nonatomic, strong) WDDetailSlideViewModel *slideViewModel; // 下一个问题，如何获取当前的？？

@property (nonatomic, strong) DetailActionRequestManager *actionManager;

@property (nonatomic, strong) TTShareManager * shareManager;

@property (strong, nonatomic) NSMutableArray *visibleIndexArray;
@property (nonatomic, assign) BOOL isHorScrolling;
@property (nonatomic, assign) BOOL isNextBtnMoving;
@property (nonatomic, assign) BOOL hasSetValue;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, assign) CGFloat lastScrollWidth;
@property (nonatomic, assign) BOOL firstAnswerSuccess;
@property (nonatomic, assign) BOOL ListContentSuccess;
@property (nonatomic, assign) BOOL isListContentFetching;

@property ( nonatomic, assign) CGFloat lastStatusBarHeight;

@end

@implementation WDDetailSlideNewViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self p_sendDetailDeallocTrack];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.slideViewModel = [[WDDetailSlideViewModel alloc] initWithRouteParamObj:paramObj];
        self.visibleIndexArray = [NSMutableArray array];
        [self p_setDetailViewBars];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_buildCustomNavigationView];
    [self p_loadFirstAnswerContent];
    self.ttTrackStayEnable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusbarFrameDidChangeNotification)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.currentAnswerCell) {
        [self.currentAnswerCell cellWillReappear];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.slideViewModel.showSlideType == AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        if (![TTDeviceHelper isPadDevice]) {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                if (self.headerView && self.headerView.top == self.customNavigation.height - self.headerView.height) {
                    self.ttStatusBarStyle = UIStatusBarStyleDefault;
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                }
                else {
                    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                }
            }
        }
    }
    if (self.currentAnswerCell) {
        [self.currentAnswerCell cellDidReappear];
    }
    self.lastStatusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.currentAnswerCell) {
        [self.currentAnswerCell cellWillDisappear];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.currentAnswerCell) {
        [self.currentAnswerCell cellDidDisappear];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        [self.customNavigation reLayoutSubviews];
        self.fullBgView.frame = [self p_frameForFullBgView];
        CGFloat oldHeaderTop = self.headerView.top;
        CGFloat oldScrollTop = self.collectionView.top;
        self.headerView.frame = [self p_frameForHeaderView];
        self.headerView.top = oldHeaderTop;
        self.collectionView.frame = [self p_frameForFullScrollView];
        self.collectionView.top = oldScrollTop;
        [self.headerView reloadView];
        self.toolbarView.frame = [self p_frameForToolBarViewIsStatusHeightChanged:NO];
        [self.toolbarView layoutIfNeeded];
    }
}

- (TTShareManager *)shareManager {
    if (nil == _shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self.currentAnswerCell cellEnterBackground];
}

- (void)trackStartedByAppWillEnterForground {
    [self.currentAnswerCell cellEnterForeground];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    if (_ListContentSuccess) {
        return YES;
    }
    return NO;
}

- (void)refreshData {
    if (!_firstAnswerSuccess) {
        [self p_loadFirstAnswerContent];
    }
    else if (!_ListContentSuccess) {
        [self p_loadListContentFirstTime:YES];
    }
}

#pragma mark - WDDetailAnswerNewCellDelegate

- (void)wd_detailAnswerNewCellAfterDeleteAnswer {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)wd_detailAnswerNewCellShowSlideHelperView {
    [self p_showSlideHelperView];
}

- (void)wd_detailAnswerNewCellShowIndicatorPolicyView {
    [self p_showIndicatorPolicyView];
}

- (void)wd_detailAnswerNewCellAfterFetchContentSuccessFirstTime:(BOOL)firstTime {
    if (!firstTime) {
        [self p_refreshBottomViewDataWithTargetModel:self.currentAnswerCell.detailModel];
    }
}

- (void)wd_detailAnswerNewCellDidScroll:(UIScrollView *)scrollView index:(NSInteger)index {
    if (self.isHorScrolling) return;
    
    
    CGFloat y = [TTDeviceHelper isPadDevice] ? 0 : self.customNavigation.bottom;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (self.currentAnswerCell.index == index) {
        if (offsetY >= 0) {
            CGFloat minTop = y - self.headerView.height;
            if ((self.headerView.top - offsetY) < minTop) {
                self.headerView.top = minTop;
                self.collectionView.top = self.headerView.bottom;
            } else {
                self.headerView.top = self.headerView.top - offsetY;
                self.collectionView.top = self.headerView.bottom;
                [scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
            }
        } else {
            CGFloat maxTop = -0.5f + y;
            if ((self.headerView.top - offsetY) > maxTop) {
                self.headerView.top = maxTop - offsetY;
                self.collectionView.top = maxTop + self.headerView.height;
            } else {
                self.headerView.top = self.headerView.top - offsetY;
                self.collectionView.top = self.headerView.bottom;
                [scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
            }
        }
        
        BOOL titleShow = (self.headerView.top == y - self.headerView.height) ? YES : NO;
        [self p_changeTitleShowState:titleShow];
        
    }
}

- (void)wd_detailAnswerNewCellDidScrollWithContentOffsetY:(CGFloat)offsetY index:(NSInteger)index {
    if (self.isHorScrolling) return;
    
    CGFloat y = [TTDeviceHelper isPadDevice] ? 0 : self.customNavigation.bottom;
    
    if (self.currentAnswerCell.index == index) {
        if (offsetY >= 0) {
            CGFloat minTop = y - self.headerView.height;
            if ((self.headerView.top - offsetY) < minTop) {
                self.headerView.top = minTop;
                self.collectionView.top = self.headerView.bottom;
            } else {
                self.headerView.top = self.headerView.top - offsetY;
                self.collectionView.top = self.headerView.bottom;
                
            }
        } else {
            CGFloat maxTop = -0.5f + y;
            if ((self.headerView.top - offsetY) > maxTop) {
                self.headerView.top = maxTop - offsetY;
                self.collectionView.top = maxTop + self.headerView.height;
            } else {
                self.headerView.top = self.headerView.top - offsetY;
                self.collectionView.top = self.headerView.bottom;
            }
        }
        
        BOOL titleShow = (self.headerView.top == y - self.headerView.height) ? YES : NO;
        [self p_changeTitleShowState:titleShow];
        
    }
}

- (void)wd_detailAnswerNewCellWriteCommentWithReservedText:(NSString *)reservedText {
    [self p_willOpenWriteCommentViewWithReservedText:reservedText switchToEmojiInput:NO];
}

- (void)wd_detailAnswerNewCellWriteCommentWithCondition:(NSDictionary *)condition {
    [self p_showWriteCommentViewWithCondtions:condition switchToEmojiInput:NO];
}

- (void)wd_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info
{
    [[WDAdapterSetting sharedInstance] commentViewControllerDidSelectedWithInfo:info viewController:self dismissBlock:^{
        [[UIApplication sharedApplication] setStatusBarStyle:[[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay? UIStatusBarStyleDefault: UIStatusBarStyleLightContent];
        if ([ttController respondsToSelector:@selector(tt_reloadData)]) {
            [ttController tt_reloadData];
        }
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat count = offsetX / scrollView.width;
    NSInteger currentIndex = floorf(count);
    if (count == currentIndex) {
        if (currentIndex != _lastIndex) {
            if (currentIndex > _lastIndex) {
                if (self.isHorScrolling) {
                    [TTTrackerWrapper eventV3:@"slide_next_answer" params:nil];
                }
                [self p_showEnterFoldAnswerAlertIfNeededWithIndex:currentIndex];
            }
            else if (currentIndex < _lastIndex) {
                if (self.isHorScrolling) {
                    [TTTrackerWrapper eventV3:@"slide_previous_answer" params:nil];
                }
            }
            for (NSIndexPath *ip in _visibleIndexArray) {
                if (ip.item == _lastIndex) {
                    WDDetailAnswerNewCell *oneCell = (WDDetailAnswerNewCell *)[self.collectionView cellForItemAtIndexPath:ip];
                    [oneCell cellEndDisplay];
                }
            }
            _lastIndex = currentIndex;
        }
    }
    if (!_hasSetValue) {
        _hasSetValue = YES;
        if (offsetX > scrollView.contentSize.width - scrollView.width) {
            if (self.slideViewModel.hasGetAllAnswers) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"这是最后一个回答", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isHorScrolling) return;
    
    self.isHorScrolling = YES;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = offsetX / scrollView.width;
    
    self.startIndex = index;
    self.lastIndex = index;
}

- (void)p_stopScrollFinallyWithScrollView:(UIScrollView *)scrollView isForce:(BOOL)isForce {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = offsetX / scrollView.width;
    
    self.hasSetValue = NO;
    
    if (self.startIndex == index) {
        if (self.currentAnswerCell.index != index) {
        }
        self.isHorScrolling = NO;
        return;
    }
    
    for (NSIndexPath *ip in _visibleIndexArray) {
        if (index == ip.item) {
            self.currentAnswerCell = (WDDetailAnswerNewCell *)[self.collectionView cellForItemAtIndexPath:ip];
            self.slideViewModel.currentDetailModel = self.currentAnswerCell.detailModel;
            // 停止的时候再调用infomation接口
            [self.currentAnswerCell loadInfomationIfNeeded];
            break;
        }
    }
    
    self.isHorScrolling = NO;
    
    [self.headerView updateCurrentDetailModel:self.currentAnswerCell.detailModel];
    [self p_refreshBottomViewDataWithTargetModel:self.currentAnswerCell.detailModel];
    
    if (self.slideViewModel.ansItemsArray.count != 0 && [self.slideViewModel isLastAnswer]) {
        if (!self.slideViewModel.hasGetAllAnswers) {
            [self p_loadListContentFirstTime:NO];
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self p_stopScrollFinallyWithScrollView:scrollView isForce:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self p_stopScrollFinallyWithScrollView:scrollView isForce:NO];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self p_stopScrollFinallyWithScrollView:scrollView isForce:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.slideViewModel.ansItemsArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"detailAnswerNewCell";
    WDDetailAnswerNewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.index = indexPath.row;
    cell.delegate = self;
    if (indexPath.item == 0) {
        [cell setDetailAnswerFromDetailModel:self.slideViewModel.initialDetailModel];
        cell.detailModel.dataSource = self;
    }
    else {
        [cell setDetailAnswerRouteParamObj:[self.slideViewModel getRouteParamObjWithIndex:indexPath.row - 1]];
        cell.detailModel.dataSource = self;
    }
    if (!_currentAnswerCell && indexPath.item == 0) {
        _currentAnswerCell = cell;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)judgeOneIndexPathIsExistInVisibleIndexArrayWithValue:(NSIndexPath *)indexPath
{
    NSInteger visibleCount = [_visibleIndexArray count];
    for(int i=0;i<visibleCount;i++){
        NSIndexPath *oneIndexPath = [_visibleIndexArray objectAtIndex:i];
        if(oneIndexPath.item == indexPath.item){
            return YES;
        }
    }
    return NO;
}

- (void)addOneIndexPathToVisibleIndexArrayWithValue:(NSIndexPath *)indexPath
{
    BOOL isExist = [self judgeOneIndexPathIsExistInVisibleIndexArrayWithValue:indexPath];
    if(!isExist){
        [_visibleIndexArray addObject:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self addOneIndexPathToVisibleIndexArrayWithValue:indexPath];
    [(WDDetailAnswerNewCell *)cell cellStartDisplay];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_visibleIndexArray removeObject:indexPath];
    [(WDDetailAnswerNewCell *)cell cellEndDisplay];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController {
    
    NSString *label = [WDShareUtilsHelper labelNameForShareActivity:activity];
    if (!isEmptyString(label)) {
        [_currentAnswerCell.detailModel sendDetailTrackEventWithTag:kWDDetailViewControllerUMEventName label:label];
    }
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:_currentAnswerCell.detailModel.answerEntity.ansid];
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    context.mediaID = _currentAnswerCell.detailModel.answerEntity.ansid;
    [self.actionManager setContext:context];
    
    DetailActionRequestType requestType = [WDShareUtilsHelper requestTypeForShareActivityType:activity];
    [self.actionManager startItemActionByType:requestType];
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc {
    
    NSString *label = [WDShareUtilsHelper labelNameForShareActivity:activity shareState:(error ? NO : YES)];
    if (!isEmptyString(label)) {
        ttTrackEventWithCustomKeys(kWDDetailViewControllerUMEventName, label, _currentAnswerCell.detailModel.answerEntity.ansid, nil, _currentAnswerCell.detailModel.gdExtJsonDict);
    }
}

#pragma mark - WDDetailSlideNavigationViewDelegate

- (void)wdDetailSlideNaviViewBackButtonTapped {
    _backButtonTouched = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)wdDetailSlideNaviViewMoreButtonTapped {
    
    [self p_removeIndicatorPolicyView];
    if (_currentAnswerCell.natantViewModel == nil || _currentAnswerCell.detailModel.answerEntity.answerDeleted) {
        return;
    }
    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:[_currentAnswerCell.natantViewModel wd_shareItems]];
    [contentItems addObject:[_currentAnswerCell.natantViewModel wd_customItems]];
    [self.shareManager displayActivitySheetWithContent:[contentItems copy]];
    //是0的情况下，可以删掉 @尹浩已确认
    //    [TTAdManageInstance share_showInAdPage:@"0" groupId:_currentAnswerCell.detailModel.answerEntity.ansid];
    
    [TTTracker category:@"umeng" event:kWDDetailViewControllerUMEventName label:@"more_clicked" dict:_currentAnswerCell.detailModel.gdExtJsonDict];
}

- (void)wdDetailSlideNaviViewTitleButtonTapped {
    if ([self.slideViewModel.currentDetailModel needReturn]) {
        [self dismissSelf];
    } else {
        [self.slideViewModel.currentDetailModel openListPage];
    }
}

#pragma mark - WDDetailSlideHeaderViewDelegate

- (void)wdDetailSlideHeaderViewShowAllAnswers {
    if ([self.slideViewModel.currentDetailModel needReturn]) {
        [self dismissSelf];
    } else {
        [self.slideViewModel.currentDetailModel openListPage];
    }
}

#pragma mark - WDBottomToolViewDelegate

- (void)bottomView:(WDBottomToolView *)bottomView writeButtonClicked:(SSThemedButton *)wirteButton {
//    if (![_currentAnswerCell.detailModel.answerEntity banComment]) {
//        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
//    } else {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"该回答禁止评论" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
//    }
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    [self p_sendDetailLogicTrackWithLabel:@"write_button"];
}

- (void)bottomView:(WDBottomToolView *)bottomView commentButtonClicked:(SSThemedButton *)commentButton {
    [_currentAnswerCell commentCountButtonTapped];
}

- (void)bottomView:(WDBottomToolView *)bottomView diggButtonClicked:(SSThemedButton *)diggButton {
    if (_currentAnswerCell.detailModel.answerEntity.isDigg) {
        [TTTracker event:kWDDetailViewControllerUMEventName label:@"digg"];
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_currentAnswerCell.detailModel.gdExtJsonDict];
        WDAnswerEntity *answerEntity = _currentAnswerCell.detailModel.answerEntity;
        [dict setValue:answerEntity.ansid forKey:@"group_id"];
        [dict setValue:answerEntity.ansid forKey:@"item_id"];
        [dict setValue:answerEntity.user.userID forKey:@"user_id"];
        [dict setValue:@(10) forKey:@"group_source"];
        [dict setValue:@"detail" forKey:@"position"];
        [TTTracker eventV3:@"rt_unlike" params:[dict copy]];
    }
}

- (void)bottomView:(WDBottomToolView *)bottomView nextButtonClicked:(SSThemedButton *)nextButton {
    [self p_tryNextAnswer];
    // 稍后改成调用方法转到内部去打点
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_currentAnswerCell.detailModel.gdExtJsonDict];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:kWDDetailViewControllerUMEventName forKey:@"tag"];
    [dict setValue:@"click_next_answer" forKey:@"label"];
    [dict setValue:_currentAnswerCell.detailModel.answerEntity.ansid forKey:@"value"];
    [TTTracker eventData:[dict copy]];
}

- (void)bottomView:(nonnull WDBottomToolView *)bottomView emojiButtonClicked:(nonnull SSThemedButton *)wirteButton {
}

- (void)p_tryNextAnswer {
    
    if (_isNextBtnMoving) return;
    _isNextBtnMoving = YES;
    
    if (![self.slideViewModel isLastAnswer]) {
        CGFloat offsetX = self.collectionView.contentOffset.x;
        CGFloat width = SSWidth(self.collectionView);
        NSInteger index = offsetX / self.collectionView.width;
        self.startIndex = index;
        self.lastIndex = index;
        [self.collectionView setContentOffset:CGPointMake(offsetX+width, 0) animated:YES];
        [self performSelector:@selector(resetNextBtnMovingValue) withObject:nil afterDelay:0.5];
    }
    else {
        _isNextBtnMoving = NO;
        if (self.slideViewModel.hasGetAllAnswers) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"这是最后一个回答", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
    }
}

- (void)resetNextBtnMovingValue {
    _isNextBtnMoving = NO;
}

#pragma mark - WDDetailSlideHintViewDelegate

- (void)wdDetailSlideHintViewSlideTrigger {
    [self p_tryNextAnswer];
}

- (void)wdDetailSlideHintViewWillDismiss {
    [self.slideViewModel afterShowSlideHint];
}

#pragma mark - WDWriteCommentViewDelegate
- (void)commentView:(TTCommentWriteView *) commentView cancelledWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager {
    _isWriteCommentViewWillShow = NO;
}

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"house_app2c_v2" forKey:@"event_type"];
    [params setValue:[self.slideViewModel.currentDetailModel.gdExtJsonDict objectForKey:@"enter_from"]  forKey:@"enter_from"];
    [params setValue:[self.slideViewModel.currentDetailModel.gdExtJsonDict objectForKey:@"category_name"]  forKey:@"category_name"];
    [params setValue:[self.slideViewModel.currentDetailModel.gdExtJsonDict objectForKey:@"ansid"]  forKey:@"ansid"];
    [params setValue:[self.slideViewModel.currentDetailModel.gdExtJsonDict objectForKey:@"qid"]  forKey:@"qid"];
    [params setValue:[self.slideViewModel.currentDetailModel.gdExtJsonDict objectForKey:@"log_pb"]  forKey:@"log_pb"];
    [params setValue:[self.slideViewModel.currentDetailModel.gdExtJsonDict objectForKey:@"group_id"]  forKey:@"group_id"];
    [TTTracker eventV3:@"rt_post_comment" params:params];
    
    [self.currentAnswerCell commentView:commentView sucessWithCommentWriteManager:commentWriteManager responsedData:responseData];
}

- (void)p_willOpenWriteCommentViewWithReservedText:(NSString *)reservedText switchToEmojiInput:(BOOL)switchToEmojiInput
{
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.currentAnswerCell.detailModel.answerEntity.ansid];
    [condition setValue:groupModel forKey:@"kQuickInputViewConditionGroupModel"];
    [condition setValue:reservedText forKey:@"kQuickInputViewConditionInputViewText"];
    [self p_showWriteCommentViewWithCondtions:condition switchToEmojiInput:switchToEmojiInput];
}

- (void)p_showWriteCommentViewWithCondtions:(NSDictionary *)conditions switchToEmojiInput:(BOOL)switchToEmojiInput
{
//    if ([_currentAnswerCell.detailModel.answerEntity banComment]) {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"该回答禁止评论" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
//        return;
//    }

    NSString *fwID = self.slideViewModel.currentDetailModel.answerEntity.ansid;

    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
    double readPct = [self.currentAnswerCell getReadPct];
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    qualityModel.readPct = @(percent);
    qualityModel.stayTimeMs = @([self stayPageTimeInterValForDetailView:self]);

    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:conditions commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fwID;
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:qualityModel];

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;
    
    // writeCommentView 禁表情
    self.commentWriteView.banEmojiInput = YES;
    [self.commentWriteView setTextViewPlaceholder:[self.currentAnswerCell writeCommentViewPlaceholder]];
    [self.commentWriteView showInView:self.view animated:YES];
}

// 这是从containerVC中粘过来的
- (CGFloat) stayPageTimeInterValForDetailView:(nullable UIViewController *)controller{
    //@ray 注意这里要返回毫秒值
    return 100;//测试数据
}

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    [self.toolbarView layoutIfNeeded];
    
    if (self.slideViewModel.showSlideType == AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        if (![TTDeviceHelper isPadDevice]) {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                if (self.customNavigation.isTitleShow) {
                    self.ttStatusBarStyle = UIStatusBarStyleDefault;
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                }
                else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
                        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                    });
                }
            }
            else {
                self.ttStatusBarStyle = UIStatusBarStyleLightContent;
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            }
        }
        
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.topBgView.backgroundColor = [UIColor colorWithHexString:@"#67778B"];
        }
        else {
            self.topBgView.backgroundColor = [UIColor colorWithHexString:@"#333B45"];
        }
    }
    
}

- (void)boardWillHideNotification:(NSNotification *)notification
{
    if (self.commentWriteView) {
        [self.commentWriteView dismissAnimated:YES];
    }
}

- (void)statusbarFrameDidChangeNotification {
    [self refreshSubViewFrameIfNeeded];
}

- (void)appDidBecomeActiveNotification {
    [self refreshSubViewFrameIfNeeded];
}

- (void)refreshSubViewFrameIfNeeded {
    CGFloat newStatusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    if (newStatusBarHeight == 0) return;
    if (self.lastStatusBarHeight != newStatusBarHeight) {
        self.lastStatusBarHeight = newStatusBarHeight;
        self.customNavigation.frame = [self p_frameForNavigationViewIsStatusHeightChanged:YES];
        [self.customNavigation statusBarHeightChanged];
        if (self.lastStatusBarHeight == 20) {
            self.collectionView.height += 20;
            // reload刷新会有大问题，不reload刷新有小问题
        }
        self.toolbarView.frame = [self p_frameForToolBarViewIsStatusHeightChanged:YES];
    }
}

#pragma mark - Private

- (void)p_setDetailViewBars
{
    self.ttHideNavigationBar = YES;
    self.ttNeedHideBottomLine = YES;
    self.ttNavigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:self.ttHideNavigationBar animated:NO];
    
    if (self.slideViewModel.showSlideType == AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        if (![TTDeviceHelper isPadDevice]) {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                self.ttStatusBarStyle = UIStatusBarStyleLightContent;
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            }
        }
        
        [[WDSettingHelper sharedInstance_tt] wdSetDetailStatusBarStyleIsDefault:NO];
    }
}

- (void)p_loadListContentSuccess {
    
    self.ListContentSuccess = YES;
    
    [self p_buildContentViews];
    
    [self p_buildToolbarView];
    
    [self.customNavigation addExtraViewWithDetailModel:self.slideViewModel.initialDetailModel];
    
    [self.view bringSubviewToFront:self.customNavigation];
    
    if (self.slideHintView) {
        [self.view bringSubviewToFront:self.slideHintView];
    }
    
}

- (void)p_loadFirstAnswerContent {
    [self tt_startUpdate];
    WeakSelf;
    [self.slideViewModel fetchContentFromRemoteIfNeededWithComplete:^(WDFetchResultType type) {
        StrongSelf;
        if (type == WDFetchResultTypeDone) {
            self.firstAnswerSuccess = YES;
            [self p_loadListContentFirstTime:YES];
        }
        else if (type == WDFetchResultTypeEndLoading) {
            
        }
        else {
            NSString *tips = TTNetworkConnected() ? @"加载失败" : @"没有网络连接";
            [self tt_endUpdataData:NO error:[NSError errorWithDomain:tips code:-3 userInfo:@{@"errmsg":tips}]];
        }
    }];
}

- (void)p_loadListContentFirstTime:(BOOL)firstTime {
    if (_isListContentFetching) return;
    _isListContentFetching = YES;
    WeakSelf;
    [self.slideViewModel startFetchAnswerListWithResult:^(NSError *error) {
        StrongSelf;
        self.isListContentFetching = NO;
        if (firstTime) {
            [self tt_endUpdataData];
            [self p_loadListContentSuccess];
        }
        else {
            if (!error) {
                if (self.slideViewModel.hasCountChange) {
                    [self.collectionView reloadData];
                }
                else {
                    [self p_refreshBottomViewDataWithTargetModel:self.currentAnswerCell.detailModel];
                }
            }
        }
    }];
}

- (void)p_refreshBottomViewDataWithTargetModel:(WDDetailModel *)targetModel {
    self.toolbarView.detailModel = targetModel;
}

- (void)p_changeTitleShowState:(BOOL)show
{
    BOOL isShow = self.customNavigation.isTitleShow;
    
    if (isShow == show) return;
    
    if (self.slideViewModel.showSlideType == AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        [[WDSettingHelper sharedInstance_tt] wdSetDetailStatusBarStyleIsDefault:show];
        
        if (![TTDeviceHelper isPadDevice]) {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                if (show) {
                    self.ttStatusBarStyle = UIStatusBarStyleDefault;
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                }
                else {
                    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                }
            }
        }
    }
    
    [self.customNavigation setTitleShow:show];
    
    if (show && !isShow) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
        [extra setValue:_currentAnswerCell.detailModel.answerEntity.ansid forKey:@"item_id"];
        [extra setValue:[_currentAnswerCell getDetailViewUserID] forKey:@"user_id"];
        [TTTracker event:kWDDetailViewControllerUMEventName label:@"show_titlebar_pgc" value:@(_currentAnswerCell.detailModel.answerEntity.ansid.longLongValue) extValue:nil extValue2:nil dict:extra];
    }
}

#pragma mark - indicator view

// 因为滑动方式变了，所以这个其实没用了
- (void)p_showSlideHelperView
{
    self.sliderHelpView = [[WDNewsHelpView alloc] initWithFrame:self.view.bounds];
    self.sliderHelpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.sliderHelpView setImage:[UIImage themedImageNamed:@"slide.png"]];
    [self.sliderHelpView setText:NSLocalizedString(@"右滑返回", nil)];
    [self.view addSubview:self.sliderHelpView];
}

// 右上角点此添加权限view
- (void)p_showIndicatorPolicyView
{
    CGFloat originY = [TTDeviceHelper isIPhoneXDevice] ? 78.0f : 58.0f;
    CGPoint anchorPoint = CGPointMake(self.view.width - 25.0f, originY);
    NSString *imageName = @"detail_close_icon";
    TTBubbleView *bubbleView = [[TTBubbleView alloc] initWithAnchorPoint:anchorPoint imageName:imageName tipText:@"点此设置评论权限" attributedText:nil
                                                          arrowDirection:TTBubbleViewArrowUp lineHeight:0 viewType:1];
    [self.navigationController.view addSubview:bubbleView];
    
    WeakSelf;
    [bubbleView showTipWithAnimation:YES automaticHide:NO animationCompleteHandle:nil tapHandle:^{
        StrongSelf;
        [self p_removeIndicatorPolicyView];
    }];
    self.bubbleView = bubbleView;

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kkHasShownCommentPolicyIndicatorViewKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_removeIndicatorPolicyView];
    });
}

- (void)p_removeIndicatorPolicyView
{
    [self.bubbleView removeFromSuperview];
    self.bubbleView = nil;
}

- (void)p_showEnterFoldAnswerAlert
{
    self.enterFoldIndicator = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"进入折叠回答区" indicatorImage:nil dismissHandler:nil];
    [self.enterFoldIndicator showFromParentView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.enterFoldIndicator dismissFromParentView];
    });
}

- (void)p_showEnterFoldAnswerAlertIfNeededWithIndex:(NSInteger)index {
    BOOL showEnterFold = [self.slideViewModel isFirstFoldAnswerWithIndex:index];
    if (showEnterFold) {
        [self p_showEnterFoldAnswerAlert];
    }
}

#pragma mark - build view

- (void)p_buildCustomNavigationView {
    self.customNavigation = [[WDDetailSlideNavigationView alloc] initWithFrame:[self p_frameForNavigationViewIsStatusHeightChanged:NO]];
    self.customNavigation.showSlideType = self.slideViewModel.showSlideType;
    self.customNavigation.delegate = self;
    self.customNavigation.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.customNavigation];
}

- (void)p_buildContentViews {
    if ([TTDeviceHelper isPadDevice]) {
        self.fullBgView = [[SSThemedView alloc] initWithFrame:[self p_frameForFullBgView]];
        self.fullBgView.backgroundColorThemeKey = kColorBackground4;
        self.wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [self p_buildTopBgView];
        [self p_buildHeaderView];
        [self p_buildCollectionView];
        [self.wrapperView addSubview:self.fullBgView];
        self.wrapperView.targetView = self.fullBgView;
        [self.view addSubview:self.wrapperView];
    }
    else {
        [self p_buildTopBgView];
        [self p_buildHeaderView];
        [self p_buildCollectionView];
    }
}

- (void)p_buildTopBgView {
    if (self.slideViewModel.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) return;
    self.topBgView = [[SSThemedView alloc] initWithFrame:[self p_frameForTopBgView]];
    self.topBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.topBgView.backgroundColor = [UIColor colorWithHexString:@"#67778B"];
    }
    else {
        self.topBgView.backgroundColor = [UIColor colorWithHexString:@"#333B45"];
    }
    if ([TTDeviceHelper isPadDevice]) {
        [self.fullBgView addSubview:self.topBgView];
    }
    else {
        [self.view addSubview:self.topBgView];
    }
}

- (void)p_buildHeaderView {
    
    if (self.slideViewModel.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        self.whiteHeaderView = [[WDDetailSlideWhiteHeaderView alloc] initWithFrame:[self p_frameForHeaderView] detailModel:self.slideViewModel.initialDetailModel];
        self.whiteHeaderView.delegate = self;
    }
    else {
        self.blueHeaderView = [[WDDetailSlideHeaderView alloc] initWithFrame:[self p_frameForHeaderView] detailModel:self.slideViewModel.initialDetailModel];
        self.blueHeaderView.delegate = self;
    }
    
    CGFloat y;
    if ([TTDeviceHelper isPadDevice]) {
        y = 0;
        [self.fullBgView addSubview:self.headerView];
    }
    else {
        y = self.customNavigation.height;
        [self.view addSubview:self.headerView];
    }
    
    if (self.slideViewModel.showSlideType == AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        __weak typeof(self) wself = self;
        [self.KVOController observe:self.headerView keyPath:@"frame" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            __strong typeof(wself) self = wself;
            if (self.headerView.top - y > 0) {
                self.topBgView.height = self.headerView.top - y;
            }
            else {
                self.topBgView.height = 0;
            }
        }];
    }
    
}

// 现在同一时间加载几个完全由系统决定；貌似会提前加载一个
- (void)p_buildCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[WDCollectionView alloc] initWithFrame:[self p_frameForFullScrollView] collectionViewLayout:layout];
    //    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[WDDetailAnswerNewCell class] forCellWithReuseIdentifier:@"detailAnswerNewCell"];
    if ([TTDeviceHelper isPadDevice]) {
        [self.fullBgView addSubview:self.collectionView];
        [self.fullBgView bringSubviewToFront:self.headerView];
        
        if (self.slideViewModel.isNeedShowSlideHint) {
            self.slideHintView = [[WDDetailSlideHintView alloc] initWithFrame:self.fullBgView.bounds];
            self.slideHintView.delegate = self;
            [self.fullBgView addSubview:self.slideHintView];
            [self.slideHintView setSlideHintViewIfNeeded];
        }
    }
    else {
        [self.view addSubview:self.collectionView];
        [self.view bringSubviewToFront:self.headerView];
        
        if (self.slideViewModel.isNeedShowSlideHint) {
            self.slideHintView = [[WDDetailSlideHintView alloc] initWithFrame:self.view.bounds];
            self.slideHintView.delegate = self;
            [self.view addSubview:self.slideHintView];
            [self.slideHintView setSlideHintViewIfNeeded];
        }
    }
    
    self.lastScrollWidth = self.collectionView.width;
    
    if ([TTDeviceHelper isPadDevice]) {
        __weak typeof(self) wself = self;
        [self.KVOController observe:self.collectionView keyPath:@"frame" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            __strong typeof(wself) self = wself;
            if (self.lastScrollWidth != _collectionView.width) {
                self.lastScrollWidth = _collectionView.width;
                [self.collectionView reloadData];
                [self.collectionView setContentOffset:CGPointMake(self.currentAnswerCell.index * self.collectionView.width, 0)];
            }
        }];
    }
    
}

- (void)p_buildToolbarView {
    self.toolbarView = [[WDBottomToolView alloc] initWithFrame:[self p_frameForToolBarViewIsStatusHeightChanged:NO]];
    self.toolbarView.detailModel = self.slideViewModel.initialDetailModel;
    self.toolbarView.delegate = self;
    self.toolbarView.banEmojiInput = YES;
    [self.view addSubview:self.toolbarView];
}

- (CGRect)p_frameForNavigationViewIsStatusHeightChanged:(BOOL)isStatusHeightChanged {
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat statusBarOffset = statusBarHeight - 20.f;
    CGFloat customNaviHeight = 64.f - statusBarOffset;
    CGFloat topY = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        customNaviHeight = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
    }
    else if (statusBarOffset == 0) {
        // 非第一次
        if (isStatusHeightChanged) {
            topY = -20;
        }
    }
    return CGRectMake(0, topY, self.view.width, customNaviHeight);
}

- (CGRect)p_frameForFullBgView {
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat y = self.customNavigation.height;
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        CGRect rect = CGRectMake(edgePadding, y, windowSize.width - edgePadding*2, windowSize.height - y - [self DetailGetToolbarHeight]);
        return rect;
    }
    return CGRectZero;
}

- (CGFloat)DetailGetToolbarHeight
{
    return ([TTDeviceHelper isPadDevice] ? 50 : self.view.tt_safeAreaInsets.bottom ? self.view.tt_safeAreaInsets.bottom + 44 : 44) + [TTDeviceHelper ssOnePixel];
}

- (CGRect)p_frameForTopBgView {
    CGRect rect;
    CGFloat y = self.customNavigation.height;
    if ([TTDeviceHelper isPadDevice]) {
        y = 0;
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        rect = CGRectMake(0, y, windowSize.width - edgePadding*2, 0);
    }
    else {
        rect = CGRectMake(0, y, SSWidth(self.view), 0);
    }
    return rect;
}

- (CGRect)p_frameForHeaderView {
    CGRect rect;
    CGFloat y = self.customNavigation.height;
    if ([TTDeviceHelper isPadDevice]) {
        y = 0;
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        rect = CGRectMake(0, y, windowSize.width - edgePadding*2, 0);
    }
    else {
        rect = CGRectMake(0, y, SSWidth(self.view), 0);
    }
    return rect;
}

- (CGRect)p_frameForFullScrollView {
    CGRect rect;
    CGFloat headerHeight = self.headerView ? self.headerView.height : 0;
    CGFloat y = self.customNavigation.height;
    if ([TTDeviceHelper isPadDevice]) {
        y = 0;
        rect = CGRectMake(0, y + headerHeight, _fullBgView.width, _fullBgView.height);
    } else {
        rect =  CGRectMake(0, y + headerHeight, SSWidth(self.view), SSHeight(self.view) - y - [self DetailGetToolbarHeight]);
    }
    if ([TTDeviceHelper isIPhoneXDevice]) {
        return rect;
    }
    CGFloat fixHotPotHeight = ([[UIApplication sharedApplication] statusBarFrame].size.height - 20);
    if (fixHotPotHeight > 0) {
        rect.size.height -= fixHotPotHeight;
    }
    return rect;
}

- (CGRect)p_frameForToolBarViewIsStatusHeightChanged:(BOOL)isStatusHeightChanged {
    CGRect rect;
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        rect = CGRectMake(0, self.view.height - [self DetailGetToolbarHeight], windowSize.width, [self DetailGetToolbarHeight]);
    }
    else {
        rect = CGRectMake(0, self.view.height - [self DetailGetToolbarHeight], SSWidth(self.view), [self DetailGetToolbarHeight]);
    }
    if ([TTDeviceHelper isIPhoneXDevice]) {
        return rect;
    }
    CGFloat fixHotPotHeight = ([[UIApplication sharedApplication] statusBarFrame].size.height - 20);
    if (fixHotPotHeight > 0) {
        rect.origin.y -= fixHotPotHeight;
    }
    else {
        // 非第一次
        if (isStatusHeightChanged) {
            rect.origin.y -= 20;
        }
    }
    return rect;
}

#pragma mark - Tracker

- (void)p_sendDetailDeallocTrack
{
    NSString *leaveType;
    if (!_closeButtonTouched) {
        if (_backButtonTouched) {
            ttTrackEvent(kWDDetailViewControllerUMEventName, @"back_button");
            leaveType = @"page_back_button";
        }
        else {
            ttTrackEvent(kWDDetailViewControllerUMEventName, @"back_gesture");
            leaveType = @"back_gesture";
        }
    }
    else {
        leaveType = @"page_close_button";
    }
}

- (void)p_sendDetailLogicTrackWithLabel:(NSString *)label
{
    [_currentAnswerCell.natantViewModel tt_sendDetailLogicTrackWithLabel:label];
}

#pragma mark - Getter & Setter


- (DetailActionRequestManager *)actionManager
{
    if (!_actionManager) {
        _actionManager = [[DetailActionRequestManager alloc] init];
    }
    return _actionManager;
}

- (SSThemedView <WDDetailSlideHeaderViewProtocol>*)headerView {
    if (self.slideViewModel.showSlideType != AnswerDetailShowSlideTypeBlueHeaderWithHint) {
        return self.whiteHeaderView;
    }
    return self.blueHeaderView;
}

#pragma mark - WDDetailSlideViewModelDataSource

- (BOOL)needReturn
{
    BOOL needReturn = NO;
    NSArray *reverseViewControllers = [[[self.navigationController viewControllers] reverseObjectEnumerator] allObjects];
    for (SSViewControllerBase *viewController in reverseViewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(@"WDDetailContainerViewController")]) {
            continue;
        } else {
            if ([viewController isKindOfClass:NSClassFromString(@"WDWendaListViewController")] || [viewController isKindOfClass:NSClassFromString(@"WDWendaMoreListViewController")]) {
                if ([viewController respondsToSelector:@selector(viewModel)]) {
                    id viewModel = [viewController valueForKey:@"viewModel"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    if ([viewModel respondsToSelector:@selector(qID)]) {
                        NSString *qid = [viewModel valueForKey:@"qID"];
                        if ([qid isEqualToString:self.slideViewModel.currentDetailModel.answerEntity.qid]) {
                            needReturn = YES;
                        }
                    }
#pragma clang diagnostic pop
                }
            }
            break;
        }
    }
    return needReturn;
}

@end
