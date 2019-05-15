//
//  TTRecommendUserCollectionView.m
//  Article
//
//  Created by SongChai on 04/06/2017.
//
//

#import "TTRecommendUserCollectionView.h"
#import "TTRecommendUserCardCell.h"
#import "TTUISettingHelper.h"
#import <TTAccountBusiness.h>
#import "FriendDataManager.h"
#import "TTRouteService.h"
#import "TTFollowThemeButton.h"
#import "SSImpressionManager.h"
#import "FRApiModel.h"
#import "TTIndicatorView.h"
#import "TTAlphaThemedButton.h"
#import "TTRedPacketManager.h"
#import <TTUIResponderHelper.h>
#import "TTAccountManager.h"
#import "TTAuthorizeManager.h"
#import "TTRecommendUserCardFlowLayout.h"

#define kLeftPadding 15
#define kRightPadding 15

@interface TTRecommendUserCollectionView () <UICollectionViewDataSourcePrefetching, TTRecommendUserCardCellDelegate, SSImpressionProtocol>

@property (nonatomic, assign) BOOL needScrollBehindFollowed;
@property (nonatomic, weak) UICollectionViewCell* currentClickFollowCell;

@property (nonatomic, assign) BOOL isDisplay;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, strong) TTHttpTask* task;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) NSArray<FRRecommendCardStructModel*>* originalCardModels;
@property (nonatomic, strong) NSMutableArray<FRRecommendCardStructModel*>* userCardModels;

@property (nonatomic, weak) id<UICollectionViewDelegate> collectionViewDelegate;

@property (nonatomic, assign) CGFloat beginDragX;

@property (nonatomic, strong) FRUserRelationUserRecommendV1SupplementRecommendsRequestModel *requestModel;
@end

@implementation TTRecommendUserCollectionView

+(instancetype)collectionView {
    TTRecommendUserCardFlowLayout *flowLayout = [[TTRecommendUserCardFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:142.f], [TTDeviceUIUtils tt_newPadding:180.f]);
    flowLayout.minimumInteritemSpacing = [TTDeviceUIUtils tt_newPadding:7.f];
    flowLayout.minimumLineSpacing = [TTDeviceUIUtils tt_newPadding:7.f];
    flowLayout.headerReferenceSize = CGSizeMake(kLeftPadding, [TTDeviceUIUtils tt_newPadding:180.f]);
    flowLayout.footerReferenceSize = CGSizeMake(kLeftPadding, 0);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    TTRecommendUserCollectionView* result = [[TTRecommendUserCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    result.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    result.delegate = result;
    result.dataSource = result;
    result.scrollsToTop = NO;
    result.showsHorizontalScrollIndicator = NO;
    [result registerClass:[TTRecommendUserCardCell class] forCellWithReuseIdentifier:TTRecommendUserCardCellIdentifier];
    
    //    result.decelerationRate = 0.1;
    result.followSource = TTFollowNewSourceRecommendUserOtherCategory;
    return result;
}

- (void)configUserModels:(NSArray<FRRecommendCardStructModel *> *)userModels
           requesetModel:(FRUserRelationUserRecommendV1SupplementRecommendsRequestModel *)requestModel{
    self.requestModel = requestModel;
    if ([self modelChanged:userModels]) {
        _originalCardModels = userModels;
        self.contentOffset = CGPointZero;
        _userCardModels = [NSMutableArray arrayWithArray:userModels];
        [_task cancel];
        _isLoadingMore = NO;
        _hasMore = requestModel != nil;
        [self reloadData];
    }
    
    if (self.userCardModels.count == 0 && self.hasMore == NO) {
        if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(onCardEmpty)]) {
            [self.recommendUserDelegate onCardEmpty];
        }
    }
}

- (NSArray<FRRecommendCardStructModel *> *)allUserModels {
    return self.userCardModels;
}

- (BOOL)modelChanged:(NSArray<FRRecommendCardStructModel*>*)remoteModels {
    if (_originalCardModels.count != remoteModels.count) {
        return YES;
    }
    int index = 0;
    for (FRRecommendCardStructModel* model in remoteModels) {
        if (![model isEqual:_originalCardModels[index]]) {
            return YES;
        }
        index++;
    }
    return NO;
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
            FRRecommendCardStructModel *model = _userCardModels[indexPath.row];
            NSMutableDictionary *params = @{}.mutableCopy;
            if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(impressionParams)]) {
                if ([self.recommendUserDelegate impressionParams].count > 0) {
                    [params addEntriesFromDictionary:[self.recommendUserDelegate impressionParams]];
                }
            }
            
            if (params.count <= 0) {
                params = nil;
            }
            
            SSImpressionParams *impressionParam = nil;
            if (!isEmptyString(model.profile_user_id) || !isEmptyString(model.stats_place_holder)) {
                impressionParam = [[SSImpressionParams alloc] init];
                impressionParam.profileUserId = model.profile_user_id;
                impressionParam.serverExtra = model.stats_place_holder;
            }
            
            [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:model.user.info.user_id
                                                                            categoryName:[self _currentCategoryName]
                                                                                  cellId:[self _currentUniqueId]
                                                                                  status:_isDisplay? SSImpressionStatusRecording:SSImpressionStatusSuspend
                                                                                   extra:params.copy
                                                                                  params:impressionParam];
        }
    }
}

