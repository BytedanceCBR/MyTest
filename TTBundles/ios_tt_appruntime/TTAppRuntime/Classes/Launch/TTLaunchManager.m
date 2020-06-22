//
//  TTLaunchManager.m
//  TTAppRuntime
//
//  Created by 春晖 on 2019/5/30.
//

#import "TTLaunchManager.h"
#import "TTLaunchDefine.h"
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import "TTStartupTask.h"
#import "NewsBaseDelegate.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "SSCommonLogic.h"
#import "NSDictionary+TTAdditions.h"

static NSDate *preMainDate = nil;

@interface TTLaunchManager ()
{
    task_header_info *_header_info;
}
@property(nonatomic , strong) NSMutableDictionary *lauchGroupsDict;

@end

@implementation TTLaunchManager

+(instancetype)sharedInstance
{
    static TTLaunchManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTLaunchManager alloc]init];
    });
    return manager;
}

+(void)setPreMainDate:(NSDate *)date
{
    preMainDate = date;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initLaunchInfo];
    }
    return self;
}

-(void)dealloc
{
    if (_header_info) {
        free(_header_info);
    }
}

-(void)initLaunchInfo
{
#ifdef __LP64__
    typedef uint64_t fb_tweak_value;
    typedef struct section_64 fh_task_section;
    typedef struct mach_header_64 fh_task_header;
#else
    typedef uint32_t fb_tweak_value;
    typedef struct section fh_task_section;
    typedef struct mach_header fh_task_header;
#endif
        
    uint32_t image_count = _dyld_image_count();
    for (uint32_t image_index = 0; image_index < image_count; image_index++) {
        const fh_task_header *mach_header = (const fh_task_header *)_dyld_get_image_header(image_index);
        
        unsigned long size;
        task_header_info *data = (task_header_info *)getsectiondata(mach_header, FHTaskSegmentName, FHTaskSectionName, &size);
        if (data == NULL) {
            continue;
        }
        
        size_t count = size / sizeof(task_header_info);
#if DEBUG
        NSLog(@"[LAUNCH] task count is: %ld",count);
#endif
        
        NSMutableArray *orders = [NSMutableArray arrayWithCapacity:count];
        for (size_t i = 0; i < count; i++) {
            [orders addObject:@(i)];
        }
        
        [orders sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSInteger i1 = [obj1 integerValue];
            NSInteger i2 = [obj2 integerValue];
            
            task_header_info *header1 = &data[i1];
            task_header_info *header2 = &data[i2];
            return header1->priority >= header2->priority;
        }];
        
        _lauchGroupsDict = [NSMutableDictionary new];
        
//        NSMutableArray *allTasks = [NSMutableArray new];
        
        for (NSNumber *num in orders) {
            task_header_info *header = &data[num.integerValue];
//            printf("=== header name is: %s  type is: %ld priority is: %d ",header->name,header->type,header->priority);
            NSMutableArray *tasks = _lauchGroupsDict[@(header->type)];
            if (!tasks) {
                tasks = [NSMutableArray new];
                _lauchGroupsDict[@(header->type)] = tasks;
            }
//            [allTasks addObject:[NSString stringWithCString:header->name encoding:NSUTF8StringEncoding]];
            NSValue *value = [NSValue value:header withObjCType:@encode(task_header_info)];
            [tasks addObject:value];
        }
        
        _header_info = data;
        
        
//        [allTasks sortUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString*  _Nonnull obj2) {
//            return [obj1 compare:obj2];
//        }];
//
//        NSLog(@"==== task ======");
//        for (NSString *task in allTasks) {
//            NSLog(@"[TASK] %@",task);
//        }
//        NSLog(@"DONE");
    }
}

-(void)launchWithApplication:(UIApplication *)application andOptions:(NSDictionary *)options
{
    NSDate *s = [NSDate date];
    
    task_header_info taskInfo;
    
    NSMutableArray *taskList = [NSMutableArray new];
    
    for (NSInteger type = 0 ; type <= FHTaskTypeAfterLaunch ; type++) {
#ifndef DEBUG
        if (type == FHTaskTypeDebug) {
            continue;
        }
#endif
        
        NSArray *tasks = self.lauchGroupsDict[@(type)];
        if (tasks.count > 0) {
            for (NSValue *taskValue in tasks) {
                [taskValue getValue:&taskInfo];
                TTStartupTask *task = [self startTask:&taskInfo withApplication:application andOptions:options];
                if(task){
                    [taskList addObject:task];
                }
            }
        }
    }
    
    BOOL startupOptimizeClose = ![[self fhSettings] tt_boolValueForKey:@"f_startup_optimize_open"];
    if(startupOptimizeClose){
        [self updateTaskRecords:taskList];
    }
#ifndef DEBUG
    NSLog(@"[LAUNCH] tasks takes %f S ",[[NSDate date]timeIntervalSinceDate:s]);
#endif
}

