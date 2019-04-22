//
//  TTRMonitor.h
//  Article
//
//  Created by muhuai on 2017/6/26.
//
//

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRMonitor : TTRDynamicPlugin

TTR_EXPORT_HANDLER(status)

TTR_EXPORT_HANDLER(value)

@end