- (void)dealloc {
    [[SSImpressionManager shareInstance] removeRegist:self];
    self.delegate = nil;
    self.dataSource = nil;
    self.collectionViewDelegate = nil;
}

- (void)performRecommendUpdateWithCell:(TTRecommendUserCardCell *)cell {
    [self performSelector:@selector(followSuccess:) withObject:cell afterDelay:0.4];
}

- (void)replaceWithSupplementModel:(FRRecommendCardStructModel *)model indexPath:(NSIndexPath *)indexPath oldModel:(FRRecommendCardStructModel *)oldModel {
    if (indexPath.item >= _userCardModels.count) {
        return;
    }
    
    if ([self.userCardModels containsObject:oldModel]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"show" forKey:@"action_type"];
        [params setValue:[self _currentCategoryName] forKey:@"category_name"];
        [params setValue:@(0) forKey:@"is_direct"];
        [params setValue:@"list_follow_card_horizon_related" forKey:@"source"];
        [params setValue:model.user.info.user_id forKey:@"to_user_id"];
        [params setValue:@(indexPath.item+1) forKey:@"order"];
        [params setValue:model.stats_place_holder forKey:@"server_extra"];
        [TTTrackerWrapper eventV3:@"follow_card" params:params.copy];
        [self.userCardModels replaceObjectAtIndex:indexPath.item withObject:model];
        if ([TTDeviceHelper OSVersionNumber] < 8.0f) { //iOS7 crash 保护 https://fabric.io/news/ios/apps/com.ss.iphone.article.news/issues/59cb056abe077a4dcc4e42e9?time=last-thirty-days
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
            });
        } else {
            [(TTRecommendUserCardFlowLayout *)self.collectionViewLayout setIndex:indexPath.item];
            TTRecommendUserCardCell *cell = (TTRecommendUserCardCell *)[self cellForItemAtIndexPath:indexPath];
            cell.hidden = YES;
            [self performBatchUpdates:^{
                [self reloadItemsAtIndexPaths:@[indexPath]];
            } completion:^(BOOL finished) {
                cell.hidden = NO;
                //如果不重置，在某些特殊情况下新出的cell并没有被系统还原正确大小
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        obj.transform = CGAffineTransformIdentity;
                    }];
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

//向后做移位
- (void) followSuccess:(TTRecommendUserCardCell*) cell {
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

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    if(delegate == self) {
        [super setDelegate:delegate];
    } else {
        self.collectionViewDelegate = delegate;
    }
}

- (void)loadMore {
    if (!_isLoadingMore && self.hasMore && self.requestModel) {
        _isLoadingMore = YES;
        
        WeakSelf;
        _task = [TTRecommendUserCollectionView requestDataWithModel:self.requestModel complete:^(NSArray<FRRecommendCardStructModel *> *models, BOOL hasMore) {
            StrongSelf;
            self.isLoadingMore = NO;
            [self.userCardModels addObjectsFromArray:models];
            self.hasMore = hasMore;
            [self reloadData];
        }];
    }
}

+ (TTHttpTask *)requestDataWithSource:(NSString *)source
                                scene:(NSString *)scene
                          sceneUserId:(NSString *)userId
                              groupId:(NSString *)groupId
                             complete:(void (^)(NSArray<FRRecommendCardStructModel *> *))block {
    FRUserRelationUserRecommendV1SupplementRecommendsRequestModel *model = [[FRUserRelationUserRecommendV1SupplementRecommendsRequestModel alloc] init];
    model.scene = scene;
    model.source = source;
    model.follow_user_id = userId;
    model.group_id = groupId;
    return [TTRecommendUserCollectionView requestDataWithModel:model complete:^(NSArray<FRRecommendCardStructModel *> *models, BOOL hasMore) {
        if (block) {
            block(models);
        }
    }];
}

+ (TTHttpTask *)requestDataWithModel:(FRUserRelationUserRecommendV1SupplementRecommendsRequestModel *)requestModel
                            complete:(void (^)(NSArray<FRRecommendCardStructModel *> *models, BOOL hasMore))block {
    return [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        //重新加载数据
        if (error == nil) {
            FRUserRelationUserRecommendV1SupplementRecommendsResponseModel *model = (FRUserRelationUserRecommendV1SupplementRecommendsResponseModel *)responseModel;
            if ([model isKindOfClass:[FRUserRelationUserRecommendV1SupplementRecommendsResponseModel class]]) {
                NSArray *userCardModels = model.user_cards;
                if (userCardModels.count > 0) {
                    if (block) {
                        block(userCardModels, model.has_more.boolValue);
                    }
                    return;
                }
            }
        }
        
        if (block) {
            block(nil, NO);
        }
    }];
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
    TTRecommendUserCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TTRecommendUserCardCellIdentifier forIndexPath:indexPath];
    if (_userCardModels.count == 0 || _userCardModels.count <= indexPath.item) {
        return cell;
    }
    
    FRRecommendCardStructModel *model = _userCardModels[indexPath.row];
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
    
    FRRecommendCardStructModel *model = _userCardModels[indexPath.row];
    NSString *openURL = [NSString stringWithFormat:@"sslocal://profile?uid=%@&page_source=%@&refer=follow_card",model.user.info.user_id, @(0)];
    
    openURL = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:openURL categoryName:[self _currentCategoryName] fromPage:[model.card_type boolValue]?@"list_follow_card_horizon_related":@"list_follow_card_horizon" groupId:nil profileUserId:model.profile_user_id];
    
    if (!isEmptyString(model.stats_place_holder)) {
        openURL = [openURL stringByAppendingString:[NSString stringWithFormat:@"&server_extra=%@", model.stats_place_holder]];
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"click_avatar" forKey:@"action_type"];
    [param setValue:model.user.info.user_id forKey:@"to_user_id"];
    [param setValue:model.stats_place_holder forKey:@"server_extra"];
    [param setValue:self.followSource == TTFollowNewSourceRecommendRelateMainFeed || self.followSource == TTFollowNewSourceRecommendRelateWeitoutiaoCategory? @"list_follow_card_related" : ([model.card_type boolValue]?@"list_follow_card_horizon_related":@"list_follow_card_horizon") forKey:@"source"];
    [param setValue:@(self.followSource) forKey:@"server_source"];
    if (!isEmptyString(model.profile_user_id)) {
        [param setValue:model.profile_user_id forKey:@"profile_user_id"];
    }
    
    if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openURL]]) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
        [self trackWithEvent:@"follow_card" extraDic:param];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (_userCardModels.count == 0 || _userCardModels.count <= indexPath.item) {
        return;
    }
    
    if (indexPath.item >= _userCardModels.count-1) {
        [self loadMore];
    }
    
    /*impression统计相关*/
    FRRecommendCardStructModel *model = _userCardModels[indexPath.row];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(impressionParams)]) {
        if ([self.recommendUserDelegate impressionParams].count > 0) {
            [params addEntriesFromDictionary:[self.recommendUserDelegate impressionParams]];
        }
    }
    
    if (params.count <= 0) {
        params = nil;
    }
    
    SSImpressionParams *impressionParam = nil;
    if (!isEmptyString(model.profile_user_id) || !isEmptyString(model.stats_place_holder)) {
        impressionParam = [[SSImpressionParams alloc] init];
        impressionParam.profileUserId = model.profile_user_id;
        impressionParam.serverExtra = model.stats_place_holder;
    }
    [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:model.user.info.user_id
                                                                    categoryName:[self _currentCategoryName]
                                                                          cellId:[self _currentUniqueId]
                                                                          status:_isDisplay? SSImpressionStatusRecording:SSImpressionStatusSuspend
                                                                           extra:params.copy
                                                                          params:impressionParam];
    /*show事件*/
    if (model.activity.redpack) {
        NSMutableDictionary * showEventExtraDic  = [NSMutableDictionary dictionary];
        [showEventExtraDic setValue:model.activity.redpack.user_info.user_id
                             forKey:@"user_id"];
        [showEventExtraDic setValue:@"show"
                             forKey:@"action_type"];
        [showEventExtraDic setValue:@"list_follow_card_horizon"
                             forKey:@"source"];
        [self trackWithEvent:@"red_button" extraDic:showEventExtraDic];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([_userCardModels count] == 0 || _userCardModels.count <= indexPath.item) {
        return;
    }
    
    // impression统计
    FRRecommendCardStructModel *model = _userCardModels[indexPath.item];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(impressionParams)]) {
        if ([self.recommendUserDelegate impressionParams].count > 0) {
            [params addEntriesFromDictionary:[self.recommendUserDelegate impressionParams]];
        }
    }
    
    if (params.count <= 0) {
        params = nil;
    }
    
    SSImpressionParams *impressionParam = nil;
    if (!isEmptyString(model.profile_user_id) || !isEmptyString(model.stats_place_holder)) {
        impressionParam = [[SSImpressionParams alloc] init];
        impressionParam.profileUserId = model.profile_user_id;
        impressionParam.serverExtra = model.stats_place_holder;
    }
    [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:model.user.info.user_id
                                                                    categoryName:[self _currentCategoryName]
                                                                          cellId:[self _currentUniqueId]
                                                                          status:SSImpressionStatusEnd
                                                                           extra:params.copy
                                                                          params:impressionParam];
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
    [self trackWithEvent:@"follow_card" extraDic:@{@"action_type": [NSString stringWithFormat:@"flip_%@", endDragX > _beginDragX? @"left":@"right"]}];
}

