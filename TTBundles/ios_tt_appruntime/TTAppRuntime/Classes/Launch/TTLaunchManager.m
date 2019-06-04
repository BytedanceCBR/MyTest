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
//        NSLog(@"---task s======");
//        for (NSString *task in allTasks) {
//            NSLog(@"[TASK] %@",task);
//        }
//        NSLog(@"DONE");
    }
}

-(void)launchWithApplication:(UIApplication *)application andOptions:(NSDictionary *)options
{
    task_header_info taskInfo;
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
                [self startTask:&taskInfo withApplication:application andOptions:options];
            }
        }
    }
    
}

-(void)startTask:(task_header_info *)headerInfo withApplication:(UIApplication *)application andOptions:(NSDictionary *)options
{
    NSString *taskName = [NSString stringWithCString:headerInfo->name encoding:NSUTF8StringEncoding];
    Class taskClass = NSClassFromString(taskName);
    if (![taskClass isSubclassOfClass:[TTStartupTask class]]) {
        return;
    }
    
    TTStartupTask *task = [[taskClass alloc] init];
    if ([task shouldExecuteForApplication:application options:options]) {
        if ([self isConcurrentFotType:headerInfo->type] || [task isConcurrent]) {
            dispatch_async(SharedAppDelegate.barrierQueue, ^{
                [task startAndTrackWithApplication:application options:options];
            });
        } else {
            [task setTaskNormal:NO];
            [task startAndTrackWithApplication:application options:options];
            [task setTaskNormal:YES];
        }
        [SharedAppDelegate trackCurrentIntervalInMainThreadWithTag:[task taskIdentifier]];
    }
    [SharedAppDelegate addResidentTaskIfNeeded:task];
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

@end
