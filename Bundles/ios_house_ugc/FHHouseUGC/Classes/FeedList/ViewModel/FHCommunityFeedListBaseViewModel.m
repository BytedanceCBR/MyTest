//
//  FHCommunityFeedListBaseViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListBaseViewModel.h"

@implementation FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController {
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.viewController = viewController;
        
        self.cellManager = [[FHUGCCellManager alloc] init];
        [self.cellManager registerAllCell:tableView];
        
        self.refer = 1;
        
    }
    return self;
}

- (void)viewWillAppear {
    self.isShowing = YES;
    [[SSImpressionManager shareInstance] enterGroupViewForCategoryID:self.categoryId concernID:nil refer:self.refer];
    [self refreshCurrentCell];
}

- (void)viewWillDisappear {
    self.isShowing = NO;
    [[SSImpressionManager shareInstance] leaveGroupViewForCategoryID:self.categoryId concernID:nil refer:self.refer];
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    
}

- (void)refreshCurrentCell {
    if(self.needRefreshCell){
        self.needRefreshCell = NO;
        [self.currentCell refreshWithData:self.currentCellModel];
    }
}

- (void)recordGroupWithCellModel:(FHFeedUGCCellModel *)cellModel status:(SSImpressionStatus)status {
    NSString *uniqueID = cellModel.groupId.length > 0 ? cellModel.groupId : @"";
    NSString *itemID = cellModel.groupId.length > 0 ? cellModel.groupId : @"";
    /*impression统计相关*/
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryId;
    params.refer = self.refer;
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:uniqueID itemID:itemID impressionID:nil aggrType:[cellModel.aggrType integerValue]];
    [ArticleImpressionHelper recordGroupWithUniqueID:uniqueID adID:nil groupModel:groupModel status:status params:params];
}

@end
