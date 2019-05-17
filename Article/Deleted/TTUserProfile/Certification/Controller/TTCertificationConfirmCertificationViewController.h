//
//  TTCertificationConfirmCertificationViewController.h
//  Article
//
//  Created by wangdi on 2017/8/31.
//
//

#import "SSViewControllerBase.h"

@interface TTCertificationConfirmCertificationViewController : SSViewControllerBase

@property (nonatomic, copy) void (^confirmCertificationClickBlock)();
- (instancetype)initWithRequestURL:(NSString *)url;

@end
