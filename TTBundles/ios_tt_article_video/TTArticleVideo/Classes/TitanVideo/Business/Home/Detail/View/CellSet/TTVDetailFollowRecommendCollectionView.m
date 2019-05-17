//
//  TTVDetailFollowRecommendCollectionView.m
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import "TTVDetailFollowRecommendCollectionView.h"
#import "TTUISettingHelper.h"
#import "FriendDataManager.h"
#import "TTFollowThemeButton.h"
#import "TTIndicatorView.h"
#import "TTAlphaThemedButton.h"
#import "TTVDetailFollowRecommendCardCell.h"
#import "SSImpressionManager.h"
#import "TTVDetailFollwRecommendCollectionViewFLowLayout.h"
#import "TTAccountManager.h"
#import "TTUGCTrackerHelper.h"

#define kLeftPadding 15
#define kRightPadding 15

@interface TTVDetailFollowRecommendCollectionView () <UICollectionViewDataSourcePrefetching, TTVDetailFollowRecommendCardCellDelegate, SSImpressionProtocol>

@property (nonatomic, assign) BOOL needScrollBehindFollowed;
@property (nonatomic, weak) UICollectionViewCell* currentClickFollowCell;

@property (nonatomic, assign) BOOL isDisplay;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, strong) TTHttpTask* task;
@property (nonatomic, strong) NSArray<id<TTVDetailRelatedRecommendCellViewModelProtocol> > *originalCardModels;
@property (nonatomic, strong) NSMutableArray<id<TTVDetailRelatedRecommendCellViewModelProtocol> > *userCardModels;

@property (nonatomic, weak) id<UICollectionViewDelegate> collectionViewDelegate;

@property (nonatomic, assign) CGFloat beginDragX;

@property (nonatomic, copy) NSString *position;

@end

@implementation TTVDetailFollowRecommendCollectionView


- (void)dealloc {
    [[SSImpressionManager shareInstance] removeRegist:self];
    self.delegate = nil;
    self.dataSource = nil;
    self.collectionViewDelegate = nil;
}

+(instancetype)collectionView {
    TTVDetailFollwRecommendCollectionViewFLowLayout *flowLayout = [[TTVDetailFollwRecommendCollectionViewFLowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:142.f], [TTDeviceUIUtils tt_newPadding:180.f]);
    flowLayout.minimumInteritemSpacing = [TTDeviceUIUtils tt_newPadding:7.f];
    flowLayout.minimumLineSpacing = [TTDeviceUIUtils tt_newPadding:7.f];
    flowLayout.headerReferenceSize = CGSizeMake(kLeftPadding, [TTDeviceUIUtils tt_newPadding:180.f]);
    flowLayout.footerReferenceSize = CGSizeMake(kLeftPadding, 0);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    TTVDetailFollowRecommendCollectionView* result = [[TTVDetailFollowRecommendCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    result.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    result.delegate = result;
    result.dataSource = result;
    result.scrollsToTop = NO;
    result.showsHorizontalScrollIndicator = NO;
    [result registerClass:[TTVDetailFollowRecommendCardCell class] forCellWithReuseIdentifier:TTVDetailFollowRecommendCellIdentifier];
    
    result.followSource = TTFollowNewSourceRecommendUserOtherCategory;
    return result;
}

- (void)configUserModels:(NSArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> *)userModels{
    if ([self modelChanged:userModels]) {
        _originalCardModels = userModels;
        self.contentOffset = CGPointZero;
        _userCardModels = [NSMutableArray arrayWithArray:userModels];
        [_task cancel];
        _isLoadingMore = NO;
        [self reloadData];
    }
    
    if (self.userCardModels.count == 0) {
        if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(onCardEmpty)]) {
            [self.recommendUserDelegate onCardEmpty];
        }
    }
}

- (BOOL)modelChanged:(NSArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> *)remoteModels {
    if (_originalCardModels.count != remoteModels.count) {
        return YES;
    }
    int index = 0;
    for (id<TTVDetailRelatedRecommendCellViewModelProtocol> model in remoteModels) {
        if (![model isEqual:_originalCardModels[index]]) {
            return YES;
        }
        index++;
    }
    return NO;
}


