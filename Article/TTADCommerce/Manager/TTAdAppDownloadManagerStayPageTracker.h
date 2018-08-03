//
//  TTAdAppDownloadManagerStayPageTracker.h
//  Article
//
//  Created by rongyingjie on 2017/7/10.
//
//

#import "TTAdAppDownloadManager.h"

@interface TTAdAppDownloadManagerStayPageTracker : NSObject <TTAdAppDownloadManagerProtocol>
/**
 *  用于统计停留时常
 */
@property (nonatomic, assign)NSTimeInterval startTime;

@end