#pragma -- mark TTRecommendUserCardCellDelegate
- (void)onClickFollow:(TTRecommendUserCardCell *)cell {
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    FRRecommendCardStructModel* model = cell.model;
    if (model == nil) {
        return;
        
    }
    NSString *userID = model.user.info.user_id;
    if ([userID isEqualToString:[TTAccountManager userID]] || isEmptyString(userID)) {
        return;
    }
    
    [cell.subscribeButton startLoading];
    
    FriendDataManager *dataManager = [FriendDataManager sharedManager];
    FriendActionType actionType;
    if (model.user.relation.is_following.boolValue) {
        actionType = FriendActionTypeUnfollow;
    }
    else {
        actionType = FriendActionTypeFollow;
    }
    self.currentClickFollowCell = cell;
    self.needScrollBehindFollowed = YES;
    
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    __weak TTRecommendUserCardCell* wCell = cell;
    
    TTFollowNewSource source = self.followSource;
    if (model.activity.redpack) {
        switch (source) {
            case TTFollowNewSourceRecommendUserWeitoutiaoCategory:
                source = TTFollowNewSourceRecommendUserWeitoutiaoCategoryRedPacket;
                break;
            case TTFollowNewSourceRecommendUserMainFeed:
                source = TTFollowNewSourceRecommendUserMainFeedRedPacket;
                break;
            case TTFollowNewSourceRecommendUserFollowCategory:
                source = TTFollowNewSourceRecommendUserFollowCategoryRedPacket;
                break;
            case TTFollowNewSourcePersonal:
                source = TTFollowNewSourcePersonalRedPacket;
                break;
            default:
                source = TTFollowNewSourceRecommendUserOtherCategoryRedPacket;
                break;
        }
    }
    
    NSString * event = nil;
    if (FriendActionTypeFollow == actionType) {
        event = @"follow";
    }else {
        event = @"unfollow";
    }
    long index = indexPath.item + 1;
    NSMutableDictionary* extraDict = [NSMutableDictionary dictionaryWithObject:userID forKey:@"user_id"];
    [extraDict setObject:@"follow_card" forKey:@"source"];
    [extraDict setObject:@(index) forKey:@"order"];
    [extraDict setObject:@(source) forKey:@"server_source"];
    if (actionType == FriendActionTypeFollow && model.activity.redpack) {
        [extraDict setObject:@(1) forKey:@"is_redpacket"];
    }
    [extraDict setValue:([TTAccountManager userID] ?: @"") forKey:@"profile_user_id"]; //该值在外部delegate会进行覆盖，所有关注用户带来的推人卡片，外部delegate会赋值为源关注用户
    
    if (!isEmptyString(model.profile_user_id)) {
        [extraDict setValue:model.profile_user_id forKey:@"profile_user_id"];
    }
    [extraDict setValue:@(1) forKey:@"is_follow_card"];
    
    if (!isEmptyString(model.stats_place_holder)) {
        [extraDict setValue:model.stats_place_holder forKey:@"server_extra"];
    }
    
    [self trackWithEvent:event extraDic:extraDict]; //该埋点一定要不删除，外部delegate使用@"follow"和 @"unfollow"字段判断follow的打点时机！
    
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:actionType
                                             userID:model.user.info.user_id
                                           platform:nil
                                               name:nil
                                               from:nil
                                             reason:nil
                                          newReason:model.recommend_type
                                          newSource:@(source)
                                         completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                                             StrongSelf;
                                             if (!error) {
                                                 NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                                                 NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                                                 NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                                                 BOOL followResult = [user tt_boolValueForKey:@"is_following"];
                                                 model.user.relation.is_following = @(followResult);
                                                 [wCell.subscribeButton stopLoading:^{
                                                 }];
                                                 if (followResult && model.activity.redpack) {
                                                     TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
                                                     redPacketTrackModel.userId = userID;
                                                     if ([self.recommendUserDelegate respondsToSelector:@selector(categoryID)]) {
                                                         redPacketTrackModel.categoryName = [self.recommendUserDelegate categoryID];
                                                     }
                                                     redPacketTrackModel.source = @"follow_card";
                                                     [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:model.activity.redpack
                                                                                                                source:redPacketTrackModel
                                                                                                        viewController:[TTUIResponderHelper topmostViewController]];
                                                     model.activity.redpack = nil;
                                                 }
                                                 if (followResult) {
                                                     if (self.needSupplementCard) {
                                                         //需要新增推人
                                                         FRUserRelationUserRecommendV1SupplementCardRequestModel *requestModel =  [[FRUserRelationUserRecommendV1SupplementCardRequestModel alloc] init];
                                                         requestModel.source = [self _currentCategoryName];
                                                         requestModel.follow_user_id = model.user.info.user_id;
                                                         [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
                                                             FRUserRelationUserRecommendV1SupplementCardResponseModel *suppleModel = (FRUserRelationUserRecommendV1SupplementCardResponseModel *)responseModel;
                                                             if (!error && suppleModel.data) {
                                                                 [self replaceWithSupplementModel:suppleModel.data indexPath:indexPath oldModel:model];
                                                             } else {
                                                                 [self performRecommendUpdateWithCell:wCell];//如果出错照常出前移动一个
                                                             }
                                                         }];
                                                     } else {
                                                         [self performRecommendUpdateWithCell:wCell];
                                                     }
                                                 }
                                             } else {
                                                 [wCell.subscribeButton stopLoading:nil];
                                             }
                                         }];
}

