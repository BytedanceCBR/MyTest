//
//  TTCertificationChooseIndustryViewController.h
//  Article
//
//  Created by wangdi on 2017/5/19.
//
//

#import "SSViewControllerBase.h"
#import "TTGetCertificationResponseModel.h"

@interface TTCertificationChooseIndustryViewController : SSViewControllerBase

@property (nonatomic, strong) NSArray <TTGetCertificationDataIndustryResponseModel *> *dataArray;
@property (nonatomic, copy) void (^chooseIndustryBlock)(NSString *text);

@end
