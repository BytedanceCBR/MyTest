//
//  FHDetailQACellModel.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/2/7.
//

#import "FHDetailQACellModel.h"
#import "FHFeedUGCCellModel.h"

@implementation FHDetailQACellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _topMargin = 30.0f;
    }
    return self;
}

- (void)setQuestion:(FHDetailNeighborhoodDataQuestionModel *)question {
    _question = question;
    
    self.title = question.title ?: @"小区问答";
    
    self.askTitle = question.questionWrite.title ?: @"我要提问";
    self.contentEmptyTitle = question.questionWrite.contentEmptyTitle ?: @"问问小区业主";
    self.askSchema = question.questionWrite.schema;
    self.questionListSchema = question.content.questionListSchema;

    self.dataList = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < question.content.data.count; i++) {
        NSString *content = question.content.data[i];
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:content];
        cellModel.isInNeighbourhoodQAList = NO;
        
        NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
        tracerDic[@"rank"] = @(i);
        tracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
        tracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
        tracerDic[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
        tracerDic[@"element_from"] = @"neighborhood_question";
        cellModel.tracerDic = [tracerDic copy];
        
        [_dataList addObject:cellModel];
    }
    
    if(!isEmptyString(question.content.count)){
        self.totalCount = [question.content.count integerValue];
        if(self.totalCount > 0 && self.dataList.count > 0){
            self.title = [NSString stringWithFormat:@"%@（%li）",self.title,(long)self.totalCount];
        }
    }
    
    //总数
    if(self.totalCount > 2 || self.dataList.count <= 0){
        self.footerViewHeight = 60;
    }else{
        self.footerViewHeight = 10;
    }
    
    self.headerViewHeight = _topMargin + 21;
    
    if(self.dataList.count > 0){
        self.viewHeight = self.headerViewHeight + self.footerViewHeight;
        for (FHFeedUGCCellModel *cellModel in self.dataList) {
            CGFloat cellHeight = [FHNeighbourhoodQuestionCell heightForData:cellModel];
            self.viewHeight += cellHeight;
        }
    }else{
        self.viewHeight = self.headerViewHeight + self.footerViewHeight;
    }
}

@end
