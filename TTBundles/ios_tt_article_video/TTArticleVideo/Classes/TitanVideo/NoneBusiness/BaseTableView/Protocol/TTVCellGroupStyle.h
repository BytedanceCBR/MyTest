//
//  TTVCellGroupStyle.h
//  Article
//
//  Created by pei yun on 2017/4/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTVCellGroupStyle){
    TTVCellGroupStyleSingle = 0, //顶部和底部分割线均为外分割线
    TTVCellGroupStyleTop = 1,    //顶部为外分割线，底部为内分割线
    TTVCellGroupStyleMiddle = 2, //顶部没有分割线，底部为内分割线
    TTVCellGroupStyleBottom = 3, //顶部没有分割线，底部为外分割线
    TTVCellGroupStyleNone = 4,   //顶部和底部都没有分割线
};

extern TTVCellGroupStyle ttv_cellGroupStyleByTotalAndRow(NSInteger total,NSInteger row);
