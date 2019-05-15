//
//  TTCertificationFailureViewController.h
//  Article
//
//  Created by wangdi on 2017/5/22.
//
//

#import "TTCertificationInReviewViewController.h"


/*
 * 审核失败提示页面
 */

@interface TTCertificationFailureViewController : TTCertificationInReviewViewController

@property (nonatomic, copy) void (^operationViewClickBlock)();
@property (nonatomic, copy) NSString *emailText;

@end
