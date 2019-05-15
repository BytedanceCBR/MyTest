//
//  AKProfileBenefitReddotView.h
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AKProfileBenefitReddotViewType)
{
    AKProfileBenefitReddotViewTypeSimple = 0,//圆圈红点
    AKProfileBenefitReddotViewTypeText,//文字箭头红点
};

@class AKProfileBenefitReddotInfo;
@interface AKProfileBenefitReddotView : UIView

@property (nonatomic, assign)AKProfileBenefitReddotViewType         reddotType;

- (void)refreshContentWithInfo:(AKProfileBenefitReddotInfo *)info;
//用于检测是否超出了父视图的宽度，并做省略处理
- (void)checkFixIfNeedAdjustLabelWidth;
@end
