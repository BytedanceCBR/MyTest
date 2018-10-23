//
//  TTMemoryUsageMonitorRecorder.h
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import "TTBaseSystemMonitorRecorder.h"
#include <mach/mach.h>
#include <mach/mach_host.h>

static double memory_now(){
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ){
        return info.resident_size / (1024.0 * 1024.0);
    }
    else{
        return -1;
    }
    return -1;
}


@interface TTMemoryUsageMonitorRecorder : TTBaseSystemMonitorRecorder

@end
