//
//  TTRPay.h
//  Article
//
//  Created by muhuai on 2017/5/18.
//
//
#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRPay : TTRDynamicPlugin

TTR_EXPORT_HANDLER(pay)

TTR_EXPORT_HANDLER(iap)
@end
