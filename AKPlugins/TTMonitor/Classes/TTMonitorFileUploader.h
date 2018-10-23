//
//  TTMonitorFileUploader.h
//  TTMonitor
//
//  Created by bytedance on 2017/10/24.
//

#import <Foundation/Foundation.h>

@interface TTMonitorFileUploader : NSObject

+(void)uploadIfNeeded:(NSArray *)fileList;

@end