-(TTStartupTask *)startTask:(task_header_info *)headerInfo withApplication:(UIApplication *)application andOptions:(NSDictionary *)options
{
    NSString *taskName = [NSString stringWithCString:headerInfo->name encoding:NSUTF8StringEncoding];
    Class taskClass = NSClassFromString(taskName);
    if (![taskClass isSubclassOfClass:[TTStartupTask class]]) {
        return nil;
    }
     
    TTStartupTask *task = [[taskClass alloc] init];
    if ([task shouldExecuteForApplication:application options:options]) {
        if ([self isConcurrentFotType:headerInfo->type] || [task isConcurrent]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /*
                 * 主要执行TTFabricSDKRegister、TTFeedPreloadTask、TTUserConfigReportTask
                 * 因为feed移动在第二栏，可以延迟执行，带首页加载完成后执行
                 */
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [task startAndTrackWithApplication:application options:options];
                });
            });
        } else {
            BOOL startupOptimizeClose = ![[self fhSettings] tt_boolValueForKey:@"f_startup_optimize_open"];
            if(startupOptimizeClose){
                [task setTaskNormal:NO];
            }
            [task startAndTrackWithApplication:application options:options];
            if(startupOptimizeClose){
                [task setTaskNormal:YES];
            }
        }
        [SharedAppDelegate trackCurrentIntervalInMainThreadWithTag:[task taskIdentifier]];
    }
    [SharedAppDelegate addResidentTaskIfNeeded:task];
    return task;
}

-(BOOL)isConcurrentFotType:(FHTaskType )type
{
//    switch (type) {
//        case FHTaskTypeSerial:
//        case FHTaskTypeAD:
//
//            return NO;
//
//        default:
//            break;
//    }
    return NO;
}

-(void)updateTaskRecords:(NSArray *)tasks
{
    if ([SSCommonLogic isFHNewLaunchOptimizeEnabled]) {
        for(TTStartupTask *task in tasks){
            NSString *key = [TTStartupProtectPrefix stringByAppendingString:[task taskIdentifier]];
            if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:key];
            }
        }
    }
    else {
        
        NSMutableDictionary *defaultDict = [NSMutableDictionary new];
        for(TTStartupTask *task in tasks){
            defaultDict[[TTStartupProtectPrefix stringByAppendingString:[task taskIdentifier]]] = @(YES);
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultDict];
    }
}


+ (BOOL)processInfoForPID:(int)pid procInfo:(struct kinfo_proc*)procInfo
{
    int cmd[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, pid};
    size_t size = sizeof(*procInfo);
    return sysctl(cmd, sizeof(cmd)/sizeof(*cmd), procInfo, &size, NULL, 0) == 0;
}

+ (NSTimeInterval)processStartTime
{
    struct kinfo_proc kProcInfo;
    if ([self processInfoForPID:[[NSProcessInfo processInfo] processIdentifier] procInfo:&kProcInfo]) {
        return kProcInfo.kp_proc.p_un.__p_starttime.tv_sec * 1000.0 + kProcInfo.kp_proc.p_un.__p_starttime.tv_usec / 1000.0;
    } else {
        NSAssert(NO, @"无法取得进程的信息");
        return 0;
    }
}

+(void)dumpLaunchDuration
{
    NSDate *now = [NSDate date];
    NSTimeInterval laucnhTS = [self processStartTime];
    NSTimeInterval nowTS = [now timeIntervalSince1970]*1000;
    NSLog(@"[LAUNCH] whole launch takes: %f ms",(nowTS - laucnhTS));
    if(preMainDate){
        NSLog(@"[LAUNCH] after main launch takes: %f ms",nowTS - [preMainDate timeIntervalSince1970]*1000);
    }
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

@end
