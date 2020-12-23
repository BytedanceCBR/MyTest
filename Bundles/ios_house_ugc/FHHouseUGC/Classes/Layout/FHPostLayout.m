//
//  FHPostLayout.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import "FHPostLayout.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"

#define topMargin 20
#define leftMargin 20
#define rightMargin 20
#define userInfoViewHeight 40
#define bottomViewHeight 45
#define singleImageViewHeight 90
#define originViewHeight 80
#define attachCardViewHeight 57

@interface FHPostLayout ()

@end

@implementation FHPostLayout

- (void)commonInit {
    self.userInfoViewLayout = [FHLayoutItem layoutWithTop:topMargin
                                                     left:0
                                                    width:screenWidth
                                                   height:userInfoViewHeight];
    
    self.contentLabelLayout = [FHLayoutItem layoutWithTop:self.userInfoViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:screenWidth - leftMargin - rightMargin
                                                   height:0];
    
    self.multiImageViewLayout = [FHLayoutItem layoutWithTop:self.userInfoViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:screenWidth - leftMargin - rightMargin
                                                   height:[FHUGCCellMultiImageView viewHeightForCount:3 width:screenWidth - leftMargin - rightMargin]];
    
    self.singleImageViewLayout = [FHLayoutItem layoutWithTop:self.userInfoViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:screenWidth - leftMargin - rightMargin
                                                   height:[FHUGCCellMultiImageView viewHeightForCount:1 width:screenWidth - leftMargin - rightMargin]];
    
    self.bottomViewLayout = [FHLayoutItem layoutWithTop:self.multiImageViewLayout.bottom + 10
                                                     left:0
                                                    width:screenWidth
                                                   height:bottomViewHeight];
    
    self.originViewLayout = [FHLayoutItem layoutWithTop:self.multiImageViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:screenWidth - leftMargin - rightMargin
                                                   height:originViewHeight];
    
    self.attachCardViewLayout = [FHLayoutItem layoutWithTop:self.multiImageViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:screenWidth - leftMargin - rightMargin
                                                   height:attachCardViewHeight];
}

- (void)updateLayoutWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    
    if(![cellModel.cellLayoutStyle isEqualToString:@"10001"]){
        [FHUGCCellHelper setRichContentWithModel:cellModel width:self.contentLabelLayout.width numberOfLines:cellModel.numberOfLines];
    }
    
    if(isEmptyString(cellModel.content)){
        self.contentLabelLayout.height = 0;
        self.multiImageViewLayout.top = self.userInfoViewLayout.bottom + 10;
        self.singleImageViewLayout.top = self.userInfoViewLayout.bottom + 10;
    }else{
        self.contentLabelLayout.height = cellModel.contentHeight;
        self.multiImageViewLayout.top = self.userInfoViewLayout.bottom + 20 + cellModel.contentHeight;
        self.singleImageViewLayout.top = self.userInfoViewLayout.bottom + 20 + cellModel.contentHeight;
    }
    
    FHLayoutItem *lastViewLayout = self.contentLabelLayout;
    CGFloat topOffset = 10;
    //图片
    if(cellModel.imageList.count > 1){
        lastViewLayout = self.multiImageViewLayout;
    }else if(cellModel.imageList.count == 1){
        lastViewLayout = self.singleImageViewLayout;
    }else{
        lastViewLayout = self.contentLabelLayout;
    }
     //origin
    if(cellModel.originItemModel){
        self.originViewLayout.top = lastViewLayout.bottom + topOffset;
        self.originViewLayout.height = cellModel.originItemHeight;
        topOffset += cellModel.originItemHeight;
        topOffset += 10;
    }
    //attach card
    if(cellModel.attachCardInfo){
        self.attachCardViewLayout.top = lastViewLayout.bottom + topOffset;
        topOffset += attachCardViewHeight;
        topOffset += 10;
    }
    
    self.bottomViewLayout.top = lastViewLayout.bottom + topOffset;
    
    [self calculateHeight:cellModel];
}

- (void)calculateHeight:(FHFeedUGCCellModel *)cellModel {
    self.height = self.bottomViewLayout.bottom;
}

@end
