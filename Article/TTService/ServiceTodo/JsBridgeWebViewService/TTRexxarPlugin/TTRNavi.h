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
TTR_EXPORT_HANDLER(openHotsoon)
TTR_EXPORT_HANDLER(openApp)
@end
