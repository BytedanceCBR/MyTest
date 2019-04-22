//
//  TTRNavi.h
//  Article
//
//  Created by muhuai on 2017/5/21.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRNavi : TTRDynamicPlugin

TTR_EXPORT_HANDLER(close)
TTR_EXPORT_HANDLER(open)
TTR_EXPORT_HANDLER(openPage)
TTR_EXPORT_HANDLER(openHotsoon)
TTR_EXPORT_HANDLER(openApp)
TTR_EXPORT_HANDLER(handleNavBack)
TTR_EXPORT_HANDLER(onAccountCancellationSuccess)
TTR_EXPORT_HANDLER(showBackBtn)

// 禁用滑动返回
TTR_EXPORT_HANDLER(disableDragBack)
TTR_EXPORT_HANDLER(setNativeTitle)
TTR_EXPORT_HANDLER(setNativeDividerVisible)

@end
