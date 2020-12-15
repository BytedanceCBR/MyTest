//
//  FHVideoLayout.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import "FHVideoLayout.h"
#import "FHFeedUGCCellModel.h"

#define topMargin 20
#define leftMargin 20
#define rightMargin 20
#define userInfoViewHeight 40
#define bottomViewHeight 45
#define singleImageViewHeight 90
#define originViewHeight 80
#define attachCardViewHeight 57

@implementation FHVideoLayout

- (void)commonInit {
    self.userInfoViewLayout = [FHLayoutItem layoutWithTop:topMargin
                                                     left:0
                                                    width:[UIScreen mainScreen].bounds.size.width
                                                   height:userInfoViewHeight];
    
    self.contentLabelLayout = [FHLayoutItem layoutWithTop:self.userInfoViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin
                                                   height:0];
    
    self.videoViewLayout = [FHLayoutItem layoutWithTop:self.userInfoViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin
                                                   height:ceil(([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * 188.0/335.0)];
    
    self.bottomViewLayout = [FHLayoutItem layoutWithTop:self.videoViewLayout.bottom + 10
                                                     left:0
                                                    width:[UIScreen mainScreen].bounds.size.width
                                                   height:bottomViewHeight];
}

- (void)updateLayoutWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    //内容
    if(isEmptyString(cellModel.content)){
        self.contentLabelLayout.height = 0;
        self.videoViewLayout.top = self.userInfoViewLayout.bottom + 10;
        self.bottomViewLayout.top = self.videoViewLayout.bottom + 10;
    }else{
        self.contentLabelLayout.height = cellModel.contentHeight;
        self.videoViewLayout.top = self.userInfoViewLayout.bottom + 20 + cellModel.contentHeight;
        self.bottomViewLayout.top = self.videoViewLayout.bottom + 10;
    }
    
    [self calculateHeight:cellModel];
}

- (void)calculateHeight:(FHFeedUGCCellModel *)cellModel {
    self.height = self.bottomViewLayout.bottom;
}

@end
