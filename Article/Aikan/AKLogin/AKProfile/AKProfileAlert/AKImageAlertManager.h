//
//  AKImageAlertManager.h
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import <Foundation/Foundation.h>
#import "AKImageAlertModel.h"
@interface AKImageAlertManager : NSObject

//检查是否需要展示我的页面的图片弹窗
+ (void)checkProfileImageAlertShowIfNeed;

/**
 展示一个图片弹窗，会对图片进行下载，下载完成后弹出弹窗

 @param model 已经构建好的model
 */
+ (void)appendImageAlertWithModel:(AKImageAlertModel *)model;
@end
