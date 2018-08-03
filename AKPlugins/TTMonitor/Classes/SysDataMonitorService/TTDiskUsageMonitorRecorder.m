//
//  TTDiskUsageMonitorRecorder.m
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import "TTDiskUsageMonitorRecorder.h"
#import "TTExtensions.h"
#import "TTMonitor.h"
#include <sys/stat.h>
#include <dirent.h>

#define kMaxFileNameLength 20
static NSMutableDictionary * directoryList;

@implementation TTDiskUsageMonitorRecorder

- (NSString *)type{
    return @"disk_monitor";
}

- (double)monitorInterval{
    double value = [TTMonitorConfiguration queryActionIntervalForKey:@"disk_monitor_interval"];
    if (value<=0) {
        value = 60*60;
    }
    return value;
}

- (BOOL)isEnabled{
#ifdef DEBUG
    return YES;
#endif
    return [TTMonitorConfiguration queryIfEnabledForKey:@"disk_monitor"];
}

- (void)recordIfNeeded:(BOOL)isTermite{
    if (!self.isEnabled) {
        return;
    }
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    NSString * key = [TTBaseSystemMonitorRecorder latestActionKey:[self type]];
    NSTimeInterval latestActionTime = [[[NSUserDefaults standardUserDefaults] valueForKey:key] doubleValue];
    NSTimeInterval currentNow = [[NSDate date] timeIntervalSince1970];
    if (currentNow - latestActionTime < [self monitorInterval]) {
        return;
    }
    double currentAppDiskCost = [self getThisAppSpace];
    if (currentAppDiskCost <= 1) {
        return;
    }
    if (key) {
     [[NSUserDefaults standardUserDefaults] setValue:@([[NSDate date] timeIntervalSince1970]) forKey:key];
    }
    double currentFreeDisk = [self getFreeDiskSpace];
    double totalDisk = [self getTotalDiskSpace];
    double currentAppDiskCostRate = currentAppDiskCost*1.0 / (currentFreeDisk+currentAppDiskCost)*1.0;
    
    [[TTMonitor shareManager] event:[self type] label:@"disk_usage" duration:currentAppDiskCost needAggregate:NO];
    [[TTMonitor shareManager] event:[self type] label:@"disk_total" duration:totalDisk needAggregate:NO];
    [[TTMonitor shareManager] event:[self type] label:@"disk_free" duration:currentFreeDisk needAggregate:NO];
    NSDictionary * storage = @{@"disk_usage":@(currentAppDiskCost),@"disk_total":@(totalDisk),@"disk_free":@(currentFreeDisk)};
    
    [[TTMonitor shareManager] trackService:@"disk_stroge_serice" attributes:storage];
    if (!isnan(currentAppDiskCostRate)) {
        [[TTMonitor shareManager] event:[self type] label:@"disk_usage_rate" duration:currentAppDiskCostRate needAggregate:NO];
    }
}

- (float)getTotalDiskSpace{
    float totalSpace;
    NSError * error;
    NSDictionary * infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error: &error];
    if (infoDic) {
        NSNumber * fileSystemSizeInBytes = [infoDic objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue]/1024.0f/1024.0f;
        return totalSpace;
    } else {
        return 0;
    } 
}

- (float)getFreeDiskSpace{
    float totalFreeSpace;
    NSError * error;
    NSDictionary * infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error: &error];
    if (infoDic) {
        NSNumber * fileSystemSizeInBytes = [infoDic objectForKey: NSFileSystemFreeSize];
        totalFreeSpace = ([fileSystemSizeInBytes unsignedLongLongValue]*1.0)/1024.0f/1024.0f;
        return totalFreeSpace;
    } else {
        return 0;
    }
}

- (void)getFolderDescriptionIfNeeded{
    BOOL query_desc_enabled = [TTMonitorConfiguration queryIfEnabledForKey:@"disk_description"];
    if (!query_desc_enabled) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, nil), ^{
        NSString * dirPath = NSHomeDirectory();
        NSTimeInterval lastSyncTime = [[NSUserDefaults standardUserDefaults] doubleForKey:@"lastSysTime"];
        if ([[NSDate date] timeIntervalSince1970] - lastSyncTime > 60*60*24*3) {
            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"lastSysTime"];
            NSDictionary * folderDescription = [TTDiskUsageMonitorRecorder _folderDescription:[dirPath UTF8String]];
            [[TTMonitor shareManager] trackService:@"exceed_disk_capacity" status:1 extra:folderDescription];
        }
    });
}

- (float)getThisAppSpace{
    double value = [[[NSUserDefaults standardUserDefaults] valueForKey:@"disk_monitor_value"] doubleValue];
    NSString * dirPath = NSHomeDirectory();
    dispatch_async(dispatch_get_global_queue(0, nil), ^{
        long long value = [TTDiskUsageMonitorRecorder folderSizeAtPath:dirPath];
        if (value>1024*1024*200) {//大于200MB
            [self getFolderDescriptionIfNeeded];
        }
        [[NSUserDefaults standardUserDefaults] setValue:@(value/(1000*1000)) forKey:@"disk_monitor_value"];
    });
    return value;
}

////////////////////获取文件大小
+(long long) folderSizeAtPath:(NSString*) folderPath{
    return [self _folderSizeAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}
+(long long) _folderSizeAtPath: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        NSInteger folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            
            //跳过Snapshots 该目录不算在cache大小里
            if (!strcasecmp(child->d_name, "Snapshots")) {
                continue;
            }
            folderSize += [self _folderSizeAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }
    }
    closedir(dir);
    return folderSize;
}


+(NSDictionary *) _folderDescription: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    NSMutableDictionary * fileList = [[NSMutableDictionary alloc] init];
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        NSInteger folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            
            //跳过Snapshots 该目录不算在cache大小里
            if (!strcasecmp(child->d_name, "Snapshots")) {
                continue;
            }
            NSDictionary * subFileList = [self _folderDescription:childPath]; // 递归调用子目录
            long long subFolderSize = 0;
            for(id obj in [subFileList allValues]){
                if ([obj isKindOfClass:[NSNumber class]]) {
                    subFolderSize += [obj longLongValue];
                }
                if ([obj isKindOfClass:[NSArray class]]) {
                    subFolderSize += [[obj firstObject] longLongValue];
                }
            }
            if (subFileList) {
                NSString * fileName = [NSString stringWithUTF8String:child->d_name];
                if (fileName) {
                    if (fileName.length>kMaxFileNameLength) {
                        fileName = [fileName substringToIndex:kMaxFileNameLength];
                    }
                    if (subFileList.count>1) {
                     [fileList setValue:@[@(subFolderSize), subFileList] forKey:fileName];
                    }else{
                     [fileList setValue:subFileList forKey:fileName];
                    }
                }
            }
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
            NSString * fileName = [NSString stringWithUTF8String:child->d_name];
           // NSDictionary * fileDict = @{@"name":fileName,@"size":@(st.st_size)};
            if (fileName) {
                if (fileName.length>kMaxFileNameLength) {
                 [fileList setValue:@(st.st_size) forKey:[fileName substringToIndex:kMaxFileNameLength]];
                }else{
                 [fileList setValue:@(st.st_size) forKey:fileName];
                }
            }
            
        }
    }
    closedir(dir);
    return [fileList copy];
}

@end
