//
//  ExploreArticleTitleLargePicCellView.h
//  Article
//
//  Created by Chen Hong on 14-9-14.
//
//

#import "ExploreArticleCellView.h"

@class TTImageView;

typedef NS_ENUM(NSInteger, LargePicViewType)
{
    LargePicViewTypeNormal,     //原有大图样式
    LargePicViewTypeGallary,    //组图新增大图样式，通过gallaryFlag=1确认
};

@interface ExploreArticleTitleLargePicCellView : ExploreArticleCellView

@property(nonatomic,strong)SSThemedView* adInfoBgView;

@end
