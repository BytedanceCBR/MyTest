//
//  TTMessageNotificationStartupTask.h
//  Article
//
//  Created by 邱鑫玥 on 2017/5/3.
//
//

#import "TTStartupTask.h"

/**
 * 消息通知启动task
 * 将消息通知启动时轮询时机放在application:didFinishLaunchingWithOptions:
 */

@interface TTMessageNotificationStartupTask : TTStartupTask

@end
