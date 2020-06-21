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

- (instancetype)init {
    self = [super init];
    if (self) {
        _topMargin = 30.0f;
        _bottomMargin = 35.0f;
    }
    return self;
}

- (void)setComments:(FHDetailNeighborhoodDataCommentsModel *)comments {
    _comments = comments;
    
    self.title = comments.title ?: @"小区点评";
    self.commentTitle = comments.commentsWrite.title ?: @"我要点评";
    self.contentEmptyTitle = comments.commentsWrite.contentEmptyTitle ?: @"写首条小区精选点评";
    self.commentsSchema = comments.commentsWrite.schema;
    self.commentsListSchema = comments.content.commentsListSchema;

    self.dataList = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < comments.content.data.count; i++) {
        NSString *content = comments.content.data[i];
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:content];
        cellModel.isInNeighbourhoodCommentsList = NO;
        cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCNeighbourhoodComments;
        
        NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
        tracerDic[@"rank"] = @(i);
        tracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
        tracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
        tracerDic[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
        cellModel.tracerDic = [tracerDic copy];
        
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
        self.footerViewHeight = _bottomMargin + 45;
    }else{
        self.footerViewHeight = 10;
    }
    
    self.headerViewHeight = _topMargin + 20;
    
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

