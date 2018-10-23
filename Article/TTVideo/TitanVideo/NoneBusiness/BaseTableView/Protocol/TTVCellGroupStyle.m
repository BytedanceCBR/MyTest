//
//  TTVCellGroupStyle.m
//  Article
//
//  Created by pei yun on 2017/4/17.
//
//

#import "TTVCellGroupStyle.h"

TTVCellGroupStyle ttv_cellGroupStyleByTotalAndRow(NSInteger total,NSInteger row)
{
    TTVCellGroupStyle cellStyle = TTVCellGroupStyleSingle;
    if (!(total == 1 && row == 0)) {
        if (row == 0) {
            cellStyle = TTVCellGroupStyleTop;
        } else if (row == total - 1){
            cellStyle = TTVCellGroupStyleBottom;
        } else {
            cellStyle = TTVCellGroupStyleMiddle;
        }
    }
    return cellStyle;
}
