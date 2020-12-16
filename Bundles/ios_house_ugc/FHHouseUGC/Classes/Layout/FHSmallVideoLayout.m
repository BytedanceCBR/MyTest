//
//  FHSmallVideoLayout.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/15.
//

#import "FHSmallVideoLayout.h"
#import "FHFeedUGCCellModel.h"

#define topMargin 20
#define leftMargin 20
#define rightMargin 20

#define userInfoViewHeight 40
#define bottomViewHeight 45

@interface FHSmallVideoLayout ()

@property(nonatomic ,assign) CGFloat imageViewHeight;
@property(nonatomic ,assign) CGFloat imageViewWidth;

@end

@implementation FHSmallVideoLayout

- (void)commonInit {
    
    self.imageViewHeight = 200;
    self.imageViewWidth = 150;
    
    self.userInfoViewLayout = [FHLayoutItem layoutWithTop:topMargin
                                                     left:0
                                                    width:[UIScreen mainScreen].bounds.size.width
                                                   height:userInfoViewHeight];
    
    self.contentLabelLayout = [FHLayoutItem layoutWithTop:self.userInfoViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin
                                                   height:0];
    
    self.videoImageViewLayout = [FHLayoutItem layoutWithTop:self.userInfoViewLayout.bottom + 10
                                                     left:leftMargin
                                                    width:self.imageViewWidth
                                                   height:self.imageViewHeight];
    
    self.bottomViewLayout = [FHLayoutItem layoutWithTop:self.videoImageViewLayout.bottom + 10
                                                     left:0
                                                    width:[UIScreen mainScreen].bounds.size.width
                                                   height:bottomViewHeight];
    
    self.playIconLayout = [FHLayoutItem layoutWithTop:(self.imageViewHeight - 44)/2
                                                     left:(self.imageViewWidth - 44)/2
                                                    width:44
                                                   height:44];
    
    self.timeBgViewLayout = [FHLayoutItem layoutWithTop:(self.imageViewHeight - 20 - 4)
                                                     left:(self.imageViewWidth - 44 - 4)
                                                    width:44
                                                   height:20];
    
    self.timeLabelLayout = [FHLayoutItem layoutWithTop:3
                                                     left:6
                                                    width:32
                                                   height:14];
    
    
}

- (void)updateLayoutWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    //图片
    if (cellModel.imageList.count > 0) {
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        CGFloat wid = [imageModel.width floatValue];
        CGFloat hei = [imageModel.height floatValue];
        if (wid <= hei) {
            self.imageViewHeight = 200;
            self.imageViewWidth = 150;
        } else {
            self.imageViewHeight = 152;
            self.imageViewWidth = 270;
        }
        
        self.videoImageViewLayout.width = self.imageViewWidth;
        self.videoImageViewLayout.height = self.imageViewHeight;
    }
    // 时间
    CGRect timeLabelRect = [cellModel.videoDurationStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14) options:0 attributes:@{NSFontAttributeName : [UIFont themeFontRegular:10]} context:nil];
    self.timeLabelLayout.width = ceil(timeLabelRect.size.width);
    self.timeBgViewLayout.width = self.timeLabelLayout.width + 12;
    self.timeBgViewLayout.left = self.imageViewWidth - self.timeBgViewLayout.width - 4;
    self.timeLabelLayout.left = 6;
    
    if(isEmptyString(cellModel.content)){
        self.contentLabelLayout.height = 0;
        self.videoImageViewLayout.top = self.userInfoViewLayout.bottom + 10;
    }else{
        self.contentLabelLayout.height = cellModel.contentHeight;
        self.videoImageViewLayout.top = self.contentLabelLayout.bottom + 10;
    }
    
    self.bottomViewLayout.top = self.videoImageViewLayout.bottom + 10;
    
    [self calculateHeight:cellModel];
}

- (void)calculateHeight:(FHFeedUGCCellModel *)cellModel {
    self.height = self.bottomViewLayout.bottom;
}

@end
