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

        tableView.delegate = self;
        tableView.dataSource = self;
    }
    return self;
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    [super requestData:isHead first:isFirst];

    if(isFirst){
        [self.viewController startLoading];
    }

    __weak typeof(self) wself = self;
    
    NSInteger listCount = self.dataList.count;
    double behotTime = 0;
    
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:@"weitoutiao" behotTime:behotTime loadMore:!isHead listCount:listCount completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        if(isFirst){
            [self.viewController endLoading];
        }
        
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        
        if (!wself) {
            return;
        }
        
        if (error && self.dataList.count == 0) {
            //TODO: show handle error
//            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            return;
        }
        
        if(model){
            if (isHead) {
                [wself.dataList removeAllObjects];
            }
            NSArray *result = [wself convertModel:feedListModel.data];
            [wself.dataList addObjectsFromArray:result];
            wself.tableView.hasMore = feedListModel.hasMore;
//            [wself updateTableViewWithMoreData:msgModel.data.hasMore];
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
//                wself.refreshFooter.hidden = NO;
//                [wself.viewController.emptyView hideEmptyView];
                [wself.tableView reloadData];
            }else{
//                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyMessage];
            }
            
//            if(isFirst){
//                self.originSearchId = self.searchId;
//                [self addEnterCategoryLog];
//            }
            
//            if(!isHead){
//                [self addRefreshLog];
//            }
        }
    }];
    
//    for (NSInteger i = 0; i < 50; i++) {
//        int x = arc4random() % 100;
//        int y = x % 2;
//        [self.dataList addObject:[NSString stringWithFormat:@"%i",y]];
//    }
//    [self.tableView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
