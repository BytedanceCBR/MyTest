//
//  TTRecommendUserCell.m
//  Article
//
//  Created by 王双华 on 16/11/30.
//
//

#import "TTRecommendUserCell.h"
#import "ExploreOrderedData.h"
#import "RecommendUser.h"
#import "TTUISettingHelper.h"
#import "TTRecommendCollectionViewCell.h"
#import "TTRecommendModel.h"

#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "ExploreDislikeView.h"
#import "ExploreMixListDefine.h"
#import "ExploreArticleCellViewConsts.h"
#import "SSImpressionModel.h"
#import "ArticleImpressionHelper.h"
#import "FriendDataManager.h"
#import "TTIndicatorView.h"
#import "TTFollowThemeButton.h"
#import "TTAccountManagerHeader.h"
#import "TTFirstConcernManager.h"
#import "TTRoute.h"
#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"

#define kHeaderViewHeight 40
#define kFooterViewHeight 40

#define kLeftPadding 15
#define kRightPadding 15

#define kRecommendLabelHeight ([TTDeviceHelper isScreenWidthLarge320] ? 20 : 18)
#define kShowMoreLabelHeight 18

#define kRecommendLabelFontSize ([TTDeviceHelper isScreenWidthLarge320] ? 16 : 14)
#define kShowMoreLabelFontSize  14

@interface TTRecommendUserCell ()

@property (nonatomic, strong) TTRecommendUserCellView *recommendUserCellView;

@end

@implementation TTRecommendUserCell

+ (Class)cellViewClass
{
    return [TTRecommendUserCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_recommendUserCellView) {
        self.recommendUserCellView = [[TTRecommendUserCellView alloc] initWithFrame:self.bounds];
    }
    return _recommendUserCellView;
}

- (void)willDisplay
{
    [_recommendUserCellView willDisplay];
}

- (void)didEndDisplaying
{
    [_recommendUserCellView didEndDisplaying];
}

@end

@interface TTRecommendUserCellView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) RecommendUser *recommendUser;

@property (nonatomic, strong) SSThemedView *topRect;
@property (nonatomic, strong) SSThemedView *bottomRect;
@property (nonatomic, strong) SSThemedLabel *recommendLabel;
@property (nonatomic, strong) SSThemedLabel *showMoreLabel;
@property (nonatomic, strong) SSThemedImageView *arrowImageView;
@property (nonatomic, strong) TTAlphaThemedButton *unInterestedButton;
@property (nonatomic, assign) BOOL isDisplay;
@end

@implementation TTRecommendUserCellView

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (cacheH > 0) {
                if ([orderedData nextCellHasTopPadding]){
                    cacheH -= kCellSeprateViewHeight();
                }
                if ([orderedData preCellHasBottomPadding]) {
                    cacheH -= kCellSeprateViewHeight();
                }
                if (cacheH > 0) {
                    return cacheH;
                }
            }
            return 0.f;
        }
        

        
        CGFloat height = kHeaderViewHeight;

        height += [TTDeviceUIUtils tt_newPadding:180.f];//collectionView的高度

        height += kFooterViewHeight;
        
        height += 2 * kCellSeprateViewHeight();
        
        height = ceilf(height);
        
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];

        if (height > 0) {
            if ([orderedData nextCellHasTopPadding]){
                height -= kCellSeprateViewHeight();
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kCellSeprateViewHeight();
            }
            if (height > 0) {
                return height;
            }
        }

    }
    return 0.f;
}

- (NSUInteger)refer {
    return [[self cell] refer];
}

- (id)cellData {
    return self.orderedData;
}

- (BOOL)shouldRefresh {
    if ([[self recommendUser] needRefreshUI]) {
        return [[self recommendUser] needRefreshUI];
    }
    return NO;
}

- (void)refreshDone {
    if ([self recommendUser]) {
        [[self recommendUser] setNeedRefreshUI:YES];
    }
}

- (void)willDisplay {
    _isDisplay = YES;
    [[SSImpressionManager shareInstance] enterRecommendUserList];
}

- (void)didEndDisplaying
{
    _isDisplay = NO;
    [[SSImpressionManager shareInstance] leaveRecommendUserList];
}


- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:142.f], [TTDeviceUIUtils tt_newPadding:180.f]);
        flowLayout.minimumInteritemSpacing = [TTDeviceUIUtils tt_newPadding:7.f];
        flowLayout.minimumLineSpacing = [TTDeviceUIUtils tt_newPadding:7.f];
        flowLayout.headerReferenceSize = CGSizeMake(kLeftPadding, [TTDeviceUIUtils tt_newPadding:180.f]);
        flowLayout.footerReferenceSize = CGSizeMake(kLeftPadding, 0);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TTRecommendCollectionViewCell class] forCellWithReuseIdentifier:TTRecommendCollectionViewCellIdentifier];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

/** 顶部分割面 */
- (SSThemedView *)topRect {
    if (_topRect == nil) {
        _topRect = [[SSThemedView alloc] init];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }
    return _topRect;
}

