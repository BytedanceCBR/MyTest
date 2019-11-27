//
//  FHHouseNewDetailViewModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseNewDetailViewModel : FHHouseDetailBaseViewModel

// 是否弹出ugc表单
// FHHouseFillFormConfigModel
// FHHouseContactConfigModel
- (BOOL)needShowSocialInfoForm:(id)model;

// 显示新房UGC填留资弹窗
- (void)showUgcSocialEntrance:(FHDetailNoticeAlertView *)alertView;

@end

NS_ASSUME_NONNULL_END
