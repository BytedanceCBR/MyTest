//
//  TTOccupationalCertificationViewController.h
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "SSViewControllerBase.h"
#import "TTCertificationEditView.h"
#import "TTPostCertificationResponseModel.h"

/*
 * 个人和机构认证的页面，属于头条号类型
 */

@interface TTOccupationalCertificationViewController : SSViewControllerBase

@property (nonatomic, strong) NSArray<TTCertificationEditModel *> *occupationalEditModels;
@property (nonatomic, strong) TTCertificationEditModel *supplementModel;
@property (nonatomic, strong) TTCertificationEditView *editView;
@property (nonatomic, strong) NSDictionary<NSString *,UIImage *> *images;
@property (nonatomic, assign) BOOL isModify;
@property (nonatomic, assign) BOOL isCertificationV;
@property (nonatomic, copy) NSString *authType;
@property (nonatomic, copy) NSString *questionUrl;

- (BOOL)hasEditInfo;
- (void)tapClick;

@end