/** 底部分割线 */
- (SSThemedView *)bottomRect {
    if (_bottomRect == nil) {
        _bottomRect = [[SSThemedView alloc] init];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }
    return _bottomRect;
}


- (SSThemedLabel *)recommendLabel {
    if (!_recommendLabel) {
        _recommendLabel = [[SSThemedLabel alloc] init];
        _recommendLabel.font = [UIFont systemFontOfSize:kRecommendLabelFontSize];
        _recommendLabel.numberOfLines = 1;
        _recommendLabel.textColorThemeKey = kColorText1;
        _recommendLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        [self addSubview:_recommendLabel];
    }
    return _recommendLabel;
}

- (SSThemedLabel *)showMoreLabel {
    if (!_showMoreLabel) {
        _showMoreLabel = [[SSThemedLabel alloc] init];
        _showMoreLabel.font = [UIFont systemFontOfSize:kShowMoreLabelFontSize];
        _showMoreLabel.numberOfLines = 1;
        _showMoreLabel.textColorThemeKey = kColorText1;
        _showMoreLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        [self addSubview:_showMoreLabel];
    }
    return _showMoreLabel;
}

- (SSThemedImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 14)];
        _arrowImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        _arrowImageView.imageName = @"all_card_arrow";
        [self addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (TTAlphaThemedButton *)unInterestedButton {
    if (!_unInterestedButton) {
        _unInterestedButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _unInterestedButton.imageName = @"add_textpage.png";
        _unInterestedButton.backgroundColor = [UIColor clearColor];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_unInterestedButton];
    }
    return _unInterestedButton;
}

- (void)unInterestButtonClicked:(id)sender
{
    [ExploreDislikeView dismissIfVisible];
    [self showMenu];
}

- (void)showMenu
{
    if (TTPlatformEnable([TTFeedDislikeView class])) {
        TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
        TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
        viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.originalData.uniqueID];
        viewModel.logExtra = self.orderedData.logExtra;
        [dislikeView refreshWithModel:viewModel];
        CGPoint point = self.unInterestedButton.center;
        [dislikeView showAtPoint:point
                        fromView:self.unInterestedButton
                 didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                     // Cast view to `ExploreDislikeView`, `exploreDislikeViewOKBtnClicked` only calls `selectedWords`, which is compatible
                     [self exploreDislikeViewOKBtnClicked:(ExploreDislikeView *)view];
                 }];
    } else {
        // 新版不感兴趣测试
        ExploreDislikeView *popupView = [[ExploreDislikeView alloc] initWithFrame:CGRectZero];
        popupView.delegate = self;
        [popupView refreshWithData:self.orderedData];

        CGPoint p = self.unInterestedButton.center;
        [popupView showAtPoint:p fromView:self.unInterestedButton];
    }
}

#pragma mark - ExploreDislikeViewDelegate

- (void)exploreDislikeViewOKBtnClicked:(ExploreDislikeView *)dislikeView {
    if (!self.orderedData) {
        return;
    }
    NSArray *filterWords = [dislikeView selectedWords];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}


- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _collectionView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _recommendLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _showMoreLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _arrowImageView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
}

- (void)refreshUI {
    self.topRect.frame = CGRectMake(0, 0, 0, kCellSeprateViewHeight());
    self.bottomRect.frame = CGRectMake(0, 0, 0, kCellSeprateViewHeight());
    
    self.recommendLabel.frame = CGRectMake(kLeftPadding, (kHeaderViewHeight - kRecommendLabelHeight) / 2, self.width - kLeftPadding - kRightPadding, kRecommendLabelHeight);
    
    self.collectionView.frame = CGRectMake(0, kHeaderViewHeight, self.width, [TTDeviceUIUtils tt_newPadding:180.f]);
    
    self.showMoreLabel.top = self.collectionView.bottom + (kFooterViewHeight - kShowMoreLabelHeight) / 2;
    self.showMoreLabel.left = kLeftPadding;
    
    CGFloat maxWidth = self.width - 2 * kLeftPadding - kCellUninterestedButtonWidth - self.arrowImageView.width - 6;
    if (self.showMoreLabel.width > maxWidth) {
        self.showMoreLabel.width = maxWidth;
    }
    self.showMoreLabel.height = kShowMoreLabelHeight;
    
    self.arrowImageView.left = self.showMoreLabel.right + 6;
    self.arrowImageView.centerY = self.showMoreLabel.centerY;
    
    self.unInterestedButton.centerY = self.recommendLabel.centerY;
    self.unInterestedButton.centerX = self.width - kLeftPadding - kCellUninterestedButtonWidth / 2;
    
    if ([self.orderedData preCellHasBottomPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = - kCellSeprateViewHeight();
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    }
    
    if (!([self.orderedData nextCellHasTopPadding])) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    }
    else{
        self.bottomRect.hidden = YES;
    }
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    if ([self.orderedData.originalData isKindOfClass:[RecommendUser class]]) {
        self.recommendUser = (RecommendUser *)self.orderedData.originalData;
    }
    else {
        self.recommendUser = nil;
        return;
    }
    
    self.recommendLabel.text = _recommendUser.title;
    [self.recommendLabel sizeToFit];
    
    self.showMoreLabel.text = _recommendUser.showMore;
    [self.showMoreLabel sizeToFit];
    
    [self.collectionView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.dragging) {
        if (scrollView.contentOffset.x == scrollView.contentSize.width - scrollView.width) {
            [scrollView setContentOffset:CGPointMake(scrollView.contentSize.width - scrollView.width - 1.f, 0)];
        }
        else if (scrollView.contentOffset.x == 0) {
            [scrollView setContentOffset:CGPointMake(1.f, 0)];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((*targetContentOffset).x == scrollView.contentSize.width - scrollView.width){
        (*targetContentOffset).x = scrollView.contentSize.width - scrollView.width - 1.f;
    }
    else if ((*targetContentOffset).x == 0){
        (*targetContentOffset).x = 1.f;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self trackWithLabel:@"flip" extraDic:nil];
}

- (void)trackWithLabel:(NSString *)label extraDic:(NSDictionary *)extraDic
{
    wrapperTrackEventWithCustomKeys(@"people_cell", label, self.recommendUser.cellID, nil, extraDic);
}

#pragma UICollectionViewDelegate
//展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.recommendUser.userListModels) {
        return self.recommendUser.userListModels.count;
    }
    return 0;
}

