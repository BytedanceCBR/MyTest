//
//  FHFullScreenVideoLayout.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/15.
//

#import "FHFullScreenVideoLayout.h"
#import "FHFeedUGCCellModel.h"
#import "FHHouseUGCHeader.h"
#import "FHUGCCellHelper.h"

#define topMargin 15
#define leftMargin 15
#define rightMargin 15
#define maxLines 3

#define userInfoViewHeight 20
#define bottomViewHeight 50

@implementation FHFullScreenVideoLayout

- (void)commonInit {
    self.iconLayout = [FHLayoutItem layoutWithTop:topMargin
                                                     left:leftMargin
                                                    width:20
                                                   height:20];
    
    self.userNameLayout = [FHLayoutItem layoutWithTop:self.iconLayout.top + 1
                                                     left:self.iconLayout.right + 8
                                                    width:0
                                                   height:18];
    
    self.contentLabelLayout = [FHLayoutItem layoutWithTop:self.iconLayout.bottom + 8
                                                     left:leftMargin
                                                    width:screenWidth - leftMargin - rightMargin
                                                   height:0];
    
    self.videoViewLayout = [FHLayoutItem layoutWithTop:self.iconLayout.bottom + 10
                                                     left:0
                                                    width:screenWidth
                                                   height:ceil(screenWidth * 211.0/375.0)];
    
    self.bottomViewLayout = [FHLayoutItem layoutWithTop:self.videoViewLayout.bottom + 10
                                                     left:0
                                                    width:screenWidth
                                                   height:bottomViewHeight];
    
    self.mutedBgViewLayout = [FHLayoutItem layoutWithTop:self.videoViewLayout.bottom + 10
                                                     left:0
                                                    width:screenWidth
                                                   height:34];
    
    self.muteBtnLayout = [FHLayoutItem layoutWithTop:5
                                                     left:15
                                                    width:24
                                                   height:24];
    
    self.videoLeftTimeLayout = [FHLayoutItem layoutWithTop:10
                                                     left:screenWidth - 42
                                                    width:42
                                                   height:14];
}

- (void)updateLayoutWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    
    [FHUGCCellHelper setRichContentWithModel:cellModel width:self.contentLabelLayout.width numberOfLines:cellModel.numberOfLines font:[UIFont themeFontMedium:16]];
    
    NSString *userName = !isEmptyString(cellModel.user.name) ? cellModel.user.name : @"用户";
    CGRect userNameRect = [userName boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 18) options:0 attributes:@{NSFontAttributeName : [UIFont themeFontRegular:12]} context:nil];
    self.userNameLayout.width = userNameRect.size.width;
    //内容
    if(isEmptyString(cellModel.content)){
        self.contentLabelLayout.height = 0;
        self.videoViewLayout.top = self.iconLayout.bottom + 8;
    }else{
        self.contentLabelLayout.height = cellModel.contentHeight;
        self.videoViewLayout.top = self.iconLayout.bottom + 16 + cellModel.contentHeight;
    }
    
    self.bottomViewLayout.top = self.videoViewLayout.bottom;
    self.mutedBgViewLayout.top = self.bottomViewLayout.top - 34;
    
    CGRect videoLeftTimeRect = [cellModel.videoItem.durationTimeString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14) options:0 attributes:@{NSFontAttributeName : [UIFont themeFontRegular:10]} context:nil];
    
    CGFloat width = videoLeftTimeRect.size.width;
    // 27,42
    if(width < 32){
        width = 42;
    }else{
        width = 57;
    }
    
    self.videoLeftTimeLayout.left = screenWidth - width;
    self.videoLeftTimeLayout.width = width;
    
    [self calculateHeight:cellModel];
}

- (void)calculateHeight:(FHFeedUGCCellModel *)cellModel {
    self.height = self.bottomViewLayout.bottom;
}

@end
