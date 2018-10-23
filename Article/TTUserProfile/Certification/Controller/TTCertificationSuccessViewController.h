//
//  TTCertificationSuccessViewController.h
//  Article
//
//  Created by wangdi on 2017/5/22.
//
//

#import "SSViewControllerBase.h"

/*
 * 认证成功界面，显示认证结果
 */

@interface TTCertificationSuccessViewController : SSViewControllerBase

@property (nonatomic, copy) void (^operationViewClick)(BOOL ismodify);
@property (nonatomic, copy) void (^certificationGetVClick)();
@property (nonatomic, copy) NSString *occupationalText;
@property (nonatomic, copy) NSString *certificationText;
@property (nonatomic, copy) NSString *certificationResultText;
@property (nonatomic, copy) NSString *certificationTipText;
@property (nonatomic, copy) NSString *authType;
@property (nonatomic, assign) BOOL isCertificationV;
@end
