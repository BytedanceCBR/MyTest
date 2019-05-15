//
//  TTRAd.h
//  Article
//
//  Created by muhuai on 2017/5/31.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRAd : TTRDynamicPlugin

TTR_EXPORT_HANDLER(openCommodity)

TTR_EXPORT_HANDLER(callNativePhone)

TTR_EXPORT_HANDLER(getAddress)

TTR_EXPORT_HANDLER(temaiEvent)
@end
