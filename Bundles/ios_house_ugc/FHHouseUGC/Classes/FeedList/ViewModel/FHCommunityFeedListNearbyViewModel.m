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

@interface FHCommunityFeedListNearbyViewModel () <UITableViewDelegate, UITableViewDataSource>

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
    // 下拉刷新
    [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
        [wself requestData:YES first:NO];
    }];
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    [super requestData:isHead first:isFirst];

    if(isFirst){
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
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:@"weitoutiao" behotTime:behotTime loadMore:!isHead listCount:listCount completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
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
            if (isHead && self.dataList.count > 0 && ![refreshTip isEqualToString:@""]){
                [self.viewController showNotify:refreshTip];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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
    
    for (FHFeedListDataModel *itemModel in feedList) {
        NSString *content = itemModel.content;
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        if(cellModel){
            [resultArray addObject:cellModel];
        }
    }
    
    return resultArray;
}

//用来根据model计算类型
- (FHUGCFeedListCellSubType)getFeedType:(FHFeedUGCCellModel *)model {
    FHUGCFeedListCellSubType type = FHUGCFeedListCellSubTypePureTitle;
    

//    NSInteger cellType = [model.cellType integerValue];
    //文章是0， 帖子32
//    NSArray *imageList = model.imageList;
//    if(imageList.count >= 3){
//        type = FHUGCFeedListCellTypeMultiImage;
//    }else if(imageList.count == 2){
//        type = FHUGCFeedListCellTypeTwoImage;
//    }else if(imageList.count == 1){
//        type = FHUGCFeedListCellTypeSingleImage;
//    }else{
        type = FHUGCFeedListCellSubTypeSingleImage;
//    }
//    if(imageList.count > 0){
//        type = FHUGCFeedListCellSubTypeArticleMultiImage;
//    }else{
//        type = FHUGCFeedListCellSubTypeArticlePureTitle;
//    }
    
    return  type;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
    self.cellHeightCaches[tempKey] = cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
//    FHUGCFeedListCellSubType type = [self getFeedType:cellModel];

    NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
    FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        Class cellClass = NSClassFromString(cellIdentifier);
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if(indexPath.row < self.dataList.count){
        [cell refreshWithData:cellModel];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = self.cellHeightCaches[tempKey];
    if (cellHeight) {
        return [cellHeight floatValue];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self jumpToTopicList];
}

//TODO 测试用的，后续去掉
- (void)jumpToTopicList {
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://topic_list?community_id=%@", @"12345"];
    NSURL *openUrl = [NSURL URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
}

@end
