//
//  TTCrashAttemptFixTask.m
//  Article
//
//  Created by fengyadong on 2017/5/16.
//
//

#import "TTCrashAttemptFixTask.h"
#import "SSCommonLogic.h"
#import <mach/mach.h>
#import <mach/vm_types.h>
#import <mach/vm_map.h>
#import <sys/sysctl.h>
#import <mach/task.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <objc/runtime.h>

@implementation TTCrashAttemptFixTask

- (NSString *)taskIdentifier {
    return @"CrashAttemptFix";
}

- (BOOL)shouldExecuteForApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    fix_nano_crash_if_enable();
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-prototypes"
void fix_nano_crash_if_enable() {
    if (is_enable_fix_nano_crash()) {
        fix_nano_crash();
    }
}

void fix_nano_crash() {
    vm_size_t allocation_size = 1024 * 1024;
    vm_address_t startAddress = (vm_address_t)0x170000000;
    
    vm_size_t total_alloc_vm_mem = 0;
    while (startAddress < (vm_address_t)0x180000000)
    {
        kern_return_t kr = vm_allocate(mach_task_self(), &startAddress, allocation_size, false);
        if (kr == KERN_SUCCESS)
        {
            total_alloc_vm_mem += allocation_size;
        }
        
        startAddress += allocation_size;
    }
}

bool is_enable_fix_nano_crash() {
    cpu_type_t type;
    size_t size;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    if (type != CPU_TYPE_ARM64)
    {
        return false ;
    }
    
    return true;
}
#pragma clang diagnostic pop

@end
