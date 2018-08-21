//
//  AKProfileHeaderBeneficialButton.h
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import <UIKit/UIKit.h>

#import "AKProfileHeaderViewDefine.h"

@class AKProfileBenefitModel;
@interface AKProfileHeaderBeneficialButton : UIControl

@property (nonatomic, copy,   readonly)NSString                                   *benefitType;
@property (nonatomic, strong, readonly)AKProfileBenefitModel                      *model;
+ (instancetype)buttonWithBeneficialButtonType:(NSString *)type;
- (void)setupDesLabelText:(NSString *)text;
- (void)refreshContentWithModel:(AKProfileBenefitModel *)model;
@end
