//
//  FHArticleLayout.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import "FHArticleLayout.h"
#import "FHFeedUGCCellModel.h"

#define topMargin 15
#define leftMargin 20
#define rightMargin 20
#define imagePadding 4
#define singleImageViewHeight 90
#define bottomViewHeight 35

@interface FHArticleLayout ()

@property(nonatomic ,assign) CGFloat imageWidth;
@property(nonatomic ,assign) CGFloat imageHeight;

@end

@implementation FHArticleLayout

- (void)commonInit {
    self.imageWidth = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin - imagePadding * 2)/3;
    self.imageHeight = ceil(self.imageWidth * 82.0f/109.0f);
    
    self.contentLabelLayout = [FHLayoutItem layoutWithTop:topMargin
                                                     left:leftMargin
                                                    width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin
                                                   height:0];
    
    self.singleImageViewLayout = [FHLayoutItem layoutWithTop:topMargin
                                                     left:0
                                                    width:120
                                                   height:singleImageViewHeight];
    
    self.imageViewContainerLayout = [FHLayoutItem layoutWithTop:0
                                                     left:leftMargin
                                                    width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin
                                                   height:self.imageHeight];
    
    self.bottomViewLayout = [FHLayoutItem layoutWithTop:0
                                                     left:0
                                                    width:[UIScreen mainScreen].bounds.size.width
                                                   height:bottomViewHeight];
    
    NSMutableArray *imageLayouts = [NSMutableArray array];
    FHLayoutItem *firstLayout = self.imageViewContainerLayout;
    for (NSInteger i = 0; i < 3; i++) {
        FHLayoutItem *imageLayout = [[FHLayoutItem alloc] init];
        if(firstLayout == self.imageViewContainerLayout){
            imageLayout.left = 0;
        }else{
            imageLayout.left = firstLayout.right + imagePadding;
        }
        imageLayout.top = 0;
        imageLayout.width = self.imageWidth;
        imageLayout.height = self.imageHeight;

        [imageLayouts addObject:imageLayout];
        
        firstLayout = imageLayout;
    }
    self.imageLayouts = [imageLayouts copy];
}

- (void)updateLayoutWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    
    if(isEmptyString(cellModel.title)){
        self.contentLabelLayout.height = 0;
        self.imageViewContainerLayout.top = self.contentLabelLayout.bottom + 10;
    }else{
        self.contentLabelLayout.height = cellModel.contentHeight;
        self.imageViewContainerLayout.top = self.contentLabelLayout.bottom + 10;
    }
    //图片
    NSArray *imageList = cellModel.imageList;
    if(imageList.count > 1){
        self.contentLabelLayout.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
        self.bottomViewLayout.top = self.imageViewContainerLayout.bottom + 10;
    }else if(imageList.count == 1){
        self.contentLabelLayout.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin - 120 - 15;
        self.singleImageViewLayout.left = self.contentLabelLayout.right + 15;
        self.bottomViewLayout.top = self.singleImageViewLayout.bottom + 10;
    }else{
        self.contentLabelLayout.width = [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin;
        self.bottomViewLayout.top = self.contentLabelLayout.bottom + 10;
    }
    
    [self calculateHeight:cellModel];
}

- (void)calculateHeight:(FHFeedUGCCellModel *)cellModel {
    self.height = self.bottomViewLayout.bottom;
}

@end
