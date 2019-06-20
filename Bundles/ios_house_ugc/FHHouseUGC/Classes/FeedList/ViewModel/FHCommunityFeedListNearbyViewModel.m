//
//  FHCommunityFeedListNearbyViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListNearbyViewModel.h"
#import "FHUGCBaseCell.h"
#import "FHTopicListModel.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import <UIScrollView+Refresh.h>
#import "FHFeedUGCCellModel.h"
#import "Article.h"
#import "TTBaseMacro.h"
#import "TTStringHelper.h"
#import "FHUGCGuideHelper.h"

@interface FHCommunityFeedListNearbyViewModel () <UITableViewDelegate,UITableViewDataSource,FHUGCBaseCellDelegate>

@property(nonatomic, strong) FHFeedUGCCellModel *guideCellModel;

@end

@implementation FHCommunityFeedListNearbyViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController {
    self = [super initWithTableView:tableView controller:viewController];
    if (self) {
        self.dataList = [[NSMutableArray alloc] init];
        [self configTableView];
    }
    
    return self;
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
            [wself requestData:YES first:NO];
        }];
    }
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    [super requestData:isHead first:isFirst];

    if(isFirst){
        [self.dataList removeAllObjects];
        [self.viewController startLoading];
    }

    __weak typeof(self) wself = self;
    
    NSInteger listCount = self.dataList.count;
    double behotTime = 0;
    
    if(!isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList lastObject];
        behotTime = [cellModel.behotTime doubleValue];
    }
    
