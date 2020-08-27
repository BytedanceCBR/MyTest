//
//  FHHouseOldDetailViewModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import "FHHouseDetailBaseViewModel.h"
#import "FHSurveyBubbleView.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseOldDetailViewModel : FHHouseDetailBaseViewModel

//实勘经纪人提示
@property(nonatomic,weak) FHSurveyBubbleView *surveyTipView;
@property(nonatomic,copy) NSString *surveyTipName;
- (void)showSurveyTip;
- (void)hiddenSurveyTip;
@end

NS_ASSUME_NONNULL_END