- (void)replaceWithSupplementModel:(id<TTVDetailRelatedRecommendCellViewModelProtocol> )model indexPath:(NSIndexPath *)indexPath oldModel:(id<TTVDetailRelatedRecommendCellViewModelProtocol> )oldModel {
    if (indexPath.item >= _userCardModels.count) {
        return;
    }
    
    if ([self.userCardModels containsObject:oldModel]) {
        [TTTrackerWrapper eventV3:@"follow_card" params:@{@"action_type":@"show", @"category_name":[self _currentCategoryName], @"is_direct":@(0), @"source":@"list_follow_card_horizon_related", @"to_user_id":model.userId?:@"", @"order":@(indexPath.item+1)}];
        [self.userCardModels replaceObjectAtIndex:indexPath.item withObject:model];
        if ([TTDeviceHelper OSVersionNumber] < 8.0f) { //iOS7 crash 保护 https://fabric.io/news/ios/apps/com.ss.iphone.article.news/issues/59cb056abe077a4dcc4e42e9?time=last-thirty-days
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
            });
        } else {
            [(TTVDetailFollwRecommendCollectionViewFLowLayout *)self.collectionViewLayout setIndex:indexPath.item];
            TTVDetailFollowRecommendCardCell *cell = (TTVDetailFollowRecommendCardCell *)[self cellForItemAtIndexPath:indexPath];
            cell.hidden = YES;
            [self performBatchUpdates:^{
                [self reloadItemsAtIndexPaths:@[indexPath]];
            } completion:^(BOOL finished) {
                cell.hidden = NO;
                //如果不重置，在某些特殊情况下新出的cell并没有被系统还原正确大小
                dispatch_async(dispatch_get_main_queue(), ^{
                    TTVDetailFollowRecommendCardCell *newcell = (TTVDetailFollowRecommendCardCell *)[self cellForItemAtIndexPath:indexPath];
                    newcell.transform = CGAffineTransformIdentity;
                });
            }];
        }
    }
    
    if ([self.originalCardModels containsObject:oldModel]) {
        NSMutableArray* array = [NSMutableArray arrayWithArray:self.originalCardModels];
        NSInteger index = [self.originalCardModels indexOfObject:oldModel];
        [array replaceObjectAtIndex:index withObject:model];
        _originalCardModels = array.copy;
        if (_recommendUserDelegate && [_recommendUserDelegate respondsToSelector:@selector(onReplaceModel:newModel:originalModels:)]) {
            [_recommendUserDelegate onReplaceModel:oldModel newModel:model originalModels:_originalCardModels];
        }
    }
}

- (void)performRecommendUpdateWithCell:(TTVDetailFollowRecommendCardCell *)cell {
    [self performSelector:@selector(followSuccess:) withObject:cell afterDelay:0.4];
}

- (void) followSuccess:(TTVDetailFollowRecommendCardCell *) cell {
    if (_needScrollBehindFollowed && cell != nil && cell == _currentClickFollowCell) {
        NSIndexPath* firstVisibleItem = nil;
        for (NSIndexPath* indexPath in self.indexPathsForVisibleItems) { //顺序不一定对，要做取最小
            if (firstVisibleItem == nil || indexPath.section < firstVisibleItem.section || indexPath.item < firstVisibleItem.item) {
                firstVisibleItem = indexPath;
            }
        }
        if (firstVisibleItem != nil) {
            
            UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*) self.collectionViewLayout;
            
            CGFloat contentX = (flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing)*(firstVisibleItem.item+1) + flowLayout.headerReferenceSize.width - flowLayout.minimumInteritemSpacing;
            
            contentX = MIN(contentX, self.contentSize.width - self.width);
            if (contentX > 0) {
                [self setContentOffset:CGPointMake(contentX, 0) animated:YES];
            }
        }
        
        _needScrollBehindFollowed = NO;
        _currentClickFollowCell = nil;
    }
}

#pragma mark - UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_userCardModels count] > 0) {
        return _userCardModels.count;
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTVDetailFollowRecommendCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TTVDetailFollowRecommendCellIdentifier forIndexPath:indexPath];
    if (_userCardModels.count == 0 || _userCardModels.count <= indexPath.item) {
        return cell;
    }
    
    id<TTVDetailRelatedRecommendCellViewModelProtocol> model = _userCardModels[indexPath.row];
    cell.delegate = self;
    cell.dislikeButton.hidden = self.disableDislike;
    
    [cell configWithModel:model];
    
    return cell ?: [[UICollectionViewCell alloc] init];
}

