//
//  TTCertificationInReviewViewController.h
//  Article
//
//  Created by wangdi on 2017/5/22.
//
//

#import "SSViewControllerBase.h"
#import "SSThemed.h"
#import "TTCertificationConst.h"
/*
 * 审核中提示页面
 */

@interface TTCertificationInReviewViewController : SSViewControllerBase

@property (nonatomic, strong) SSThemedImageView *iconView;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) SSThemedLabel *timeLabel;
@property (nonatomic, strong) SSThemedButton *questionButton;
@property (nonatomic, copy) NSString *questionUrl;
- (void)setupSubview;

@end
