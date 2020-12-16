//
//  FHAnswerLayout.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import "FHAnswerLayout.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCCellMultiImageView.h"

#define topMargin 20
#define leftMargin 20
#define rightMargin 20
#define userInfoViewHeight 30
#define bottomViewHeight 45
#define singleImageViewHeight 90

@implementation FHAnswerLayout

- (void)commonInit {
    self.userInfoViewLayout = [FHLayoutItem layoutWithTop:topMargin
                                                     left:0
                                                    width:[UIScreen mainScreen].bounds.size.width
                                                   height:userInfoViewHeight];
    
    self.userImaLayout = [FHLayoutItem layoutWithTop:self.userInfoViewLayout.bottom + 5
                                                     left:leftMargin
                                                    width:20
                                                   height:20];
    
    self.usernameLayout = [FHLayoutItem layoutWithTop:self.userImaLayout.top + 1
                                                     left:self.userImaLayout.right + 4
                                                    width:50
                                                   height:18];
    
    self.userideLayout = [FHLayoutItem layoutWithTop:self.userImaLayout.top + 1
                                                     left:self.usernameLayout.right + 4
                                                    width:20
                                                   height:18];
    
    self.contentLabelLayout = [FHLayoutItem layoutWithTop:self.userImaLayout.bottom + 5
                                                     left:leftMargin
                                                    width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin
                                                   height:0];
    
    self.multiImageViewLayout = [FHLayoutItem layoutWithTop:self.contentLabelLayout.bottom + 10
                                                     left:leftMargin
                                                    width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin
                                                   height:[FHUGCCellMultiImageView viewHeightForCount:3 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin]];
    
    self.singleImageViewLayout = [FHLayoutItem layoutWithTop:self.contentLabelLayout.bottom + 10
                                                     left:leftMargin
                                                    width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin
                                                   height:[FHUGCCellMultiImageView viewHeightForCount:1 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin]];
    
    self.bottomViewLayout = [FHLayoutItem layoutWithTop:self.multiImageViewLayout.bottom + 10
                                                     left:0
                                                    width:[UIScreen mainScreen].bounds.size.width
                                                   height:bottomViewHeight];
}

- (void)updateLayoutWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    
    //设置userInfo
    NSString *titleStr =  !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"    %@",cellModel.originItemModel.content] : @"";
    CGRect titleRect = [titleStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:0 attributes:@{NSFontAttributeName : [UIFont themeFontMedium:16]} context:nil];
    CGFloat maxTitleLabelSizeWidth = [UIScreen mainScreen].bounds.size.width - 10 - 50 -5;
    if(titleRect.size.width > maxTitleLabelSizeWidth){
        self.userInfoViewLayout.height = 50;
    }else {
         self.userInfoViewLayout.height = 30;
    }
    
    self.userImaLayout.top =  self.userInfoViewLayout.bottom + 5;
    CGRect titleRect1 = [cellModel.user.name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:0 attributes:@{NSFontAttributeName : [UIFont themeFontRegular:14]} context:nil];
    self.usernameLayout.width = ceil(titleRect1.size.width);
    self.userideLayout.width = [UIScreen mainScreen].bounds.size.width - 30 - 40 - titleRect1.size.width;
    self.usernameLayout.top =  self.userImaLayout.top + 1;
    self.userideLayout.top =  self.userImaLayout.top + 1;
    self.userideLayout.left = self.usernameLayout.right + 4;
    self.contentLabelLayout.top = self.userImaLayout.bottom + 5;
    
    //内容
    if(isEmptyString(cellModel.content)){
        self.contentLabelLayout.height = 0;
        self.multiImageViewLayout.top = self.userImaLayout.bottom + 10;
        self.singleImageViewLayout.top = self.userImaLayout.bottom + 10;
    }else{
        self.contentLabelLayout.height = cellModel.contentHeight;
        self.multiImageViewLayout.top = self.userImaLayout.bottom + 15 + cellModel.contentHeight;
        self.singleImageViewLayout.top = self.userImaLayout.bottom + 15 + cellModel.contentHeight;
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
    
    self.bottomViewLayout.top = lastViewLayout.bottom + topOffset;
    [self calculateHeight:cellModel];
}

- (void)calculateHeight:(FHFeedUGCCellModel *)cellModel {
    self.height = self.bottomViewLayout.bottom;
}

@end