#pragma mark - UICollectionViewDataSourcePrefetching

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_userCardModels.count == 0 || _userCardModels.count <= indexPath.item) {
        return;
    }
    
    id<TTVDetailRelatedRecommendCellViewModelProtocol> model = _userCardModels[indexPath.row];
    NSString *openURL = [NSString stringWithFormat:@"sslocal://profile?uid=%@&page_source=%@&refer=follow_card",model.userId, @(0)];
    
    NSString *fromPage = nil;
    if (self.position){
        if ([_position isEqualToString:@"video_list"]){
            fromPage = @"list_follow_card_related";
        }else if ([_position isEqualToString:@"video_detail"]){
            fromPage = @"detail_follow_card";
        }
    }
    openURL = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:openURL categoryName:[self _currentCategoryName] fromPage:fromPage ?: @"detail_follow_card" groupId:nil profileUserId:[self _currentUniqueId]];
    
    // add by zjing 去掉个人主页跳转
//    if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openURL]]) {
//        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
        //        [self trackWithEvent:@"enter_homepage" extraDic:@{@"action_type":@"click_avatar",
        //                                                       @"to_user_id":model.userId}];
//    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (_userCardModels.count == 0 || _userCardModels.count <= indexPath.item) {
        return;
    }
    
    /*impression统计相关*/
    id<TTVDetailRelatedRecommendCellViewModelProtocol> model = _userCardModels[indexPath.row];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(impressionParams)]) {
        if ([self.recommendUserDelegate impressionParams].count > 0) {
            [params addEntriesFromDictionary:[self.recommendUserDelegate impressionParams]];
        }
    }
    [params setObject:[self sourceName] forKey:@"source"];
    [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:model.userId
                                                                    categoryName:[self _currentCategoryName]
                                                                          cellId:[self _currentUniqueId]
                                                                          status:_isDisplay? SSImpressionStatusRecording:SSImpressionStatusSuspend
                                                                           extra:params.copy];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([_userCardModels count] == 0 || _userCardModels.count <= indexPath.item) {
        return;
    }
    
    // impression统计
    id<TTVDetailRelatedRecommendCellViewModelProtocol> model = _userCardModels[indexPath.item];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(impressionParams)]) {
        if ([self.recommendUserDelegate impressionParams].count > 0) {
            [params addEntriesFromDictionary:[self.recommendUserDelegate impressionParams]];
        }
    }
    
    [params setObject:[self sourceName] forKey:@"source"];
    [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:model.userId
                                                                    categoryName:[self _currentCategoryName]
                                                                          cellId:[self _currentUniqueId]
                                                                          status:SSImpressionStatusEnd
                                                                           extra:params.copy];
}

#pragma -- mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _needScrollBehindFollowed = NO;
}

/**
 * 推人卡片滚动完成后不再进行卡片左对齐 pm:weiyanran
 - (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
 {
 UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*) self.collectionViewLayout;
 
 CGFloat endDragX = scrollView.contentOffset.x;
 
 if (endDragX < 0) {
 return;
 }
 
 NSUInteger index = (endDragX - flowLayout.headerReferenceSize.width)/(flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing);
 
 CGFloat contentX = (flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing)*(index+1) + flowLayout.headerReferenceSize.width - flowLayout.minimumInteritemSpacing;
 
 if (endDragX > _beginDragX) { //往后滑
 if (endDragX < contentX - flowLayout.itemSize.width*5/5) { //往后滑却没划过卡片的前1/5，则弹回去
 contentX = contentX - flowLayout.itemSize.width - flowLayout.minimumInteritemSpacing;
 }
 } else {
 if (endDragX < contentX - flowLayout.itemSize.width*0/5) { //往前滑且划过卡片的后1/5，则弹回去
 contentX = contentX - flowLayout.itemSize.width - flowLayout.minimumInteritemSpacing;
 }
 }
 contentX = MIN(contentX, self.contentSize.width - self.width);
 contentX = MAX(0, contentX);
 
 (*targetContentOffset).x = contentX;
 }
 */

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _beginDragX = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat endDragX = scrollView.contentOffset.x;
    if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(recordCollectionViewContentOffset:)]) {
        [self.recommendUserDelegate recordCollectionViewContentOffset:scrollView.contentOffset];
    }
    [self trackWithEvent:@"follow_card" extraDic:@{@"action_type": [NSString stringWithFormat:@"flip_%@", endDragX > _beginDragX? @"left":@"right"]}];
}

