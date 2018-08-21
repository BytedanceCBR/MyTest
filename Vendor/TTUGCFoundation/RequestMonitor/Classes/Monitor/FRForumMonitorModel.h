//
//  FRForumMonitorModel.h
//  News
//
//  Created by ranny_90 on 2017/10/18.
//

#import <Foundation/Foundation.h>
#import "FRForumNetWorkMonitor.h"

@interface FRForumMonitorModel : NSObject

@property(nonatomic, copy)NSString *monitorService;

@property(nonatomic, assign)NSInteger monitorStatus;

@property(nonatomic, strong)NSDictionary *monitorExtra;

@end
