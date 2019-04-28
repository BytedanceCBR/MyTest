//
//  AKProfileHeaderBeneficialView.h
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import <UIKit/UIKit.h>

#import "AKProfileHeaderViewDefine.h"

@class AKProfileBenefitModel;
@class AKProfileHeaderBeneficialButton;
@protocol AKProfileHeaderBeneficialViewDelegate <NSObject>

- (void)beneficalButtonClickedWithModel:(AKProfileBenefitModel *)model
                          beneficButton:(AKProfileHeaderBeneficialButton *)button;

@end

@interface AKProfileHeaderBeneficialView : UIView

@property (nonatomic, weak) NSObject<AKProfileHeaderBeneficialViewDelegate> *delegate;
- (void)refreshBenefitInfoWithModels:(NSArray<AKProfileBenefitModel *> *)model;
@end
