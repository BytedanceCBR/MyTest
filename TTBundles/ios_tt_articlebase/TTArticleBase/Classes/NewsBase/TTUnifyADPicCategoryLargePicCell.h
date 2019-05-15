//
//  TTUnify1ADLargePicCell.h
//  Article
//
//  Created by yin on 16/10/12.
//
//
/*
  此Cell数据与TTUnifyADLargePicCell共用,仅多ad_display_style=1字段,通过ExploreOrderData中largePicCeativeType属性区别,1标示第一种新增大图创意通投新样式,0标示原创意通投大图样式,新样式只在图片频道中投放
  需求文档:https://wiki.bytedance.com/pages/viewpage.action?pageId=65997635
 */

#define kLargePicADCellInPicCategoryDisplayType      1

#import "TTADBaseCell.h"

@interface TTUnifyADPicCategoryLargePicCell : TTADBaseCell

@end
