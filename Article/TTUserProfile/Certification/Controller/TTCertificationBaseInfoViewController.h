//
//  TTCertificationBaseInfoViewController.h
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "SSViewControllerBase.h"
#import "TTGetCertificationResponseModel.h"
#import "TTCertificationEditView.h"

/*
 * 个人和机构认证的页面，不是头条号类型
 */

@interface TTCertificationBaseInfoViewController : SSViewControllerBase

@property (nonatomic, strong) TTCertificationEditView *editView;
@property (nonatomic, strong) NSArray<TTCertificationEditModel *> *editModels;
@property (nonatomic, copy) void (^opreationViewClickBlock)();

- (NSDictionary *)images;
- (BOOL)hasEditInfo;
- (void)tapClick;

@end
