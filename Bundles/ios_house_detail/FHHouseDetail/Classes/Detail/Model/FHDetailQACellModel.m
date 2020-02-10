//
//  FHDetailQACellModel.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/2/7.
//

#import "FHDetailQACellModel.h"
#import "FHFeedUGCCellModel.h"

@implementation FHDetailQACellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFold = YES;
    }
    return self;
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
