//
//  TTRApp.h
//  Article
//
//  Created by muhuai on 2017/5/19.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>
@interface TTRApp : TTRDynamicPlugin

TTR_EXPORT_HANDLER(isAppInstalled)
TTR_EXPORT_HANDLER(copyToClipboard)
TTR_EXPORT_HANDLER(appInfo)
TTR_EXPORT_HANDLER(config)
TTR_EXPORT_HANDLER(deviceInfo)
TTR_EXPORT_HANDLER(sendNotification)
@end
