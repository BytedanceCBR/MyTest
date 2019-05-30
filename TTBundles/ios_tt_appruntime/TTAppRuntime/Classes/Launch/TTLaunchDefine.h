//
//  TTLaunchDefine.h
//  TTAppRuntime
//
//  Created by 春晖 on 2019/5/30.
//

#ifndef TTLaunchDefine_h
#define TTLaunchDefine_h

typedef NS_ENUM(NSInteger , FHTaskType) {
    FHTaskTypeSerial = 0,
    FHTaskTypeUI = 1,
    FHTaskTypeOpenURL = 2,
    FHTaskTypeAfterLaunch , //待app 启动后调用
};

typedef struct {
    char *name ;
    FHTaskType type;
    uint16_t priority;
}task_header_info;

typedef struct {
    char *cname;
    char *action;
}after_launch_action_info;

// 在main 函数前执行 代替 load
#define AFTER_LOAD(code) __attribute__((constructor)) static void afterLoad(){ code }

// 定义task
#define DEC_TASK(n,t,p) __attribute__ ((used,section(FHTaskSegmentName "," FHTaskSectionName))) static task_header_info _task_  = {.name = n,.type = t , .priority = p}

// 在applaunch 之后执行的不紧急的任务
#define DEC_AFTER_LAUNCH_ACTION(class_name,action_name) __attribute__ ((used,section(FHTaskSegmentName "," FHTaskSectionName))) static after_launch_action_info _action_ = {.cname = class_name , .action = action_name}


#endif /* TTLaunchDefine_h */
