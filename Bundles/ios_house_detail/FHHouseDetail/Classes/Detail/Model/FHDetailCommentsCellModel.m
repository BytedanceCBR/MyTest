//
//  FHDetailCommentsCellModel.m
//  FHHouseDetail
//
//  Created by wangzhizhou on 2020/2/23.
//

#import "FHDetailCommentsCellModel.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCBaseCell.h"
#import "FHUGCCellManager.h"

@implementation FHDetailCommentsCellModel
- (void)setComments:(FHDetailNeighborhoodDataCommentsModel *)comments {
    _comments = comments;
    
    self.title = comments.title ?: @"小区点评";
    self.commentTitle = comments.commentsWrite.title ?: @"我要点评";
    self.contentEmptyTitle = comments.commentsWrite.contentEmptyTitle ?: @"写首条小区精选点评";
    self.commentsSchema = comments.commentsWrite.schema;
    self.commentsListSchema = comments.content.commentsListSchema;

    self.dataList = [[NSMutableArray alloc] init];
    
    for (NSString *content in comments.content.data) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:content];
        cellModel.isInNeighbourhoodCommentsList = NO;
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodComments;
        [_dataList addObject:cellModel];
    }
    
    if(!isEmptyString(comments.content.count)){
        self.totalCount = [comments.content.count integerValue];
        if(self.totalCount > 0 && self.dataList.count > 0){
            self.title = [NSString stringWithFormat:@"%@（%li）",self.title,(long)self.totalCount];
        }
    }
    
    //总数
    if(self.totalCount > 2 || self.dataList.count <= 0){
        self.footerViewHeight = 80;
    }else{
        self.footerViewHeight = 10;
    }
    
    self.headerViewHeight = 65;
    
    if(self.dataList.count > 0){
        self.viewHeight = self.headerViewHeight + self.footerViewHeight;
        FHUGCCellManager *cellManager = [[FHUGCCellManager alloc] init];
        for (FHFeedUGCCellModel *cellModel in self.dataList) {
            Class cellClass = [cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
            if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
                CGFloat cellHeight = [cellClass heightForData:cellModel];
                self.viewHeight += cellHeight;
            }
        }
    }else{
        self.viewHeight = self.headerViewHeight + self.footerViewHeight;
    }
}
@end
