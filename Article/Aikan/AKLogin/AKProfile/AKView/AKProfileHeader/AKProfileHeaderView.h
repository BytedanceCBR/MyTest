//
//  AKProfileHeaderView.h
//  News
//
//  Created by chenjiesheng on 2018/3/2.
//

#import <UIKit/UIKit.h>

#import "AKProfileHeaderViewLogined.h"
#import "AKProfileHeaderViewUnLogin.h"

@protocol AKProfileHeaderViewDelegate
<NSObject,
AKProfileHeaderViewLoginedDelegate,
AKProfileHeaderViewUnLoginDelegate>

@end


@class AKProfileBenefitModel;
@interface AKProfileHeaderView : UIView

- (void)refreshLoginViewAndUnLoginViewStatus;
- (void)refreshUserinfo;
- (void)refreshBenefitInfoWithModels:(NSArray<AKProfileBenefitModel *> *)model;
@end
