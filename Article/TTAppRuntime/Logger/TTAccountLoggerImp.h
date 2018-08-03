//
//  TTAccountLoggerImp.h
//  Article
//
//  Created by liuzuopeng on 01/08/2017.
//
//

#import <Foundation/Foundation.h>
#import <TTAccountSDK.h>
#import <TTAccountMonitorProtocol.h>




/** 埋点和监控 */
@interface TTAccountLoggerImp : NSObject
<
TTAccountAuthLoginLogger,
TTAccountAuthLoginCallbackLogger,
TTAccountMonitorProtocol
>

@end