#pragma -- mark TTVDetailFollowRecommendCardCellDelegate
- (void)onClickFollow:(TTVDetailFollowRecommendCardCell *)cell {
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    id<TTVDetailRelatedRecommendCellViewModelProtocol> model = cell.model;
    if (model == nil) {
        return;
        
    }
    NSString *userID = model.userId;
    if ([userID isEqualToString:[TTAccountManager userID]] || isEmptyString(userID)) {
        return;
    }
    
    [cell.subscribeButton startLoading];
    
    FriendDataManager *dataManager = [FriendDataManager sharedManager];
    FriendActionType actionType;
    if (model.isFollowing.boolValue) {
        actionType = FriendActionTypeUnfollow;
    }
    else {
        actionType = FriendActionTypeFollow;
    }
    self.currentClickFollowCell = cell;
    self.needScrollBehindFollowed = YES;
    
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    __weak TTVDetailFollowRecommendCardCell* wCell = cell;
    
    TTFollowNewSource source = self.followSource;
    
    NSString * event = nil;
    if (FriendActionTypeFollow == actionType) {
        event = @"rt_follow";
    }else {
        event = @"rt_unfollow";
    }
    long index = indexPath.item + 1;
    NSMutableDictionary* extraDict = [NSMutableDictionary dictionaryWithObject:userID forKey:@"user_id"];
    [extraDict setValue:@"follow_card" forKey:@"source"];
    [extraDict setValue:@(index) forKey:@"order"];
    [extraDict setValue:@(source) forKey:@"server_source"];
    [extraDict setValue:([TTAccountManager userID] ?: @"") forKey:@"profile_user_id"]; //该值在外部delegate会进行覆盖，所有关注用户带来的推人卡片，外部delegate会赋值为源关注用户
    
    [extraDict setValue:@(1) forKey:@"is_follow_card"];
    
    [self trackWithEvent:event extraDic:extraDict];
    
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:actionType
                                             userID:model.userId
                                           platform:nil
                                               name:nil
                                               from:nil
                                             reason:nil
                                          newReason:model.recommendType
                                          newSource:@(source)
                                         completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                                             StrongSelf;
                                             if (!error) {
                                                 NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                                                 NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                                                 NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                                                 BOOL followResult = [user tt_boolValueForKey:@"is_following"];
                                                 model.isFollowing = @(followResult);
                                                 [wCell.subscribeButton stopLoading:^{
                                                 }];
                                                 if (followResult) {
                                                     [self performRecommendUpdateWithCell:wCell];
                                                 }
                                             } else {
                                                 [wCell.subscribeButton stopLoading:nil];
                                             }
                                         }];
}

- (void)onClickDislike:(TTVDetailFollowRecommendCardCell *)cell {
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    if ([self.userCardModels containsObject:cell.model]) {
        [self trackWithEvent:@"follow_card" extraDic:@{@"action_type": @"delete",
                                                       @"is_follow": cell.model.isFollowing?: @(0),
                                                       @"to_user_id": cell.model.userId ? cell.model.userId: @"",
                                                       @"order" : @(indexPath.item+1),
                                                       @"source" : @"list_follow_card_horizon_related",
                                                       @"category_name":[self _currentCategoryName],
                                                       @"is_direct":@(1)}];
        [self.userCardModels removeObject:cell.model];
        if ([TTDeviceHelper OSVersionNumber] < 8.0) { //针对iOS7可能的数组越界问题加保护 https://fabric.io/news/ios/apps/com.ss.iphone.article.news/issues/59806015be077a4dcc6e5efe
            [UIView performWithoutAnimation:^{
                [self reloadData];
            }];
        } else {
            [UIView performWithoutAnimation:^{
                [self deleteItemsAtIndexPaths:@[indexPath]];
            }];
        }
    }
    
//    FRUserRelationUserRecommendV1DislikeUserRequestModel *requestModel = [[FRUserRelationUserRecommendV1DislikeUserRequestModel alloc] init];
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    requestModel.dislike_user_id = [formatter numberFromString:cell.model.userId];
//    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
//        if (error) {
//
//        }
//    }];
    
    if ([self.originalCardModels containsObject:cell.model]) {
        NSMutableArray* array = [NSMutableArray arrayWithArray:self.originalCardModels];
        [array removeObject:cell.model];
        _originalCardModels = array.copy;
        if (_recommendUserDelegate && [_recommendUserDelegate respondsToSelector:@selector(onRemoveModel:originalModels:)]) {
            [_recommendUserDelegate onRemoveModel:cell.model originalModels:_originalCardModels];
        }
    }
    
    if (self.userCardModels.count == 0) {
        if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(onCardEmpty)]) {
            [self.recommendUserDelegate onCardEmpty];
        }
    }
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    if(delegate == self) {
        [super setDelegate:delegate];
    } else {
        self.collectionViewDelegate = delegate;
    }
}

