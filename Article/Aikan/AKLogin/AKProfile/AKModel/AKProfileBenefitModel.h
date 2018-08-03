//
//  AKProfileBenefitModel.h
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import <JSONModel.h>
#import "AKProfileHeaderViewDefine.h"

@interface AKProfileBenefitReddotInfo : JSONModel

@property (nonatomic, copy)NSString           *text;
@property (nonatomic, copy)NSString           *postUrl;
@property (nonatomic, strong)NSNumber         *needShow;
@end

@interface AKProfileBenefitModel : JSONModel

@property (nonatomic, copy)  NSString                                    *type;
@property (nonatomic, copy)  NSString                                    *digit;
@property (nonatomic, copy)  NSString                                    *openURL;
@property (nonatomic, copy)  NSString                                    *benefitName;
@property (nonatomic, strong)AKProfileBenefitReddotInfo<Optional>        *reddotInfo;
@end