- (void)onClickDislike:(TTRecommendUserCardCell *)cell {
    NSIndexPath* indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    if ([self.userCardModels containsObject:cell.model]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"delete" forKey:@"action_type"];
        [params setValue:[self _currentCategoryName] forKey:@"category_name"];
        [params setValue:cell.model.user.relation.is_following?: @(0) forKey:@"is_follow"];
        [params setValue:@([cell.model.card_type boolValue]?0:1) forKey:@"is_direct"];
        [params setValue:@(self.followSource) forKey:@"server_source"];
        [params setValue:self.followSource == TTFollowNewSourceRecommendRelateMainFeed || self.followSource == TTFollowNewSourceRecommendRelateWeitoutiaoCategory? @"list_follow_card_related" : ([cell.model.card_type boolValue]?@"list_follow_card_horizon_related":@"list_follow_card_horizon") forKey:@"source"];
        [params setValue:cell.model.user.info.user_id forKey:@"to_user_id"];
        [params setValue:@(indexPath.item+1) forKey:@"order"];
        [params setValue:cell.model.stats_place_holder forKey:@"server_extra"];
        if (!isEmptyString(cell.model.profile_user_id)) {
            [params setValue:cell.model.profile_user_id forKey:@"profile_user_id"];
        }
        [self trackWithEvent:@"follow_card" extraDic:params.copy];
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
    
    FRUserRelationUserRecommendV1DislikeUserRequestModel *requestModel = [[FRUserRelationUserRecommendV1DislikeUserRequestModel alloc] init];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    requestModel.dislike_user_id = [formatter numberFromString:cell.model.user.info.user_id];
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (error) {
            
        }
    }];
    
    if ([self.originalCardModels containsObject:cell.model]) {
        NSMutableArray* array = [NSMutableArray arrayWithArray:self.originalCardModels];
        [array removeObject:cell.model];
        _originalCardModels = array.copy;
        if (_recommendUserDelegate && [_recommendUserDelegate respondsToSelector:@selector(onRemoveModel:originalModels:)]) {
            [_recommendUserDelegate onRemoveModel:cell.model originalModels:_originalCardModels];
        }
    }
    
    if (self.userCardModels.count == 0 && self.hasMore == NO) {
        if (self.recommendUserDelegate && [self.recommendUserDelegate respondsToSelector:@selector(onCardEmpty)]) {
            [self.recommendUserDelegate onCardEmpty];
        }
    }
}

- (void)trackWithEvent:(NSString *)label extraDic:(NSDictionary *)extraDic {
    if (_recommendUserDelegate && [_recommendUserDelegate respondsToSelector:@selector(trackWithEvent:extraDic:)]) {
        [_recommendUserDelegate trackWithEvent:label extraDic:extraDic];
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

//impression需要
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
@end