- (NSArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> *)allUserModels {
    return self.userCardModels;
}

- (void)willDisplay {
    _isDisplay = YES;
    
    [[SSImpressionManager shareInstance] enterRecommendUserListWithCategoryName:[self _currentCategoryName] cellId:[self _currentUniqueId]];
    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)didEndDisplaying {
    _isDisplay = NO;
    
    [[SSImpressionManager shareInstance] leaveRecommendUserListWithCategoryName:[self _currentCategoryName] cellId:[self _currentUniqueId]];
}

- (void)needRerecordImpressions {
    if ([_userCardModels count] == 0) {
        return;
    }
    
    for (NSIndexPath* indexPath in self.indexPathsForVisibleItems) { //顺序不一定对，要做取最小
        if (_userCardModels.count > indexPath.row) {
            id<TTVDetailRelatedRecommendCellViewModelProtocol> model = _userCardModels[indexPath.row];
            NSMutableDictionary *params = @{}.mutableCopy;
            if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(impressionParams)]) {
                if ([self.recommendUserDelegate impressionParams].count > 0) {
                    [params addEntriesFromDictionary:[self.recommendUserDelegate impressionParams]];
                }
            }
            if (params.count <= 0) {
                params = nil;
            }
            
            [params setValue:[self sourceName] forKey:@"source"];
            [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:model.userId
                                                                            categoryName:[self _currentCategoryName]
                                                                                  cellId:[self _currentUniqueId]
                                                                                  status:_isDisplay? SSImpressionStatusRecording:SSImpressionStatusSuspend
                                                                                   extra:params.copy];
        }
    }
}

//impression需要
- (NSString*) _currentUniqueId {
    if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(impressionParams)]) {
        NSDictionary* params = [self.recommendUserDelegate impressionParams];
        NSString* uniqueId = [params tt_stringValueForKey:@"unique_id"];
        if (isEmptyString(uniqueId)) {
            uniqueId = [params tt_stringValueForKey:@"profile_user_id"];
        }
        
        if (!isEmptyString(uniqueId)) {
            return uniqueId;
        }
    }
    
    return @"";
}

//pgc相关动作／埋点需要
- (NSString*) _currentCategoryName {
    if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(impressionParams)]) {
        NSDictionary* params = [self.recommendUserDelegate impressionParams];
        NSString* categoryName = [params tt_stringValueForKey:@"category_name"];
        if (!isEmptyString(categoryName)) {
            return categoryName;
        }
    }
    
    return @"";
}

//impr 需要
- (NSString *)sourceName{
    if (self.position) {
        if ([self.position isEqualToString:@"video_list"]) {
            return @"video_list";
        }else{
            return @"video";
        }
    }else{
        return @"video_list";
    }
}

- (NSString *)position{
    if (!_position){
        if ([self.recommendUserDelegate respondsToSelector:@selector(recommendViewPositon)]){
            _position = [self.recommendUserDelegate recommendViewPositon];
        }
    }
    return _position;
}

- (void)trackWithEvent:(NSString *)label extraDic:(NSDictionary *)extraDic {
    
    if ([label isEqualToString:@"enter_homepage"]) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary: [self.recommendUserDelegate impressionParams]];
        if (self.position){
            if ([_position isEqualToString:@"video_list"]){
                [params setValue:@"list_follow_card_related" forKey:@"from_page"];
            }else if ([_position isEqualToString:@"video_detail"]){
                [params setValue:@"detail_follow_card" forKey:@"from_page"];
            }
        }
        [params addEntriesFromDictionary:extraDic];
        [TTTrackerWrapper eventV3:@"enter_homepage" params:params];
        return ;
    }
    
    if (_recommendUserDelegate && [_recommendUserDelegate respondsToSelector:@selector(trackWithEvent:extraDic:)]) {
        [_recommendUserDelegate trackWithEvent:label extraDic:extraDic];
    }
}


@end