//展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.recommendUser.userListModels count] == 0) {
        return [[UICollectionViewCell alloc] init];
    }
    TTRecommendModel *model = self.recommendUser.userListModels[indexPath.row];
    TTRecommendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TTRecommendCollectionViewCellIdentifier forIndexPath:indexPath];
    __weak typeof(cell) wCell = cell;
    cell.followPressed = ^{
        NSString *userID = model.userID;
        if ([userID isEqualToString:[TTAccountManager userID]] || isEmptyString(userID)) {
            return;
        }
        
        FriendDataManager *dataManager = [FriendDataManager sharedManager];
        FriendActionType actionType;
        if (model.isFollowing) {
            actionType = FriendActionTypeUnfollow;
        }
        else {
            actionType = FriendActionTypeFollow;
        }
        
        [dataManager newStartAction:actionType userID:model.userID platform:nil name:nil from:nil reason:nil newReason:model.reason newSource:@(FriendFollowNewSourceFeedCard) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
            if (!error) {
                NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                model.isFollowing = [user tt_boolValueForKey:@"is_following"];
                long index = indexPath.row + 1;
                if (model.isFollowing) {
                    if (![TTAccountManager isLogin]) {
                        [self trackWithLabel:[NSString stringWithFormat:@"follow_click_logoff_%ld", index] extraDic:@{@"user_id":userID}];
                    }
                    else{
                        [self trackWithLabel:[NSString stringWithFormat:@"follow_click_%ld",index] extraDic:@{@"user_id":userID}];
                    }
                    
                }
                else {
                    if (![TTAccountManager isLogin]) {
                        [self trackWithLabel:[NSString stringWithFormat:@"cancel_follow_click_logoff_%ld", index] extraDic:@{@"user_id":userID}];
                    }
                    else{
                        [self trackWithLabel:[NSString stringWithFormat:@"cancel_follow_click_%ld",index] extraDic:@{@"user_id":userID}];
                    }
                }
                [wCell.subscribeButton stopLoading:^{
                }];
            }
            else {
                NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                if (isEmptyString(hint)) {
                    hint = NSLocalizedString(actionType == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                }
                [wCell.subscribeButton stopLoading:^{
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                }];
            }
        }];
        
    };
    [cell configWithModel:model];
    
    return cell!=nil ? cell : [[UICollectionViewCell alloc] init];
}

#pragma mark --UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.recommendUser.userListModels count] == 0) {
        return ;
    }
    TTRecommendModel *model = self.recommendUser.userListModels[indexPath.row];
    NSString *openURL = [NSString stringWithFormat:@"sslocal://profile?uid=%@&page_source=%@",model.userID, @(0)];
    if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openURL]]) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
        [self trackWithLabel:[NSString stringWithFormat:@"click_%ld",(long)(indexPath.row + 1)] extraDic:@{@"user_id":model.userID}];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([self.recommendUser.userListModels count] == 0) {
        return ;
    }
    /*impression统计相关*/
    TTRecommendModel *model = self.recommendUser.userListModels[indexPath.row];
    [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:model.userID status:_isDisplay? SSImpressionStatusRecording:SSImpressionStatusSuspend userInfo:nil];

}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([self.recommendUser.userListModels count] == 0) {
        return ;
    }
    // impression统计
    TTRecommendModel *model = self.recommendUser.userListModels[indexPath.row];
    [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:model.userID status:SSImpressionStatusEnd userInfo:nil];
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    RecommendUser *recommendUser = self.recommendUser;
    if (recommendUser != nil) {
        NSURL *openURL = [TTStringHelper URLWithURLString:recommendUser.showMoreJumpURL];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL];
            wrapperTrackEventWithCustomKeys(@"people_cell", @"more", recommendUser.cellID, nil, nil);
        }
    }
}

@end