//    @"weitoutiao" @"f_wenda"
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead listCount:listCount completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        if(isFirst){
            [self.viewController endLoading];
        }
        
        [self.tableView finishPullDownWithSuccess:YES];
        
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        
        if (!wself) {
            return;
        }
        
        if (error) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            wself.viewController.showenRetryButton = YES;
            return;
        }
        
        if(model){
            if (isHead && feedListModel.hasMore) {
                [wself.dataList removeAllObjects];
            }
            NSArray *result = [wself convertModel:feedListModel.data];
            
            if(isHead){
                if(result.count > 0){
                    [wself.cellHeightCaches removeAllObjects];
                }
                [wself.dataList insertObjects:result atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
            }else{
                [wself.dataList addObjectsFromArray:result];
            }
            wself.tableView.hasMore = feedListModel.hasMore;
            [wself updateTableViewWithMoreData:feedListModel.hasMore];
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                wself.refreshFooter.hidden = NO;
                [wself.viewController.emptyView hideEmptyView];
                
                if(isFirst){
                    [wself insertGuideCell];
                }
            }else{
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                wself.viewController.showenRetryButton = YES;
            }
            
            [wself.tableView reloadData];
            
//            if(isFirst){
//                self.originSearchId = self.searchId;
//                [self addEnterCategoryLog];
//            }
            
            NSString *refreshTip = feedListModel.tips.displayInfo;
            if (isHead && self.dataList.count > 0 && ![refreshTip isEqualToString:@""] && self.viewController.tableViewNeedPullDown){
                [self.viewController showNotify:refreshTip];
                [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
            
//            if(!isHead){
//                [self addRefreshLog];
//            }
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

- (NSArray *)convertModel:(NSArray *)feedList {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    if(feedList.count > 0){
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFakeData];
        cellModel.tableView = self.tableView;
        [resultArray addObject:cellModel];

        [resultArray addObject:[FHFeedUGCCellModel modelFromFakeData2]];
    }
    for (FHFeedListDataModel *itemModel in feedList) {
        NSString *content = itemModel.content;
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.categoryId = self.categoryId;
        cellModel.feedVC = self.viewController;
        if(cellModel){
            [resultArray addObject:cellModel];
        }
    }
    return resultArray;
}

- (void)insertGuideCell {
//    if([FHUGCGuideHelper shouldShowFeedGuide]){
        //符合引导页显示条件时
        for (NSInteger i = 0; i < self.dataList.count; i++) {
            FHFeedUGCCellModel *cellModel = self.dataList[i];
            if([cellModel.cellType integerValue] == FHUGCFeedListCellTypeArticle || [cellModel.cellType integerValue] == FHUGCFeedListCellTypeUGC){
                self.guideCellModel = [FHFeedUGCCellModel guideCellModel];
                [self.dataList insertObject:self.guideCellModel atIndex:(i + 1)];
                //显示以后次数加1
                [FHUGCGuideHelper addFeedGuideCount];
                return;
            }
        }
//    }
}

- (void)deleteGuideCell {
    if(self.guideCellModel){
        NSInteger row = [self.dataList indexOfObject:self.guideCellModel];
        if(row < self.dataList.count && row >= 0){
            [self.dataList removeObject:self.guideCellModel];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
    self.cellHeightCaches[tempKey] = cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
    FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        Class cellClass = NSClassFromString(cellIdentifier);
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.delegate = self;

    if(indexPath.row < self.dataList.count){
        [cell refreshWithData:cellModel];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = self.cellHeightCaches[tempKey];
    if (cellHeight) {
        return [cellHeight floatValue];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    self.currentCellModel = cellModel;
    self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
    [self jumpToDetail:cellModel];
}

- (void)jumpToDetail:(FHFeedUGCCellModel *)cellModel {
    if([cellModel.cellType integerValue] == FHUGCFeedListCellTypeArticle){
        BOOL canOpenURL = NO;
        if (!canOpenURL && !isEmptyString(cellModel.openUrl)) {
            NSURL *url = [TTStringHelper URLWithURLString:cellModel.openUrl];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                canOpenURL = YES;
                [[UIApplication sharedApplication] openURL:url];
            }
            else if([[TTRoute sharedRoute] canOpenURL:url]){
                canOpenURL = YES;
                //问答
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
            }
        }else{
            //文章
            NSURL *openUrl = [NSURL URLWithString:cellModel.detailScheme];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
        }
    }else if([cellModel.cellType integerValue] == FHUGCFeedListCellTypeUGC){
        [self jumpToPostDetail:cellModel showComment:NO];
    }
}

- (void)jumpToPostDetail:(FHFeedUGCCellModel *)cellModel showComment:(BOOL)showComment {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"data"] = cellModel;
    dict[@"begin_show_comment"] = showComment ? @"1" : @"0";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    FHFeedUGCContentModel *contentModel = cellModel.originData;
    NSString *routeUrl = @"sslocal://ugc_post_detail";
    if (contentModel && [contentModel isKindOfClass:[FHFeedUGCContentModel class]]) {
        NSString *schema = contentModel.schema;
        if (schema.length > 0) {
            routeUrl = [schema stringByReplacingOccurrencesOfString:@"sslocal://thread_detail" withString:@"sslocal://ugc_post_detail"];
        }
        // 记得 如果是push 和 url要添加评论数 点赞数以及自己是否点赞
        routeUrl = [NSString stringWithFormat:@"%@&comment_count=%@&digg_count=%@&user_digg=%@",routeUrl,contentModel.commentCount,contentModel.diggCount,contentModel.userDigg];
    }
    
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    self.needRefreshCell = YES;
}

#pragma mark - FHUGCBaseCellDelegate

- (void)deleteCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self.dataList indexOfObject:cellModel];
    if(row < self.dataList.count && row >= 0){
        [self.dataList removeObject:cellModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    if(cellModel == self.guideCellModel){
        [FHUGCGuideHelper hideFeedGuide];
    }
}

- (void)commentClicked:(FHFeedUGCCellModel *)cellModel {
    [self jumpToPostDetail:cellModel showComment:YES];
}

- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    //关闭引导cell
    [self deleteGuideCell];
    [FHUGCGuideHelper hideFeedGuide];
}

@end
