//
//  FHCommunityFeedListNearbyViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListPostDetailViewModel.h"
#import "FHUGCBaseCell.h"
#import "FHTopicListModel.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import <UIScrollView+Refresh.h>
#import "FHFeedUGCCellModel.h"
#import "Article.h"
#import "TTBaseMacro.h"
#import "TTStringHelper.h"
#import "TTRoute.h"
#import "TTUGCDefine.h"
#import "FHUGCModel.h"
#import "FHFeedUGCContentModel.h"
#import "FHFeedListModel.h"
#import "ToastManager.h"
#import <FHEnvContext.h>
#import <TTAccountManager.h>
#import <TTURLUtils.h>

@interface FHCommunityFeedListPostDetailViewModel () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FHCommunityFeedListPostDetailViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController {
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
        self.dataList = [[NSMutableArray alloc] init];
        [self configTableView];
        // 删帖成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCDelPostNotification object:nil];
        // 举报成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeleteSuccess:) name:kFHUGCReportPostNotification object:nil];
        // 发帖成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccess:) name:kTTForumPostThreadSuccessNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 发帖成功，插入数据
- (void)postThreadSuccess:(NSNotification *)noti {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    if (noti && noti.userInfo && self.dataList) {
        NSDictionary *userInfo = noti.userInfo;
        NSString *social_group_id = userInfo[@"social_group_id"];
        NSDictionary *result_model = userInfo[@"result_model"];
        if (result_model && [result_model isKindOfClass:[NSDictionary class]]) {
            NSDictionary * thread_cell_dic = result_model[@"data"];
            if (thread_cell_dic && [thread_cell_dic isKindOfClass:[NSDictionary class]]) {
                NSString * thread_cell_data = thread_cell_dic[@"thread_cell"];
                if (thread_cell_data && [thread_cell_data isKindOfClass:[NSString class]]) {
                    // 得到cell 数据
                    NSError *jsonParseError;
                    NSData *jsonData = [thread_cell_data dataUsingEncoding:NSUTF8StringEncoding];
                    if (jsonData) {
                        Class cls = [FHFeedUGCContentModel class];
                        FHFeedUGCContentModel * model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:[FHFeedUGCContentModel class] error:&jsonParseError];
                        if (model && jsonParseError == nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeedUGCContent:model];
                                cellModel.showCommunity = NO;
                                if (cellModel && [cellModel.community.socialGroupId isEqualToString:self.viewController.forumId]) {
                                    //去重逻辑
                                    [self removeDuplicaionModel:cellModel.groupId];
                                    if (self.dataList.count == 0) {
                                        [self.dataList addObject:cellModel];
                                    } else {
                                        [self.dataList insertObject:cellModel atIndex:0];
                                    }
                                    [self.tableView reloadData];
                                    self.needRefreshCell = NO;
                                }
                            });
                        }
                    }
                }
            }
        }
    }
}


- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    self.refreshFooter.hidden = YES;
    
    if(self.viewController.tableViewNeedPullDown){
        // 下拉刷新
        [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
            wself.isRefreshingTip = NO;
            [wself.viewController hideImmediately];
            [wself requestData:YES first:NO];
        }];
    }
}

//- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
//    if(self.viewController.isLoadingData){
//        return;
//    }
//
//    self.viewController.isLoadingData = YES;
//
//    if(isFirst){
//        [self.viewController startLoading];
//    }
//
//    __weak typeof(self) wself = self;
//
//    NSInteger listCount = self.dataList.count;
//    NSInteger offset = 0;
//
//    if(listCount > 0 && !isFirst){
//        if(self.feedListModel){
//            offset = [self.feedListModel.lastOffset integerValue];
//        }
//    }
//
//    self.requestTask = [FHHouseUGCAPI requestForumFeedListWithForumId:self.categoryId offset:offset loadMore:!isHead completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
//        wself.viewController.isLoadingData = NO;
//        if(isFirst){
//            [wself.viewController endLoading];
//        }
//
//        [wself.tableView finishPullDownWithSuccess:YES];
//
//        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
//        wself.feedListModel = feedListModel;
//
//        if (!wself) {
//            return;
//        }
//
//        if (error) {
//            //TODO: show handle error
//            if(isFirst){
//                if(error.code != -999){
//                    [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
//                    wself.viewController.showenRetryButton = YES;
//                }
//            }else{
//                [[ToastManager manager] showToast:@"网络异常"];
//                [wself updateTableViewWithMoreData:YES];
//            }
//            return;
//        }
//
//        if(model){
//            if (isHead && feedListModel.hasMore) {
//                [wself.dataList removeAllObjects];
//            }
//            NSArray *result = [wself convertModel:feedListModel.data isHead:isHead];
//
//            if(isFirst){
//                [wself.dataList removeAllObjects];
//            }
//
//            if(isHead){
//                [wself.dataList insertObjects:result atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
//            }else{
//                [wself.dataList addObjectsFromArray:result];
//            }
//
//            wself.tableView.hasMore = feedListModel.hasMore;
//            wself.viewController.hasValidateData = wself.dataList.count > 0;
//
//            if(wself.dataList.count > 0){
//                [wself updateTableViewWithMoreData:feedListModel.hasMore];
//                [wself.viewController.emptyView hideEmptyView];
//            }else{
//                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
//                wself.viewController.showenRetryButton = YES;
//            }
//            [wself.tableView reloadData];
//
//            NSString *refreshTip = feedListModel.tips.displayInfo;
//            if (isHead && wself.dataList.count > 0 && ![refreshTip isEqualToString:@""] && wself.viewController.tableViewNeedPullDown && !wself.isRefreshingTip){
//                wself.isRefreshingTip = YES;
//                [wself.viewController showNotify:refreshTip completion:^{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        wself.isRefreshingTip = NO;
//                    });
//                }];
//                [wself.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//            }
//        }
//    }];
//}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if(self.viewController.isLoadingData){
        return;
    }
    
    self.viewController.isLoadingData = YES;
    
    if(self.isRefreshingTip){
        [self.tableView finishPullDownWithSuccess:YES];
        return;
    }
    
    if(isFirst){
        [self.viewController startLoading];
    }
    
    __weak typeof(self) wself = self;
    
    NSInteger listCount = self.dataList.count;
    
    double behotTime = 0;
    NSString *lastGroupId = nil;
    
    if(!isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList lastObject];
        behotTime = [cellModel.behotTime doubleValue];
        lastGroupId = cellModel.groupId;
    }
    if(isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList firstObject];
        behotTime = [cellModel.behotTime doubleValue];
        lastGroupId = cellModel.groupId;
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }
    if(self.socialGroupId){
        [extraDic setObject:self.socialGroupId forKey:@"social_group_id"];
    }
    if(lastGroupId){
        [extraDic setObject:lastGroupId forKey:@"last_group_id"];
    }
    
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wself.viewController.isLoadingData = NO;
        if(isFirst){
            [wself.viewController endLoading];
        }
        
        [wself.tableView finishPullDownWithSuccess:YES];
        
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        wself.feedListModel = feedListModel;
        
        if (!wself) {
            return;
        }
        
        if (error) {
            //TODO: show handle error
            if(isFirst){
                if(error.code != -999){
                    [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
                    wself.viewController.showenRetryButton = YES;
                }
            }else{
                [[ToastManager manager] showToast:@"网络异常"];
                [wself updateTableViewWithMoreData:YES];
            }
            return;
        }
        
        if(model){
            if(isHead){
                if(feedListModel.hasMore){
                    [wself.dataList removeAllObjects];
                }
                wself.tableView.hasMore = YES;
            }else{
                wself.tableView.hasMore = feedListModel.hasMore;
            }
            
            NSArray *result = [wself convertModel:feedListModel.data isHead:isHead];
            
            if(isFirst){
                [self.clientShowDict removeAllObjects];
                [wself.dataList removeAllObjects];
            }
            if(isHead){
                [wself.dataList insertObjects:result atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
            }else{
                [wself.dataList addObjectsFromArray:result];
            }
            
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                [wself updateTableViewWithMoreData:wself.tableView.hasMore];
                [wself.viewController.emptyView hideEmptyView];
            }else{
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                wself.viewController.showenRetryButton = YES;
            }
            [wself.tableView reloadData];
            
            NSString *refreshTip = feedListModel.tips.displayInfo;
            if (isHead && wself.dataList.count > 0 && ![refreshTip isEqualToString:@""] && wself.viewController.tableViewNeedPullDown && !wself.isRefreshingTip){
                wself.isRefreshingTip = YES;
                [wself.viewController showNotify:refreshTip completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wself.isRefreshingTip = NO;
                    });
                }];
                [wself.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
        }
    }];
}


- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore) {
        [self.tableView.mj_footer endRefreshing];
    }else {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (NSArray *)convertModel:(NSArray *)feedList isHead:(BOOL)isHead {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.categoryId = self.categoryId;
        cellModel.feedVC = self.viewController;
        cellModel.tableView = self.tableView;
        cellModel.showCommunity = NO;
        if(cellModel){
            if(isHead){
                [resultArray addObject:cellModel];
                //去重逻辑
                [self removeDuplicaionModel:cellModel.groupId];
            }else{
                NSInteger index = [self getCellIndex:cellModel];
                if(index < 0){
                    [resultArray addObject:cellModel];
                }
            }
        }
    }
    return resultArray;
}

- (void)removeDuplicaionModel:(NSString *)groupId {
    for (FHFeedUGCCellModel *itemModel in self.dataList) {
        if([groupId isEqualToString:itemModel.groupId]){
            [self.dataList removeObject:itemModel];
            break;
        }
    }
}

- (void)postDeleteSuccess:(NSNotification *)noti {
    if (noti && noti.userInfo && self.dataList) {
        NSDictionary *userInfo = noti.userInfo;
        FHFeedUGCCellModel *cellModel = userInfo[@"cellModel"];
        [self deleteCell:cellModel];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        [self traceClientShowAtIndexPath:indexPath];
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        /*impression统计相关*/
        SSImpressionStatus impressionStatus = self.isShowing ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
        [self recordGroupWithCellModel:cellModel status:impressionStatus];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // impression统计
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        [self recordGroupWithCellModel:cellModel status:SSImpressionStatusEnd];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.delegate = self;
        cellModel.tracerDic = [self trackDict:cellModel rank:indexPath.row];
        
        if(indexPath.row < self.dataList.count){
            [cell refreshWithData:cellModel];
        }
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    self.currentCellModel = cellModel;
    self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
    [self jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

#pragma UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewController.scrollViewDelegate scrollViewDidScroll:scrollView];
    if(scrollView == self.tableView){
        if (scrollView.isDragging) {
            [self.viewController.notifyBarView performSelector:@selector(hideIfNeeds) withObject:nil];
        }
    }
}

- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    if(cellModel.cellType == FHUGCFeedListCellTypeArticle || cellModel.cellType == FHUGCFeedListCellTypeQuestion){
        BOOL canOpenURL = NO;
        if (!canOpenURL && !isEmptyString(cellModel.openUrl)) {
            NSURL *url = [TTStringHelper URLWithURLString:cellModel.openUrl];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                canOpenURL = YES;
                [[UIApplication sharedApplication] openURL:url];
            }
            else if([[TTRoute sharedRoute] canOpenURL:url]){
                canOpenURL = YES;
                //优先跳转openurl
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
            }
        }else{
            NSURL *openUrl = [NSURL URLWithString:cellModel.detailScheme];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
        }
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGC){
        [self jumpToPostDetail:cellModel showComment:showComment enterType:enterType];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeArticleComment){
        // 评论
        NSMutableDictionary *dict = [NSMutableDictionary new];
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[@"enter_from"] = @"community_group_detail";
        traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
        traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
        traceParam[@"log_pb"] = cellModel.logPb;
        dict[TRACER_KEY] = traceParam;
        
        dict[@"data"] = cellModel;
        dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
        dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeAnswer){
        // 问题 回答
        BOOL jump_comment = NO;
        if (showComment) {
            jump_comment = YES;
        }
        NSDictionary *dict = @{@"is_jump_comment":@(jump_comment)};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        NSURL *openUrl = [NSURL URLWithString:cellModel.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }else if(cellModel.cellType == FHUGCFeedListCellTypeUGCVote){
        [self goToVoteDetail:cellModel value:0];
    }
}

- (void)jumpToPostDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment enterType:(NSString *)enterType {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 埋点
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_from"] = @"community_group_detail";
    traceParam[@"enter_type"] = enterType ? enterType : @"be_null";
    traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
    traceParam[@"log_pb"] = cellModel.logPb;
    dict[TRACER_KEY] = traceParam;
    
    dict[@"data"] = cellModel;
    dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
    dict[@"social_group_id"] = cellModel.community.socialGroupId ?: @"";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    FHFeedUGCContentModel *contentModel = cellModel.originData;
    NSString *routeUrl = @"sslocal://thread_detail";
    if (contentModel && [contentModel isKindOfClass:[FHFeedUGCContentModel class]]) {
        NSString *schema = contentModel.schema;
        if (schema.length > 0) {
            routeUrl = schema;
        }
    }
    
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    self.needRefreshCell = YES;
}

#pragma mark - FHUGCBaseCellDelegate

- (void)deleteCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        [self.dataList removeObjectAtIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (NSInteger)getCellIndex:(FHFeedUGCCellModel *)cellModel {
    for (NSInteger i = 0; i < self.dataList.count; i++) {
        FHFeedUGCCellModel *model = self.dataList[i];
        if([model.groupId isEqualToString:cellModel.groupId]){
            return i;
        }
    }
    return -1;
}

- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    [self trackClickComment:cellModel];
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    [self jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    [self jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    NSMutableDictionary *dict = @{}.mutableCopy;
    // 埋点
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_from"] = @"community_group_detail";
    traceParam[@"element_from"] = @"feed_topic";
    traceParam[@"enter_type"] = @"click";
    traceParam[@"rank"] = cellModel.tracerDic[@"rank"];
    traceParam[@"log_pb"] = cellModel.logPb;
    dict[TRACER_KEY] = traceParam;
    
    if (url) {
        if ([url.absoluteString containsString:@"concern"]) {
            // 话题
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

- (void)goToVoteDetail:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value {
    [self trackVoteClickOptions:cellModel value:value];
    if([TTAccountManager isLogin] || !cellModel.vote.needUserLogin){
        if(cellModel.vote.openUrl){
            NSString *urlStr = cellModel.vote.openUrl;
            if(value > 0){
                NSString *append = [TTURLUtils queryItemAddingPercentEscapes:[NSString stringWithFormat:@"&vote=%d",value]];
                urlStr = [urlStr stringByAppendingString:append];
            }
            
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        }
    }else{
        [self gotoLogin:cellModel value:value];
    }
}

- (void)gotoLogin:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value  {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[self pageType] forKey:@"enter_from"];
    [params setObject:@"" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(cellModel.vote.openUrl){
                        NSString *urlStr = cellModel.vote.openUrl;
                        NSURL *url = [NSURL URLWithString:urlStr];
                        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                    }
                });
            }
        }
    }];
}

