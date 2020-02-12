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
        
    }
    return self;
}

- (void)setQuestion:(FHDetailNeighborhoodDataQuestionModel *)question {
    _question = question;
    
    self.title = question.title ?: @"小区问答";
    if(!isEmptyString(question.content.count)){
//        self.totalCount = [question.content.count integerValue];
        self.totalCount = 20;
        self.title = [NSString stringWithFormat:@"%@（%li）",self.title,(long)self.totalCount];
    }
    
    self.askTitle = question.questionWrite.title ?: @"我要提问";
    self.contentEmptyTitle = question.questionWrite.contentEmptyTitle ?: @"问问小区业主";
    self.askSchema = question.questionWrite.schema;
    self.questionListSchema = question.content.questionListSchema;

    self.dataList = [[NSMutableArray alloc] init];
    
    for (NSString *content in question.content.data) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:content];
        cellModel.isInNeighbourhoodQAList = NO;
        [_dataList addObject:cellModel];
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
        for (FHFeedUGCCellModel *cellModel in self.dataList) {
            CGFloat cellHeight = [FHNeighbourhoodQuestionCell heightForData:cellModel];
            self.viewHeight += cellHeight;
        }
    }else{
        self.viewHeight = self.headerViewHeight + self.footerViewHeight;
    }
}

- (void)fakeData {
    self.title = @"小区问答（20）";
    self.askTitle = @"我要提问";
    self.dataList = [[NSMutableArray alloc] init];
    [_dataList addObject:[FHFeedUGCCellModel modelFromFake3:NO]];
    [_dataList addObject:[FHFeedUGCCellModel modelFromFake3:NO]];
    
    //总数
    self.totalCount = 20;
    if(self.totalCount > 2 || self.dataList.count <= 0){
        self.footerViewHeight = 80;
    }else{
        self.footerViewHeight = 10;
    }
    
    self.headerViewHeight = 65;
    
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
