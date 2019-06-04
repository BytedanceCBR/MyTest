//
//  FHCommunityFeedListNearbyViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListNearbyViewModel.h"
#import "FHUGCBaseCell.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import <UIScrollView+Refresh.h>
#import "FHFeedContentModel.h"

@interface FHCommunityFeedListNearbyViewModel ()<UITableViewDelegate,UITableViewDataSource>

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
    
//    if(isFirst){
//        [self.viewController startLoading];
//
    __weak typeof(self) wself = self;
    
    NSInteger listCount = self.dataList.count;
    double behotTime = 0;
    
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:@"f_house_news" behotTime:behotTime loadMore:!isHead listCount:listCount completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
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
        NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
        
        Class cls = [FHFeedContentModel class];
        
        __block NSError *backError = nil;
        
        id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:cls error:&backError];
        if(!backError){
            FHFeedContentModel *contentModel = (FHFeedContentModel *)model;
            [resultArray addObject:contentModel];
        }
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:cls error:&backError];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(!backError){
//                    FHFeedContentModel *contentModel = (FHFeedContentModel *)model;
//                    [resultArray addObject:contentModel];
//                }
//            });
//        });
    }
    
    return resultArray;
}

//用来根据model计算类型
- (FHUGCFeedListCellType)getFeedType:(FHFeedContentModel *)model {
    FHUGCFeedListCellType type = FHUGCFeedListCellTypePureTitle;
//    NSInteger cellType = [model.cellType integerValue];
    
    FHFeedContentMiddleImageModel *middleImage = model.middleImage;
    if(middleImage){
        type = FHUGCFeedListCellTypeSingleImage;
    }
    
    return  type;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FHFeedContentModel *model = self.dataList[indexPath.row];
    FHUGCFeedListCellType type = [self getFeedType:model];

    NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:type data:nil]);
    FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        Class cellClass = NSClassFromString(cellIdentifier);
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.row < self.dataList.count){
        [cell refreshWithData:model];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
