//
//  TTCertificationConditionViewController.h
//  Article
//
//  Created by wangdi on 2017/5/17.
//
//

#import "SSViewControllerBase.h"
#import "TTCertificationConditionView.h"

/*
 * 申请认证需要满足条件界面
 */

#define kIconRegex @"^.*pstatp\\.com\\/.*\\/(3791\\/5035712059|3795\\/3033762272|3792\\/5112637127|3791\\/5070639578|3797\\/2889309425|3793\\/3114521287|3796\\/2975850990|3795\\/3044413937|3795\\/3047680722|3793\\/3131589739)$"
#define kUserNameRegex @"^(手机)?用户\\d+$"

@protocol TTCertificationConditionViewControllerDelegate <NSObject>

- (void)didSelectedWithType:(TTCertificationConditionType)type;

@end

@interface TTCertificationConditionViewController : SSViewControllerBase

@property (nonatomic, strong) NSArray<TTCertificationConditionModel *> *dataArray;
@property (nonatomic, weak) id <TTCertificationConditionViewControllerDelegate>delegate;

@end
