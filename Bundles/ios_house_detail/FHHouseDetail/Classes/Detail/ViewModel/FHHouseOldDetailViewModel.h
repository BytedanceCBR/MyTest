//
//  FHHouseOldDetailViewModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import "FHHouseDetailBaseViewModel.h"
#import "FHBubbleView.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseOldDetailViewModel : FHHouseDetailBaseViewModel

@property(nonatomic,weak) FHBubbleView *tipView;
@property(nonatomic,copy) NSString *tipName;
- (void)showSurveyTip;
- (void)hiddenSurveyTip;
@end

NS_ASSUME_NONNULL_END
