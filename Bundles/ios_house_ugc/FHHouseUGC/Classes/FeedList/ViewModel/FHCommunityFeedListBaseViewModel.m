//
//  FHCommunityFeedListBaseViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHUGCSmallVideoCell.h"
#import <FHUGCVideoCell.h>
#import "TTVFeedPlayMovie.h"
#import "FHUGCFullScreenVideoCell.h"


@implementation FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController {
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.viewController = viewController;
        
        self.cellManager = [[FHUGCCellManager alloc] init];
        [self.cellManager registerAllCell:tableView];
        
        self.refer = 1;
        
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = self.refer;
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
    [self endDisplay];
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    
}

- (void)refreshCurrentCell {
    if(self.needRefreshCell){
        self.needRefreshCell = NO;
        [self refreshCell:self.currentCellModel];
    }
}

- (void)refreshCell:(FHFeedUGCCellModel *)cellModel {
    NSInteger row = [self getCellIndex:cellModel];
    if(row < self.dataList.count && row >= 0){
        [self.dataList replaceObjectAtIndex:row withObject:cellModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationNone];
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

- (void)recordGroupWithCellModel:(FHFeedUGCCellModel *)cellModel status:(SSImpressionStatus)status {
    NSString *uniqueID = cellModel.groupId.length > 0 ? cellModel.groupId : @"";
    NSString *itemID = cellModel.groupId.length > 0 ? cellModel.groupId : @"";
    /*impression统计相关*/
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.categoryId;
    params.refer = self.refer;
    SSImpressionModelType modelType = [FHUGCCellManager impressModelTypeWithCellType:cellModel.cellType];
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:uniqueID itemID:itemID impressionID:nil aggrType:[cellModel.aggrType integerValue]];
    [ArticleImpressionHelper recordItemWithUniqueID:uniqueID modelType:modelType logPb:cellModel.logPb status:status params:params];
}

- (UIView *)currentSelectSmallVideoView {
    if (self.currentCell && [self.currentCell isKindOfClass:[FHUGCSmallVideoCell class]]) {
        FHUGCSmallVideoCell *smallVideoCell = self.currentCell;
        return smallVideoCell.videoImageView;
    }
    return nil;
}

- (CGRect)selectedSmallVideoFrame
{
    UIView *view = [self currentSelectSmallVideoView];
    if (view) {
        CGRect frame = [view convertRect:view.bounds toView:nil];
        return frame;
    }
    return CGRectZero;
}

- (void)endDisplay {
    NSArray *cells = self.tableView.visibleCells;
    for (id cell in cells) {
        if([cell isKindOfClass:[FHUGCVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
            FHUGCVideoCell<TTVFeedPlayMovie> *cellBase = (FHUGCVideoCell<TTVFeedPlayMovie> *)cell;
            if([cellBase cell_isPlayingMovie]){
                [cellBase endDisplay];
            }
        }else if([cell isKindOfClass:[FHUGCFullScreenVideoCell class]] && [cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
            FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *cellBase = (FHUGCFullScreenVideoCell<TTVFeedPlayMovie> *)cell;
            if([cellBase cell_isPlayingMovie]){
                [cellBase endDisplay];
            }
        }
    }
}

- (void)showCustomErrorView:(FHEmptyMaskViewType)type {
    
}

- (void)updateJoinProgressView {
    
}

@end
