//
//  AKLoginTrafficViewController.h
//  News
//
//  Created by chenjiesheng on 2018/3/15.
//

#import "SSViewControllerBase.h"

typedef void(^CompleteBlock)(BOOL result);
@interface AKLoginTrafficViewController : SSViewControllerBase

- (instancetype)initWithCompleteBlock:(CompleteBlock)block;
+ (void)presentLoginTrafficViewControllerWithCompleteBlock:(CompleteBlock)block;

+ (void)presentLoginTrafficViewControllerWithCompleteBlock:(CompleteBlock)block params:(NSDictionary *)params;

@end