#pragma mark - 埋点

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    
    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *groupId = cellModel.groupId;
    if(groupId){
        if (self.clientShowDict[groupId]) {
            return;
        }
        
        self.clientShowDict[groupId] = @(indexPath.row);
        [self trackClientShow:cellModel rank:indexPath.row];
    }
}

- (void)trackClientShow:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict =  [self trackDict:cellModel rank:rank];
    TRACK_EVENT(@"feed_client_show", dict);
}

- (NSMutableDictionary *)trackDict:(FHFeedUGCCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"enter_from"] = @"community_group";
    dict[@"page_type"] = [self pageType];
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"rank"] = @(rank);
    
    return dict;
}

- (NSString *)pageType {
    return @"community_group_detail";
}

- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_comment";
    TRACK_EVENT(@"click_comment", dict);
}

- (void)trackVoteClickOptions:(FHFeedUGCCellModel *)cellModel value:(NSInteger)value {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"log_pb"] = cellModel.logPb;
    if(value == [cellModel.vote.leftValue integerValue]){
        dict[@"click_position"] = @"1";
    }else if(value == [cellModel.vote.rightValue integerValue]){
        dict[@"click_position"] = @"2";
    }else{
        dict[@"click_position"] = @"vote_content";
    }
    TRACK_EVENT(@"click_options", dict);
}

@end
