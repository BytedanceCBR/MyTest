//
//  AKProfileHeaderViewLogined.h
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import <UIKit/UIKit.h>

#import "AKProfileHeaderBeneficialView.h"

@protocol AKProfileHeaderViewLoginedDelegate <NSObject, AKProfileHeaderBeneficialViewDelegate>

//当点击infoView区域的时候会回调该方法
- (void)infoViewRegionClicked;

@end

@interface AKProfileHeaderViewLogined : UIView

- (instancetype)initWithDelegate:(NSObject<AKProfileHeaderViewLoginedDelegate> *)delegate;
- (void)refreshUserInfo;
- (void)refreshBenefitInfoWithModels:(NSArray<AKProfileBenefitModel *> *)model;

@end
