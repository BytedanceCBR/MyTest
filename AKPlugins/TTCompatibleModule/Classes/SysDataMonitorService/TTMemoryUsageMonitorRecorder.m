//
//  TTMemoryUsageMonitorRecorder.m
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import "TTMemoryUsageMonitorRecorder.h"
#import "TTMonitor.h"

@implementation TTMemoryUsageMonitorRecorder
{
    uint64_t _memoryActiveBytes;
    uint64_t _memoryInactiveBytes;
    uint64_t _memoryWiredBytes;
    uint64_t _memoryFreeBytes;
    uint64_t _memoryUsedBytes;
    uint64_t _memoryTotalBytes;
    uint64_t _memoryPageSize;
    NSTimeInterval _startTime;
}

- (id)init{
    self = [super init];
    if (self) {
        _startTime = [[NSDate date] timeIntervalSince1970];
        [self updateInfo];
    }
    return self;
}

- (NSString *)type{
    return @"mem_monitor";
}

- (double)monitorInterval{
    double value = [TTMonitorConfiguration queryActionIntervalForKey:@"mem_monitor_interval"];
    if (value<=0) {
        value = 30;
    }
    return value;
}

- (BOOL)isEnabled{
#ifdef DEBUG
    return YES;
#endif
    return [TTMonitorConfiguration queryIfEnabledForKey:@"mem_monitor"];
}

- (void)recordIfNeeded:(BOOL)isTermite {
    if (![self isEnabled]) {
        return;
    }
    NSString * key = [TTBaseSystemMonitorRecorder latestActionKey:[self type]];
    NSTimeInterval latestActionTime = [[[NSUserDefaults standardUserDefaults] valueForKey:key] doubleValue];
    NSTimeInterval currentNow = [[NSDate date] timeIntervalSince1970];
    if (currentNow - latestActionTime < [self monitorInterval]) {
        return;
    }
    double currentMemory = [self memoryNow];
    double rate = currentMemory / [self totalMemory];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSLog(@"now-start=%f", now-_startTime);
    if (now - _startTime < 5 * 60) {
        [[TTMonitor shareManager] trackService:@"currentMemory" value:@{@"thirty":@(currentMemory),@"status":@(1)} extra:nil];
    }
    else if (now - _startTime <10*60) {
        [[TTMonitor shareManager] trackService:@"currentMemory" value:@{@"oneminute":@(currentMemory),@"status":@(2)} extra:nil];
    }
    else if (now - _startTime < 15*60) {
        [[TTMonitor shareManager] trackService:@"currentMemory" value:@{@"fiveminute":@(currentMemory),@"status":@(3)} extra:nil];
    }
    else if (now - _startTime < 20*60) {
        [[TTMonitor shareManager] trackService:@"currentMemory" value:@{@"tenminute":@(currentMemory),@"status":@(4)} extra:nil];
    }
    else if (now - _startTime < 30*60) {
        [[TTMonitor shareManager] trackService:@"currentMemory" value:@{@"halfhour":@(currentMemory),@"status":@(5)} extra:nil];
    }
    else if (now - _startTime <60*60) {
        [[TTMonitor shareManager] trackService:@"currentMemory" value:@{@"onehour":@(currentMemory),@"status":@(6)} extra:nil];
    }
    else{
        [[TTMonitor shareManager] trackService:@"currentMemory" value:@{@"halfday":@(currentMemory),@"status":@(7)} extra:nil];
    }
    [[TTMonitor shareManager] event:[self type] label:@"current_active_memory" duration:currentMemory needAggregate:NO];
    if (!isnan(rate)) {
     [[TTMonitor shareManager] event:[self type] label:@"current_active_memory_rate" duration:rate needAggregate:NO];
    }
}

-(double)memoryNow{
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

-(double)totalMemory{
    return _memoryTotalBytes/ (1024.0 * 1024.0);
}

- ( void )updateInfo
{
    @synchronized( self )
    {
        mach_port_t             hostPort;
        mach_msg_type_number_t  hostSize;
        vm_size_t               pageSize;
        vm_statistics_data_t    vmStat;
        
        hostPort = mach_host_self();
        hostSize = sizeof( vm_statistics_data_t ) / sizeof( integer_t );
        
        host_page_size( hostPort, &pageSize );
        
        if( host_statistics( hostPort, HOST_VM_INFO, ( host_info_t )&vmStat, &hostSize ) != KERN_SUCCESS )
        {
            return;
        }
        
        _memoryPageSize        = pageSize;
        _memoryActiveBytes     = vmStat.active_count   * _memoryPageSize;
        _memoryInactiveBytes   = vmStat.inactive_count * _memoryPageSize;
        _memoryWiredBytes      = vmStat.wire_count     * _memoryPageSize;
        _memoryFreeBytes       = vmStat.free_count     * _memoryPageSize;
        _memoryUsedBytes       = _memoryActiveBytes + _memoryInactiveBytes + _memoryWiredBytes;
        _memoryTotalBytes      = _memoryUsedBytes + _memoryFreeBytes;
    }
}
@end
